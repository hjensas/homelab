source /home/stack/overcloudrc

mkdir -r /home/stack/oc-images
curl -O https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
curl -O https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2
curl -O https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20220125.0.x86_64.qcow2
curl -O https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20210603.0.x86_64.qcow2

openstack image create --public --disk-format qcow2 --file CentOS-7-x86_64-GenericCloud.qcow2 CentOS-7-x86_64-GenericCloud
openstack image create --public --disk-format qcow2 --file CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2 CentOS-8-x86_64-GenericCloud
openstack image create --public --disk-format qcow2 --file CentOS-Stream-GenericCloud-8-20210603.0.x86_64.qcow2 CentOS-Stream-GenericCloud-8
openstack image create --public --disk-format qcow2 --file CentOS-Stream-GenericCloud-9-20220125.0.x86_64.qcow2 CentOS-Stream-GenericCloud-9

