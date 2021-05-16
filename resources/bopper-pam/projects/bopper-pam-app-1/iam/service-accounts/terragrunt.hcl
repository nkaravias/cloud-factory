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
  source = "git::git@github.com:terraform-google-modules/terraform-google-service-accounts.git?ref=v4.0.0"
}

dependency "project" {
  config_path = "${dirname(dirname(get_terragrunt_dir()))}"

  // this is needed to satisfy the dependency if `parent` module is not provisioned yet
  // when running `terragrunt plan-all` from root level
  mock_outputs = {
    project_id = "some_project_id"
  }
}

inputs = {
  names = local.inputs.service-accounts
  project_id = dependency.project.outputs.project_id
}
