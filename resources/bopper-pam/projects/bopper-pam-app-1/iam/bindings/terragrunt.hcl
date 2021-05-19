include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  tenant_vars = yamldecode(file(find_in_parent_folders("tenant-vars.yaml")))
  inputs = merge(local.global_vars, local.tenant_vars)
}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-iam.git//modules/projects_iam?ref=v7.1.0"
}

dependency "project" {
  config_path = "${dirname(dirname(get_terragrunt_dir()))}"
  mock_outputs = {
    id = "some_id"
    project_id = "some_id"
  }
}

dependency "service-accounts" {
  config_path = "../service-accounts"
  mock_outputs = {
    service_accounts_map = {}
  }
}


inputs = {
  projects = [ dependency.project.outputs.project_id ]
  mode = "additive"

  bindings = {
    "roles/logging.logWriter" = [
      "serviceAccount:${dependency.service-accounts.outputs.service_accounts_map["gkeworker-common"].email}",
      "serviceAccount:${dependency.service-accounts.outputs.service_accounts_map["gkeworker-platform"].email}"
    ],
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${dependency.service-accounts.outputs.service_accounts_map["gkeworker-common"].email}",
      "serviceAccount:${dependency.service-accounts.outputs.service_accounts_map["gkeworker-platform"].email}"
    ]
  }
}
