class role::kube_workstation(
  String $sshkey,# add your local path to your ssh key like this... = '/mnt/secure/keys/chris.key',
  String $repourl = 'https://github.com/CultClassik/k8s-cluster.git',
){
  require docker # I do a custom docker install via another profile but this should work
  require profile::kube_hosts
  include profile::linux::users::myuser # this one creates my user account and distrobutes my ssh key
  include profile::kube_tools

  # deploy the PRIVATE ssh key here that will be used to connect to the controllers and nodes
  #file { $sskey:
  #  ensure => file,
  #}
  vcsrepo { '/k8s':
    ensure   => present,
    provider => git,
    source   => $repourl,
  }

}
