class profile::linux::kube_lb (
  String $conf_dir = '/confdata/haproxy/conf',
  String $conf_file = 'haproxy.cfg',
  String $container_name = 'haproxy-klb',
  String $container_image = 'haproxy:1.7',
  String $port = '6443',
  Hash $nodes = {
    'kc1' => '192.168.1.101',
    'kc2' => '192.168.1.102',
    'kc3' => '192.168.1.103',
  }
){
  require docker

  file { $conf_dir:
    ensure => directory,
  }

  file { "${conf_dir}/haproxy":
    ensure => directory,
    require => File[$conf_dir],
  }

  file { "${conf_dir}/haproxy/run":
    ensure => directory,
    require => File["${conf_dir}/haproxy"],
  }

  # deploy the ha proxy config file
  file { "${conf_dir}/${conf_file}":
    ensure  => file,
    content => epp(
      'profile/docker/kube_lb.epp',
      {
        'backend_nodes' => $nodes,
        'port' => $port,
        'lb_ip' => '192.168.1.107',
      }
    ),
    require => File["${conf_dir}/haproxy"],
  }

  # create ha proxy container using config file
  docker::run { $container_name:
    image   => $container_image,
    volumes => [ 
      "${conf_dir}:/usr/local/etc/haproxy ",
      "/confdir/haproxy/run:/var/run/haproxy",
      ],
    ports   => [ '80:80/tcp', '443:443/tcp', '6443:6443/tcp' ],
    extra_parameters => [ 
      '--restart=always',
      ],
    health_check_cmd => 'ls -l',
    restart_on_unhealthy => false,
    health_check_interval => 10000,
    require => File["${conf_dir}/${conf_file}"],
  }

}