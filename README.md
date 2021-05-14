# Terraform for Infra only
Terraform and ansible to provision a kubernetes cluster deployment on AWS using kubeadm with cloud-provider config

## Generate custom variables.tf
Custom config is defined in params.sh which is used by setup-terraform-vars.sh to generate the variables.tf from a template file variables.tf.template
```
cp ./params.sh.example ./params.sh
edit: params.sh
run ./setup-terraform-vars.sh
```
check generated ./tf/variables.tf is as required, no missing variables etc.

note: if you want to add variables you need to change the template and the setup script as well as adding them to the params.sh


## Setup and test terraform

note: I wrote and tested this with terraform v0.11

```
terraform init tf
terraform plan tf
```

## All looking good, then apply the terraform to deploy..

```
terraform apply -auto-approve tf
```

## check the terraform output variables are looking good
as they are used by later scripts to generate the inventory files for ansible..

```
terraform output
```

## Ansible to finish the infra config, deploy docker daemon and bits
First generate an ansible hosts file to use with the playbooks defined in the site.yml:
```
---

- hosts: all
  roles:
  - accept-host-keys
  - ntp
  - pre-deploy
  - update-packages
  - firewall

- hosts: bootstrap
  roles:
  - docker-install
```
note: this script includes the params.sh so gets some of the variables directly from there, the rest are parsed from terraform output.
note2: I've moved the docker installation to only run on the bootstrap/jump host as most kubernetes installers use containerd now

```
./generate-hosts-file.sh
```
check the generated hosts file and run the ansible playbook to finish the infra config..
You can see which hosts will be included and also which role tasks will be run from the ./roles directory;
```
ansible-playbook -i hosts --list-hosts site.yml
ansible-playbook -i hosts --list-tasks site.yml
#ansible-playbook -i hosts --check site.yml
```

Run the config playbook, note that this also updates and reboots the instances so takes a while..
```
ansible-playbook -i hosts site.yml
```

Test that kubernetes is configured:
```
kubectl --kubeconfig=working-files/admin.conf get nodes
export KUBECONFIG=./working-files/admin.conf
kubectl get nodes
```

Add a networking CNI:
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
watch kubectl get pods --all-namespaces
```

