resource "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "das_datastore_cluster"
  datacenter_id = vsphere_datacenter.datacenter.moid
  sdrs_enabled  = true
}