variable ssh_public_key_file {default = "./id_rsa.pub"}
variable vnic {type = "list"}

resource "opc_compute_ssh_key" "sshkey1" {
name = "osc${var.request_number}sshkey1"
key = "${file(var.ssh_public_key_file)}"
enabled = true}

resource "opc_compute_ip_network" "ip_network" {
name                = "osc${var.request_number}ipnet1"
ip_address_prefix   = "10.0.0.0/24"
public_napt_enabled = true}

resource "opc_compute_vnic_set" "test_set" {
name         = "osc${var.request_number}vnicset1"
applied_acls = ["${opc_compute_acl.my-acl.name}"]
virtual_nics = ["${var.vnic}"]}

resource "opc_compute_acl" "my-acl" {
name        = "osc${var.request_number}acl1"}

resource "opc_compute_security_rule" "ssh" {
name                    = "osc${var.request_number}secrule-ingress1"
flow_direction          = "ingress"
acl                     = "${opc_compute_acl.my-acl.name}"
security_protocols      = ["${opc_compute_security_protocol.ssh.name}"]                      
dst_vnic_set            = "${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_protocol" "ssh" {
name        = "osc${var.request_number}secprot1"
dst_ports   = ["22"]
ip_protocol = "tcp"}

resource "opc_compute_security_rule" "all" {
name                    = "osc${var.request_number}secrule-ingress2"
flow_direction          = "ingress"
acl                     = "${opc_compute_acl.my-acl.name}"
security_protocols      = ["${opc_compute_security_protocol.all.name}"]
dst_vnic_set            = "${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_rule" "egress" {
name               = "osc${var.request_number}secrule-egress1"
flow_direction     = "egress"
acl                = "${opc_compute_acl.my-acl.name}"
security_protocols = ["${opc_compute_security_protocol.all.name}"]
src_vnic_set       = "${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_rule" "ip_network" {
name                    = "osc${var.request_number}secrule-ip-network1"
flow_direction          = "ingress"
acl                     = "${opc_compute_acl.my-acl.name}"
security_protocols      = ["${opc_compute_security_protocol.all.name}"]
src_vnic_set            = "${opc_compute_vnic_set.test_set.name}"
dst_vnic_set            = "${opc_compute_vnic_set.test_set.name}"}

resource "opc_compute_security_protocol" "all" {
name        = "osc${var.request_number}secprot2"
ip_protocol = "all"}
variable request_number {type = "string" default = "11"}
