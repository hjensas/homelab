#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud deploy --stack overcloud \
  --deployed-server \
  -n /home/cloud-user/overcloud/network_data_v2.yaml \
  -r /home/cloud-user/overcloud/my_roles_data.yaml \
  -e /home/cloud-user/overcloud-baremetal-deployed.yaml \
  -e /home/cloud-user/overcloud-networks-deployed.yaml \
  -e /home/cloud-user/overcloud-vips-deployed.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/cloud-user/overcloud/node_data.yaml

