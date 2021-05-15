include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  tenant_vars = yamldecode(file(find_in_parent_folders("tenant-vars.yaml")))
  #input_vars = yamldecode(file("${get_terragrunt_dir()}/input-vars.yaml"))
  inputs = merge(local.global_vars, local.tenant_vars)
  #inputs = merge(local.global_vars, local.tenant_vars, local.inut_vars)

  project_name = basename(dirname(dirname(dirname(get_terragrunt_dir()))))
  #bucket_name = "${local.tfstate_buckets}-${local.tier}-infra-tfstate"
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v1.7.1"
}

dependency "project" {
  config_path = "../../../"

  // this is needed to satisfy the dependency if `parent` module is not provisioned yet
  // when running `terragrunt plan-all` from root level
  mock_outputs = {
    project_id = "mock_project_id"
  }
}

#tfstate_buckets:
#  name: platform-us-tfstate
inputs = {
  #names = ["bucketname"]
  #names = [local.inputs.tfstate_buckets["name"]]
  name = local.inputs.tfstate_buckets["name"]
  prefix = local.inputs.tenant
  project_id = dependency.project.outputs.project_id
  location = "US"
  storage_class = "STANDARD"

  #versioning = {
  #  enabled = true
  #}
  versioning = true

  lifecycle_rule = {
    action = {
      type = "Delete"
    }

    condition = {
      num_newer_versions = 3
    }
  }  
}
