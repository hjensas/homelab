source /home/cloud-user/stackrc

openstack overcloud node provision \
	--stack overcloud \
	--network-config \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

