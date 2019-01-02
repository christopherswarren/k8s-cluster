#!/bin/sh

SSHUSR="chris"
SSHKEY="/mnt/secure/keys/chris.key"

chmod -R +x ./*.sh

./04_ssl/04_gencerts.sh
./04_ssl/04.99_dist-keys.sh ${SSHUSR} ${SSHKEY}

THIS_BOX=`vboxmanage list vms | grep kws | awk '{ gsub("\"", ""); print $1 }'`
KUBERNETES_PUBLIC_ADDRESS=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
./05_kubeconfig.sh ${SSHUSR} ${SSHKEY} ${KUBERNETES_PUBLIC_ADDRESS}
./06_data-encryption-conf-key.sh ${SSHUSR} ${SSHKEY}

########################################
# install etcd on controllers
########################################
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

  scp -i $SSHKEY ./07_etcd.sh ${SSHUSR}@${EXTERNAL_IP}:/tmp
  ssh -t -i $SSHKEY ${SSHUSR}@${EXTERNAL_IP} /tmp/07_etcd.sh $INTERNAL_IP $INITIAL_CLUSTER
done

########################################
# bootstrap control plane
########################################
ETCD_SERVERS=`echo ${INITIAL_CLUSTER} | awk '{ gsub(/kc[0-9]=/, ""); gsub("2380", "2379"); print $1 }'`
for instance in kc1 kc2 kc3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  EXTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  INTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`

  scp -i $SSHKEY ./08_controlplane.sh ${SSHUSR}@${EXTERNAL_IP}:/tmp
  ssh -t -i $SSHKEY ${SSHUSR}@${EXTERNAL_IP} /tmp/08_controlplane.sh $INTERNAL_IP $ETCD_SERVERS
done

# RBAC
THIS_BOX=`vboxmanage list vms | grep kc1 | awk '{ gsub("\"", ""); print $1 }'`
EXTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
scp -i $SSHKEY ./08.01_rbac.sh ${SSHUSR}@${EXTERNAL_IP}:/tmp
ssh -t -i $SSHKEY ${SSHUSR}@${EXTERNAL_IP} /tmp/08.01_rbac.sh
