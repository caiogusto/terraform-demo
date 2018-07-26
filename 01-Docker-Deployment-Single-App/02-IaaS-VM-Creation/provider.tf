variable oracle_cloud_username {type = "string"}
variable oracle_cloud_password {type = "string"}

provider "opc" {
user = "${var.oracle_cloud_username}"
password = "${var.oracle_cloud_password}"
endpoint = "https://compute.brcom-central-1.oraclecloud.com"
identity_domain = "588717951"}
