#!/bin/sh

# Can be run from anywhere.

{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "26280h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "26280h"
      },
      "client": {
          "expiry": "1000000h",
          "usages": [
              "signing",
              "key encipherment",
              "client auth"
          ]
      },
      "peer": {
          "expiry": "43800h",
          "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
          ]
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Fort Worth",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Texas"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}