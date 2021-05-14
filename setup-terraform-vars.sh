#!/bin/bash

source ./params.sh

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




# Subsitute terraform variables to generate variables.tf
echo ">>> Generating Terraform ./tf/variables.tf file from ./templates/variables.tf.template.."
cp ./templates/variables.tf.template ./tf/variables.tf

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##TF_AWS_OWNER_TAG##/$TF_AWS_OWNER_TAG/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_EXPIRATION_TAG##/$TF_AWS_EXPIRATION_TAG/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_PURPOSE_TAG##/$TF_AWS_PURPOSE_TAG/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_KEY_NAME##/$TF_AWS_KEY_NAME/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_INSTANCE_PREFIX##/$TF_AWS_INSTANCE_PREFIX/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOMAINNAME##/$TF_AWS_DOMAINNAME/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_ROUTE53_ZONE_ID##/$TF_AWS_ROUTE53_ZONE_ID/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_REGION##/$TF_AWS_REGION/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_AVAILABILITY_ZONES##/$TF_AWS_AVAILABILITY_ZONES/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_CENTOS_AMI##/$TF_AWS_CENTOS_AMI/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_MASTER_COUNT##/$TF_AWS_MASTER_COUNT/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_COUNT##/$TF_AWS_NODE_COUNT/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOCKER_VOLUME_SIZE##/$TF_AWS_DOCKER_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_LPV_VOLUME_SIZE##/$TF_AWS_LPV_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_PX_VOLUME_SIZE##/$TF_AWS_PX_VOLUME_SIZE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_BOOTSTRAP_INSTANCE_TYPE##/$TF_AWS_BOOTSTRAP_INSTANCE_TYPE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_MASTER_INSTANCE_TYPE##/$TF_AWS_MASTER_INSTANCE_TYPE/" ./tf/variables.tf
sed -i $SEDBAK "s/##TF_AWS_NODE_INSTANCE_TYPE##/$TF_AWS_NODE_INSTANCE_TYPE/" ./tf/variables.tf

rm ./tf/variables.tf.bak

exit 0

