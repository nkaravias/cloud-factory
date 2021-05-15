include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  input_vars = yamldecode(file("${get_terragrunt_dir()}/input-vars.yaml"))
  inputs = merge(local.global_vars, local.input_vars)

  folder_name = basename(get_terragrunt_dir())
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-folders.git//?ref=v3.0.0"
}

inputs = {
  parent = local.inputs.platform-root-location
  names = ["${local.inputs.platform-prefix}-${local.folder_name}"]
  # names = [local.folder_name]

  set_roles = local.inputs.set_roles
  folder_admin_roles = local.inputs.folder_admin_roles
  all_folder_admins = local.inputs.all_folder_admins
}
