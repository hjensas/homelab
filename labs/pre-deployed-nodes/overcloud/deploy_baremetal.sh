source /home/centos/stackrc

openstack overcloud node provision \
	--stack my_overcloud \
	--network-ports \
	--network-config \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud-baremetal-deployed.yaml
