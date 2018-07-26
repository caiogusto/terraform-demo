variable storage_size1 {type = "string" default = "100"}
variable shape1 {type = "string" default = "oc1m"}
variable SO1 {type = "string" default = "CENTOS7-2"}
variable request_number1 {type = "string" default = "11"}

resource "opc_compute_storage_volume" "volume1" {
size             = "${var.storage_size1}"
name             = "osc${var.request_number1}st1"
bootable         = true
image_list       = "${var.SO1}"
image_list_entry = 1}

resource "opc_compute_ip_address_reservation" "ipreservation1" {
name = "osc${var.request_number1}ip1"
ip_address_pool = "public-ippool"}

resource "opc_compute_instance" "instance1" {
name = "osc${var.request_number1}cp1"
hostname = "osc${var.request_number1}cp1"
label= "osc${var.request_number1}cp1"
shape = "${var.shape1}"
ssh_keys = [ "${opc_compute_ssh_key.sshkey1.name}" ]
boot_order = [1]
networking_info {
index      = 0
ip_network = "${opc_compute_ip_network.ip_network.name}"
ip_address = "10.0.0.253"
is_default_gateway = true
vnic = "osc${var.request_number1}.vnic1"
vnic_sets  = ["${opc_compute_vnic_set.test_set.name}"]
nat        = ["${opc_compute_ip_address_reservation.ipreservation1.name}"]
shared_network = false}
storage {
index  = 1
volume = "${opc_compute_storage_volume.volume1.name}"}
connection {
type = "ssh"
host = "${opc_compute_ip_address_reservation.ipreservation1.ip_address}"
user = "centos"
password = ""
private_key = "${file("./id_rsa")}"
timeout = "10m"
}

provisioner "file" {
source      = "/home/opc/terraform-demo/01-Docker-Deployment/02-IaaS-VM-Creation/script.sh"
destination = "/home/centos/script.sh"
}

provisioner "remote-exec" {
inline = ["sudo chmod +x /home/centos/script.sh","sudo /home/centos/script.sh"]
}
}


output "public_ip_address1" {
value = "${opc_compute_ip_address_reservation.ipreservation1.ip_address}"}
