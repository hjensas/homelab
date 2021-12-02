source /home/centos/stackrc

openstack overcloud node provision \
	--stack my_overcloud \
	--network-config \
	--templates ~/tripleo-heat-templates \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

