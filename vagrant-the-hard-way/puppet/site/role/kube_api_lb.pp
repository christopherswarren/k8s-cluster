class role::kube_api_lb{
  require role::kube_workstation
  include profile::kube_lb
}
