source ~/stackrc

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='control-leaf1' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' control-leaf1

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='compute-leaf1' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' compute-leaf1

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='compute-leaf2' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' compute-leaf2

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='ceph-leaf2' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' ceph-leaf2


openstack baremetal node set \
  --property capabilities='profile:control-leaf1,boot_option:local' baremetal-leaf1-0
openstack baremetal node set \
 --property capabilities='profile:compute-leaf1,boot_option:local' baremetal-leaf1-1

openstack baremetal node set \
  --property capabilities='profile:compute-leaf2,boot_option:local' baremetal-leaf2-0
openstack baremetal node set \
  --property capabilities='profile:compute-leaf2,boot_option:local' baremetal-leaf2-1

# openstack baremetal node set \
#   --property capabilities='profile:ceph-leaf2,boot_option:local' baremetal-leaf2-0
# openstack baremetal node set \
#   --property capabilities='profile:ceph-leaf2,boot_option:local' baremetal-leaf2-1

