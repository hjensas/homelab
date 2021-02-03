source /home/centos/stackrc

openstack overcloud node provision \
	--stack overcloud \
	--output ~/overcloud-baremetal-deployed.yaml \
	~/overcloud/baremetal_deployment.yaml

