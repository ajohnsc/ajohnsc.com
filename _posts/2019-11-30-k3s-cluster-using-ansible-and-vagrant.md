---
layout: post
categories: jekyll update
title: K3s Cluster using Ansible and Vagrant
---
# Rest time

From a long work week finally got rest since I don't have any classes this saturday that gave me a lot of time to rest.

While i'm at it, stumbled upon a cool project called K3s it is a lightweight kubernetes project by Rancher so while resting I will try to install it with Vagrant VMs and Ansible

### Vagrant for ease

Vagrant is a tool made by Hashicorp to provision VMs in any provider, in my case I will use VirtualBox.

Created my vagrant file first.
```
# vagrant init
```

It will initialize a file named Vagrantfile in my directory then I will edit it for my requirement
```
# vim Vagrantfile
Vagrant.configure("2") do |config|

	(1..3).each do |i|
		config.vm.define "worker#{i}" do |worker|
			worker.vm.box = "ubuntu/xenial64"
			worker.vm.network "private_network", ip: "192.168.0.11#{i}", virtualbox__intnet: true
			worker.vm.provider "virtualbox" do |workervm|
				workervm.memory = 4096
				workervm.cpus = 2
			end
			worker.vm.provision "shell", path: "worker.sh"
			worker.vm.hostname = "worker#{i}.ajohnsc.io"
		end
	end

	config.vm.define "master" do |master|
		master.vm.box = "ubuntu/xenial64"
		master.vm.network "private_network", ip: "192.168.0.110", virtualbox__intnet: true
		master.vm.provider "virtualbox" do |mastervm|
			mastervm.memory = 4096
			mastervm.cpus = 2
		end
		master.vm.provision "shell", path: "master.sh"
		master.vm.hostname = "master.ajohnsc.io"
	end

end
```

So this is my final Vagrant file, it will provision 1 master and 3 worker nodes with all internal IPs and hostnames, it uses a "provisioning" concept that I can pass scripts to my nodes via `shell` or `ansible`. however the default boxes of Vagrant doesn't come with ansible thus I created specific scripts for workers and master nodes.


### Back to shell scripting

I wanted to install the K3s cluster using Ansible however Vagrant won't allow me thus I can pass the Ansible playbooks inside the scripts.

For my worker scripts all I want to have a user named `kubecfg` with the default keys that I created, with passwordless sudo:
```
#/bin/bash

# create kubecfg user
sudo useradd -m kubecfg

# create ssh directory
sudo mkdir -p /home/kubecfg/.ssh

# copy keys to .ssh directory
sudo cp /vagrant/keys/* /home/kubecfg/.ssh/

# make kubecfg authorized by the same key
sudo cp /home/kubecfg/.ssh/id_rsa.pub /home/kubecfg/.ssh/authorized_keys

# Change ownership
sudo chown -R kubecfg. /home/kubecfg/.ssh/

# Change permissions
sudo chmod 700 /home/kubecfg/.ssh/
sudo chmod 600 /home/kubecfg/.ssh/id_rsa
sudo chmod 644 /home/kubecfg/.ssh/id_rsa.pub
sudo chmod 700 /home/kubecfg/.ssh/authorized_keys

# Make kubecfg sudoer
echo "kubecfg ALL=(ALL)	NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/kubecfg
```

For my master script same as  the worker but I want it to install ansible to the master node and install K3s using my playbook that I created.
```
#/bin/bash

# create kubecfg user
sudo useradd -m kubecfg

# create ssh directory
sudo mkdir -p /home/kubecfg/.ssh

# copy keys to .ssh directory
sudo cp /vagrant/keys/* /home/kubecfg/.ssh/

# make kubecfg authorized by the same key
sudo cp /home/kubecfg/.ssh/id_rsa.pub /home/kubecfg/.ssh/authorized_keys

# Change ownership
sudo chown -R kubecfg. /home/kubecfg/.ssh/

# Change permissions
sudo chmod 700 /home/kubecfg/.ssh/
sudo chmod 600 /home/kubecfg/.ssh/id_rsa
sudo chmod 644 /home/kubecfg/.ssh/id_rsa.pub
sudo chmod 700 /home/kubecfg/.ssh/authorized_keys

# Make kubecfg sudoer
echo "kubecfg ALL=(ALL)	NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/kubecfg

# install ansible
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible -y

# run ansible playbook as kubecfg user
sudo su - kubecfg -c "cd /vagrant/k3sdeploy;ansible-playbook main.yaml"
```

### Ansible is the way

Since everything is ready I can now create my Ansible playbook to install the K3s cluster

First I need the configuration file for ansible
```
# cat ansible.cfg
[defaults]

inventory      = ./inventory
remote_user = kubecfg
host_key_checking = false

[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False
```
I want my ansible playbook to get my inventory from my local inventory file and won't do host checking since all users are newly created via vagrant, also I want to use `kubecfg` user for remote user with privilege escalations.

This is my inventory file:
```
# cat inventory
[master]
192.168.0.110

[worker]
192.168.0.111
192.168.0.112
192.168.0.113
```
Since my IP is defined using Vagrant my inventory was easier to create

Then this is my playbook to install K3s
```
# cat main.yaml
---
- name: Deploy K3s Master
  hosts: master

  tasks:
  - name: install k3s using k3s script
    shell: >
      curl -sfL https://get.k3s.io | sh -s - server --bind-address 192.168.0.110 --advertise-address 192.168.0.110

  - name: get node token
    slurp:
      src: /var/lib/rancher/k3s/server/node-token
    register: token

  - name: add token holder
    add_host:
      name: "K3S_TOKEN_HOLDER"
      token: "{{ token.content | b64decode }}"

- name: Deploy k3s workers
  hosts: worker

  tasks:
  
  - name: install k3s using k3s script
    shell: >
      curl -sfL https://get.k3s.io | K3S_URL='https://192.168.0.110:6443' K3S_TOKEN="{{ hostvars['K3S_TOKEN_HOLDER']['token'] }}" sh -
```

I used the installation script of K3s in my ansible playbook for easier installation then get the token from the master node to install the agents in the worker nodes.

### Make it simple

Since I want to make it simple you can simply get all of these in my repository:
```
# git clone git clone https://github.com/ajohnsc/K3sVagrant.git
# cd K3sVagrant
# vagrant up
```

Then you will have your own K3s cluster using vagrant and Ansible.
