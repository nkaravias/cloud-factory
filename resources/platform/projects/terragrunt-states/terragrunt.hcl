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
  source = "git::git@github.com:terraform-google-modules/terraform-google-project-factory.git//modules/core_project_factory?ref=v10.3.2"
}

dependency "parent_folder" {
  config_path = "../../folders/root"

  mock_outputs = {
    folder_id = "mock_env_folder_id"
    id = "some_id"
  }
}

inputs = {
  name = local.project_name
  random_project_id    = true
  billing_account      = local.inputs.billing_account
  org_id = local.inputs.org_id
  folder_id         = dependency.parent_folder.outputs.id
  lien = false
  enable_shared_vpc_service_project = false
  activate_apis = local.inputs.activate_apis
  labels = local.inputs.labels
}
