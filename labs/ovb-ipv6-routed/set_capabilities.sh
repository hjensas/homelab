source ~/stackrc

openstack flavor delete control

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='control' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' control

openstack flavor create \
  --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 \
  --property capabilities:boot_option='local' \
  --property capabilities:profile='compute-leaf1' \
  --property resources:CUSTOM_BAREMETAL='1' \
  --property resources:DISK_GB='0' \
  --property resources:MEMORY_MB='0' \
  --property resources:VCPU='0' compute-leaf1

openstack baremetal node set \
  --property capabilities='profile:control,boot_option:local' baremetal-ipv6-l3-leaf1_0
openstack baremetal node set \
  --property capabilities='profile:compute-leaf1,boot_option:local' baremetal-ipv6-l3-leaf2_0

