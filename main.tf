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
  description = "terraform test project"

  zone_assignments {
    zone_id          = data.vra_zone.this.id
    priority         = 1
    max_instances    = 2
    cpu_limit        = 128
    memory_limit_mb  = 256
    storage_limit_gb = 8192
  }

  shared_resources = true

  administrators = ["vraadmins@int.sentania.net"]

  members = ["vrausers@int.sentania.net"]

  operation_timeout = 6000

  machine_naming_template = "$${resource.name}-$${####}"
}

data "vra_project" "this" {
  name = vra_project.this.name
}
