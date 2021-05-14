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
terraform output > $TMP_FILE

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g'`

  #echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION="$var_value"
      #echo REGION=$REGION
      ;;
    "domain_name")
      DOMAIN_NAME="$var_value"
      #echo DOMAIN_NAME=$DOMAIN_NAME
      ;;

    "route53-admin")
      ADMIN_LB_FQDN="$var_value"
      #echo ADMIN_LB_FQDN=$ADMIN_LB_FQDN
      ;;

    # Bootstrap:
    "route53-bootstrap")
      BOOTSTRAP_NAME="$var_value"
      #echo BOOTSTRAP_NAME=$BOOTSTRAP_NAME
      ;;

    "bootstrap-public-name")
      BOOTSTRAP_PUBLIC_NAME=$var_value
      #echo BOOTSTRAP_PUBLIC_NAME=$BOOTSTRAP_PUBLIC_NAME
      ;;
    "bootstrap-public-ip")
      BOOTSTRAP_PUBLIC_IP=$var_value
      #echo BOOTSTRAP_PUBLIC_IP=$BOOTSTRAP_PUBLIC_IP
      ;;

    # Master:
    "master-primary-public-name")
      MASTER_PRIMARY_PUBLIC_NAME=$var_value
      #echo MASTER_PRIMARY_PUBLIC_NAME=$MASTER_PRIMARY_PUBLIC_NAME
      ;;
    "master-primary-public-ip")
      MASTER_PRIMARY_PUBLIC_IP=$var_value
      #echo MASTER_PRIMARY_PUBLIC_IP=$MASTER_PRIMARY_PUBLIC_IP
      ;;
    "route53-masters")
      MASTERS=$var_value
      #echo MASTERS=$MASTERS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_NAME[$COUNT]=$entry
        #echo MASTER_NAME[$COUNT]=${MASTER_NAME[$COUNT]}
      done
      NUM_MASTERS=$COUNT
      ;;
    "master-public-names")
      MASTER_PUBLIC_NAMES="$var_value"
      #echo MASTER_PUBLIC_NAMES=$MASTER_PUBLIC_NAMES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_NAME[$COUNT]=$entry
        #echo MASTER_PUBLIC_NAME[$COUNT]=${MASTER_PUBLIC_NAME[$COUNT]}
      done
      ;;
    "master-public-ips")
      MASTER_PUBLIC_IPS="$var_value"
      #echo MASTER_PUBLIC_IPS=$MASTER_PUBLIC_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PUBLIC_IP[$COUNT]=$entry
        #echo MASTER_PUBLIC_IP[$COUNT]=${MASTER_PUBLIC_IP[$COUNT]}
      done
      ;;

    # nodes:
    "route53-nodes")
      NODES="$var_value"
      #echo NODES=$NODES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_NAME[$COUNT]=$entry
        #echo NODE_NAME[$COUNT]=${NODE_NAME[$COUNT]}
      done
      NUM_NODES=$COUNT
      ;;
    "node-public-names")
      NODES_PUBLIC_NAMES="$var_value"
      #echo NODE_PUBLIC_NAMES=$NODE_PUBLIC_NAMES
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_NAME[$COUNT]=$entry
        #echo NODE_PUBLIC_NAME[$COUNT]=${NODE_PUBLIC_NAME[$COUNT]}
      done
      ;;
    "node-public-ips")
      NODE_PUBLIC_IPS="$var_value"
      #echo NODE_PUBLIC_IPS=$NODE_PUBLIC_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PUBLIC_IP[$COUNT]=$entry
        #echo NODE_PUBLIC_IP[$COUNT]=${NODE_PUBLIC_IP[$COUNT]}
      done
      ;;

  esac
done

echo ">>> done."



# Output shell variables
#echo
#echo ">>> Variables from Terraform output are:"
#echo REGION=$REGION
#echo DOMAIN_NAME=$DOMAIN_NAME
#echo ADMIN_LB_FQDN=$ADMIN_LB_FQDN

#echo BOOTSTRAP_PUBLIC_NAME=$BOOTSTRAP_PUBLIC_NAME
#echo BOOTSTRAP_PUBLIC_IP=$BOOTSTRAP_PUBLIC_IP

#echo MASTER_PRIMARY_PUBLIC_NAME=$MASTER_PRIMARY_PUBLIC_NAME
#echo MASTER_PRIMARY_PUBLIC_IP=$MASTER_PRIMARY_PUBLIC_IP

#echo NUM_MASTERS=$NUM_MASTERS
#for (( COUNT=1; COUNT<=$NUM_MASTERS; COUNT++ ))
#do
#  echo MASTER_NAME[$COUNT]=${MASTER_NAME[$COUNT]}
#  echo MASTER_PUBLIC_NAME[$COUNT]=${MASTER_PUBLIC_NAME[$COUNT]}
#  echo MASTER_PUBLIC_IP[$COUNT]=${MASTER_PUBLIC_IP[$COUNT]}
#done

#echo NUM_NODES=$NUM_NODES
#for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
#do
#  echo NODE_NAME[$COUNT]=${NODE_NAME[$COUNT]}
#  echo NODE_PUBLIC_NAME[$COUNT]=${NODE_PUBLIC_NAME[$COUNT]}
#  echo NODE_PUBLIC_IP[$COUNT]=${NODE_PUBLIC_IP[$COUNT]}
#done
#
#echo ">>> done."


# Parse Ansible ./templates/hosts.template to generate the Ansible hosts file
#
echo
echo ">>> Generating Ansible hosts file from ./templates/hosts.template.."
cp ./templates/hosts.template hosts

sed -i $SEDBAK "s/##REGION##/$REGION/" ./hosts
sed -i $SEDBAK "s/##ANSIBLE_SSH_PRIVATE_KEY_FILE##/$ANSIBLE_SSH_PRIVATE_KEY_FILE/" ./hosts
sed -i $SEDBAK "s/##DOMAIN_NAME##/$DOMAIN_NAME/" ./hosts
sed -i $SEDBAK "s/##ADMIN_EXTERNAL_FQDN##/$ADMIN_LB_FQDN/g" ./hosts
sed -i $SEDBAK "s/##KUBERNETES_PACKAGE_VERSION##/$KUBERNETES_PACKAGE_VERSION/g" ./hosts

sed -i $SEDBAK "s/##BOOTSTRAP_PUBLIC_IP##/$BOOTSTRAP_PUBLIC_IP/" ./hosts
sed -i $SEDBAK "s/##BOOTSTRAP_NAME##/$BOOTSTRAP_NAME/" ./hosts

for (( COUNT=1; COUNT<=$NUM_MASTERS; COUNT++ ))
do
  sed -i $SEDBAK "s/##MASTER_NAME_${COUNT}##/${MASTER_NAME[$COUNT]}/" ./hosts
  sed -i $SEDBAK "s/##MASTER_PUBLIC_IP_${COUNT}##/${MASTER_PUBLIC_IP[$COUNT]}/" ./hosts
done

# Append variable number of agent nodes to ansible hosts file
echo "" >> ./hosts
echo "[nodes]" >> ./hosts
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  echo "node${COUNT} ansible_host=${NODE_PUBLIC_IP[$COUNT]} fqdn=${NODE_NAME[$COUNT]}" >> ./hosts
done
echo "" >> ./hosts
echo ">>> done."

echo
echo "Please check the Ansible hosts file and run the playbook:"
echo "   ansible-playbook -i hosts site.yml"
echo


/bin/rm $TMP_FILE
rm ./hosts.bak
exit 0

