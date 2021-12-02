#!/bin/bash

source /home/centos/stackrc
cd /home/centos


openstack overcloud network provision \
  --templates ~/tripleo-heat-templates \
  --output /home/centos/overcloud-networks-deployed.yaml \
  /home/centos/overcloud/network_data_v2.yaml 

