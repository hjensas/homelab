#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud network vip provision \
  --stack overcloud \
  --templates ~/tripleo-heat-templates \
  --output /home/centos/overcloud-vips-deployed.yaml \
  /home/centos/overcloud/vip_data.yaml

