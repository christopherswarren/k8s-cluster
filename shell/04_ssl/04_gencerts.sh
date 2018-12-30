#!/bin/sh

# Run from VBox host
#KUBERNETES_PUBLIC_ADDRESS=$(hostname -I | awk '{print  $2}')

./04_ca.sh
./04.01_admin.sh

for instance in kn1 kn2 kn3; do
  echo "Instance: ${instance}"
  this_box=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  external_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  internal_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
  ./04.02_kubelet-client.sh ${instance} ${external_ip} ${internal_ip}
done

./04.03_controller-manager.sh
./04.04_kube-proxy.sh
./04.05_scheduler-client.sh

# build string to pass along to api server cert gen script
lb_address=""
for instance in kc1 kc2 kc3 kws; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  EXTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  INTERNAL_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/2/V4/IP" | awk '{ print $2}'`
  lb_address="${lb_address},${EXTERNAL_IP},${INTERNAL_IP}"
done
lb_address=`echo ${lb_address} | cut -c 1-`

./04.06_api-server.sh ${lb_address}
./04.07_svcacct-keypair.sh
