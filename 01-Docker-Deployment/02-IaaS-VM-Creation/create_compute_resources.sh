#!/bin/bash
##################
error_code='./create_compute_resources.sh --help'

#################
# Explanation of script arguments
#
################

if [ "$1" = "--help" ]; then
echo "
----------------Argument Description---------------------------------------------------------------------------------------------------

r = is used for request number - provide your numericaly OSC request number
e = is used for environment - choose between this 2 availables environments - osclad004 and osclad005
o = is used for OS - choose between this 2 availables OS's - OL7, Ubuntu16, WS2012, WS2008, WS2016 and Centos7
s = is used for Storage Size - provide the Storage size of your boot disk in GB
q = is used for VM Shape - choose between 7 different shapes available - 1_OCPU, 2_OCPU, 4_OCPU, 8_OCPU, 16_OCPU, 24_OCPU and 32_OCPU
p = is used for Windows VM password - provide the Administrator Password
k = is used to auto approve VM creation - use yes to auto approve

----------------Example of usage---------------------------------------------------------------------------------------------------

Example of output after running ./create_compute_resources.sh -r 12 -e osclad004 -o OL7 -s 150 -q 1_OCPU -k yes

terraform files in: ./requests/osc<request_number>/
If it is the first Linux machine created for this request, the script will create a openssh key tha will be located with terraform files

The instance will be created with the name osc12cp1 will have:
OS                              : OL_7.2_UEKR3
Nº of Storage Volumes           : 1
Storage Volume Name             : osc12st1
Size of Boot Volume             : 150 GB
VM Shape                        : 1 OCPU 15 GB Ram
IP Network Name                 : osc12ipnet1
IP Network                      : 10.0.0.0/24
Public IP in IP Network         : yes
Ingress Rules Allowed           : ssh and IP Network IPs
Egress Rules Allowed            : All
SSH Key                         : id_rsa located in ./requests/osc<request_number>/
"
exit 0
fi

#################
# Script arguments declare
#
################

while getopts r:e:o:s:q:p:k: option
do
case "${option}"
in
r) request_number=${OPTARG};;
e) ambiente=${OPTARG};;
o) VM_SO=${OPTARG};;
s) storage_size=$OPTARG;;
q) Shape_VM=$OPTARG;;
p) password=$OPTARG;;
k) auto=$OPTARG;;
esac
done

#################
# script arguments selection
#
################

#Enviroment
case $ambiente in
osclad004) endpoint="https://compute.uscom-central-1.oraclecloud.com/"
identity_domain='588601188';;
osclad005) endpoint="https://compute.brcom-central-1.oraclecloud.com"
identity_domain='588717951';;
*) echo "Error selecting environment, for help please type $error_code"
exit 0;;
esac

#OS for osclad004
if [ "$ambiente" = 'osclad004' ]
then
case $VM_SO in
OL7) SO="/oracle/public/OL_7.2_UEKR4_x86_64"
imagelist=1;;
Ubuntu16) SO='Ubuntu.16.04.amd64.20180222.1'
imagelist=1;;
WS2012) SO='Microsoft_Windows_Server_2012_R2-18.1.2-20180110-070846'
imagelist=1;;
WS2008) SO='Microsoft_Windows_Server_2008_EE_R2-18.1.2-20180110-010357'
imagelist=1;;
WS2016) SO='Microsoft_Windows_Server_2016_SE-18.2.4-20180330-114741'
imagelist=1;;
Centos7) SO='CENTOS7'
imagelist=1;;
*) echo "Error selecting OS, for help please type $error_code"
exit 0;;
esac

#OS for osclad005
else
case $VM_SO in
OL7) SO="/oracle/public/OL_7.2_UEKR4_x86_64"
imagelist=1;;
Ubuntu16) SO='Ubuntu.16.04.amd64.20180522'
imagelist=1;;
WS2012) SO='Microsoft_Windows_Server_2012_R2-18.1.2-20180110-070846'
imagelist=1;;
WS2008) SO='Microsoft_Windows_Server_2008_EE_R2-18.1.2-20180110-010357'
imagelist=1;;
WS2016) SO='Microsoft_Windows_Server_2016_SE-18.2.4-20180330-114741'
imagelist=1;;
Centos7) SO='CENTOS7-2'
imagelist=1;;
*) echo "Error selecting OS, for help please type $error_code"
exit 0;;
esac
fi

#VM Shape
case $Shape_VM in
1_OCPU) Shape='oc1m';;
2_OCPU) Shape='oc2m';;
4_OCPU) Shape='oc3m';;
8_OCPU) Shape='oc4m';;
16_OCPU) Shape='oc5m';;
24_OCPU) Shape='oc8m';;
32_OCPU) Shape='oc9m';;
*) echo "Error selecting environment, for help please type $error_code"
exit 0;;
esac

#################
# Creation Summary
#
################

echo
echo "------------------------------------------------------"
echo "-------------- Creation Summary ----------------------"
echo "Request Number: $request_number"
echo "Environment: $ambiente"
echo "SO Choosen: $SO"
echo "Size of Boot Storage Volume: $storage_size"
echo "Shape Choosen: $Shape_VM"
echo "------------------------------------------------------"
echo "------------------------------------------------------"

if [ "$auto" != 'yes' ]
then
echo "Deseja prosseguir com a criação da VM?"
select choice in yes no
do
case $choice in
yes)break;;
no)exit 0;;
*)echo "error please type 1 or 2"
break
exit 0;;
esac
done
fi

#################
# Creation First Division
# First time creating resources for this request?
################

name=./requests/osc$request_number
if [[ -e $name ]] ;
then

cp ./requests/osc$request_number/terraform.tfvars ./requests/osc$request_number/terraform.tfvars.tmp
sed '$ d' ./requests/osc$request_number/terraform.tfvars.tmp > ./requests/osc$request_number/terraform.tfvars
rm -f ./requests/osc$request_number/terraform.tfvars.tmp

#################
# Creation First Division
# No its not the first time!
################

i=1
while [[ -e $name/osc"$request_number"cp$i.tf ]] ;
do
let i++
done
let t=254-$i
declare -i t

#cp ./requests/osc$request_number/terraform.tfvars ./requests/osc$request_number/terraform.tfvars.tmp
#sed '$ d' ./requests/osc$request_number/terraform.tfvars.tmp > ./requests/osc$request_number/terraform.tfvars
#rm -f ./requests/osc$request_number/terraform.tfvars.tmp

#################
# Creation Template
# UNIX
################
if [ "$VM_SO" != 'WS2012' -a "$VM_SO" != 'WS2008' -a "$VM_SO" != 'WS2016' ]
then

cat > ./requests/osc$request_number/osc"$request_number"cp$i.tf <<EOF
variable storage_size$i {type = "string" default = "$storage_size"}
variable shape$i {type = "string" default = "$Shape"}
variable SO$i {type = "string" default = "$SO"}
variable request_number$i {type = "string" default = "$request_number"}

resource "opc_compute_storage_volume" "volume$i" {
size             = "\${var.storage_size$i}"
name             = "osc\${var.request_number$i}st$i"
bootable         = true
image_list       = "\${var.SO$i}"
image_list_entry = $imagelist }

resource "opc_compute_ip_address_reservation" "ipreservation$i" {
name = "osc\${var.request_number$i}ip$i"
ip_address_pool = "public-ippool"}

resource "opc_compute_instance" "instance$i" {
name = "osc\${var.request_number$i}cp$i"
hostname = "osc\${var.request_number$i}cp$i"
label= "osc\${var.request_number$i}cp$i"
shape = "\${var.shape$i}"
ssh_keys = [ "\${opc_compute_ssh_key.sshkey1.name}" ]
boot_order = [1]
networking_info {
index      = 0
ip_network = "\${opc_compute_ip_network.ip_network.name}"
ip_address = "10.0.0.$t"
is_default_gateway = true
vnic = "osc\${var.request_number$i}.vnic$i"
vnic_sets  = ["\${opc_compute_vnic_set.test_set.name}"]
nat        = ["\${opc_compute_ip_address_reservation.ipreservation$i.name}"]
shared_network = false}
storage {
index  = 1
volume = "\${opc_compute_storage_volume.volume$i.name}"}}

output "public_ip_address$i" {
value = "\${opc_compute_ip_address_reservation.ipreservation$i.ip_address}"}
EOF

echo "\"osc$request_number.vnic$i\"," >> ./requests/osc$request_number/terraform.tfvars

#################
# Creation Template
# WINDOWS
################

else
cat > ./requests/osc$request_number/osc"$request_number"cp$i.tf <<EOF
variable storage_size$i {type = "string" default = "$storage_size"}
variable shape$i {type = "string" default = "$Shape"}
variable SO$i {type = "string" default = "$SO"}
variable request_number$i {type = "string" default = "$request_number"}

resource "opc_compute_storage_volume" "volume$i" {
size             = "\${var.storage_size$i}"
name             = "osc\${var.request_number$i}st$i"
bootable         = true
image_list       = "\${var.SO$i}"
image_list_entry = $imagelist}

resource "opc_compute_ip_address_reservation" "ipreservation$i" {
name = "osc\${var.request_number$i}ip$i"
ip_address_pool = "public-ippool"}

resource "opc_compute_instance" "instance$i" {
name = "osc\${var.request_number$i}cp$i"
hostname = "osc\${var.request_number$i}cp$i"
label= "osc\${var.request_number$i}cp$i"
shape = "\${var.shape$i}"
instance_attributes = <<JSON
{"userdata": {"enable_rdp" : true,"administrator_password" : "$password"}}
JSON
boot_order = [1]
networking_info {
index      = 0
ip_network = "\${opc_compute_ip_network.ip_network.name}"
ip_address = "10.0.0.$t"
is_default_gateway = true
vnic = "osc\${var.request_number$i}.vnic$i"
vnic_sets  = ["\${opc_compute_vnic_set.test_set.name}"]
nat        = ["\${opc_compute_ip_address_reservation.ipreservation$i.name}"]
shared_network = false}
storage {
index  = 1
volume = "\${opc_compute_storage_volume.volume$i.name}"}}

output "public_ip_address$i" {
value = "\${opc_compute_ip_address_reservation.ipreservation$i.ip_address}"}
EOF

echo "\"osc$request_number.vnic$i\"," >> ./requests/osc$request_number/terraform.tfvars

fi

else
#################
# Creation First Division
# Yes its the first time!
################

i=1
let t=254-$i
declare -i t
mkdir -p ./requests/osc$request_number/

cat > ./requests/osc$request_number/terraform.tfvars<<EOF
vnic = [
EOF

cd ./requests/osc$request_number/
ssh-keygen -t rsa -N '' -f id_rsa
cd -

if [ "$VM_SO" != 'WS2012' -a "$VM_SO" != 'WS2008' -a "$VM_SO" != 'WS2016' ]
then
#################
# Creation Template
# UNIX
################

cat > ./requests/osc$request_number/osc"$request_number"cp$i.tf <<EOF
variable storage_size$i {type = "string" default = "$storage_size"}
variable shape$i {type = "string" default = "$Shape"}
variable SO$i {type = "string" default = "$SO"}
variable request_number$i {type = "string" default = "$request_number"}

resource "opc_compute_storage_volume" "volume$i" {
size             = "\${var.storage_size$i}"
name             = "osc\${var.request_number$i}st$i"
bootable         = true
image_list       = "\${var.SO$i}"
image_list_entry = $imagelist}

resource "opc_compute_ip_address_reservation" "ipreservation$i" {
name = "osc\${var.request_number$i}ip$i"
ip_address_pool = "public-ippool"}

resource "opc_compute_instance" "instance$i" {
name = "osc\${var.request_number$i}cp$i"
hostname = "osc\${var.request_number$i}cp$i"
label= "osc\${var.request_number$i}cp$i"
shape = "\${var.shape$i}"
ssh_keys = [ "\${opc_compute_ssh_key.sshkey$i.name}" ]
boot_order = [1]
networking_info {
index      = 0
ip_network = "\${opc_compute_ip_network.ip_network.name}"
ip_address = "10.0.0.$t"
is_default_gateway = true
vnic = "osc\${var.request_number$i}.vnic$i"
vnic_sets  = ["\${opc_compute_vnic_set.test_set.name}"]
nat        = ["\${opc_compute_ip_address_reservation.ipreservation$i.name}"]
shared_network = false}
storage {
index  = 1
volume = "\${opc_compute_storage_volume.volume$i.name}"}}

output "public_ip_address$i" {
value = "\${opc_compute_ip_address_reservation.ipreservation$i.ip_address}"}
EOF

echo "\"osc$request_number.vnic$i\"," >> ./requests/osc$request_number/terraform.tfvars

#################
# Creation Template
# WINDOWS
################
else

cat > ./requests/osc$request_number/osc"$request_number"cp$i.tf <<EOF
variable storage_size$i {type = "string" default = "$storage_size"}
variable shape$i {type = "string" default = "$Shape"}
variable SO$i {type = "string" default = "$SO"}
variable request_number$i {type = "string" default = "$request_number"}

resource "opc_compute_storage_volume" "volume$i" {
size             = "\${var.storage_size$i}"
name             = "osc\${var.request_number$i}st$i"
bootable         = true
image_list       = "\${var.SO$i}"
image_list_entry = $imagelist}

resource "opc_compute_ip_address_reservation" "ipreservation$i" {
name = "osc\${var.request_number$i}ip$i"
ip_address_pool = "public-ippool"}

resource "opc_compute_instance" "instance$i" {
name = "osc\${var.request_number$i}cp$i"
hostname = "osc\${var.request_number$i}cp$i"
label= "osc\${var.request_number$i}cp$i"
shape = "\${var.shape$i}"
instance_attributes = <<JSON
{"userdata": {"enable_rdp" : true,"administrator_password" : "$password"}}
JSON
boot_order = [1]
networking_info {
index      = 0
ip_network = "\${opc_compute_ip_network.ip_network.name}"
ip_address = "10.0.0.$t"
is_default_gateway = true
vnic = "osc\${var.request_number$i}.vnic$i"
vnic_sets  = ["\${opc_compute_vnic_set.test_set.name}"]
nat        = ["\${opc_compute_ip_address_reservation.ipreservation$i.name}"]
shared_network = false}
storage {
index  = 1
volume = "\${opc_compute_storage_volume.volume$i.name}"}}

output "public_ip_address$i" {
value = "\${opc_compute_ip_address_reservation.ipreservation$i.ip_address}"}
EOF

echo "\"osc$request_number.vnic$i\"," >> ./requests/osc$request_number/terraform.tfvars

fi

#################
# Creation Template
# Shared Resources
################

cat > ./requests/osc$request_number/shared-resources.tf <<EOF
variable ssh_public_key_file {default = "./id_rsa.pub"}
variable vnic {type = "list"}

resource "opc_compute_ssh_key" "sshkey1" {
name = "osc\${var.request_number}sshkey1"
key = "\${file(var.ssh_public_key_file)}"
enabled = true}

resource "opc_compute_ip_network" "ip_network" {
name                = "osc\${var.request_number}ipnet1"
ip_address_prefix   = "10.0.0.0/24"
public_napt_enabled = true}

resource "opc_compute_vnic_set" "test_set" {
name         = "osc\${var.request_number}vnicset1"
applied_acls = ["\${opc_compute_acl.my-acl.name}"]
virtual_nics = ["\${var.vnic}"]}

resource "opc_compute_acl" "my-acl" {
name        = "osc\${var.request_number}acl1"}

resource "opc_compute_security_rule" "ssh" {
name                    = "osc\${var.request_number}secrule-ingress1"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.ssh.name}"]                      
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_protocol" "ssh" {
name        = "osc\${var.request_number}secprot1"
dst_ports   = ["22"]
ip_protocol = "tcp"}

resource "opc_compute_security_rule" "all" {
name                    = "osc\${var.request_number}secrule-ingress2"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.all.name}"]
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_rule" "egress" {
name               = "osc\${var.request_number}secrule-egress1"
flow_direction     = "egress"
acl                = "\${opc_compute_acl.my-acl.name}"
security_protocols = ["\${opc_compute_security_protocol.all.name}"]
src_vnic_set       = "\${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_rule" "ip_network" {
name                    = "osc\${var.request_number}secrule-ip-network1"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.all.name}"]
src_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_protocol" "all" {
name        = "osc\${var.request_number}secprot2"
ip_protocol = "all"}
EOF

#################
# Creation Template
# Provider Information
################

cat > ./requests/osc$request_number/provider.tf <<EOF
variable oracle_cloud_username {type = "string"}
variable oracle_cloud_password {type = "string"}

provider "opc" {
user = "\${var.oracle_cloud_username}"
password = "\${var.oracle_cloud_password}"
endpoint = "$endpoint"
identity_domain = "$identity_domain"}
EOF

echo "variable request_number {type = \"string\" default = \"$request_number\"}" >> ./requests/osc$request_number/shared-resources.tf
fi
echo "]" >> ./requests/osc$request_number/terraform.tfvars
cd ./requests/osc$request_number/
echo
echo
echo "All the resource, including the SSH key pair, was successful generated and placed in:./requests/osc$request_number/"
echo "Please go to the ./requests/osc$request_number/ and tun the terraform apply --auto-approve to deploy your resources into the cloud"
