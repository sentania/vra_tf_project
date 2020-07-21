url = "https://vra8.lab.sentania.net/"
zone_name = "WLD 1 / lab-vcf-w01-DC"
project_name = "Demo Terraform Project"
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
network_domain_name = "overlay-tz-lab-vcf-w01-nsx01.lab.sentania.net"
cloud_account = "lab-vcf-w01-vc"
region = "lab-vcf-w01-DC"
cidr_prefix = "27"
cidr = "10.205.0.0/16"
subnet_name = "w01-netseg01"
compliance = "pci"
environment = "demoProject"
blueprint_name = "Demo Project Blueprint"