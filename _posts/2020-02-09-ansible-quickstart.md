---
layout: post
categories: jekyll update
title: Ansible QuickStart
---

# Finding Inspiration

For almost a month I looked for something to write about, and sometimes it was the most obvious things.

Last Saturday, I gave some overview of Ansible to students with great potentials, some are new and some already has good grasp in Linux thus teaching was easy.

Then I promised them to for me to send notes about our discussion and here it is..

## What is Ansible?

So Ansible is an Automation tool that is Highly accepted in the industry today, It is bought and maintained now by Red Hat with a big community.

Ansible has different parts on how it works:

- Ansible Engine - It is basically the ansible command that you are using in the terminal it is the interpreter that makes your playbook or modules to life.

- Ansible Module - It is the command of Ansible to make things happen to your target machine.

- Ansible Playbook - It is the script that creates the workflow of multiple modules.

- Inventory File - It is the collection of multiple targets that will be automated.

## What can Ansible Automate ?

Ansible can automate Linux-Based or Windows Server, Network devices like Cisco, Dell, Juniper etc., Storage devices like EMC, HPe3par, IBM, Netapp etc., Cloud Infras, like OpenStack, AWS, Azure, VMWAre etc., basically everything.

You can check out in the [Module Index](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html) on what more ansible does.

## How to install Ansible?

It is straightforward installing a package in Linux, and Ansible documentation did a great job on how to install, You check it [HERE](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installation-guide).

## How to use it?

First you need to have a target machine, for beginers I suggest to use a Linux VM for you to start as a target.

For this example I used Centos 8 as my target and control machine.

Then create a directory where we will try Ansible.
```
[root@localhost]# mkdir trial && cd trial
```

After that copy the Ansible configuration for your ansible to have unique configuration per workspace.
```
[root@localhost trial]# cp /etc/ansible/ansible.cfg .
```

now we edit it basically without all the comment this is how it looks like
```
[root@localhost trial]# cat ansible.cfg | grep -vE "#|^$"
[defaults]
[inventory]
[privilege_escalation]
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
[root@localhost trial]#
```

Now edit under defaults the line that says `inventory` and change its value to `./inventory`, After editing the looks like this.
```
[root@localhost trial]# cat ansible.cfg | grep -vE "#|^$"
[defaults]
inventory = ./inventory
[inventory]
[privilege_escalation]
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
[root@localhost trial]#
```
This states that our Inventory File would be in the same working directory and it will be named `inventory`.

Then we will create the Inventory File named `inventory` and this is how it looks if I add one VM.
```
[root@localhost trial]# cat inventory | grep -vE "#|^$"
[vm1]
192.168.1.10	ansible_user=user1 ansible_port=22
[root@localhost trial]#
```
In this file we said that the VM that has an IP of `192.168.1.10` is with the `vm1` group and it will be connected using the user named `user1` with a port of `22`.

To add more VM there are 2 ways one add them in the same group or create a new group for them example.
```
Same Group
[root@localhost trial]# cat inventory | grep -vE "#|^$"
[vm1]
192.168.1.10	ansible_user=user1 ansible_port=22
192.168.1.11	ansible_user=user1 ansible_port=22
[root@localhost trial]#

New Group
[root@localhost trial]# cat inventory | grep -vE "#|^$"
[vm1]
192.168.1.10	ansible_user=user1 ansible_port=22

[vm2]
192.168.1.11	ansible_user=user1 ansible_port=22
[root@localhost trial]#
```
Both are effective depends on the use case.

Now we are all set up we can try a basic ping pong.
```
[root@localhost trial]# ansible all -m ping 
192.168.1.10 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
[root@localhost trial]# 
```
This is called an Adhoc command. using the `ping` module, It is an effective way to determine if you can connect to the machine via SSH.

One of the most basic modules is `shell` it will use any command that you do to get the grasp of it, i will use `id` command in the remote machine.
```
[root@localhost trial]# ansible all -m shell -a 'id'
192.168.1.10 | CHANGED | rc=0 >>
uid=1000(user1) gid=1000(user1) groups=1000(user1),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

[root@localhost trial]#
```
As you can see we are using the remote user `user1` how about if I try to be root in executing modules to do that we need to edit the `[privilege_escalation]` in the Ansible Configuration file if edited it lookes like this.
```
[root@localhost trial]# cat ansible.cfg | grep -Ev "#|^$"
[defaults]
inventory      = ./inventory
[inventory]
[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=True
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
[root@localhost trial]#
```
The configuration states that I will escalate using `sudo` and my become or admin user is named `root`, And it will ask a password since my user `user1` uses a password to execute in `sudo`.

Now let's try the same command earlier.
```
[root@localhost trial]# ansible all -m shell -a 'id'
BECOME password: 
192.168.1.10 | CHANGED | rc=0 >>
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

[root@localhost trial]#
```
Now I'm a root user. while executing commands.

## Build your playbook

Now lets try to manage it with a Ansible Playbook, to convert the 2 things we did earlier in Adhoc this is how our playbook look like, created a file named `playbook.yaml` and edited it via `vim`.
```
[root@localhost trial]# cat playbook.yaml 
---
- hosts: vm1
  
  tasks:
  - name: ping pong vm1
    ping:

  - name: use shell and query id
    shell: "id"
[root@localhost trial]#
```

To run this playbook and its outputs.
```
[root@localhost trial]# ansible-playbook playbook.yaml 
BECOME password: 

PLAY [vm1] ******************************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [192.168.1.10]

TASK [ping pong vm1] ********************************************************************************
ok: [192.168.1.10]

TASK [use shell and query id] ***********************************************************************
changed: [192.168.1.10]

PLAY RECAP ******************************************************************************************
192.168.1.10              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
[root@localhost trial]#
```

Everytime we edit a playbook best practice to check always the syntax of the playbook to do that:
```
[root@localhost trial]# ansible-playbook --syntax-check playbook.yaml 

playbook: playbook.yaml
[root@localhost trial]#
```
without a problem it will not say any syntax error.

To check any module that you want to use you can use `ansible-doc` command for that it has also examples on how to use it in a playbook.

Example if I want to check the `yum` module of Ansible and how it is used.
```
[root@localhost trial]# ansible-doc yum
```
It is like a man page for Ansible Modules.

So to create a simple workflow using Ansible, I will install the latest httpd, start it and allow it in the firewall using Ansible.
```
[root@localhost trial]# cat playbook.yaml 
---
- hosts: vm1
  
  tasks:
  - name: ping pong vm1
    ping:

  - name: use shell and query id
    shell: "id"

  - name: install httpd
    yum:
      name: httpd
      state: latest

  - name: start and enable service
    service:
      name: httpd
      state: started
      enabled: yes

  - name: firewalld let httpd get through
    firewalld:
      port: 80/tcp
      permanent: yes
      immediate: yes
      state: enabled
[root@localhost trial]#
```
I added the `yum` module to install the latest httpd in my Centos target, also started it using the `service` module and enabled it in case of reboot, then I added port 80 in the firewall using `firewalld` module.

If I run this first time it lookes like this.
```
[root@localhost trial]# ansible-playbook playbook.yaml 
BECOME password: 

PLAY [vm1] ******************************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [192.168.0.169]

TASK [ping pong vm1] ********************************************************************************
ok: [192.168.0.169]

TASK [use shell and query id] ***********************************************************************
changed: [192.168.0.169]

TASK [install httpd] ********************************************************************************
changed: [192.168.0.169]

TASK [start and enable service] *********************************************************************
changed: [192.168.0.169]

TASK [firewalld let httpd get through] **************************************************************
changed: [192.168.0.169]

PLAY RECAP ******************************************************************************************
192.168.0.169              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[root@localhost trial]#
```
In my newly added tasks it says `changed` meaning it was succesfully executed.

but if I try to run it again.
```
[root@localhost trial]# ansible-playbook playbook.yaml 
BECOME password: 

PLAY [vm1] ******************************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [192.168.0.169]

TASK [ping pong vm1] ********************************************************************************
ok: [192.168.0.169]

TASK [use shell and query id] ***********************************************************************
changed: [192.168.0.169]

TASK [install httpd] ********************************************************************************
ok: [192.168.0.169]

TASK [start and enable service] *********************************************************************
ok: [192.168.0.169]

TASK [firewalld let httpd get through] **************************************************************
ok: [192.168.0.169]

PLAY RECAP ******************************************************************************************
192.168.0.169              : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[root@localhost trial]#
```
Only the `shell` module was tagged as `changed` since Ansible can't monitor what is done in the `shell` module if it is already done, thus the only output is `changed` or `failed`, however since we have succesfully installed, started and allowed httpd earlier the status is `ok`.

## Tips and tricks

- Since I used vim as my editor for playbooks I suggest to add this to your `~/.vimrc` to make it easier.
```
[root@localhost trial]# cat .vimrc 
autocmd FileType yaml setlocal ai ts=2 sw=2 et
[root@localhost trial]#
```
This will ease up your work to align everything using tabs.

- Practice to be familiar on other modules.

## End of QuickStart

That's it, hope you like my article about Ansible there are ton to discuss for a deepdive in Ansible like

1. Ansible Facts
1. Ansible Handlers
1. Ansible Roles (This is powerful)
1. Ansible Galaxy
1. Ansible Vault
1. Dynamic Inventory V.S. Static Inventory
1. Advance Ansible Playbook:
- Conditionals
- Variables
- Templates

