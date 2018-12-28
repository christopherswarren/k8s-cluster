#!/bin/sh

# Run from VM host system

instance=$1
external_ip=$2
internal_ip=$3

cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Fort Worth",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Texas"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${external_ip},${internal_ip} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
