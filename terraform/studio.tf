provider "libvirt" {
    uri = "qemu:///system"
}

variable "image_root" {}

variable "image_version" {}

variable "dev_host_count" {
    default = 1
}

resource "libvirt_volume" "vfx-studio-soe" {
    name = "vfx-studio-soe_${var.image_version}.qcow2"
    source = "${var.image_root}/vfx-studio-soe_${var.image_version}.qcow2"
}

resource "libvirt_volume" "dev" {
    name = "vfx-dev-${format("%03d", count.index + 1)}.qcow2"
    base_volume_id = "${libvirt_volume.vfx-studio-soe.id}"
    count = "${var.dev_host_count}"
}

resource "libvirt_domain" "dev" {
    name = "vfx-dev-${format("%03d", count.index + 1)}"
    vcpu = 2
    memory = 1024

    disk {
        volume_id = "${element(libvirt_volume.dev.*.id, format("%03d", count.index + 1))}"
        scsi = "true"
    }

    network_interface {
        bridge = "br0"
        mac = "02:00:00:00:00:${format("%02X", count.index + 1)}"
    }

    count = "${var.dev_host_count}"
}
