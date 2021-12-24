resource "vsphere_license" "vcenter" {
  license_key = var.licenses.vcenter
}

resource "vsphere_license" "vsan" {
  license_key = var.licenses.vsan
}

resource "vsphere_license" "esxi" {
  license_key = var.licenses.esxi
}

resource "vsphere_license" "tanzu" {
  license_key = var.licenses.tanzu
}
