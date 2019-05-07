#!/bin/sh

# The DNS Cluster Add-on
# Deploy the coredns cluster add-on:
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

# List the pods created by the kube-dns deployment:
kubectl get pods -l k8s-app=kube-dns -n kube-system

# full verification steps;:
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/12-dns-addon.md#verification