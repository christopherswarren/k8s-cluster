#!/bin/sh

# Run from VM host system

for instance in kn1 kn2 kn3; do
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

echo "Instance: ${instance}"

this_box=`vboxmanage list vms | grep ${instance} | awk '{ gsub("\"", ""); print $1 }'`
external_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{ print $2}'`
internal_ip=`vboxmanage guestproperty get ${this_box} "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2}'`

echo "Box name: ${this_box}"
echo "Ext IP: ${external_ip}"
echo "Int IP: ${internal_ip}"

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${external_ip},${internal_ip} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done