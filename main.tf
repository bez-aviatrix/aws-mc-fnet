terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      #version = "2.21.0"
    }
  }
}

provider "aviatrix" {
}

module "bootstrap" {
  source = "./modules/bootstrap"
}

module "mc_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.0"

  name                   = var.name
  cloud                  = var.cloud
  region                 = var.region
  cidr                   = var.cidr
  account                = var.account
  enable_transit_firenet = true
  tags                   = var.tags
}

module "mc_firenet" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "1.0.0"

  transit_module          = module.mc_transit
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version  = var.fw_version
  bootstrap_bucket_name_1 = module.bootstrap.bootstrap_bucket_name
  iam_role_1              = module.bootstrap.bootstrap_iam_role

  depends_on = [
    module.bootstrap
  ]
}


module "spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  count = length(var.sp_name)

  cloud      = var.cloud
  name       = var.sp_name[count.index]
  cidr       = cidrsubnet(var.sp_cidr, 3, count.index)
  region     = var.sp_region[count.index]
  account    = var.account
  transit_gw = module.mc_transit.transit_gateway.gw_name
  tags       = var.tags
}

resource "aviatrix_transit_firenet_policy" "default" {
  count = 2
  transit_firenet_gateway_name = module.mc_transit.transit_gateway.gw_name
  inspected_resource_name      = "SPOKE:${module.spoke[count.index].spoke_gateway.gw_name}"
}