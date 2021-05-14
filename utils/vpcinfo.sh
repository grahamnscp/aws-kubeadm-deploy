#!/bin/bash

vpc_var=$1
vpc=`aws elb describe-load-balancers | egrep 'VPCId' | sort -u | awk '{print $2}' | sed 's/[",]//g'`
if [ "${vpc_var}" != "" ]; then vpc=$vpc_var ; fi

echo Instances: -----------------------------------------------------------------------------------
aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
echo Network Interfaces: --------------------------------------------------------------------------
aws ec2 describe-network-interfaces --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId
echo VPN Connections: -----------------------------------------------------------------------------
aws ec2 describe-vpn-connections --filters 'Name=vpc-id,Values='$vpc | grep VpnConnectionId
echo VPN Gateways: --------------------------------------------------------------------------------
aws ec2 describe-vpn-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
echo VPC Peering Connections: ---------------------------------------------------------------------
aws ec2 describe-vpc-peering-connections --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
echo VPC Endpoints: -------------------------------------------------------------------------------
aws ec2 describe-vpc-endpoints --filters 'Name=vpc-id,Values='$vpc | grep VpcEndpointId
echo Gateways: ------------------------------------------------------------------------------------
aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep InternetGatewayId
echo NAT Gateways: --------------------------------------------------------------------------------
aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
echo Network ACLs: --------------------------------------------------------------------------------
aws ec2 describe-network-acls --filters 'Name=vpc-id,Values='$vpc | grep NetworkAclId
echo Subnets: -------------------------------------------------------------------------------------
aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc | grep SubnetId
echo Routing Tables: ------------------------------------------------------------------------------
aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc | grep RouteTableId
echo Security Groups: -----------------------------------------------------------------------------
aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc | egrep 'GroupId|GroupName'
echo ELB: -----------------------------------------------------------------------------------------
aws elb describe-load-balancers | egrep 'LoadBalancerName|DNSName|VPCId'
echo ----------------------------------------------------------------------------------------------
