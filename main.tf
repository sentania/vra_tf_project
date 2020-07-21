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

data "vra_cloud_account_vsphere" "this" {
  name = var.cloud_account
}

data "vra_network_domain" "vpc" {
  filter = "name eq '${var.network_domain_name}'"
}

resource "vra_network_profile" "subnet_isolation" {
  name        = "Demo Network Profile"
  description = "On-demand networks are created for outbound and private networks."
  region_id   = "9d71f931-addd-41ba-b591-1b65c3ae84d6"

  isolation_type               = "SUBNET"
  isolated_network_domain_id   = "cb13ebf0-8600-465a-a50b-69544f3ad06d"
  isolated_network_cidr_prefix = var.cidr_prefix
  isolated_network_domain_cidr = var.cidr
  custom_properties ={
      datacenterId = "Datacenter:datacenter-3"
      edgeClusterRouterStateLink = "/resources/routers/67527579-f47d-4c83-8c33-0211f56a9f74"
      tier0LogicalRouterStateLink = "/resources/routers/79664a75-c966-4f8f-a5d7-4065f4fb1652"
      onDemandNetworkIPAssignmentType = "mixed"
  }

  tags {
    key   = "compliance"
    value = var.compliance
  }
  tags {
    key   = "environment"
    value = var.environment
  }

}

resource "vra_blueprint" "this" {
  name        = var.blueprint_name
  description = "Created by vRA terraform provider"

  project_id = data.vra_project.this.id

  content = <<-EOT
    formatVersion: 1
    inputs: {}
    resources:
      Cloud_SecurityGroup_1:
        type: Cloud.SecurityGroup
        properties:
          constraints:
            - tag: "sg:RiskyBusiness"
          securityGroupType: existing
      Cloud_Machine_1:
        type: Cloud.Machine
        properties:
          image: CentOS7
          flavor: Small
          networks:
            - network: "$${resource.Cloud_NSX_Network_1.id}"
              securityGroups:
                - "$${resource.Cloud_SecurityGroup_1.id}"
          customizationSpec: custSpec-CentOS7
          tags:
            - key: protection
              value: bkupnoCred
            - key: operatingSystem
              value: centOS
      Cloud_NSX_Network_1:
        type: Cloud.NSX.Network
        properties:
          networkType: routed
          constraints:
            - tag: "dynamicNetwork:Routed"
  EOT
}
