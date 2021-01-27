# Do you intend to use ciscodevnet/aci? 
# If so, you must specify that source address in each module which requires that provider.
terraform {
 required_providers {
   aci = {
     source = "CiscoDevNet/aci"
   }
 }
}

# Tenant name is referenced from a variable in variables.tf and terraform.tfvars
resource "aci_tenant" "tnLocalName" {
  name                    = "${var.tenant_name}-${var.student_id}"
  description             = ""
}

# Networking
# Tenant DN is referenced by Resource type (aci_tenant) and Local Name (TNLocalName)
resource "aci_vrf" "vrfLocalName" {
  tenant_dn               = aci_tenant.tnLocalName.id
  name                    = var.vrf_name
}

resource "aci_bridge_domain" "bdLocalName" {
  tenant_dn               = aci_tenant.tnLocalName.id
  name                    = var.bd_name
  relation_fv_rs_ctx      = aci_vrf.vrfLocalName.id
}

# L3Out
resource "aci_l3_outside" "l3outLocalName" {
  tenant_dn               = aci_tenant.tnLocalName.id
  name                    = var.l3out_name
  relation_l3ext_rs_ectx  = aci_vrf.vrfLocalName.id
}

resource "aci_external_network_instance_profile" "exEpgLocalName" {
  l3_outside_dn           = aci_l3_outside.l3outLocalName.id
  name                    = var.exepg_name
}

resource "aci_logical_node_profile" "nodePLocalName" {
  l3_outside_dn           = aci_l3_outside.l3outLocalName.id
  name                    = "${var.l3out_name}_nodeProfile"
}

resource "aci_logical_node_to_fabric_node" "nodeLocalName" {
  logical_node_profile_dn = aci_logical_node_profile.nodePLocalName.id
  tdn                     = "topology/pod-1/node-111"
  rtr_id                  = "1.1.1.1"
  rtr_id_loop_back        = "yes"
}

resource "aci_logical_interface_profile" "intPLocalName" {
  logical_node_profile_dn = aci_logical_node_profile.nodePLocalName.id
  name                    = "${var.l3out_name}_interfaceProfile"
}      

resource "aci_rest" "rest1LocalName" {
  path       = "/api/node/mo/uni/tn-${var.tenant_name}-${var.student_id}/out-${var.l3out_name}/lnodep-${var.l3out_name}_nodeProfile/lifp-${var.l3out_name}_interfaceProfile/rspathL3OutAtt-[topology/pod-1/paths-111/pathep-[eth1/1]].json"
  class_name = "l3extRsPathL3OutAtt"
  content = {
    "addr" = "2.2.2.2/24"
    "encap" = "vlan-5${var.student_id}"
    "ifInstT" = "ext-svi"
  }
  depends_on = [
  aci_logical_interface_profile.intPLocalName,
  ]
}

# Application Profile
resource "aci_application_profile" "apLocalName" {
  name                    = var.ap_name
  tenant_dn               = aci_tenant.tnLocalName.id
}

resource "aci_application_epg" "epgFeLocalName" {
  application_profile_dn  = aci_application_profile.apLocalName.id
  name                    = var.epg_name1
  relation_fv_rs_bd       = aci_bridge_domain.bdLocalName.id
}

resource "aci_application_epg" "epgBeLocalName" {
  application_profile_dn  = aci_application_profile.apLocalName.id
  name                    = var.epg_name2
  relation_fv_rs_bd       = aci_bridge_domain.bdLocalName.id
}


