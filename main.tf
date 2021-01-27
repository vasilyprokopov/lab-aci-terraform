# Do you intend to use ciscodevnet/aci? 
# If so, you must specify that source address in each module which requires that provider.
terraform {
 required_providers {
   aci = {
     source = "CiscoDevNet/aci"
   }
 }
}

# This is how Provider is added to TF. After it has been announced, TF will download required Provider code
# Provider supports password-based and certificate-based authentication
# private_key refers to a private key file in the project folder
# cert_name refers to a certificate name that you configure on APIC for particular user

provider "aci" {
        username    = "user"
        password    = "pass"
        url         = "https://1.1.1.1"
        insecure    = true
}

module "aci_tenant" {
  source = "./modules/aci_tenant"

  # Input variables (also defined in the module directory)

  # Terraform will run the module as many times as there are student_id values in terraform.tfvars
  for_each                = var.student_id
  student_id              = each.value
  
  tenant_name             = "TENANT"
  ap_name                 = "AP-01"
  epg_name1               = "EPG-FE"
  epg_name2               = "EPG-BE"
  vrf_name                = "VRF-01"
  bd_name                 = "BD-01"
  l3out_name              = "L3OUT-01"
  exepg_name              = "EXEPG-01"
}