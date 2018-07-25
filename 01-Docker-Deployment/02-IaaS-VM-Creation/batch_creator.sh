#!/bin/bash
lad='osclad005'
request='11'
cloud_username=''
cloud_password=''

#./create_compute_resources.sh -r $request -e $lad -o OL7 -s 100 -q 1_OCPU -k yes
#./create_compute_resources.sh -r $request -e $lad -o Ubuntu16 -s 150 -q 1_OCPU -k yes
./create_compute_resources.sh -r $request -e $lad -o Centos7 -s 300 -q 2_OCPU -k yes
#./create_compute_resources.sh -r $request -e $lad -o WS2012 -s 300 -q 4_OCPU -p 'ml6pO4iDRi#' -k yes
#./create_compute_resources.sh -r $request -e $lad -o WS2008 -s 150 -q 1_OCPU -p 'Teste123#' -k yes
#./create_compute_resources.sh -r $request -e $lad -o WS2016 -s 150 -q 1_OCPU -p 'Teste123#' -k yes
#./create_dbaas_resources.sh -r $request -e $lad -o SE -s 2048 -q 4_OCPU -v 11.2.0.4 -p 'ml6pO4iDRi#' -a 'ORCL' -h true -c WE8ISO8859P1 -k yes

cd ./requests/osc$request/
terraform init
terraform apply --auto-approve -var "oracle_cloud_username=$cloud_username" -var "oracle_cloud_password=$cloud_password" -var "oracle_cloud_username_db=$cloud_username" -var "oracle_cloud_password_db=$cloud_password"

#terraform apply -var "oracle_cloud_username=caio.oliveira@oracle.com" -var "oracle_cloud_password=Kyo221091*" -var "oracle_cloud_username_db=caio.oliveira@oracle.com" -var "oracle_cloud_password_db=Kyo221091*"
