#!/bin/bash

## This script creates various AWS resources including an EC2 instance. It also makes use of the userdata.sh script to install mprime while the instance is booting.

#*********************************************************************************************************************************************************************
#	VARIABLES
#*********************************************************************************************************************************************************************

AWS_REGION="us-east-1"
PUBLIC_AZ="us-east-1a"
VPC_NAME="Bash_VPC"
VPC_CIDR="10.20.0.0/16"
PUBLIC_SUBNET_NAME="Public_Subnet"
PUBLIC_SUBNET_CIDR="10.20.1.0/24"
GATEWAY_NAME="Bash_IGW"
RT_NAME="Bash_RT"
SG_PUBLIC_NAME="Public_EC2_SG"
PORT22_CIDR="0.0.0.0/0"
DESTINATION_CIDR="0.0.0.0/0"
PUBLIC_INSTANCE_NAME="PublicEC2"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c4f7023847b90238"

#*********************************************************************************************************************************************************************
#	VPC
#*********************************************************************************************************************************************************************

echo "**** STARTING ****\n\n\n"

echo "Creating VPC...\n\n"

## Create VPC and get its ID
VPC_ID=$(aws ec2 create-vpc \
 --cidr-block "$VPC_CIDR" \
 --query Vpc.VpcId \
 --region "$AWS_REGION" \
 --output text)
echo "VPC ID --> '$VPC_ID'\n"

## Add name tag to the VPC
aws ec2 create-tags \
 --resources "$VPC_ID" \
 --tags Key=Name,Value="$VPC_NAME" \
 --region "$AWS_REGION"
echo "VPC name --> '$VPC_NAME'\n\n\n"

#*********************************************************************************************************************************************************************
#	INTERNET GATEWAY
#*********************************************************************************************************************************************************************

echo "Creating Internet Gateway...\n\n"

## Create internet gateway and get its ID
GATEWAY_ID=$(aws ec2 create-internet-gateway \
 --query InternetGateway.InternetGatewayId \
 --region "$AWS_REGION" \
 --output text)
echo "Internet Gateway ID --> '$GATEWAY_ID'\n"

## Add name tag to the internet gateway
aws ec2 create-tags \
 --resources "$GATEWAY_ID" \
 --tags Key=Name,Value="$GATEWAY_NAME" \
 --region "$AWS_REGION"
echo "Internet Gateway name --> '$GATEWAY_NAME'\n"

## Attach gateway to vpc
aws ec2 attach-internet-gateway \
 --vpc-id "$VPC_ID"  \
 --internet-gateway-id "$GATEWAY_ID" \
 --region "$AWS_REGION"
echo "Internet Gateway successfully attached to VPC\n\n\n"

#*********************************************************************************************************************************************************************
#	SUBNETS
#*********************************************************************************************************************************************************************

echo "Creating Subnets...\n\n"

## Create the public subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
 --cidr-block "$PUBLIC_SUBNET_CIDR" \
 --availability-zone "$PUBLIC_AZ" \
 --vpc-id "$VPC_ID" \
 --query Subnet.SubnetId \
 --region "$AWS_REGION" \
 --output text)
echo "Public subnet ID --> '$PUBLIC_SUBNET_ID'\n"

## Add name tag to the public subnet
aws ec2 create-tags \
 --resources "$PUBLIC_SUBNET_ID" \
 --tags Key=Name,Value="$PUBLIC_SUBNET_NAME" \
 --region "$AWS_REGION"
echo "Public subnet name --> '$PUBLIC_SUBNET_NAME'\n"

## Enable auto-assign Public IP on public subnet
aws ec2 modify-subnet-attribute \
 --subnet-id "$PUBLIC_SUBNET_ID" \
 --map-public-ip-on-launch
echo "Auto-assign Public IP enabled for Public Subnet\n\n\n"

#*********************************************************************************************************************************************************************
#	KEY PAIR
#*********************************************************************************************************************************************************************

echo "Creating Key Pair...\n\n"

## Create a key pair and output to MyKeyPair.pem
aws ec2 create-key-pair \
 --key-name MyKeyPair \
 --query 'KeyMaterial' \
 --output text > ~/MyKeyPair.pem
echo "Key pair successfully created\n"

## Linux / Mac only - modify permissions
chmod 400 MyKeyPair.pem
echo "Permissions modified successfully\n\n\n"

#*********************************************************************************************************************************************************************
#	SECURITY GROUP & EC2 INSTANCE
#*********************************************************************************************************************************************************************

echo "Creating Security Group & Public EC2 Instance...\n\n"

## Create security group for public EC2 instance
SG_CREATE=$(aws ec2 create-security-group \
 --group-name "$SG_PUBLIC_NAME" \
 --description "Security group granting SSH access to public instance" \
 --vpc-id "$VPC_ID" \
 --region "$AWS_REGION")
echo "Public security group successfully created\n"

## Get security group ID
SG_PUBLIC_ID=$(aws ec2 describe-security-groups \
 --region "$AWS_REGION" \
 --filters Name=group-name,Values="$SG_PUBLIC_NAME" \
 --query "SecurityGroups[*].[GroupId]" \
 --output text)
echo "Public ec2 security group ID --> '$SG_PUBLIC_ID'\n"

## Add name tag to public security group
SG_TAG=$(aws ec2 create-tags \
 --resources "$SG_PUBLIC_ID" \
 --tags Key=Name,Value="$SG_PUBLIC_NAME" \
 --region "$AWS_REGION")
echo "Public ec2 security group name --> '$SG_PUBLIC_NAME'\n"

## Allow inbound traffic on port 22
RESULT=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_PUBLIC_ID" \
 --protocol tcp \
 --port 22 \
 --cidr "$PORT22_CIDR")
echo "Inbound SSH traffic from '$PORT22_CIDR' ALLOWED\n"

## Launch EC2 instance in public subnet (Obtain the image-id i.e. AMI ID from the console)
INSTANCE1=$(aws ec2 run-instances \
 --image-id "$AMI_ID" \
 --count 1 \
 --instance-type "$INSTANCE_TYPE" \
 --key-name MyKeyPair \
 --user-data file://setup.sh
 --security-group-ids "$SG_PUBLIC_ID" \
 --subnet-id "$PUBLIC_SUBNET_ID" \
 --region "$AWS_REGION" \
 --output text)
echo "Public EC2 instance successfully created\n"

## Get public instnce ID
PUBLIC_EC2_ID=$(aws ec2 describe-instances \
 --filters Name=subnet-id,Values="$PUBLIC_SUBNET_ID" \
 --query "Reservations[*].Instances[*].[InstanceId]" \
 --output text)
echo "Public EC2 instance ID --> '$PUBLIC_EC2_ID'\n"

## Get public instance IPv4 address
PUBLIC_IP=$(aws ec2 describe-instances \
 --filters Name=subnet-id,Values="$PUBLIC_SUBNET_ID" \
 --query "Reservations[*].Instances[*].[PublicIpAddress]" \
 --output text)
echo "Public EC2 instance IPv4 --> '$PUBLIC_IP'\n"

## Add name tag to public EC2 instance
SG_TAG=$(aws ec2 create-tags \
 --resources "$PUBLIC_EC2_ID" \
 --tags Key=Name,Value="$PUBLIC_INSTANCE_NAME" \
 --region "$AWS_REGION")
echo "Public EC2 instance name --> '$PUBLIC_INSTANCE_NAME'\n\n\n"

#*********************************************************************************************************************************************************************
#	ROUTE TABLE
#*********************************************************************************************************************************************************************

echo "Creating Custom (Public) Route Table...\n\n"

## Create custom route table for vpc
RT_ID=$(aws ec2 create-route-table \
 --vpc-id "$VPC_ID" \
 --query RouteTable.RouteTableId \
 --region "$AWS_REGION" \
 --output text)
echo "Route table ID --> '$RT_ID'\n"

## Add name tag to the route table
RT_NAME_TAG=$(aws ec2 create-tags \
 --resources "$RT_ID" \
 --tags Key=Name,Value="$RT_NAME" \
 --region "$AWS_REGION")
echo "Route table name --> '$RT_NAME'\n"

## Create route to the internet gateway
RT_IGW_ROUTE=$(aws ec2 create-route \
 --route-table-id "$RT_ID" \
 --destination-cidr-block "$DESTINATION_CIDR" \
 --gateway-id "$GATEWAY_ID" \
 --region "$AWS_REGION")
echo "Route to internet gateway has been successfully added\n"

## Associate public subnet with route table
ASSOCIATE=$(aws ec2 associate-route-table \
 --subnet-id "$PUBLIC_SUBNET_ID" \
 --route-table-id "$RT_ID" \
 --region "$AWS_REGION")
echo "Public subnet CIDR block has been associated with route table successfully\n\n\n"

echo "**** COMPLETED ****"