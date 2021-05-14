#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud network vip provision \
  --output /home/centos/overcloud-vips-deployed.yaml \
  --stack my_overcloud \
  /home/centos/overcloud/vip_data.yaml

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud-vips-deployed.yaml

