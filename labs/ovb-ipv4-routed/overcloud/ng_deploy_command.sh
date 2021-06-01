openstack overcloud deploy \
  --stack ng_overcloud \
  --templates \
  --networks-file ~/overcloud/network_data_v2.yaml \
  --vip-file ~/overcloud/vip_data.yaml \
  --baremetal-deployment ~/overcloud/baremetal_deployment.yaml \
  --network-config \
  --deployed-server \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/centos/overcloud/node_data.yaml

