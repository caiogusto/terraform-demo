#!/bin/bash
##################


#################
# Explanation of script arguments
#
################

if [ "$1" = "--help" ]; then
echo "
----------------Argument Description---------------------------------------------------------------------------------------------------

r = is used for request number - provide your numericaly OSC request number
u = is used for Oracle Cloud Username
p = is used for Oracle Cloud password
k = is used to auto approve project destruction - use yes to auto approve
"
exit 0
fi

#################
# Script arguments declare
#
################

while getopts r:u:p:k: option
do
case "${option}"
in
r) request_number=${OPTARG};;
u) cloud_username=${OPTARG};;
p) cloud_password=${OPTARG};;
k) auto=$OPTARG;;
esac
done

Local="$(find ./requests/ -name osc$request_number)"
cd $Local/
export PATH=$PATH:~/Desktop/Terraform
terraform init
if [ "$k" != "yes" ]
then
terraform plan  -var "oracle_cloud_username=$cloud_username" -var "oracle_cloud_password=$cloud_password" -var "oracle_cloud_username_db=$cloud_username" -var "oracle_cloud_password_db=$cloud_password"
echo "Do you really want to delete resources from cloud?"
select choice in yes no
do
case $choice in
yes) escolha="yes"
break;;
no) escolha="No"
break
exit 0;;
*)echo "error"
break;;
esac
done
terraform destroy  -var "oracle_cloud_username=$cloud_username" -var "oracle_cloud_password=$cloud_password" -var "oracle_cloud_username_db=$cloud_username" -var "oracle_cloud_password_db=$cloud_password"
else
terraform destroy --force  -var "oracle_cloud_username=$cloud_username" -var "oracle_cloud_password=$cloud_password" -var "oracle_cloud_username_db=$cloud_username" -var "oracle_cloud_password_db=$cloud_password"
fi
