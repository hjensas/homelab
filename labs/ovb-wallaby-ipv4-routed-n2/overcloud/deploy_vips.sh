#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud network vip provision \
  --output /home/cloud-user/overcloud-vips-deployed.yaml \
  --stack my_overcloud \
  /home/cloud-user/overcloud/vip_data.yaml

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/cloud-user/tripleo-heat-templates|g' /home/cloud-user/overcloud-vips-deployed.yaml

