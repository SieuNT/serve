# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
  
  config.vm.network "private_network", ip: "192.168.99.9"
  config.vm.synced_folder "./html", "/var/www/html", type: "nfs"
  
  config.vm.provision "setup", type: "shell", path: "./setup.sh"
end
