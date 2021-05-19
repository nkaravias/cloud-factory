include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  tenant_vars = yamldecode(file(find_in_parent_folders("tenant-vars.yaml")))
  input_vars = yamldecode(file("${get_terragrunt_dir()}/input-vars.yaml"))
  inputs = merge(local.global_vars, local.tenant_vars, local.input_vars)

  project_name = basename(get_terragrunt_dir())
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-project-factory.git?ref=v10.3.2"
  #source = "git::git@github.com:terraform-google-modules/terraform-google-project-factory.git//modules/core_project_factory?ref=v10.3.2"
}

dependency "parent_folder" {
  config_path = "../../folders/root"

  mock_outputs = {
    folder_id = "mock_env_folder_id"
    #id = "some_id"
  }
}

dependency "host_project"  {
  config_path = "../bopper-pam-net"

  mock_outputs = {
    id = "some_id"
    project_id = "mock_project_id"
  }
}

dependency "shared_vpc" {
  #config_path = "${dirname(dirname(get_terragrunt_dir()))}"
  config_path = "../bopper-pam-net/global/vpc-alpha"
  mock_outputs = {
    #id = "some_id"
    #project_id = "some_id"
    shared_vpc_subnets = "mock_shared_vpc_subnets"
  }
}

inputs = {
  name = local.project_name
  random_project_id    = true
  billing_account      = local.inputs.billing_account
  org_id = local.inputs.org_id
  folder_id         = dependency.parent_folder.outputs.id
  activate_apis = local.inputs.activate_apis
  create_project_sa = false
  labels = local.inputs.labels
  lien = false
  
  #enable_shared_vpc_service_project = false
  svpc_host_project_id = dependency.host_project.outputs.project_id
  shared_vpc_subnets = [ for subnet in dependency.shared_vpc.outputs.subnets: subnet.id]
  #shared_vpc_subnets = dependency.shared_vpc.outputs.subnets_self_links
}
