#!/bin/bash

source ./params.sh

TMP_FILE=/tmp/generate-bind-config-file.tmp.$$

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
  #echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION="$var_value"
      #echo REGION=$REGION
      ;;

    "route53_domain")
      BASEDOMAIN=$var_value
      ;;

    "route53_subdomain")
      SUBDOMAIN=$var_value
      ;;

    "route53-admin")
      ADMIN_LB_FQDN="$var_value"
      #echo ADMIN_LB_FQDN=$ADMIN_LB_FQDN
      ;;

    # infra:
    "route53-infra")
      INFRA_NAME="$var_value"
      #echo INFRA_NAME=$INFRA_NAME
      ;;

    "infra-public-name")
      INFRA_PUBLIC_NAME=$var_value
      #echo INFRA_PUBLIC_NAME=$INFRA_PUBLIC_NAME
      ;;
    "infra-public-ip")
      INFRA_PUBLIC_IP=$var_value
      #echo INFRA_PUBLIC_IP=$INFRA_PUBLIC_IP
      ;;
    "infra-private-ip")
      INFRA_PRIVATE_IP=$var_value
      #echo INFRA_PRIVATE_IP=$INFRA_PRIVATE_IP
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
    "master-private-ips")
      MASTER_PRIVATE_IPS="$var_value"
      #echo MASTER_PRIVATE_IPS=$MASTER_PRIVATE_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MASTER_PRIVATE_IP[$COUNT]=$entry
        #echo MASTER_PRIVATE_IP[$COUNT]=${MASTER_PRIVATE_IP[$COUNT]}
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
    "node-private-ips")
      NODE_PRIVATE_IPS="$var_value"
      #echo NODE_PRIVATE_IPS=$NODE_PRIVATE_IPS
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        NODE_PRIVATE_IP[$COUNT]=$entry
        #echo NODE_PRIVATE_IP[$COUNT]=${NODE_PRIVATE_IP[$COUNT]}
      done
      ;;

  esac
done

echo ">>> done."


# --------------------------------------------------
# Configure DNS entries for Docker bind-docker image
# --------------------------------------------------
echo ">>> Generating bind-docker/varbind/docker entries for bind-docker image.."

DOMAIN=$SUBDOMAIN.$BASEDOMAIN
PRIVATE_SUBNET_NET=`echo ${INFRA_PRIVATE_IP} |awk -F "." '{print $1"."$2"."$3}'`
PRIVATE_SUBNET_REV=`echo ${INFRA_PRIVATE_IP} |awk -F "." '{print $3"."$2"."$1}'`
INFRA_IP_NUM=`echo $INFRA_PRIVATE_IP |awk -F "." '{print $4}'`
#
PRIVATE_VPC_NET=`echo ${TF_VPC_CIDR} |awk -F "." '{print $1"."$2"."$3}'`
AWS_META_DNS=${PRIVATE_VPC_NET}.2
#
ZONE_CONFIG_DIR=bind-docker/varbind/docker
DNS_F=${ZONE_CONFIG_DIR}/${DOMAIN}.db
DNS_R=${ZONE_CONFIG_DIR}/db.${PRIVATE_SUBNET_REV}.in-addr.arpa

# subsitute token values in zone config files
cp templates/named.conf.docker.template bind-docker/configs/named.conf.docker
sed -i $SEDBAK "s/##DOMAIN##/${DOMAIN}/g" bind-docker/configs/named.conf.docker
sed -i $SEDBAK "s/##SUBNET_REV##/${PRIVATE_SUBNET_REV}/g" bind-docker/configs/named.conf.docker

cp templates/subdomain.domain.db.template ${DNS_F}
cp templates/db.reversesubnet.in-addr.arpa.template ${DNS_R}
# forward lookup:
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/g" ${DNS_F}
sed -i $SEDBAK "s/##INFRA_IP_NUM##/${PRIVATE_SUBNET_NET}.${INFRA_IP_NUM}/g" ${DNS_F}
MASTER1_IP_NUM=`echo ${MASTER_PRIVATE_IP[1]} |awk -F "." '{print $4}'`
echo "admin             IN      A     ${PRIVATE_SUBNET_NET}.${MASTER1_IP_NUM}" >> ${DNS_F}

# reverse lookup:
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/g" ${DNS_R}
sed -i $SEDBAK "s/##INFRA_IP_NUM##/$INFRA_IP_NUM/g" ${DNS_R}
sed -i $SEDBAK "s/##SUBNET_REV##/$PRIVATE_SUBNET_REV/g" ${DNS_R}

# master entries in both lookups
for (( COUNT=1; COUNT<=$NUM_MASTERS; COUNT++ ))
do
  MASTER_IP_NUM[$COUNT]=`echo ${MASTER_PRIVATE_IP[$COUNT]} |awk -F "." '{print $4}'`
  echo "master${COUNT}           IN      A     ${PRIVATE_SUBNET_NET}.${MASTER_IP_NUM[$COUNT]}" >> ${DNS_F}
  echo "${MASTER_IP_NUM[$COUNT]}   IN     PTR     master${COUNT}.$DOMAIN." >> ${DNS_R}
done

echo ";" >> ${DNS_F}
echo ";" >> ${DNS_R}

# node entries in both lookups
for (( COUNT=1; COUNT<=$NUM_NODES; COUNT++ ))
do
  NODE_IP_NUM[$COUNT]=`echo ${NODE_PRIVATE_IP[$COUNT]} |awk -F "." '{print $4}'`
  echo "node${COUNT}             IN      A     ${PRIVATE_SUBNET_NET}.${NODE_IP_NUM[$COUNT]}" >> ${DNS_F}
  echo "${NODE_IP_NUM[$COUNT]}    IN     PTR     node${COUNT}.$DOMAIN." >> ${DNS_R}
done


# ---------------------------------------
# Generate working-files/resolv.conf file
# ---------------------------------------
echo ">>> Generating working-files/resolv.conf.."

cp templates/resolv.conf.template ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##INFRA_PRIVATE_IP##/$INFRA_PRIVATE_IP/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##AWS_META_DNS##/${AWS_META_DNS}/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##REGION##/$REGION/" ansible/working-files/resolv.conf
sed -i $SEDBAK "s/##DOMAIN##/$DOMAIN/" ansible/working-files/resolv.conf


# ---------------------------------------------------
# Build instance of bind-docker and push to dockerhub
# ---------------------------------------------------
echo ">>> Generating new instance of $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG.."
echo ""

cd bind-docker
docker build -t bind-docker:$BIND_DOCKER_TAG .
docker tag bind-docker:$BIND_DOCKER_TAG $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG
docker push $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG
cd $CWD
echo ""
echo ">>> New image pushed to: $DOCKERHUB_USER/bind-docker:$BIND_DOCKER_TAG"
echo ""


# All done, tidy up
/bin/rm $TMP_FILE
rm bind-docker/configs/named.conf.docker.bak
rm bind-docker/varbind/docker/*.bak
rm ansible/working-files/resolv.conf.bak
exit 0

