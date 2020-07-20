provider "vra" {
  url           = var.url
  refresh_token = var.refresh_token
  insecure      = var.insecure
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

resource "vra_network_profile" "firewall_rules" {
  name        = "vra_project.this.name"
  description = "Firewall rules are added to all machines provisioned."
  region_id   = data.vra_zone.this.id

  tags {
    key   = "environment"
    value = "production"
  }
}

data "vra_network_profile" "firewall_rules" {
  name = firewall_rules.this.name
}
