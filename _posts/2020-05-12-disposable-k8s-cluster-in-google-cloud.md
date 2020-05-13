---
layout: post
title: Disposable K8s cluster in Google Cloud
categories: jekyll update
---

# Hello world again !

It's been more than a month, I had a struggle in using my previous theme, It begins to be buggy if you have more than 5 posts, thus I had to migrate my contents in a new theme and nothing beats simple.

I've been playing with kubernetes latley and it's a fun experience, however creating an environment for me to play and destroy it afterwards like a disposable cluster.

Thus I decided to create an Ansible playbook to run it when it is time to learn something new and destroy after I use it.

In this blog I will walkthrough the steps on creating, I will use Google Cloud since they give 300$ credits for a year in new accounts.

### Setup Google Cloud first

As you login in Google cloud, you need to create a project top left beside the Google cloud platform logo, click on "Select a project".

![disposable-k8s-cluster-in-google-cloud-blog1](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog1.png)

A dialog box will pop out, like this

![disposable-k8s-cluster-in-google-cloud-blog2](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog2.png)

And click "NEW PROJECT" on the top right of the dialog box,

In the new window fill up the "Project Name", click "CREATE"

![disposable-k8s-cluster-in-google-cloud-blog3](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog3.png)

You will have a dashboard with all information.

![disposable-k8s-cluster-in-google-cloud-blog4](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog4.png)

Click on the sandwich button on the top left corner to get all of the services of Google Cloud and go to "IAM & Admin" > "Service Account".

![disposable-k8s-cluster-in-google-cloud-blog5](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog5.png)

On the body pane beside "Service Account" click on "+ Create Service Account" to create a new service account.

![disposable-k8s-cluster-in-google-cloud-blog6](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog6.png)

Fill out the "Service account name"

![disposable-k8s-cluster-in-google-cloud-blog7](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog7.png)

Click "Create"

Under the Service account permission there is a dropbox with "Select a role" handler, choose "Editor"

![disposable-k8s-cluster-in-google-cloud-blog8](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog8.png)

Then click "Continur", now you need to create keys and download the JSON file, under "Keys" click on the "+ Create Keys"

![disposable-k8s-cluster-in-google-cloud-blog9](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog9.png)

A left side panel will show and choose "JSON" and click "Create"

![disposable-k8s-cluster-in-google-cloud-blog10](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog10.png)

then Click "Done" under the "+ Create keys".

You will have file named something like this `ajohnsc-k8s-xxxxxxxxxx.json` we need it later for the Ansible.

You have succesfuly downloaded your creadential file in Google Cloud, now we have to add a project wide ssh keys.

For safety reason since this is a disposable cluster we can create a seperate ssh keys for the instances later.

```
[aj@localhost] ssh-keygen -t ed25519 -f gcp.key -t ed25519 -q -N ""
```

It will create `gcp.key` and `gcp.key.pub`

now we will upload our public key as a project wide ssh keys.

Click on the sandwich button on the top left corner to get all of the services of Google Cloud and go to "Compute Engine" > "Metadata".

![disposable-k8s-cluster-in-google-cloud-blog11](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog11.png)

Under "Metadata", click on "SSH Keys" tab

![disposable-k8s-cluster-in-google-cloud-blog12](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog12.png)

In the middle dialog bog click on "Add SSH Keys"

Now we will have a text box, copy paste the contents of `gcp.key.pub`

![disposable-k8s-cluster-in-google-cloud-blog13](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog13.png)

And click "Save".

Next we will setup our Control node.

### Setup your control node

Install Ansible first here is a [link](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installation-guide)

In Ansible we need to meet certain criteria to use specific modules.

Google Cloud modules are part of the Google Cloud SDK and to comply to it we need to install few things.

```
[aj@localhost] pip install requests google-auth --user
```
the control node is good to go now use the playbook

### Configure the playbook

To configure the playbook you need to clone the repository.

```
[aj@localhost] git clone https://github.com/ajohnsc/k8s4learning.git
```

Copy the `gcp.key` file earlier in the directory and `cd` to the directory

```
[aj@localhost] cp gcp.key k8s4learning/
[aj@localhost] cd k8s4learning/
```

There are 3 sample files for you to configure

1. ansible.cfg-sample
1. config.yaml-sample
1. credentials.json-sample

Rename `ansible.cfg-sample`  to `ansible.cfg`

```
[aj@localhost] mv ansible.cfg-sample ansible.cfg
```

Edit the contents of `ansible.cfg`
```
[aj@localhost] vim ansible.cfg

[defaults]
remote_user = (your remote user)
host_key_checking = False
private_key_file = (your private key)


[inventory]
enable_plugins = gcp_compute

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

`(your remote user)`  represents what user you use in the project wide ssh keys, most of the time your current user (not recommended to use root).

`(your private key)` is the private key we generated earlier which is `gcp.key`

so my `ansible.cfg` looks like this:
```
[aj@localhost] cat ansible.cfg
[defaults]
remote_user = aj
host_key_checking = False
private_key_file = gcp.key


[inventory]
enable_plugins = gcp_compute

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

next is my `config.yaml`, rename the `config.yaml-sample` to `config.yaml` and edit it like wise.

```
[aj@localhost] mv config.yaml-sample config.yaml
[aj@localhost] vim config.yaml
---
gcp_project: ( your project ID )
gcp_cred_kind: serviceaccount
gcp_cred_file: credentials.json
region: ( your region )
zone: ( your regions zone )
instance_config:
  - vm_name: "k8smaster"
    vm_machine_type: "n1-standard-2"
    vm_address_name: "k8smaster-address"
    vm_group: "k8smaster"
    disk_name: "k8smaster-disk"
    disk_size: "20"
  - vm_name: "k8sworker"
    vm_machine_type: "n1-standard-2"
    vm_address_name: "k8sworker-address"
    vm_group: "k8sworker"
    disk_name: "k8sworker-disk"
    disk_size: "20"
```

`( your project ID )` we can get it by the following steps.

Go to your Google Cloud Platform dasboard again on the top left beside the Google Cloud Platform logo is your Project name click on that.

![disposable-k8s-cluster-in-google-cloud-blog14](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog14.png)

You will have a dialog box like this:

![disposable-k8s-cluster-in-google-cloud-blog15](/assets/2020-05-12-disposable-k8s-cluster-in-google-cloud/blog15.png)

Your current projet in use will have a check in the left side, and from left to right you will have your Project Name and Project ID, use that and replace that value in your `config.yaml` fila

`( your region )` and `( your region zone )` can get from this [link](https://cloud.google.com/compute/docs/regions-zones) choose what suits you.

 My final `config.yaml` looks like this.

```
[aj@localhost] cat config.yaml
---
gcp_project: ajohnsc-k8s
gcp_cred_kind: serviceaccount
gcp_cred_file: credentials.json
region: asia-east1
zone: asia-east1-a
instance_config:
  - vm_name: "k8smaster"
    vm_machine_type: "n1-standard-2"
    vm_address_name: "k8smaster-address"
    vm_group: "k8smaster"
    disk_name: "k8smaster-disk"
    disk_size: "20"
  - vm_name: "k8sworker"
    vm_machine_type: "n1-standard-2"
    vm_address_name: "k8sworker-address"
    vm_group: "k8sworker"
    disk_name: "k8sworker-disk"
    disk_size: "20"
```
Next is your `credentials.json-sample` file, we already have the actual `credentials.json`, mined named something like `ajohnsc-k8s-xxxxxxxxxx.json` you can copy that in the `k8slearning` directory and rename it `credentials.json`, also you can remove `credentials.json-sample`.

```
[aj@localhost] mv ~/Downloads/ajohnsc-k8s-xxxxxxxxxx.json credentials.json
[aj@localhost] rm credentials.json-sample
```

### Create the cluster

With all thing good to go, we can run the playbook.
```
[aj@localhost] ansible-playbook main_create.yaml  
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create Instances] **********************************************************************************************************************************************************************************************************************

TASK [include_role : createnetwork] **********************************************************************************************************************************************************************************************************

TASK [createnetwork : create a network] ******************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createnetwork : create a firewall] *****************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [include_role : createvm] ***************************************************************************************************************************************************************************************************************

TASK [createvm : create "k8smaster-disk" disk] ***********************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : create "k8smaster-address" address] *****************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : create k8smaster instance] **************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : Wait for SSH to come up] ****************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [createvm : Add host to "k8smaster" inventory group] ************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : create "k8sworker-disk" disk] ***********************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : create "k8sworker-address" address] *****************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : create k8sworker instance] **************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [createvm : Wait for SSH to come up] ****************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [createvm : Add host to "k8sworker" inventory group] ************************************************************************************************************************************************************************************
changed: [localhost]

PLAY [Install Pre-requisites for Kubernetes] *************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************
ok: [35.234.3.178]
ok: [35.201.222.226]

TASK [installprereq : disabling swap] ********************************************************************************************************************************************************************************************************
changed: [35.234.3.178]
changed: [35.201.222.226]

TASK [installprereq : Update packages] *******************************************************************************************************************************************************************************************************
changed: [35.234.3.178]
changed: [35.201.222.226]

TASK [installprereq : Install docker.io and vim] *********************************************************************************************************************************************************************************************
changed: [35.234.3.178]
changed: [35.201.222.226]

TASK [installprereq : add kubernetes repo] ***************************************************************************************************************************************************************************************************
changed: [35.201.222.226]
changed: [35.234.3.178]

TASK [installprereq : Install google cloud gpg keys] *****************************************************************************************************************************************************************************************
changed: [35.201.222.226]
changed: [35.234.3.178]

TASK [installprereq : Update packages] *******************************************************************************************************************************************************************************************************
changed: [35.234.3.178]
changed: [35.201.222.226]

TASK [installprereq : Install kubeadm kubelet and kubectl] ***********************************************************************************************************************************************************************************
changed: [35.234.3.178]
changed: [35.201.222.226]

PLAY [Setup k8s in master node] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************
ok: [35.234.3.178]

TASK [installmaster : create variable for /etc/hosts file] ***********************************************************************************************************************************************************************************
ok: [35.234.3.178] => {
    "msg": "10.240.0.2 k8smaster.asia-east1-a.c.ajohnsc-k8s.internal"
}

TASK [installmaster : add etchosts value to /etc/hosts] **************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : copy kubeadm-config.yaml.j2 to /root directory] ************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : copy modified calico.yaml to /root directory] **************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : install k8s using kubadm command] **************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : create configuration directory] ****************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : copy kubernetes configuration file] ************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : Apply Calico network in kubernetes cluster] ****************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : Install bass-completion] ***********************************************************************************************************************************************************************************************
ok: [35.234.3.178]

TASK [installmaster : add line in a file] ****************************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : create new kubectl token] **********************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : create new discover token] *********************************************************************************************************************************************************************************************
changed: [35.234.3.178]

TASK [installmaster : add variable holder] ***************************************************************************************************************************************************************************************************
changed: [35.234.3.178]

PLAY [Setup k8s in worker node] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************
ok: [35.201.222.226]

TASK [installworker : add etchosts variable in /etc/hosts] ***********************************************************************************************************************************************************************************
changed: [35.201.222.226]

TASK [installworker : add worker to cluster] *************************************************************************************************************************************************************************************************
changed: [35.201.222.226]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************
35.201.222.226             : ok=11   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
35.234.3.178               : ok=22   changed=18   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=12   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Now i can ssh to my master node
```
[aj@localhost] ssh -i gcp.key 35.234.3.178
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 5.0.0-1034-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed May 13 03:11:17 UTC 2020

  System load:  0.49               Users logged in:        0
  Usage of /:   18.1% of 19.21GB   IP address for ens4:    10.240.0.2
  Memory usage: 13%                IP address for docker0: 172.17.0.1
  Swap usage:   0%                 IP address for tunl0:   192.168.16.128
  Processes:    159


40 packages can be updated.
17 updates are security updates.


Last login: Wed May 13 03:08:21 2020 from 152.32.105.137
aj@k8smaster:~$
```

to check if kubernetes succesfully check by using `kubectl get nodes`
```
aj@k8smaster:~$ kubectl get nodes
NAME        STATUS   ROLES    AGE     VERSION
k8smaster   Ready    master   5m45s   v1.18.1
k8sworker   Ready    <none>   5m17s   v1.18.1
aj@k8smaster:~$ 
```
also to check if calico is installed correctly
```
aj@k8smaster:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6fcbbfb6fb-lms9m   1/1     Running   0          8m47s
kube-system   calico-node-jbvkf                          1/1     Running   0          8m47s
kube-system   calico-node-nqwc7                          1/1     Running   0          8m39s
kube-system   coredns-66bff467f8-n86xt                   1/1     Running   0          8m47s
kube-system   coredns-66bff467f8-whhbh                   1/1     Running   0          8m47s
kube-system   etcd-k8smaster                             1/1     Running   0          9m2s
kube-system   kube-apiserver-k8smaster                   1/1     Running   0          9m2s
kube-system   kube-controller-manager-k8smaster          1/1     Running   0          9m2s
kube-system   kube-proxy-8fc42                           1/1     Running   0          8m39s
kube-system   kube-proxy-t9mfq                           1/1     Running   0          8m47s
kube-system   kube-scheduler-k8smaster                   1/1     Running   0          9m2s
aj@k8smaster:~$ 
```
### Deleting the cluster

After using this cluster you can delete it using the other main playbook.
```
[aj@localhost] ansible-playbook main_delete.yaml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Delete K8s-cluster] ********************************************************************************************************************************************************************************************************************

TASK [deletevms : delete vms] ****************************************************************************************************************************************************************************************************************
changed: [localhost] => (item={'vm_name': 'k8smaster', 'vm_machine_type': 'n1-standard-2', 'vm_address_name': 'k8smaster-address', 'vm_group': 'k8smaster', 'disk_name': 'k8smaster-disk', 'disk_size': '20'})
changed: [localhost] => (item={'vm_name': 'k8sworker', 'vm_machine_type': 'n1-standard-2', 'vm_address_name': 'k8sworker-address', 'vm_group': 'k8sworker', 'disk_name': 'k8sworker-disk', 'disk_size': '20'})

TASK [deletevms : delete addresses] **********************************************************************************************************************************************************************************************************
changed: [localhost] => (item={'vm_name': 'k8smaster', 'vm_machine_type': 'n1-standard-2', 'vm_address_name': 'k8smaster-address', 'vm_group': 'k8smaster', 'disk_name': 'k8smaster-disk', 'disk_size': '20'})
changed: [localhost] => (item={'vm_name': 'k8sworker', 'vm_machine_type': 'n1-standard-2', 'vm_address_name': 'k8sworker-address', 'vm_group': 'k8sworker', 'disk_name': 'k8sworker-disk', 'disk_size': '20'})

TASK [deletenetwork : delete firewall] *******************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [deletenetwork : delete network] ********************************************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************
localhost                  : ok=4    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

### Done

While studying kubernetes in depth it really helped me to understand how it works from the inside out, thus creating this playbook help me hone 2 skills at once (Ansible and Kubernetes skills). 