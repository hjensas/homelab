# IPXE image-building tools


This directory contains tools for for building an IPXE image.

## To install the required build dependencies on a Fedora system:

```
sudo dnf install -y gcc xorriso make qemu-img syslinux-nonlinux xz-devel
```

**NOTE**: It may be necessary to use the direct libguestfs backend:

```
export LIBGUESTFS_BACKEND=direct
```

## To build the image, run the following from the root of the OVB repo:

```
make -C ipxe
```

## Upload an ipxe-boot image for the baremetal instances, for both UEFI boot and legacy BIOS boot:

```
openstack image create --progress --disk-format iso --property os_shutdown_timeout=5 --file ipxe/ipxe-boot.img ipxe-boot
openstack image create --progress --disk-format iso --property os_shutdown_timeout=5 --property hw_firmware_type=uefi --file ipxe/ipxe-boot.img ipxe-boot-uefi
```