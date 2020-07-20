url = "https://vra8.lab.sentania.net/"
zone_name = "WLD 1 / lab-vcf-w01-DC"
project_name = "Production Non-PCI"
insecure = false
priority         = 1
max_instances    = 50
cpu_limit        = 64
memory_limit_mb  = 131072
storage_limit_gb = 3072
description = "This is a project created with TF"
administrators = ["vradmins@int.sentania.net","labadmins@int.sentania.net"]
users = ["terraform@int.sentania.net"]
basename =  "$${project.name}-$${userName}-$${####}"
subnet_name = "w01-netseg03"
security_group_name = "Production Non-PCI"
network_region "WLD-NSX"
