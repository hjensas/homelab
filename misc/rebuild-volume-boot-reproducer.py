#
#
# PREREQUISITES:
# - A blank image in glance
# - A CentOS-9-Stream-GenericCloud image in glance
# - A CentOS-9-Stream-GenericCloud ISO image in glance
# - A keypair
# - A flavor 
# - A network

# CREATE THE IMAGES:
# 
# BLANK-IMAGE: 
# 
# qemu-img create -f raw blank-img.raw 1G
# openstack image create --disk-format=raw --file blank-img.raw blank-img \
#   --property hw_firmware_type=uefi \
#   --property hw_machine_type=q35 \
#   --tag test_vol_rebuild

# CentOS-9-Stream ISO image:
#
# curl -O https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso
# openstack image create --disk-format=raw --file CentOS-Stream-9-latest-x86_64-boot.iso cs9stream-iso 
#   --property hw_firmware_type=uefi \
#   --property hw_machine_type=q35 \
#   --tag test_vol_rebuild

# CentOS-9-Stream-GenericCloud: 
#
# curl -O https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2
# qemu-img convert CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2 CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.raw
# openstack image create --disk-format=raw --file CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.raw cs9stream-genericcloud
#   --property hw_firmware_type=uefi \
#   --property hw_machine_type=q35 \
#   --tag test_vol_rebuild

#
#
# USAGE:
# 
# Edit the constants below to set flavors, network, keypair etc.
# 
# python rebuild-volume-boot-reproducer.py
 

import openstack
import time


CLOUD = 'openstack'               # The cloud to use
SERVER_NAME = 'blk-dev-test'      # The server name to use
FLAVOR = 'm1.medium'              # The flavor to use
NETWORK = 'provider'              # The network to use
IMAGE = 'cs9stream-genericcloud'  # The image to use
ISO_IMAGE = 'cs9stream-iso'       # The ISO image to use
BLANK_IMAGE = 'blank-img'         # The "blank" image to use   
KEYPAIR = 'default'               # The keypair to use
VOLUME_SIZE = 10                  # The volume size to use


conn = openstack.connect(cloud=CLOUD)


# Validate all required resources exist
print("Validating required resources...")

flavor = conn.compute.find_flavor(FLAVOR)
if not flavor:
    print(f"✗ ERROR: Flavor '{FLAVOR}' not found!")
    print("Available flavors:")
    for f in conn.compute.flavors():
        print(f"  - {f.name}")
    exit(1)
print(f"✓ Found flavor: {flavor.name}")

network = conn.network.find_network(NETWORK)
if not network:
    print(f"✗ ERROR: Network '{NETWORK}' not found!")
    print("Available networks:")
    for n in conn.network.networks():
        print(f"  - {n.name}")
    exit(1)
print(f"✓ Found network: {network.name}")

keypair = conn.compute.find_keypair(KEYPAIR)
if not keypair:
    print(f"✗ ERROR: Keypair '{KEYPAIR}' not found!")
    print("Available keypairs:")
    for k in conn.compute.keypairs():
        print(f"  - {k.name}")
    exit(1)
print(f"✓ Found keypair: {keypair.name}")

server_img = conn.image.find_image(IMAGE)
if not server_img:
    print(f"✗ ERROR: Server image '{IMAGE}' not found!")
    print("Available images:")
    for img in conn.image.images():
        print(f"  - {img.name}")
    exit(1)
print(f"✓ Found server image: {server_img.name}")

iso_image = conn.image.find_image(ISO_IMAGE)
if not iso_image:
    print(f"✗ ERROR: ISO image '{ISO_IMAGE}' not found!")
    print("Available images:")
    for img in conn.image.images():
        print(f"  - {img.name}")
    exit(1)
print(f"✓ Found ISO image: {iso_image.name}")

blank_image = conn.image.find_image(BLANK_IMAGE)
if not blank_image:
    print(f"✗ ERROR: Blank image '{BLANK_IMAGE}' not found!")
    print("Available images:")
    for img in conn.image.images():
        print(f"  - {img.name}")
    exit(1)
print(f"✓ Found blank image: {blank_image.name}")

print("✓ All required resources validated successfully!\n")


# Set up the block device mapping for the server
# - The server image is the bootable image as boot index 1
# - The blank image is the blank image as boot index 0
# The server will fail too boot the blank image "index 0", and fall back to the bootable image "index 1"
block_device_mapping = [
    {'uuid': server_img.id,
     'boot_index': 1,
     'source_type': 'image',
     'destination_type': 'volume',
     'device_type': 'disk',
     'volume_size': VOLUME_SIZE,
     'delete_on_termination': True,
    },
    {'uuid': blank_image.id,
     'boot_index': 0,
     'source_type': 'image',
     'destination_type': 'volume',
     'device_type': 'cdrom',
     'disk_bus': 'sata',
     'volume_size': VOLUME_SIZE,
     'delete_on_termination': True,
    }
]

server = conn.compute.create_server(
    name=SERVER_NAME,
    flavor_id=flavor.id,
    networks=[{"uuid": network.id}],
    key_name=keypair.id,
    block_device_mapping=block_device_mapping
)

# Wait for the server to be ACTIVE
print(f"\nWaiting for server '{SERVER_NAME}' to become ACTIVE...")
while server.status != 'ACTIVE':
    print(f"  Current status: {server.status}")
    time.sleep(5)
    server = conn.compute.get_server(server)
print(f"✓ Server is now {server.status}")

# Wait for initial boot process and capture console output
print("\nWaiting 60 seconds for initial boot process...")
time.sleep(60)

print("\nCapturing initial server console output (last 15 lines):")
print("-" * 60)
try:
    console_response = conn.compute.get_server_console_output(server.id, length=15)
    if console_response and 'output' in console_response:
        print(console_response['output'])
    else:
        print("No console output available")
except Exception as e:
    print(f"Failed to retrieve console output: {e}")
print("-" * 60)

server = conn.compute.find_server(SERVER_NAME)

print(f"\nServer '{SERVER_NAME}' is now ACTIVE and ready for rebuild test.")
print(f"About to rebuild the server with ISO image '{ISO_IMAGE}'.")
print("This will replace the boot index 0 device (currently blank image) with the ISO image.")
print("The server should then boot from the ISO image instead of falling back to boot index 1.")
print("\nPress 'y' to proceed with the rebuild, or any other key to exit: ", end='')

user_input = input().strip().lower()
if user_input != 'y':
    print("Rebuild cancelled. Exiting...")
    exit(0)

print(f"\nProceeding with server rebuild using image: {ISO_IMAGE}")

# Rebuild the server with the ISO image
# This will rebiuld the block device with "index 0" and the server should boot to the ISO image (e.g CS9-stream install ISO)
res = conn.compute.post(
    "servers/%s/action" % server.id, 
    microversion="2.93", 
    json={"rebuild": {"imageRef": iso_image.id}}
)

# Check the rebuild operation results
print(f"\nRebuild operation response status: {res.status_code}")

if res.status_code == 202:
    print("✓ Rebuild operation accepted successfully!")
    print("Waiting for rebuild to complete...")
    
    # Wait for rebuild to complete
    server = conn.compute.get_server(server)
    while server.status in ['REBUILD', 'BUILD']:
        print(f"  Current status: {server.status}")
        time.sleep(5)
        server = conn.compute.get_server(server)
    
    if server.status == 'ACTIVE':
        print(f"✓ Server rebuild completed successfully!")
        print(f"Server '{server.name}' is now ACTIVE")
        print(f"Server ID: {server.id}")
        print(f"Image used for rebuild: {iso_image.name} ({iso_image.id})")
        print("\nThe server should now boot from the ISO image at boot index 0.")
        
        # Wait for boot process and capture console output
        print("\nWaiting 60 seconds for boot process...")
        time.sleep(60)
        
        print("\nCapturing server console output (last 15 lines):")
        print("-" * 60)
        try:
            console_response = conn.compute.get_server_console_output(server.id, length=15)
            if console_response and 'output' in console_response:
                print(console_response['output'])
            else:
                print("No console output available")
        except Exception as e:
            print(f"Failed to retrieve console output: {e}")
        print("-" * 60)
    else:
        print(f"✗ Server rebuild failed!")
        print(f"Final server status: {server.status}")
        if hasattr(server, 'fault') and server.fault:
            print(f"Fault details: {server.fault}")
else:
    print(f"✗ Rebuild operation failed with status code: {res.status_code}")
    try:
        error_details = res.json()
        print(f"Error details: {error_details}")
    except:
        print(f"Response text: {res.text}")
    print("Rebuild operation was not accepted by the server.")

# Second rebuild test with blank image
print(f"\n" + "="*60)
print("SECOND REBUILD TEST")
print("="*60)
print(f"About to rebuild the server again with blank image '{BLANK_IMAGE}'.")
print("This will replace the boot index 0 device (currently ISO image) back to the blank image.")
print("The server should then fail to boot from blank image and fall back to boot index 1.")
print("\nPress 'y' to proceed with the second rebuild, or any other key to exit: ", end='')

user_input = input().strip().lower()
if user_input != 'y':
    print("Second rebuild cancelled. Script completed.")
    exit(0)

print(f"\nProceeding with second rebuild using image: {BLANK_IMAGE}")

res = conn.compute.post(
    "servers/%s/action" % server.id, 
    microversion="2.93",
    json={"rebuild": {"imageRef": blank_image.id}}
)

# Check the second rebuild operation results
print(f"\nSecond rebuild operation response status: {res.status_code}")

if res.status_code == 202:
    print("✓ Second rebuild operation accepted successfully!")
    print("Waiting for second rebuild to complete...")
    
    # Wait for second rebuild to complete
    server = conn.compute.get_server(server)
    while server.status in ['REBUILD', 'BUILD']:
        print(f"  Current status: {server.status}")
        time.sleep(5)
        server = conn.compute.get_server(server)
    
    if server.status == 'ACTIVE':
        print(f"✓ Second server rebuild completed successfully!")
        print(f"Server '{server.name}' is now ACTIVE")
        print(f"Server ID: {server.id}")
        print(f"Image used for second rebuild: {blank_image.name} ({blank_image.id})")
        print("\nThe server should now fail to boot from blank image and fall back to boot index 1.")
        
        # Wait for boot process and capture console output
        print("\nWaiting 60 seconds for boot process...")
        time.sleep(60)
        
        print("\nCapturing server console output after second rebuild (last 15 lines):")
        print("-" * 60)
        try:
            console_response = conn.compute.get_server_console_output(server.id, length=15)
            if console_response and 'output' in console_response:
                print(console_response['output'])
            else:
                print("No console output available")
        except Exception as e:
            print(f"Failed to retrieve console output: {e}")
        print("-" * 60)
        
        print("Test sequence completed successfully!")
    else:
        print(f"✗ Second server rebuild failed!")
        print(f"Final server status: {server.status}")
        if hasattr(server, 'fault') and server.fault:
            print(f"Fault details: {server.fault}")
else:
    print(f"✗ Second rebuild operation failed with status code: {res.status_code}")
    try:
        error_details = res.json()
        print(f"Error details: {error_details}")
    except:
        print(f"Response text: {res.text}")
    print("Second rebuild operation was not accepted by the server.")

# Final cleanup prompt
print(f"\n" + "="*60)
print("CLEANUP")
print("="*60)
print(f"Test server '{SERVER_NAME}' is still running.")
print("Would you like to delete the test server and its associated volumes?")
print("This will permanently remove the server and all its data.")
print("\nPress 'y' to delete the server, or any other key to keep it: ", end='')

user_input = input().strip().lower()
if user_input == 'y':
    print(f"\nDeleting server '{SERVER_NAME}'...")
    try:
        conn.compute.delete_server(server.id)
        print("✓ Server deletion initiated successfully!")
        print("Note: Volumes will be automatically deleted due to 'delete_on_termination': True")
        print("Cleanup completed.")
    except Exception as e:
        print(f"✗ Failed to delete server: {e}")
        print("You may need to manually delete the server from the OpenStack dashboard.")
else:
    print("Server kept. You can manually delete it later if needed.")
    print(f"Server name: {SERVER_NAME}")
    print(f"Server ID: {server.id}")

print("\nScript execution completed.")