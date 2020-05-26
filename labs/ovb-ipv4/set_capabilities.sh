source ~/stackrc

openstack baremetal node set \
  --property capabilities='profile:control,boot_option:local' baremetal-0
openstack baremetal node set \
 --property capabilities='profile:compute,boot_option:local' baremetal-1

