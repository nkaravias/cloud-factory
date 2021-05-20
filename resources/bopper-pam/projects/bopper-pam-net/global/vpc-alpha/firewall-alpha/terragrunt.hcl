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
  input_vars = yamldecode(file("${get_terragrunt_dir()}/input-vars.yaml"))
  inputs = merge(local.global_vars, local.tenant_vars, local.input_vars)
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-network.git//modules/firewall-rules?ref=v3.2.2"
}

dependency "vpc" {
  config_path = "${dirname(get_terragrunt_dir())}"
  mock_outputs = {
    id = "some_id"
  }
}

inputs = {
  project_id = dependency.vpc.outputs.project_id
  network_name = dependency.vpc.outputs.network_name
  rules = local.inputs.rules
#  rules = [{
#      name                    = "allow-ssh-ingress"
#      description             = null
#      direction               = "INGRESS"
#      priority                = null
#      ranges                  = ["0.0.0.0/0"]
#      source_tags             = null
#      source_service_accounts = null
#      target_tags             = null
#      target_service_accounts = null
#      allow = [{
#        protocol = "tcp"
#        ports    = ["22"]
#      }]
#      deny = []
#      log_config = {
#        metadata = "INCLUDE_ALL_METADATA"
#      }
#  }]
}
