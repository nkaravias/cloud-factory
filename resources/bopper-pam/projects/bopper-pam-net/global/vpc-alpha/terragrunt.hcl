## Pods / Services x2 - R1 & R2
# https://www.davidc.net/sites/default/subnets/subnets.html?network=10.100.0.0&mask=17&division=13.7a20

## Nodes - Core & GKE1/2 - R1 & R2
# https://www.davidc.net/sites/default/subnets/subnets.html?network=10.117.0.0&mask=17&division=15.7231

## Master / Peered 2x - R1 & R2
# https://www.davidc.net/sites/default/subnets/subnets.html?network=172.16.0.0&mask=26&division=7.31
# 172.16.0.0/26 2x - R1 & R2

include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  tenant_vars = yamldecode(file(find_in_parent_folders("tenant-vars.yaml")))
  inputs = merge(local.global_vars, local.tenant_vars)
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-network.git?ref=v3.2.2"
}

dependency "project" {
  config_path = "${dirname(dirname(get_terragrunt_dir()))}"
  mock_outputs = {
    id = "some_id"
  }
}

inputs = {
  project_id = dependency.project.outputs.project_id
  #network_name = "alpha"
  network_name = "${basename(get_terragrunt_dir())}"
  routing_mode = "GLOBAL"

  subnets = [
  {
    subnet_name           = "core-ue4"
    subnet_ip             = "10.117.0.0/20"
    subnet_region         = "us-east4"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name           = "gke-ue4-1"
    subnet_ip             = "10.117.16.0/20"
    subnet_region         = "us-east4"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name           = "gke-ue4-2"
    subnet_ip             = "10.117.32.0/20"
    subnet_region         = "us-east4"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name           = "core-uc1"
    subnet_ip             = "10.117.64.0/20"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name           = "gke-uc1-1"
    subnet_ip             = "10.117.80.0/20"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  {
    subnet_name           = "gke-uc1-2"
    subnet_ip             = "10.117.96.0/20"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
  },
  ]

  secondary_ranges = {
    core-ue4 = [],
    gke-ue4-1 = [
    {
	range_name    = "pods"
	ip_cidr_range = "10.100.0.0/20"
    },
    {
	range_name    = "services"
	ip_cidr_range = "10.100.56.0/22"
    }
    ],
    gke-ue4-2 = [
    {
	range_name    = "pods"
	ip_cidr_range = "10.100.16.0/20"
    },
    {
	range_name    = "services"
	ip_cidr_range = "10.100.60.0/22"
    }
    ],
    core-uc1 = [],
    gke-uc1-1 = [
    {
	range_name    = "pods"
	ip_cidr_range = "10.100.64.0/20"
    },
    {
	range_name    = "services"
	ip_cidr_range = "10.100.120.0/22"
    }
    ],
    gke-uc1-2 = [
    {
	range_name    = "pods"
	ip_cidr_range = "10.100.80.0/20"
    },
    {
	range_name    = "services"
	ip_cidr_range = "10.100.124.0/22"
    }
    ]
  }
}
