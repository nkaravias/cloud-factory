locals {
  tenant_vars = yamldecode(file("platform/tenant-vars.yaml"))

  #tenant = basename(get_parent_terragrunt_dir())
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = local.tenant_vars.tfstate_buckets["name"]
    prefix = "${path_relative_to_include()}"
  }
}
