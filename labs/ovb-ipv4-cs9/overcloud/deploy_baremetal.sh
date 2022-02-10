source /home/cloud-user/stackrc

openstack overcloud node provision \
  --stack overcloud \
  --templates /home/cloud-user/tripleo-heat-templates \
  --output ~/overcloud-baremetal-deployed.yaml \
  ~/overcloud/baremetal_deployment.yaml

