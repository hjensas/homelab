source /home/centos/stackrc

openstack overcloud node provision \
	--stack overcloud \
	--network-ports \
	--network-config \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

