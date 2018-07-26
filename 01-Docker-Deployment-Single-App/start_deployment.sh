#!/bin/bash
docker_username=''
docker_password=''

cloud_username=''
cloud_password=''

cloud_endpoint=''
cloud_identity_domain=''

##Docker Image Creation
cd 01-Docker-Image-Files/
docker login -u "$docker_username" -p "$docker_password"
docker build -t $docker_username/01-docker-deployment:latest .
docker push $docker_username/01-docker-deployment:latest

##IaaS VM Creation
cd ../02-IaaS-VM-Creation/
echo "sudo docker login -u $docker_username -p $docker_password" >> script.sh
echo "sudo docker run -d -P $docker_username/01-docker-deployment:latest" >> script.sh
echo "sudo docker ps -a" >> script.sh
terraform init
terraform apply --auto-approve -var "oracle_cloud_username=$cloud_username" -var "oracle_cloud_password=$cloud_password"
sed -i '/sudo docker login/d' ./script.sh
sed -i '/sudo docker run/d' ./script.sh
sed -i '/sudo docker ps/d' ./script.sh
