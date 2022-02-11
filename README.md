# Terraform for Infra only
Terraform and ansible to provision a kubernetes cluster deployment on AWS using kubeadm with cloud-provider config

## Generate tf/variables.tf from template
Custom config is defined in params.sh which is used by setup-terraform-vars.sh to generate the variables.tf from a template file variables.tf.template
```
cp ./params.sh.example ./params.sh
edit: params.sh

./setup-terraform-vars.sh
```
check generated tf/variables.tf is as required, no missing variables etc.

note: if you want to add variables you need to change the template and the setup script as well as adding them to the params.sh


## Setup and test terraform

note: I wrote and tested this with terraform v0.11 (and recently with Terraform v1.1.4)

```
cd tf
terraform init
terraform plan
```

## All looking good, then apply the terraform to deploy..

```
terraform apply -auto-approve
```

## check the terraform output variables are looking good
as they are used by later scripts to generate the inventory files for ansible..

```
terraform output
cd ..
```

## Generate a new bind-docker local DNS instance and push to dockerhub
The playbooks install a docker image that hosts a local DNS server, this is used to resolv the load (private) instance IPs for the public route53 DNS names
Having this local DNS simulates an onpremise install so that when an external dns name is resolved to private IP all interr- node traffic is routed on the local subnet and not out of the environment.

This script uses template files:
templates/named.conf.docker.template
templates/subdomain.domain.db.template
templates/db.reversesubnet.in-addr.arpa.template
templates/resolv.conf.template

This script also includes the params.sh so gets some of the variables directly from there, the rest are parsed from terraform output.
```
./generate-dns.sh
```
Check zone files have been created correctly in bind-docker/varbind/docker/


## Generate the ansible/hosts inventory file used by the playbooks
This script includes the params.sh so gets some of the variables directly from there, the rest are parsed from terraform output.
```
./generate-ansbile-files.sh
```
Check the resultant ansible/hosts file is correct and all parameters have been subsituted correctly, specifically check the forward slashes "/"


## Ansible is used to configure the os infra and deploy the software..
You can see which hosts will be included for each playbook and also which role tasks will be run from the ansible/roles directory;

The playbooks are controlled by the site.yml file:
```
---

- hosts: infra-host masters nodes
  roles:
  - ntp
  - pre-deploy
  - update-packages
  - firewall
  - docker-install
  - kube-repo

- hosts: infra-host
  roles:
  - set-hostname
  - deploy-bind-docker
  - config-resolv-conf
  - kube-yum-versionlock
  - kubectl-cli-install

- hosts: masters nodes
  roles:
  - config-resolv-conf
  - kube-yum-versionlock
  - kube-kubeadm-install

- hosts: master1
  roles:
  - kube-kubeadm-init-master1
  - pause-minutes
  - kube-add-calico-cni
  - kube-add-storageclass

- hosts: master2 master3
  roles:
  - kube-kubeadm-join-master
  - pause-minutes

- hosts: nodes
  roles:
  - kube-kubeadm-join-node
```

Test runs can be made before running the actual deployment:
```
cd ansbile
ansible-playbook -i hosts --list-hosts site.yml
ansible-playbook -i hosts --list-tasks site.yml
#ansible-playbook -i hosts --check site.yml
```

Run the config playbook, note that this also updates and reboots the instances so takes a while if you have uncommented the -update-packages role
```
time ansible-playbook -i hosts site.yml
```

Test that kubernetes is configured:
```
kubectl --kubeconfig=working-files/admin.conf get nodes
ANSIBLE_DIR=`pwd`
export KUBECONFIG=$ANSIBLE_DIR/working-files/admin.conf
kubectl get nodes
```


