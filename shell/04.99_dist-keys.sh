#!/bin/bash

SSHUSR="chris"
SSHKEY="/home/chris/chris.key"

for instance in kn1 kn2 kn3; do
  scp -i ${SSHKEY} \
    ca.pem ${instance}-key.pem ${instance}.pem ${SSHUSR}@${instance}:~/
done

for instance in kc1 kc2 kc3; do
  scp -i ${SSHKEY} \
    ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${SSHUSR}@${instance}:~/
done