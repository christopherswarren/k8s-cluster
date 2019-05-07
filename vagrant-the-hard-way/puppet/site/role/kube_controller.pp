class role::kube_controller{
  require profile::kube_hosts
  include profile::linux::users::myuser # this one creates my user account and distrobutes my ssh key
  include profile::linux::kube_tools
}
