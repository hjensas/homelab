source /home/cloud-user/stackrc

openstack overcloud node provision \
	--stack my_overcloud \
	--network-config \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/cloud-user/tripleo-heat-templates|g' /home/cloud-user/overcloud-baremetal-deployed.yaml
