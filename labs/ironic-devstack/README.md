sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo su -
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudu su - stack

git clone https://opendev.org/openstack/devstack.git

IP_ADDR=$()

local.conf
----------

::

  [[local|localrc]]
  disable_all_services
  disable_service c-api
  disable_service c-bak
  disable_service c-sch
  disable_service c-vol
  disable_service cinder
  disable_service dstat
  enable_service etcd3
  enable_service g-api
  enable_service generic_switch
  disable_service horizon
  enable_service ir-neutronagt
  enable_service key
  enable_service memory_tracker
  enable_service mysql
  enable_service n-api
  enable_service n-api-meta
  enable_service n-cond
  enable_service n-cpu
  enable_service n-novnc
  enable_service n-sch
  enable_service networking_baremetal
  disable_service neutron-agent
  disable_service neutron-api
  disable_service neutron-dhcp
  disable_service neutron-l3
  disable_service neutron-metadata-agent
  disable_service neutron-metering
  disable_service ovn-controller
  disable_service ovn-northd
  enable_service ovs-vswitchd
  enable_service ovsdb-server
  enable_service placement-api
  enable_service q-agt
  enable_service q-dhcp
  enable_service q-l3
  enable_service q-meta
  enable_service q-metering
  disable_service q-ovn-metadata-agent
  enable_service q-svc
  enable_service rabbit
  enable_service s-account
  enable_service s-container
  enable_service s-object
  enable_service s-proxy
  enable_service tempest
  enable_service tls-proxy
  ADMIN_PASSWORD="secretadmin"
  API_WORKERS="1"
  BUILD_TIMEOUT="2400"
  DATABASE_PASSWORD="secretdatabase"
  DEBUG_LIBVIRT_COREDUMPS="True"
  DEFAULT_INSTANCE_TYPE="baremetal"
  EBTABLES_RACE_FIX="True"
  ENABLE_TENANT_VLANS="True"
  FIXED_RANGE="10.1.0.0/20"
  FLOATING_RANGE="172.24.5.0/24"
  FORCE_CONFIG_DRIVE="False"
  GLANCE_LIMIT_IMAGE_SIZE_TOTAL="5000"
  HOST_IP="127.0.0.1"
  INSTALL_TEMPEST="False"
  IPV4_ADDRS_SAFE_TO_USE="10.1.0.0/20"
  IRONIC_AUTOMATED_CLEAN_ENABLED="False"
  IRONIC_BAREMETAL_BASIC_OPS="True"
  IRONIC_BUILD_DEPLOY_RAMDISK="False"
  IRONIC_CALLBACK_TIMEOUT="1800"
  IRONIC_DEFAULT_DEPLOY_INTERFACE="direct"
  IRONIC_DEFAULT_RESCUE_INTERFACE=""
  IRONIC_DEPLOY_DRIVER="ipmi"
  IRONIC_ENABLED_NETWORK_INTERFACES="flat,neutron"
  IRONIC_INSPECTOR_BUILD_RAMDISK="False"
  IRONIC_INSPECTOR_TEMPEST_INTROSPECTION_TIMEOUT="1200"
  IRONIC_NETWORK_INTERFACE="neutron"
  IRONIC_PROVISION_NETWORK_NAME="ironic-provision"
  IRONIC_PROVISION_PROVIDER_NETWORK_TYPE="vlan"
  IRONIC_PROVISION_SUBNET_GATEWAY="10.0.5.1"
  IRONIC_PROVISION_SUBNET_PREFIX="10.0.5.0/24"
  IRONIC_TEMPEST_BUILD_TIMEOUT="2400"
  IRONIC_TEMPEST_WHOLE_DISK_IMAGE="True"
  IRONIC_USE_LINK_LOCAL="True"
  IRONIC_USE_NEUTRON_SEGMENTS="True"
  IRONIC_VM_COUNT="3"
  IRONIC_VM_EPHEMERAL_DISK="0"
  IRONIC_VM_LOG_DIR="/opt/stack/ironic-bm-logs"
  IRONIC_VM_SPECS_CPU="2"
  IRONIC_VM_SPECS_DISK="4"
  IRONIC_VM_SPECS_RAM="2600"
  LIBVIRT_TYPE="qemu"
  LOGFILE="/opt/stack/logs/devstacklog.txt"
  LOG_COLOR="False"
  NETWORK_GATEWAY="10.1.0.1"
  NOVA_VNC_ENABLED="True"
  NOVNC_FROM_PACKAGE="True"
  OVN_DBS_LOG_LEVEL="dbg"
  OVS_BRIDGE_MAPPINGS="mynetwork:brbm,public:br-ex"
  OVS_PHYSICAL_BRIDGE="brbm"
  PHYSICAL_NETWORK="mynetwork"
  PUBLIC_BRIDGE_MTU="1430"
  PUBLIC_NETWORK_GATEWAY="172.24.5.1"
  PUBLIC_PHYSICAL_NETWORK="public"
  Q_AGENT="openvswitch"
  Q_ML2_PLUGIN_MECHANISM_DRIVERS="openvswitch"
  Q_ML2_TENANT_NETWORK_TYPE="vlan"
  Q_PLUGIN="ml2"
  Q_SERVICE_PLUGIN_CLASSES="neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,segments"
  Q_USE_DEBUG_COMMAND="True"
  Q_USE_PROVIDERNET_FOR_PUBLIC="True"
  Q_USE_SECGROUP="False"
  RABBIT_PASSWORD="secretrabbit"
  SERVICE_HOST="127.0.0.1"
  SERVICE_PASSWORD="secretservice"
  SERVICE_TIMEOUT="90"
  SWIFT_ENABLE_TEMPURLS="True"
  SWIFT_HASH="1234123412341234"
  SWIFT_REPLICAS="1"
  SWIFT_START_ALL_SERVICES="False"
  SWIFT_TEMPURL_KEY="secretkey"
  TENANT_VLAN_RANGE="100:150"
  VERBOSE="True"
  VERBOSE_NO_TIMESTAMP="True"
  VIRT_DRIVER="ironic"
  LIBS_FROM_GIT=cinder,devstack,glance,ironic,ironic-python-agent,ironic-python-agent-builder,ironic-tempest-plugin,keystone,networking-baremetal,networking-generic-switch,neutron,nova,placement,requirements,swift,tempest,virtualbmc
  TEMPEST_PLUGINS="/opt/stack/ironic-tempest-plugin"
  enable_plugin ironic https://opendev.org/openstack/ironic
  enable_plugin networking-generic-switch https://opendev.org/openstack/networking-generic-switch
  enable_plugin networking-baremetal https://opendev.org/openstack/networking-baremetal



