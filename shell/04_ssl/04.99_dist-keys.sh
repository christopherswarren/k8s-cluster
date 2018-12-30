#!/bin/sh

# Run from whereever you ran the cert generation scripts.

SSHUSR=$1
SSHKEY=$2

for instance in kn1 kn2 kn3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  MY_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  scp -i ${SSHKEY} \
    ca.pem \
    ${instance}-key.pem
    ${instance}.pem \
    ${SSHUSR}@${MY_IP}:~/
done

for instance in kc1 kc2 kc3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  MY_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
  scp -i ${SSHKEY} \
    ca.pem \
    ca-key.pem \
    kubernetes-key.pem \
    kubernetes.pem \
    service-account-key.pem \
    service-account.pem \
    ${SSHUSR}@${MY_IP}:~/
done