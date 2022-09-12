source ~/stackrc

openstack baremetal node set \
  --property capabilities='profile:control,boot_option:local' baremetal-ipv6-l3-leaf1-0
openstack baremetal node set \
  --property capabilities='profile:compute-leaf2,boot_option:local' baremetal-ipv6-l3-leaf2-0

