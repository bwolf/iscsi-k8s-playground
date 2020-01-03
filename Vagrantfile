# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "storage" do |storage|
    storage.vm.box = "generic/debian10"
    storage.vm.hostname = "storage"
    storage.vm.network :private_network, ip: "192.168.202.201"
    storage.vm.provider "virtualbox" do |vb|
      vb.name = "storage"
      vb.memory = "1024"

      # Get disk path
      line = `VBoxManage list systemproperties | grep "Default machine folder"`
      vb_machine_folder = line.split(':')[1].strip()
      second_disk = File.join(vb_machine_folder, vb.name, 'disk2.vdi')

      # Create and attach disk
      unless File.exist?(second_disk)
        vb.customize ['createhd', '--filename', second_disk, '--format', 'VDI', '--size', 10 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', second_disk]
    end
  end

  config.vm.define "kube" do |kube|
    kube.vm.box = "generic/debian10"
    kube.vm.hostname = "minikube"
    kube.vm.network :private_network, ip: "192.168.202.202"
    kube.vm.provision "shell", path: "kube-provision.sh"
  end
end
