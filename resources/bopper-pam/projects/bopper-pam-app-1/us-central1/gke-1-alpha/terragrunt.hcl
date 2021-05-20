include {
  path = find_in_parent_folders("state.hcl")
}

locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-vars.yaml")))
  tenant_vars = yamldecode(file(find_in_parent_folders("tenant-vars.yaml")))
  region_vars = yamldecode(file(find_in_parent_folders("region-vars.yaml")))
  #input_vars = yamldecode(file("${get_terragrunt_dir()}/input-vars.yaml"))
  #inputs = merge(local.global_vars, local.tenant_vars, local.input_vars)
  inputs = merge(local.global_vars, local.tenant_vars)

}

terraform {
  source = "git::git@github.com:terraform-google-modules/terraform-google-kubernetes-engine.git//modules/private-cluster?ref=v14.3.0"
}

dependency "project" {
  config_path = "../.."
  mock_outputs = {
    project_id = "some_project_id"
  }
}

dependency "service_accounts" {
  config_path = "../../iam/service-accounts"
  mock_outputs = {
    service_accounts_map = "some_service_accounts_map"
  }
}

dependency "vpc" {
  config_path = "../../../bopper-pam-net/global/vpc-alpha"
  mock_outputs = {
    project_id = "some_project_id"
  }
}

inputs = {
  name = "${basename(get_terragrunt_dir())}-${local.region_vars.short_name}"
  project_id = dependency.project.outputs.project_id
  region = local.region_vars.name
  network = dependency.vpc.outputs.network_name
  network_project_id = dependency.vpc.outputs.project_id
  subnetwork = dependency.vpc.outputs.subnets["us-central1/gke-uc1-1"].name
  ip_range_pods              = "pods"
  ip_range_services          = "services"
  master_ipv4_cidr_block     = "172.16.0.32/28"
  default_max_pods_per_node  = 110

  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  network_policy             = true
  create_service_account     = false
  add_cluster_firewall_rules = false
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "VPC"
    },
    {
      cidr_block   = "99.239.133.126/32"
      display_name = "platform"
    },
  ]
  node_metadata            = "GKE_METADATA_SERVER"
  remove_default_node_pool	= true
#  database_encryption = [{
#    state = "ENCRYPTED",
#    key_name = "KMS key path"}
#  }]
  istio    = false
  cloudrun = false
  dns_cache         = false
  gce_pd_csi_driver = false

  #release_channel	= "REGULAR"
  kubernetes_version = "1.19.9-gke.1400"

  node_pools = [
    {
      name               = "core-1"
      machine_type       = "e2-standard-2"
      #node_locations     = "us-central1-b,us-central1-c"
      autoscaling        = false
      node_count         = 0
      #min_count          = 0
      #max_count          = 0
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = false
      service_account    = dependency.service_accounts.outputs.service_accounts_map["gkeworker-common"].email
      preemptible        = false
      initial_node_count = 1
    }
  ]


  node_pools_labels = {
    all = {}

    core-1 = {
      managed_by = "terragrunt"
    }
  }

  node_pools_metadata = {
    all = {}

    core-1  = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_tags = {
    all = [
      "generic-compute",
      "gke-compute"
    ]
    #core-1 = [
    #]
  }

#  node_pools_taints = {
#    all = []
#
#    core-1 = [
#      {
#        key    = "core-1"
#        value  = true
#        effect = "PREFER_NO_SCHEDULE"
#      },
#    ]
#  }

#  node_pools_oauth_scopes = {
#    all = []
#
#    core-1 = [
#      "https://www.googleapis.com/auth/cloud-platform",
#    ]
#  }

}

