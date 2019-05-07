NETIFACE = "enp2s0"
PUPPET_ENV = "cultclassik_prod"
#IP_NET = "192.168.1."
#$ip_start = 100

MYBOX = "ubuntu/bionic64"

servers=[
  {
    :hostname => "kc1",
    :ip => "192.168.1.101",
    :ip_pri => "172.16.0.101",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kc2",
    :ip => "192.168.1.102",
    :ip_pri => "172.16.0.102",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kc3",
    :ip => "192.168.1.103",
    :ip_pri => "172.16.0.103",
    :ram => 2048,
    :cpu => 1
  },
  {
    :hostname => "kn1",
    :ip => "192.168.1.104",
    :ip_pri => "172.16.0.104",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kn2",
    :ip => "192.168.1.105",
    :ip_pri => "172.16.0.105",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kn3",
    :ip => "192.168.1.106",
    :ip_pri => "172.16.0.106",
    :ram => 4096,
    :cpu => 2
  },
  {
    :hostname => "kws",
    :ip => "192.168.1.107",
    :ip_pri => "172.16.0.107",
    :ram => 1024,
    :cpu => 1 
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    #@IP_ADDRESS=IP_NET+$ip_start.to_s
    #puts("Provisioning box:", machine[:hostname], "with IP address:", @IP_ADDRESS)
    config.vm.define machine[:hostname] do |node|
      node.vm.box = MYBOX #machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network", ip: machine[:ip], bridge: NETIFACE
      node.vm.network "private_network", ip: machine[:ip_pri]
      #node.vm.network "public_network", ip: @IP_ADDRESS, bridge: NETIFACE
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]
      end
      node.vm.provision "shell", env: {"PUPPET_ENV" => PUPPET_ENV}, inline: <<-SHELL
	      sudo wget https://apt.puppetlabs.com/puppet6-release-bionic.deb -O /tmp/puppet.deb
      	sudo dpkg -i /tmp/puppet.deb
	      sudo rm /tmp/puppet.deb
	      sudo apt-get update
	      sudo apt-get install puppet-agent -y
	      sudo mkdir -p /etc/puppetlabs/code/environments/${PUPPET_ENV}
	      sudo echo "[main]\nenvironment=${PUPPET_ENV}" > /etc/puppetlabs/puppet/puppet.conf
	      sudo systemctl restart puppet
        SHELL
      end
	  #$ip_start += 1
  end
end
