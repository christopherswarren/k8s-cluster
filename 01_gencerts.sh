#!/bin/sh

# Run from VBox host
#KUBERNETES_PUBLIC_ADDRESS=$(hostname -I | awk '{print  $2}')
SSHUSR="chris"
SSHKEY="/mnt/secure/keys/chris.key"

this_box=`vboxmanage list vms | grep kws | awk '{ gsub("\"", ""); print $1 }'`
KUBERNETES_PUBLIC_ADDRESS=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`

chmod -R +x ./shell/*

./shell/01_ssl/04_ca.sh
./shell/01_ssl/04.01_admin.sh
./shell/01_ssl/04.02_kubelet-client.sh
./shell/01_ssl/04.03_controller-manager.sh
./shell/01_ssl/04.04_kube-proxy.sh
./shell/01_ssl/04.05_scheduler_client.sh
./shell/01_ssl/04.06_api-server.sh ${KUBERNETES_PUBLIC_ADDRESS}
./shell/01_ssl/04.07_svcacct-keypair.sh
./shell/01_ssl/04.99_dist-keys.sh ${SSHUSR} ${SSHKEY}

./shell/05_kubeconfig.sh ${SSHUSR} ${SSHKEY} ${KUBERNETES_PUBLIC_ADDRESS}