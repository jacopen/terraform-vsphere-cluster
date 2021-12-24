# dPlane

resource "vsphere_distributed_virtual_switch" "vsan_vmotion" {
  name          = "dPlane"
  datacenter_id = vsphere_datacenter.datacenter.moid
  version       = "7.0.2"

  dynamic "host" {
    for_each = { for i in var.cluster_hosts : i.name => i }
    content {
      host_system_id = vsphere_host.cluster_hosts[host.key].id
      devices        = [host.value.vsan_nic]
    }
  }
}

resource "vsphere_distributed_port_group" "vsan_vmotion" {
  name                            = "vsan-pg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.vsan_vmotion.id
  number_of_ports                 = 32
}

resource "vsphere_vnic" "vsan_vmotion" {
  for_each                = { for i in var.cluster_hosts : i.name => i }
  host                    = vsphere_host.cluster_hosts[each.key].id
  distributed_switch_port = vsphere_distributed_virtual_switch.vsan_vmotion.id
  distributed_port_group  = vsphere_distributed_port_group.vsan_vmotion.id
  ipv4 {
    ip      = split("/", each.value.vsan_cidr)[0]
    netmask = cidrnetmask(each.value.vsan_cidr)
    gw = cidrhost(each.value.vsan_cidr, 1)
  }
  depends_on = [vsphere_distributed_virtual_switch.vsan_vmotion]
}

# cPlane

resource "vsphere_distributed_virtual_switch" "cplane" {
  name          = "cPlane"
  datacenter_id = vsphere_datacenter.datacenter.moid
  version       = "7.0.2"

  dynamic "host" {
    for_each = { for i in var.cluster_hosts : i.name => i }
    content {
      host_system_id = vsphere_host.cluster_hosts[host.key].id
      devices        = [host.value.cplane_nic]
    }
  }
}

resource "vsphere_distributed_port_group" "service" {
  name                            = "service"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.cplane.id
  type = "ephemeral"
  vlan_id = "101"
  auto_expand = false
}

resource "vsphere_distributed_port_group" "tkg" {
  name                            = "tkg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.cplane.id
  type = "ephemeral"
  vlan_id = "102"
  auto_expand = false
}

resource "vsphere_distributed_port_group" "airgapped" {
  name                            = "airgapped"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.cplane.id
  type = "ephemeral"
  vlan_id = "103"
  auto_expand = false
}

resource "vsphere_distributed_port_group" "workload" {
  name                            = "workload"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.cplane.id
  type = "ephemeral"
  vlan_id = "104"
  auto_expand = false
}
