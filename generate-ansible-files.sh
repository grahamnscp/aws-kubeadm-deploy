#!/bin/bash

source ./params.sh

TMP_FILE=/tmp/generate-hosts-file.tmp.$$

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac
echo OS is ${MACHINE}


# Collect output variables
echo
echo ">>> Collecting variables from terraform output.."
CWD=`pwd`
cd tf
terraform output > $TMP_FILE
cd $CWD

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g' |sed 's/\"//g'`
  echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION=$var_value
      ;;

    "route53_domain")
      BASEDOMAIN=$var_value
      ;;

    "route53_subdomain")
      SUBDOMAIN=$var_value
      ;;

    "route53-admin")
      ADMIN_LB_FQDN=$var_value
      ;;

    # infra:
    "route53-infra")
      INFRA_NAME=$(echo $var_value |sed "s/,/ /g")
      ;;

    "infra-public-name")
      INFRA_PUBLIC_NAME=$var_value
      ;;
    "infra-public-ip")
      INFRA_PUBLIC_IP=$var_value
      ;;

    # Master:
    "master-primary-public-name")
      MASTER_PRIMARY_PUBLIC_NAME=$var_value
      ;;
    "master-primary-public-ip")
      MASTER_PRIMARY_PUBLIC_IP=$var_value
      ;;
    "route53-masters")
      MASTERS=$var_value
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_NAME[$COUNT]=$entry
      done
      NUM_MASTERS=$COUNT
      ;;
    "master-public-names")
      MASTER_PUBLIC_NAMES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_NAME[$COUNT]=$entry
      done
      ;;
    "master-public-ips")
      MASTER_PUBLIC_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_IP[$COUNT]=$entry
      done
      ;;

    # nodes:
    "route53-nodes")
      NODES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_NAME[$COUNT]=$entry
      done
      NUM_NODES=$COUNT
      ;;
    "node-public-names")
      NODES_PUBLIC_NAMES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_NAME[$COUNT]=$entry
      done
      ;;
    "node-public-ips")
      NODE_PUBLIC_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_IP[$COUNT]=$entry
      done
      ;;

  esac
done

echo ">>> done."


# Variables
DOMAIN=${SUBDOMAIN}.${BASEDOMAIN}


# Parse Ansible ./templates/hosts.template to generate the Ansible hosts file
#
echo
echo ">>> Generating ansible/hosts from templates/hosts.template.."
cp templates/hosts.template ansible/hosts

sed -i $SEDBAK "s/##REGION##/$REGION/" ansible/hosts
sed -i $SEDBAK "s/##ANSIBLE_SSH_PRIVATE_KEY_FILE##/$ANSIBLE_SSH_PRIVATE_KEY_FILE/" ansible/hosts
sed -i $SEDBAK "s/##BASEDOMAIN##/$BASEDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##SUBDOMAIN##/$SUBDOMAIN/" ansible/hosts
sed -i $SEDBAK "s/##ADMIN_EXTERNAL_FQDN##/$ADMIN_LB_FQDN/g" ansible/hosts
sed -i $SEDBAK "s/##DOCKER_STORAGE_DEVICE##/$DOCKER_STORAGE_DEVICE/g" ansible/hosts
sed -i $SEDBAK "s/##KUBERNETES_PACKAGE_VERSION##/$KUBERNETES_PACKAGE_VERSION/g" ansible/hosts
sed -i $SEDBAK "s/##DOCKERHUB_USER##/$DOCKERHUB_USER/g" ansible/hosts
sed -i $SEDBAK "s/##BIND_DOCKER_TAG##/$BIND_DOCKER_TAG/g" ansible/hosts

sed -i $SEDBAK "s/##INFRA_PUBLIC_IP##/$INFRA_PUBLIC_IP/" ansible/hosts
sed -i $SEDBAK "s/##INFRA_NAME##/$INFRA_NAME/" ansible/hosts

for (( COUNT=1; COUNT<=$NUM_MASTERS; COUNT++ ))
do
  sed -i $SEDBAK "s/##MASTER_NAME_${COUNT}##/${MASTER_NAME[$COUNT]}/" ansible/hosts
  sed -i $SEDBAK "s/##MASTER_PUBLIC_IP_${COUNT}##/${MASTER_PUBLIC_IP[$COUNT]}/" ansible/hosts
done

# Append variable number of agent nodes to ansible hosts file
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  echo "node${COUNT} ansible_host=${NODE_PUBLIC_IP[$COUNT]} fqdn=${NODE_NAME[$COUNT]}" >> ansible/hosts
done
echo "" >> ansible/hosts
echo ">>> done."

echo
echo "Please check the Ansible hosts file and run the playbook in the ansible subdirectory:"
echo "time ansible-playbook -i hosts site.yml"
echo


/bin/rm $TMP_FILE
rm ansible/hosts.bak
exit 0

