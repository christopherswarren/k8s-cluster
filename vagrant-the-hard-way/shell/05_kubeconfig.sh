#!/bin/sh

# This script will generate and distribute kube configs
SSHUSR=$1
SSHKEY=$2
#this var should be for an external load balancer typically, in this case run the script on kc1 and use the public ip of that node
KUBERNETES_PUBLIC_ADDRESS=$3 # $(hostname -I | awk '{print  $2}')

# The kubelet Kubernetes Configuration File
for instance in kn1 kn2 kn3; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

# The kube-proxy Kubernetes Configuration File
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

# The kube-controller-manager Kubernetes Configuration File
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

# The kube-scheduler Kubernetes Configuration File
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}

# The admin Kubernetes Configuration File
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

# Distribute the Kubernetes Configuration Files
for instance in kn1 kn2 kn3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  MY_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`

  scp -i $SSHKEY \
    ${instance}.kubeconfig kube-proxy.kubeconfig ${SSHUSR}@${MY_IP}:~/
done

#Copy the appropriate kube-controller-manager and kube-scheduler kubeconfig files to each controller instance:
for instance in kc1 kc2 kc3; do
  THIS_BOX=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
  MY_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`

  scp -i $SSHKEY \
    admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${SSHUSR}@${MY_IP}:~/
done

# Also copy kubeconfig to the lb/workstation
THIS_BOX=`vboxmanage list vms | grep kws | awk '{ gsub("\"", ""); print $1 }'`
MY_IP=`vboxmanage guestproperty get ${THIS_BOX} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`

scp -i $SSHKEY admin.kubeconfig ${SSHUSR}@${MY_IP}:~/