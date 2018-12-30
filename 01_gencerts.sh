#!/bin/sh

# Run from VBox host
#KUBERNETES_PUBLIC_ADDRESS=$(hostname -I | awk '{print  $2}')
SSHUSR="chris"
SSHKEY="/mnt/secure/keys/chris.key"

chmod -R +x ./shell/*
mkdir ./ssl && cd ./ssl

../shell/01_ssl/04_ca.sh
../shell/01_ssl/04.01_admin.sh

for instance in kn1 kn2 kn3; do
  echo "Instance: ${instance}"
  this_box=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  external_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  internal_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
  ../shell/01_ssl/04.02_kubelet-client.sh ${instance} ${external_ip} ${internal_ip}
done

../shell/01_ssl/04.03_controller-manager.sh
../shell/01_ssl/04.04_kube-proxy.sh
../shell/01_ssl/04.05_scheduler-client.sh

lb_address=""
for instance in kc1 kc2 kc3 kws; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  EXTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  INTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
  lb_address="${lb_address},${EXTERNAL_IP},${INTERNAL_IP}"
done
lb_address=`echo ${lb_address} | cut -c 1-`

../shell/01_ssl/04.06_api-server.sh ${lb_address}
../shell/01_ssl/04.07_svcacct-keypair.sh
../shell/01_ssl/04.99_dist-keys.sh ${SSHUSR} ${SSHKEY}

THIS_BOX=`vboxmanage list vms | grep kws | awk '{ gsub("\"", ""); print $1 }'`
KUBERNETES_PUBLIC_ADDRESS=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
../shell/05_kubeconfig.sh ${SSHUSR} ${SSHKEY} ${KUBERNETES_PUBLIC_ADDRESS}
../shell/06_data-encryption-conf-key.sh ${SSHUSR} ${SSHKEY}

# install etcd on controllers
CLUSTER_BOX1=`vboxmanage list vms | grep kc1 | awk '{ gsub("\"", ""); print $1 }'`
CLUSTER_NODE1=`vboxmanage guestproperty get ${CLUSTER_BOX1} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
CLUSTER_BOX2=`vboxmanage list vms | grep kc2 | awk '{ gsub("\"", ""); print $1 }'`
CLUSTER_NODE2=`vboxmanage guestproperty get ${CLUSTER_BOX2} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
CLUSTER_BOX3=`vboxmanage list vms | grep kc3 | awk '{ gsub("\"", ""); print $1 }'`
CLUSTER_NODE3=`vboxmanage guestproperty get ${CLUSTER_BOX3} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
INITIAL_CLUSTER="kc1=https://${CLUSTER_NODE1}:2380,kc2=https://${CLUSTER_NODE2}:2380,kc3=https://${CLUSTER_NODE3}:2380"

for instance in kc1 kc2 kc3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  EXTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  INTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`

  scp -i $SSHKEY ./shell/07_etcd.sh ${SSHUSR}@${EXTERNAL_IP}:/tmp
  ssh -t -i $SSHKEY ${SSHUSR}@${EXTERNAL_IP} /tmp/07_etcd.sh $INTERNAL_IP $INITIAL_CLUSTER
done