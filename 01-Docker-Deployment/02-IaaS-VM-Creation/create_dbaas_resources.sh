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
e = is used for environment - choose between this 2 - osclad004 and osclad005
o = is used for database  edition - choose between this 4 - SE EE EE_HP EE_EP
s = is used for Usable Storage - size in GB to be used as storage volume for database filesystem - choose between 15 and 2048
q = is used for VM Shape - choose between 7 different shapes available - 1_OCPU, 2_OCPU, 4_OCPU, 8_OCPU, 16_OCPU
v = is used for database version - choose between this 4 - 18.0.0.0 or 12.2.0.1 or 12.1.0.2 or 11.2.0.4
p = is used for sys password - Provide user sys password
a = is used for SID - provide the SID for database creation (default = ORCL)
h = is used for high performance storage SSD - use true to activate
c = is used for char set - select a char set in this list AL32UTF8,AR8ADOS710,AR8ADOS720,AR8APTEC715,AR8ARABICMACS,AR8ASMO8X,AR8ISO8859P6,AR8MSWIN1256,AR8MUSSAD768,AR8NAFITHA711,AR8NAFITHA721,AR8SAKHR706,AR8SAKHR707,AZ8ISO8859P9E,BG8MSWIN,BG8PC437S,BLT8CP921,BLT8ISO8859P13,BLT8MSWIN1257,BLT8PC775,BN8BSCII,CDN8PC863,CEL8ISO8859P14,CL8ISO8859P5,CL8ISOIR111,CL8KOI8R,CL8KOI8U,CL8MACCYRILLICS,CL8MSWIN1251,EE8ISO8859P2,EE8MACCES,EE8MACCROATIANS,EE8MSWIN1250,EE8PC852,EL8DEC,EL8ISO8859P7,EL8MACGREEKS,EL8MSWIN1253,EL8PC437S,EL8PC851,EL8PC869,ET8MSWIN923,HU8ABMOD,HU8CWI2,IN8ISCII,IS8PC861,IW8ISO8859P8,IW8MACHEBREWS,IW8MSWIN1255,IW8PC1507,JA16EUC,JA16EUCTILDE,JA16SJIS,JA16SJISTILDE,JA16VMS,KO16KSC5601,KO16KSCCS,KO16MSWIN949,LA8ISO6937,LA8PASSPORT,LT8MSWIN921,LT8PC772,LT8PC774,LV8PC1117,LV8PC8LR,LV8RST104090,N8PC865,NE8ISO8859P10,NEE8ISO8859P4,RU8BESTA,RU8PC855,RU8PC866,SE8ISO8859P3,TH8MACTHAIS,TH8TISASCII,TR8DEC,TR8MACTURKISHS,TR8MSWIN1254,TR8PC857,US7ASCII,US8PC437,UTF8,VN8MSWIN1258,VN8VN3,WE8DEC,WE8DG,WE8ISO8859P1,WE8ISO8859P15,WE8ISO8859P9,WE8MACROMAN8S,WE8MSWIN1252,WE8NCR4970,WE8NEXTSTEP,WE8PC850,WE8PC858,WE8PC860,WE8ROMAN8,ZHS16CGB231280,ZHS16GBK,ZHT16BIG5,ZHT16CCDC,ZHT16DBT,ZHT16HKSCS,ZHT16MSWIN950,ZHT32EUC,ZHT32SOPS,ZHT32TRIS
k = is used to auto approve DB creation - use yes to auto approve

----------------Example of usage---------------------------------------------------------------------------------------------------

Example of output after running ./create_dbaas_resources.sh -r 12 -e osclad004 -o SE -s 15 -q 1_OCPU -v 18.0.0.0 -p 'Teste123#' -a ORCL2 -h true -c IW8MSWIN1255 -k no

terraform files in: ./requests/osc<request_number>/
If it is the first Linux machine created for this request, the script will create a openssh key tha will be located with terraform files

The instance will be created with the name osc12cp1 will have:
Size of File Storage Volume     : 15 GB
VM Shape                        : 1 OCPU 15 GB Ram
IP Network                      : 10.0.0.0/24
Public IP in IP Network         : yes
Ingress Rules Allowed           : ssh and IP Network IPs
Egress Rules Allowed            : All
SSH Key                         : id_rsa located in ./requests/osc<request_number>/
Dabatase Version		: 18.0.0.0
Sys password			: Teste123#
SID				: ORCL2
High performance storage	: yes
character set			: IW8MSWIN1255
"
exit 0
fi

#################
# Script arguments declare
#
################

while getopts r:e:o:s:q:v:p:a:h:c:k: option
do
case "${option}"
in
r) request_number=${OPTARG};;
e) environment=${OPTARG};;
o) edition=${OPTARG};;
s) usable_storage=$OPTARG;;
q) Shape_VM=$OPTARG;;
v) version=$OPTARG;;
p) password=$OPTARG;;
a) sid=$OPTARG;;
h) high_performance=$OPTARG;;
c) char_set=$OPTARG;;
k) auto=$OPTARG;;
esac
done

#################
# script arguments selection
#
################

#Enviroment
case $environment in
osclad004) endpoint="https://compute.uscom-central-1.oraclecloud.com/"
identity_domain='588601188'
identity_domain2='idcs-917ddc58acd049a6a6977c7a29c7f2a8'
identity_domain3='https://dbaas.oraclecloud.com/'
region='uscom-central-1';;

osclad005) endpoint="https://compute.brcom-central-1.oraclecloud.com"
identity_domain='588717951'
identity_domain2='idcs-d8b5a5744cb44a329e86f715b7d9f0de'
identity_domain3='https://psm.brcom-central-1.oraclecloud.com'
region='brcom-central-1';;

*)echo "Error selecting environment, for help please type ./create_dbaas_resources.sh --help"
exit 0;;
esac

#Edition
case $edition in
SE) edition='SE';;
EE) edition='EE';;
EE_HP) edition='EE_HP';;
EE_EP) edition='EE_EP';;
*) echo "Error selecting OS, for help please type ./create_dbaas_resources.sh --help"
exit 0;;
esac


#VM Shape
case $Shape_VM in
1_OCPU) Shape='oc1m';;
2_OCPU) Shape='oc2m';;
4_OCPU) Shape='oc3m';;
8_OCPU) Shape='oc4m';;
16_OCPU) Shape='oc5m';;
*)echo "Error selecting environment, for help please type ./compute_images_creator.sh --help"
exit 0;;
esac

#Version
case $version in
'11.2.0.4') version='11.2.0.4';;
'12.2.0.1') version='12.2.0.1';;
'12.1.0.2') version='12.1.0.2';;
'18.0.0.0') version='18.0.0.0';;
*) echo "Error selecting OS, for help please type ./create_dbaas_resources.sh --help"
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
echo "Environment: $environment"
echo "Edition: $edition"
echo "Usable Storage: $usable_storage"
echo "Shape Choosen: $Shape_VM"
echo "Version: $version"
echo "Administrator Password: $password"
echo "SID: $sid"
echo "High Performance Storage: $high_performance"
echo "Char Set:$char_set"
echo "------------------------------------------------------"
echo "------------------------------------------------------"
echo "The SSH key pair will be generated and placed in:./requests/osc$request_number/"
if [ "$auto" != 'yes' ]
then
echo "Deseja prosseguir com a criação da VM?"
select choice in yes no
do
case $choice in
yes) escolha="yes"
break;;
no) escolha="no"
exit 0;;
*)echo "error"
break;;
esac
done
else
escolha="yes"
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


if [[ -e $name/provider-db.tf ]];
then

#################
# Creation First Division
# No its not the first time!
################

i=1
while [[ -e $name/osc"$request_number"db$i.tf ]] ;
do
let i++
done
let t=$i+1
declare -i t

#cp ./requests/osc$request_number/terraform.tfvars ./requests/osc$request_number/terraform.tfvars.tmp
#sed '$ d' ./requests/osc$request_number/terraform.tfvars.tmp > ./requests/osc$request_number/terraform.tfvars
#rm -f ./requests/osc$request_number/terraform.tfvars.tmp

cat > ./requests/osc$request_number/osc"$request_number"db$i.tf <<EOF
resource "oraclepaas_database_service_instance" "database$i" {
name              = "osc\${var.request_number}db$i"
shape             = "$Shape"
ssh_public_key    = "\${file(var.ssh_public_key_file)}"
description	  = "osc\${var.request_number}db$i"
subscription_type = "HOURLY"
region = "$region"
ip_network = "/Compute-$identity_domain/caio.oliveira@oracle.com/osc\${var.request_number}ipnet1"
edition = "$edition"
version = "$version"
bring_your_own_license   = false
high_performance_storage = $high_performance
database_configuration {
admin_password     = "$password"
backup_destination = "None"
sid                = "$sid"
usable_storage     = $usable_storage
is_rac             = false
character_set	   = "$char_set"
}}
EOF

echo "\"dbaas/osc"$request_number"db$i/db_1/vm-1\"," >> ./requests/osc$request_number/terraform.tfvars

else
cat > ./requests/osc$request_number/provider-db.tf <<EOF
variable oracle_cloud_username_db {type = "string"}
variable oracle_cloud_password_db {type = "string"}

provider "oraclepaas" {
user              = "\${var.oracle_cloud_username_db}"
password          = "\${var.oracle_cloud_password_db}"
identity_domain   = "$identity_domain2"
database_endpoint = "$identity_domain3"}
EOF

i=1
while [[ -e $name/osc"$request_number"db$i.tf ]] ;
do
let i++
done
let t=$i+1
declare -i t

cat > ./requests/osc$request_number/osc"$request_number"db$i.tf <<EOF
resource "oraclepaas_database_service_instance" "database$i" {
name              = "osc\${var.request_number}db$i"
shape             = "$Shape"
ssh_public_key    = "\${file(var.ssh_public_key_file)}"
description	  = "osc\${var.request_number}db$i"
subscription_type = "HOURLY"
region = "$region"
ip_network = "/Compute-$identity_domain/caio.oliveira@oracle.com/osc\${var.request_number}ipnet1"
edition = "$edition"
version = "$version"
bring_your_own_license   = false
high_performance_storage = $high_performance
database_configuration {
admin_password     = "$password"
backup_destination = "None"
sid                = "$sid"
usable_storage     = $usable_storage
is_rac             = false
character_set      = "$char_set"
}}
EOF

echo "\"dbaas/osc"$request_number"db$i/db_1/vm-1\"," >> ./requests/osc$request_number/terraform.tfvars

fi


else

#################
# Creation Second Division
# Yes its the first time!
################

i=1
let t=$i+1
declare -i t
mkdir -p ./requests/osc$request_number/
cd ./requests/osc$request_number/
ssh-keygen -t rsa -N '' -f id_rsa
cd -

cat > ./requests/osc$request_number/terraform.tfvars<<EOF
vnic = [
EOF

#################
# Creation Template
# DB Oracle
################

cat > ./requests/osc$request_number/osc"$request_number"db$i.tf <<EOF
resource "oraclepaas_database_service_instance" "database$i" {
name              = "osc\${var.request_number}db$i"
shape             = "$Shape"
ssh_public_key    = "\${file(var.ssh_public_key_file)}"
description	  = "osc\${var.request_number}db$i"
subscription_type = "HOURLY"
region = "$region"
ip_network = "/Compute-$identity_domain/caio.oliveira@oracle.com/osc\${var.request_number}ipnet1"
edition = "$edition"
version = "$version"
bring_your_own_license   = false
high_performance_storage = $high_performance
database_configuration {
admin_password     = "$password"
backup_destination = "None"
sid                = "$sid"
usable_storage     = $usable_storage
is_rac             = false
character_set      = "$char_set"
}}
EOF

echo "\"dbaas/osc"$request_number"db$i/db_1/vm-1\"," >> ./requests/osc$request_number/terraform.tfvars

#################
# Creation Template
# Shared Resources
################

if [[ ! -e $name/shared-resources.tf ]];
then
cat > ./requests/osc$request_number/shared-resources.tf <<EOF
variable ssh_public_key_file {default = "./id_rsa.pub"}
variable user {type = "string" default = "/Compute-$identity_domain/caio.oliveira@oracle.com/"}
variable j {type = "string" default = "1"}

#SSH Creation
resource "opc_compute_ssh_key" "sshkey1" {
name = "osc\${var.request_number}sshkey1"
key = "\${file(var.ssh_public_key_file)}"
enabled = true
}

resource "opc_compute_ip_network" "ip_network" {
name                = "osc\${var.request_number}ipnet1"
ip_address_prefix   = "10.0.0.0/24"
public_napt_enabled = true
}

resource "opc_compute_vnic_set" "test_set" {
name         = "osc\${var.request_number}vnicset1"
applied_acls = ["\${opc_compute_acl.my-acl.name}"]
}

resource "opc_compute_acl" "my-acl" {
name        = "osc\${var.request_number}acl1"
}

resource "opc_compute_security_rule" "ssh" {
name                    = "osc\${var.request_number}secrule-ingress1"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.ssh.name}"]                      
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"
}

resource "opc_compute_security_protocol" "ssh" {
name        = "osc\${var.request_number}secprot1"
dst_ports   = ["22"]
ip_protocol = "tcp"
}

resource "opc_compute_security_rule" "all" {
name                    = "osc\${var.request_number}secrule-ingress2"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.all.name}"]
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"
}

resource "opc_compute_security_rule" "egress" {
name               = "osc\${var.request_number}secrule-egress1"
flow_direction     = "egress"
acl                = "\${opc_compute_acl.my-acl.name}"
security_protocols = ["\${opc_compute_security_protocol.all.name}"]
src_vnic_set       = "\${opc_compute_vnic_set.test_set.name}"
}

resource "opc_compute_security_rule" "ip_network" {
name                    = "osc\${var.request_number}secrule-ip-network\${var.j}"
flow_direction          = "ingress"
acl                     = "\${opc_compute_acl.my-acl.name}"
security_protocols      = ["\${opc_compute_security_protocol.all.name}"]
src_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"
dst_vnic_set            = "\${opc_compute_vnic_set.test_set.name}"
}

resource "opc_compute_security_protocol" "all" {
name        = "osc\${var.request_number}secprot2"
ip_protocol = "all"
}
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
fi

cat > ./requests/osc$request_number/provider-db.tf <<EOF
variable oracle_cloud_username_db {type = "string"}
variable oracle_cloud_password_db {type = "string"}

provider "oraclepaas" {
user              = "\${var.oracle_cloud_username_db}"
password          = "\${var.oracle_cloud_password_db}"
identity_domain   = "$identity_domain2"
database_endpoint = "$identity_domain3"}
EOF

echo "variable request_number {type = \"string\" default = \"$request_number\"}" >> ./requests/osc$request_number/shared-resources.tf

fi

echo "]" >> ./requests/osc$request_number/terraform.tfvars
cd ./requests/osc$request_number/
echo
echo
echo "All the resource, including the SSH key pair, was successful generated and placed in:./requests/osc$request_number/"
echo "Please go to the ./requests/osc$request_number/ and tun the terraform apply --auto-approve to deploy your resources into the cloud"
