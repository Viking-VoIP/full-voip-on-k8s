module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.gcp_project_id
  name                       = var.gcp_cluster_name
  region                     = var.gcp_region
  regional                   = var.gcp_is_regional
  zones                      = ["${var.gcp_zone}"]
  network                    = var.gcp_network_name
  subnetwork                 = var.gcp_subnetwork_name
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false
  ip_range_pods              = ""
  ip_range_services          = ""


  node_pools = [
    {
      name                      = "support-node-pool"
      machine_type              = var.gks_workers.support.machine_type
      min_count                 = var.gks_workers.support.min_capacity
      max_count                 = var.gks_workers.support.max_capacity
      local_ssd_count           = 0
      disk_size_gb              = var.gks_workers.support.disk_size
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.gcp_service_account
      preemptible               = false
      initial_node_count        = var.gks_workers.support.min_capacity
    },
    {
      name                      = "backend-node-pool"
      machine_type              = var.gks_workers.backend.machine_type
      min_count                 = var.gks_workers.backend.min_capacity
      max_count                 = var.gks_workers.backend.max_capacity
      local_ssd_count           = 0
      disk_size_gb              = var.gks_workers.backend.disk_size
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.gcp_service_account
      preemptible               = false
      initial_node_count        = var.gks_workers.backend.min_capacity
    },
    {
      name                      = "sip-b2bua-node-pool"
      machine_type              = var.gks_workers.sip-b2bua.machine_type
      min_count                 = var.gks_workers.sip-b2bua.min_capacity
      max_count                 = var.gks_workers.sip-b2bua.max_capacity
      local_ssd_count           = 0
      disk_size_gb              = var.gks_workers.sip-b2bua.disk_size
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.gcp_service_account
      preemptible               = false
      initial_node_count        = var.gks_workers.sip-b2bua.min_capacity
    },
    {
      name                      = "sip-proxy-node-pool"
      machine_type              = var.gks_workers.sip-proxy.machine_type
      min_count                 = var.gks_workers.sip-proxy.min_capacity
      max_count                 = var.gks_workers.sip-proxy.max_capacity
      local_ssd_count           = 0
      disk_size_gb              = var.gks_workers.sip-proxy.disk_size
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.gcp_service_account
      preemptible               = false
      initial_node_count        = var.gks_workers.sip-proxy.min_capacity
    }
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}
    support-node-pool = { application = "support" }
    backend-node-pool = { application = "backend" }
    sip-proxy-node-pool = { application = "proxy" }
    sip-b2bua-node-pool = { application = "b2bua" }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}