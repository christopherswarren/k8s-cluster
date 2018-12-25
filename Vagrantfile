NETIFACE = "enp2s0"
PUPPET_ENV = "cultclassik_prod"
IP_NET = "192.168.1."
$ip_start = 100

MYBOX = "ubuntu/xenial64"

servers=[
  {
    :hostname => "kc1",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kc2",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kc3",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kn1",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kn2",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kn3",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kws",
    :ram => 1024,
    :cpu => 1 
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = MYBOX #machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network", ip: IP_NET+$ip_start.to_s, bridge: NETIFACE
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]
      end
      node.vm.provision "shell", env: {"PUPPET_ENV" => PUPPET_ENV}, inline: <<-SHELL
	    sudo wget https://apt.puppetlabs.com/puppet6-release-xenial.deb -O /tmp/puppet.deb 
      	sudo dpkg -i /tmp/puppet.deb
	    sudo rm /tmp/puppet.deb
	    sudo apt-get update
	    sudo apt-get install puppet-agent -y
	    sudo mkdir -p /etc/puppetlabs/code/environments/${PUPPET_ENV}
	    sudo echo "[main]\nenvironment=${PUPPET_ENV}" > /etc/puppetlabs/puppet/puppet.conf
	    sudo systemctl restart puppet
      SHELL
    end
	$ip_start += 1
  end
end
