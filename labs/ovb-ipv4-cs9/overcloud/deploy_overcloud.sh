#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud deploy --templates /home/cloud-user/tripleo-heat-templates \
  --deployed-server \
  --disable-validations \
  -n /home/cloud-user/overcloud/network_data_v2.yaml \
  -r /home/cloud-user/overcloud/my_roles_data.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/deployed-server-environment.yaml \
  -e /home/cloud-user/overcloud-baremetal-deployed.yaml \
  -e /home/cloud-user/overcloud-networks-deployed.yaml \
  -e /home/centos/overcloud-vips-deployed.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/cloud-user/overcloud/node_data.yaml


