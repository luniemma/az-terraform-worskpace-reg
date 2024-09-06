# terraform.tfvars
resource_group_name = "cloudmastermind-mixed-os-rg"
location            = "eastus"
vnet_name           = "cloudmastermind-mixed-os-vnet"
vnet_address_space  = ["10.0.0.0/16"]
subnet_name         = "cloudmastermind-mixed-os-subnet"
subnet_prefixes     = ["10.0.1.0/24"]
vm_name_prefix      = "cm"
admin_username      = "cloudmastermind"
admin_password      = "P@ssw0rd1234!"  # Remember to change this to a secure password