provider "vra" {
  url           = var.url
  refresh_token = var.refresh_token
  insecure      = var.insecure
}
provider "nsxt" {
}

data "vra_zone" "this" {
      name = var.zone_name
}  

resource "vra_project" "this" {

  name        = var.project_name
  description = var.description

  zone_assignments {
    zone_id          = data.vra_zone.this.id
    priority         = var.priority
    max_instances    = var.max_instances
    cpu_limit        = var.cpu_limit
    memory_limit_mb  = var.memory_limit_mb
    storage_limit_gb = var.storage_limit_gb
  }
  
  shared_resources = true

  administrators = var.administrators

  members = var.users
  operation_timeout = 6000

  machine_naming_template = var.basename
}

data "vra_project" "this" {
  name = vra_project.this.name
}
data "nsx_cloudAccount" "this" {
      name = var.network_region
}  
data "vra_fabric_network" "subnet" {
  filter = "name eq '${var.subnet_name}' and cloudAccountId eq '${data.nsx_cloudAccount.this.id}' "
}

data "vra_security_group" "this" {
  filter = "name eq '${var.security_group_name}' and cloudAccountId eq '${data.nsx_cloudAccount.this.id}' "
}
resource "vra_network_profile" "firewall_rules" {
  name        = var.project_name
  description = "Firewall rules are added to all machines provisioned."
  region_id   = data.vra_zone.this.id
  fabric_network_ids = [
    data.vra_fabric_network.subnet.id
  ]

  security_group_ids = [
    data.vra_security_group.this.id
  ]
  tags {
    key   = "environment"
    value = "production"
  }
}
