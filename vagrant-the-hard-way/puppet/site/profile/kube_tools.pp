class profile::linux::kube_tools(
  Hash $kubectl = {
    'url' => 'https://dl.k8s.io/v1.13.0/kubernetes-client-linux-amd64.tar.gz',
    'hash' => '61a6cd3b1fb34507e0b762a45da09d88e34921985970a2ba594e0e5af737d94c966434b4e9f8e84fb73a0aeb5fa3e557344cd2eb902bf73c67d4b4bff33c6831',
  },

) {
  wget::fetch{ 'get cfssl':
    source      => 'https://pkg.cfssl.org/R1.2/cfssl_linux-amd64',
    destination => '/usr/local/bin/cfssl',
   }
   -> file{ '/usr/local/bin/cfssl':
     ensure => file,
     mode => '0775',
    }

  wget::fetch{ 'get cfssl json':
    source      => 'https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64',
    destination => '/usr/local/bin/cfssljson',
  }
  -> file{ '/usr/local/bin/cfssljson':
     ensure => file,
     mode => '0775',
  }

  wget::fetch{ 'kubectl binary' :
    source      => 'https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl',
    destination => '/usr/local/bin/',
  } 
  -> file{ '/usr/local/bin/kubectl':
     ensure => file,
     mode => '0775',
  }

}