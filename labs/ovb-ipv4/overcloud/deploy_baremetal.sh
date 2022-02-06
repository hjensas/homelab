source /home/centos/stackrc

openstack overcloud node provision \
  --stack overcloud \
  --output ~/overcloud-baremetal-deployed.yaml \
  --templates /home/centos/tripleo-heat-templates \
  ~/overcloud/baremetal_deployment.yaml

