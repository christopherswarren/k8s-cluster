class profile::linux::kube_hosts(
  Hash $hosts = {
    'kc1' => '192.168.1.100',
    'kc2' => '192.168.1.101',
    'kc3' => '192.168.1.102',
    'kn1' => '192.168.1.103',
    'kn2' => '192.168.1.104',
    'kn3' => '192.168.1.105',
    'kws klb' => '192.168.1.110',
  }
) {

  $hosts.each | String $name, String $ip | {
    file_line { "Entry for ${name}":
      ensure => present,
      path   => '/etc/hosts',
      line   => "${ip} ${name}",
    }
  }

}