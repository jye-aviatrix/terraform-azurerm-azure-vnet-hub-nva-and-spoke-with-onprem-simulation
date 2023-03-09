# Create East / West Palo vNet hub
module "ew_palo_hub" {
  source              = "jye-aviatrix/panos-azure-nva/azurerm"
  version             = "1.0.9"
  palo_vm_count       = 1
  palo_vm_name        = "ewpan"
  region              = var.region
  resource_group_name = "ewpan"
  vnet_name           = "ewpan-vnet"
  vnet_cidr           = "10.0.16.0/24"
  mgmt_cidr           = "10.0.16.0/26"
  untrust_cidr        = "10.0.16.64/26"
  trust_cidr          = "10.0.16.128/26"
}

output "ew_palo" {
  value = module.ew_palo_hub
}

# Create Egress Palo vNet hub
module "egress_palo_hub" {
  source              = "jye-aviatrix/panos-azure-nva/azurerm"
  version             = "1.0.9"
  palo_vm_count       = 1
  palo_vm_name        = "egresspan"
  region              = var.region
  resource_group_name = "egresspan"
  vnet_name           = "egresspan-vnet"
  vnet_cidr           = "10.0.32.0/24"
  mgmt_cidr           = "10.0.32.0/26"
  untrust_cidr        = "10.0.32.64/26"
  trust_cidr          = "10.0.32.128/26"
}
output "egress_palo" {
  value = module.egress_palo_hub
}


# Create Resource Group for Spoke vNets
resource "azurerm_resource_group" "spoke_rg" {
  location = var.region
  name     = "spoke_rg"
}

# Create Spoke1

module "azure-vnet-spoke1" {
  source              = "jye-aviatrix/azure-vnet/azurerm"
  version             = "1.0.1"
  resource_group_name = azurerm_resource_group.spoke_rg.name
  ew_nva              = module.ew_palo_hub.ilb_ip
  egress_nva          = module.egress_palo_hub.ilb_ip
  public_key_file     = var.public_key_file
  vNet_config = {
    name          = "spoke1"
    address_space = ["10.0.100.0/24"]
    location      = azurerm_resource_group.spoke_rg.location
    subnets = {
      public = {
        address_prefixes              = ["10.0.100.0/25"]
        is_public_subnet              = true
        udr                           = true
        disable_bgp_route_propagation = true
        deploy_test_instance          = true
      }
      private = {
        address_prefixes              = ["10.0.100.128/25"]
        is_public_subnet              = false
        udr                           = true
        disable_bgp_route_propagation = true
        deploy_test_instance          = true
      }
    }
  }
}

output "spoke1" {
  value = module.azure-vnet-spoke1
}

# Create Spoke2
module "azure-vnet-spoke2" {
  source              = "jye-aviatrix/azure-vnet/azurerm"
  version             = "1.0.1"
  resource_group_name = azurerm_resource_group.spoke_rg.name
  ew_nva              = module.ew_palo_hub.ilb_ip
  egress_nva          = module.egress_palo_hub.ilb_ip
  public_key_file     = var.public_key_file
  vNet_config = {
    name          = "spoke2"
    address_space = ["10.0.101.0/24"]
    location      = azurerm_resource_group.spoke_rg.location
    subnets = {
      public = {
        address_prefixes              = ["10.0.101.0/25"]
        is_public_subnet              = true
        udr                           = true
        disable_bgp_route_propagation = true
        deploy_test_instance          = true
      }
      private = {
        address_prefixes              = ["10.0.101.128/25"]
        is_public_subnet              = false
        udr                           = true
        disable_bgp_route_propagation = true
        deploy_test_instance          = true
      }
    }
  }
}

output "spoke2" {
  value = module.azure-vnet-spoke2
}





# # Create VNG in E/W Palo Hub vNet and CSR in seperate RG/vNet. Create IPSec tunnel between CSR to VNG
# # Since this module use data to read existing vNet RG, it has to be commented out in first run. After the E/W Palo vNet gets created, then uncomment this section and run terraform apply again.
# module "vng-to-csr-ipsec-bgp" {
#   source                           = "jye-aviatrix/vng-to-csr-ipsec-bgp/azurerm"
#   version                          = "1.0.3"
#   public_key_file                  = var.public_key_file
#   vng_rg_name                      = module.ew_palo_hub.resource_group_name
#   vng_subnet_cidr                  = "10.0.16.192/27"
#   vng_vnet_name                    = module.ew_palo_hub.vnet_name
#   csr_vnet_address_space           = "10.10.0.0/24"
#   csr_public_subnet_address_space  = "10.10.0.0/25"
#   csr_private_subnet_address_space = "10.10.0.128/25"
#   csr_rg_location                  = var.region
# }

# output "csr" {
#   value = module.vng-to-csr-ipsec-bgp
# }


# # Create vNet peerings from spokes to hubs
# # Uncomment this after above VNG gets created, then run terraform apply, as the peering is looking for VNG
# resource "azurerm_virtual_network_peering" "spoke1_to_ew_palo_hub" {
#   name                      = "spoke1_to_ew_palo_hub"
#   resource_group_name       = module.azure-vnet-spoke1.resource_group_name
#   virtual_network_name      = module.azure-vnet-spoke1.vnet_name
#   remote_virtual_network_id = module.ew_palo_hub.vnet_id
#   use_remote_gateways = true
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }

# resource "azurerm_virtual_network_peering" "spoke2_to_ew_palo_hub" {
#   name                      = "spoke2_to_ew_palo_hub"
#   resource_group_name       = module.azure-vnet-spoke2.resource_group_name
#   virtual_network_name      = module.azure-vnet-spoke2.vnet_name
#   remote_virtual_network_id = module.ew_palo_hub.vnet_id
#   use_remote_gateways = true
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }

# resource "azurerm_virtual_network_peering" "spoke1_to_egress_palo_hub" {
#   name                      = "spoke1_to_egress_palo_hub"
#   resource_group_name       = module.azure-vnet-spoke1.resource_group_name
#   virtual_network_name      = module.azure-vnet-spoke1.vnet_name
#   remote_virtual_network_id = module.egress_palo_hub.vnet_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }

# resource "azurerm_virtual_network_peering" "spoke2_to_egress_palo_hub" {
#   name                      = "spoke2_to_egress_palo_hub"
#   resource_group_name       = module.azure-vnet-spoke2.resource_group_name
#   virtual_network_name      = module.azure-vnet-spoke2.vnet_name
#   remote_virtual_network_id = module.egress_palo_hub.vnet_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }


# resource "azurerm_virtual_network_peering" "ew_palo_hub_to_spoke1" {
#   name                      = "ew_palo_hub_to_spoke1"
#   resource_group_name       = module.ew_palo_hub.resource_group_name
#   virtual_network_name      = module.ew_palo_hub.vnet_name
#   remote_virtual_network_id = module.azure-vnet-spoke1.vnet_id
#   allow_gateway_transit = true
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }

# resource "azurerm_virtual_network_peering" "ew_palo_hub_to_spoke2" {
#   name                      = "ew_palo_hub_to_spoke2"
#   resource_group_name       = module.ew_palo_hub.resource_group_name
#   virtual_network_name      = module.ew_palo_hub.vnet_name
#   remote_virtual_network_id = module.azure-vnet-spoke2.vnet_id
#   allow_gateway_transit = true
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }


# resource "azurerm_virtual_network_peering" "egress_palo_hub_to_spoke1" {
#   name                      = "egress_palo_hub_to_spoke1"
#   resource_group_name       = module.egress_palo_hub.resource_group_name
#   virtual_network_name      = module.egress_palo_hub.vnet_name
#   remote_virtual_network_id = module.azure-vnet-spoke1.vnet_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }

# resource "azurerm_virtual_network_peering" "egress_palo_hub_to_spoke2" {
#   name                      = "egress_palo_hub_to_spoke2"
#   resource_group_name       = module.egress_palo_hub.resource_group_name
#   virtual_network_name      = module.egress_palo_hub.vnet_name
#   remote_virtual_network_id = module.azure-vnet-spoke2.vnet_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = false
# }