#
# These variables are subsituted into templates buy run-terraform.sh
#

# Terraform Variables - terraform/variables.tf.template -> terraform/variables.tf
#
TF_AWS_INSTANCE_PREFIX=kube
TF_AWS_DOMAINNAME=dev.example.com
TF_AWS_OWNER_TAG=grahamh
TF_AWS_EXPIRATION_TAG=6h
TF_AWS_PURPOSE_TAG="devtest"
#
TF_AWS_KEY_NAME=id_rsa
#
# buildsilab.com
TF_AWS_ROUTE53_ZONE_ID=<Existing AWS Zone ID>
#
#TF_AWS_REGION=us-east-1
#TF_AWS_AVAILABILITY_ZONES=us-east-1a,us-east-1b,us-east-1c,us-east-1d
TF_AWS_REGION=eu-west-2
TF_AWS_AVAILABILITY_ZONES=eu-west-2a,eu-west-2b,eu-west-2c
#
# https://wiki.centos.org/Cloud/AWS: CentOS Linux 7 1801_01 2018-Jan-14 us-east-1 ami-4bf3d731 x86_64 HVM EBS
#TF_AWS_CENTOS_AMI=ami-4bf3d731
# aws --region eu-west-2 ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce | egrep 'CreationDate|Description|ImageId'
# Centos 6.9:
#TF_AWS_CENTOS_AMI=ami-3d6b7059
# Centos 7 2020_01 - eu-west-2 / London:
TF_AWS_CENTOS_AMI=ami-09e5afc68eed60ef4

#
TF_AWS_MASTER_COUNT=3
TF_AWS_NODE_COUNT=5
TF_AWS_DOCKER_VOLUME_SIZE=31
TF_AWS_LPV_VOLUME_SIZE=50
TF_AWS_PX_VOLUME_SIZE=50
#
TF_AWS_BOOTSTRAP_INSTANCE_TYPE=t2.medium
TF_AWS_MASTER_INSTANCE_TYPE=t2.large
#TF_AWS_NODE_INSTANCE_TYPE=m4.2xlarge
#TF_AWS_NODE_INSTANCE_TYPE=t2.large
TF_AWS_NODE_INSTANCE_TYPE=m4.xlarge


# Ansible variables
ANSIBLE_SSH_PRIVATE_KEY_FILE="\~\/.ssh\/id_rsa"
ANSIBLE_USER=centos

# https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64/repodata/filelists.xml 
#KUBERNETES_PACKAGE_VERSION=1.17.8-0
KUBERNETES_PACKAGE_VERSION=1.18.5-0

