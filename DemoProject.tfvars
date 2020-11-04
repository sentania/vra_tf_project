url = "https://vra8.lab.sentania.net/"
zone_name = "lab-comp01-Cloud-Zone"
project_name = "Private Cloud - DemoProject (Live)"
insecure = false
priority         = 1
max_instances    = 50
cpu_limit        = 64
memory_limit_mb  = 131072
storage_limit_gb = 3072
description = "This is a project created with TF - Do Not Edit"
administrators = ["vradmins@int.sentania.net","labadmins@int.sentania.net"]
users = ["terraform@int.sentania.net"]
basename =  "vra$${####}"
