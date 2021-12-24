provider "vsphere" {
  allow_unverified_ssl = true
  # Use environment variables to configure the vsphere provider
  # VSPHERE_USER
  # VSPHERE_PASSWORD
  # VSPHERE_SERVER
}

# Datacenter
resource "vsphere_datacenter" "datacenter" {
  name = "Datacenter"
}

resource "vsphere_compute_cluster" "compute_cluster" {
  name          = "Wells"
  datacenter_id = vsphere_datacenter.datacenter.moid
  host_managed  = true

  drs_enabled          = true
  drs_automation_level = "fullyAutomated"

  ha_enabled = true
}

# Hosts
resource "vsphere_host" "cluster_hosts" {
  for_each = { for i in var.cluster_hosts : i.name => i }
  hostname = each.value.ip
  username = each.value.user
  password = each.value.password
  license  = var.licenses.esxi
  cluster    = vsphere_compute_cluster.compute_cluster.id
  thumbprint = each.value.thumbprint
}

resource "vsphere_host" "standalone_hosts" {
  for_each = { for i in var.standalone_hosts : i.name => i }
  hostname = each.value.ip
  username = each.value.user
  password = each.value.password
  license  = var.licenses.esxi
  datacenter = vsphere_datacenter.datacenter.moid
  thumbprint = each.value.thumbprint
}

# Resource Pools
resource "vsphere_resource_pool" "tkg" {
  name                    = "tkg"
  parent_resource_pool_id = vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_resource_pool" "hashistack" {
  name                    = "hashistack"
  parent_resource_pool_id = vsphere_compute_cluster.compute_cluster.resource_pool_id
}

# Folders
resource "vsphere_folder" "tkg_folder" {
  path          = "tkg"
  type          = "vm"
  datacenter_id = vsphere_datacenter.datacenter.moid
}

resource "vsphere_folder" "bastion_folder" {
  path          = "bastion"
  type          = "vm"
  datacenter_id = vsphere_datacenter.datacenter.moid
}
