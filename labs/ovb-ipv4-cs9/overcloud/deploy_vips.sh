#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud network vip provision \
  --stack overcloud \
  --templates ~/tripleo-heat-templates \
  --output /home/cloud-user/overcloud-vips-deployed.yaml \
  /home/cloud-user/overcloud/vip_data.yaml

