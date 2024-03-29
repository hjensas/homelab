#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud network vip provision \
  --output /home/centos/overcloud-vips-deployed.yaml \
  --stack overcloud \
  --templates /home/centos/tripleo-heat-templates \
  /home/centos/overcloud/vip_data.yaml

