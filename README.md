# terraform-azurerm-azure-vnet-hub-nva-and-spoke-with-onprem-simulation

- This module create two hub vNets with Palo Alto VM deployed for E/W and Egress Firewall
- This module deploy VNG in the E/W vNet to simulate on-prem connectivity to a CSR in a different Resource Group/vNet, with test instance deployed.
- Spoke vNets are deployed with test instances and peer with the two hub vNets


## Architecture
![Architecture](https://raw.githubusercontent.com/jye-aviatrix/terraform-azurerm-azure-vnet-hub-nva-and-spoke-with-onprem-simulation/master/20230303192646.png)

## Tested environment

```
Terraform v1.3.7
on linux_amd64
+ provider registry.terraform.io/hashicorp/azurerm v3.46.0
+ provider registry.terraform.io/hashicorp/http v3.2.1
+ provider registry.terraform.io/hashicorp/local v2.3.0
+ provider registry.terraform.io/hashicorp/random v3.4.3
```

## Run terraform apply in three phrases
> **IMPORTANT!**  
- Phrase one, in main.tf, before line 120, we are creating E/W Palo vNet, Egress vNet and Spoke vNets first
- Phrase two, after first terraform apply, uncomment line 120 to 137, then run terraform apply again. This section of code use data to read vNet/RG created by first portion of code. Hence need to be run after the first portion is complete
- Phrase three, after second terraform apply, uncomment line 140 to end, then run terraform apply once more. This last section create vNet peering and it's looing for VNG created by phrase two


## Estimated cost

```
Name                                                                                                         Monthly Qty  Unit                      Monthly Cost

 azurerm_virtual_network_peering.egress_palo_hub_to_spoke1
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.egress_palo_hub_to_spoke2
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.ew_palo_hub_to_spoke1
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.ew_palo_hub_to_spoke2
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.spoke1_to_egress_palo_hub
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.spoke1_to_ew_palo_hub
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.spoke2_to_egress_palo_hub
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 azurerm_virtual_network_peering.spoke2_to_ew_palo_hub
 ├─ Inbound data transfer                                                                              Monthly cost depends on usage: $0.01 per GB
 └─ Outbound data transfer                                                                             Monthly cost depends on usage: $0.01 per GB

 module.azure-vnet-spoke1.module.azure-linux-vm-private["private"].azurerm_linux_virtual_machine.this
 ├─ Instance usage (pay as you go, Standard_B1s)                                                                      730  hours                            $7.59
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.azure-vnet-spoke1.module.azure-linux-vm-public["public"].azurerm_linux_virtual_machine.this
 ├─ Instance usage (pay as you go, Standard_B1s)                                                                      730  hours                            $7.59
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.azure-vnet-spoke1.module.azure-linux-vm-public["public"].azurerm_public_ip.this
 └─ IP address (static)                                                                                               730  hours                            $0.00

 module.azure-vnet-spoke2.module.azure-linux-vm-private["private"].azurerm_linux_virtual_machine.this
 ├─ Instance usage (pay as you go, Standard_B1s)                                                                      730  hours                            $7.59
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.azure-vnet-spoke2.module.azure-linux-vm-public["public"].azurerm_linux_virtual_machine.this
 ├─ Instance usage (pay as you go, Standard_B1s)                                                                      730  hours                            $7.59
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.azure-vnet-spoke2.module.azure-linux-vm-public["public"].azurerm_public_ip.this
 └─ IP address (static)                                                                                               730  hours                            $0.00

 module.egress_palo_hub.azurerm_lb.this
 └─ Data processed                                                                                     Monthly cost depends on usage: $0.00 per GB

 module.egress_palo_hub.azurerm_lb_rule.this
 └─ Rule usage                                                                                                        730  hours                            $0.00

 module.egress_palo_hub.azurerm_storage_account.palo_bootstrap
 ├─ Capacity                                                                                           Monthly cost depends on usage: $0.0208 per GB
 ├─ List and create container operations                                                               Monthly cost depends on usage: $0.05 per 10k operations
 ├─ Read operations                                                                                    Monthly cost depends on usage: $0.004 per 10k operations
 ├─ All other operations                                                                               Monthly cost depends on usage: $0.004 per 10k operations
 └─ Blob index                                                                                         Monthly cost depends on usage: $0.03 per 10k tags

 module.egress_palo_hub.module.palo_byol[0].azurerm_linux_virtual_machine.palo_byol
 ├─ Instance usage (pay as you go, Standard_D3_v2)                                                                    730  hours                          $213.89
 └─ os_disk
    ├─ Storage (E4)                                                                                                     1  months                           $2.40
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.002 per 10k operations

 module.egress_palo_hub.module.palo_byol[0].azurerm_public_ip.mgmt_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.egress_palo_hub.module.palo_byol[0].azurerm_public_ip.untrust_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.ew_palo_hub.azurerm_lb.this
 └─ Data processed                                                                                     Monthly cost depends on usage: $0.00 per GB

 module.ew_palo_hub.azurerm_lb_rule.this
 └─ Rule usage                                                                                                        730  hours                            $0.00

 module.ew_palo_hub.azurerm_storage_account.palo_bootstrap
 ├─ Capacity                                                                                           Monthly cost depends on usage: $0.0208 per GB
 ├─ List and create container operations                                                               Monthly cost depends on usage: $0.05 per 10k operations
 ├─ Read operations                                                                                    Monthly cost depends on usage: $0.004 per 10k operations
 ├─ All other operations                                                                               Monthly cost depends on usage: $0.004 per 10k operations
 └─ Blob index                                                                                         Monthly cost depends on usage: $0.03 per 10k tags

 module.ew_palo_hub.module.palo_byol[0].azurerm_linux_virtual_machine.palo_byol
 ├─ Instance usage (pay as you go, Standard_D3_v2)                                                                    730  hours                          $213.89
 └─ os_disk
    ├─ Storage (E4)                                                                                                     1  months                           $2.40
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.002 per 10k operations

 module.ew_palo_hub.module.palo_byol[0].azurerm_public_ip.mgmt_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.ew_palo_hub.module.palo_byol[0].azurerm_public_ip.untrust_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.vng-to-csr-ipsec-bgp.azurerm_linux_virtual_machine.csr
 ├─ Instance usage (pay as you go, Standard_B2ms)                                                                     730  hours                           $60.74
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.vng-to-csr-ipsec-bgp.azurerm_public_ip.csr_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.vng-to-csr-ipsec-bgp.azurerm_public_ip.vng_pip
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.vng-to-csr-ipsec-bgp.azurerm_public_ip.vng_pip_ha
 └─ IP address (static)                                                                                               730  hours                            $3.65

 module.vng-to-csr-ipsec-bgp.azurerm_virtual_network_gateway.vng
 ├─ VPN gateway (VpnGw2AZ)                                                                                            730  hours                          $411.72
 ├─ VPN gateway P2S tunnels (over 128)                                                                 Monthly cost depends on usage: $7.30 per tunnel
 └─ VPN gateway data tranfer                                                                           Monthly cost depends on usage: $0.035 per GB

 module.vng-to-csr-ipsec-bgp.azurerm_virtual_network_gateway_connection.to_csr
 └─ VPN gateway (VpnGw2AZ)                                                                                            730  hours                           $10.95

 module.vng-to-csr-ipsec-bgp.module.azure-linux-vm-public.azurerm_linux_virtual_machine.this
 ├─ Instance usage (pay as you go, Standard_B1s)                                                                      730  hours                            $7.59
 └─ os_disk
    ├─ Storage (S4)                                                                                                     1  months                           $1.54
    └─ Disk operations                                                                                 Monthly cost depends on usage: $0.0005 per 10k operations

 module.vng-to-csr-ipsec-bgp.module.azure-linux-vm-public.azurerm_public_ip.this
 └─ IP address (static)                                                                                               730  hours                            $0.00

 OVERALL TOTAL                                                                                                                                            $988.71
```

## Reference:
- This module deploy Azure vNet, subnet and route tables, you may seletive deploy test instance in the subnet.

   https://github.com/jye-aviatrix/terraform-azurerm-azure-vnet

- This Repo will create Palo Alto Networks VM-Series firewalls in Azure, it will also bootstrap the Firewall, as well as provision Azure Internal Load Balancer.

   https://github.com/jye-aviatrix/terraform-azurerm-panos-azure-nva

- This module deploy Azure VNG to existing vNet. It will also deploy Cisco CSR to a new vNet simulate on-prem environment. IPSec/ BGP Site to Site will be established between CSR and VNG.

   https://github.com/jye-aviatrix/terraform-azurerm-vng-to-csr-ipsec-bgp


