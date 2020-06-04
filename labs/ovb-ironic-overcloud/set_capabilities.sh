source ~/stackrc

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:profile='leaf1' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' leaf1

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:profile='leaf2' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' leaf2


openstack baremetal node set \
  --property capabilities='profile:control' baremetal-0

openstack baremetal node set \
  --property capabilities='profile:leaf1' baremetal-leaf1-0
openstack baremetal node set \
  --property capabilities='profile:leaf2' baremetal-leaf2-0

#
# Delete nodes on undercloud, will add them in overcloud.
#
openstack baremetal node manage baremetal-leaf1-1
openstack baremetal node manage baremetal-leaf2-1
openstack baremetal node delete baremetal-leaf1-1
openstack baremetal node delete baremetal-leaf2-1

