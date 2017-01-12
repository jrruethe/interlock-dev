#!/bin/bash

# Stop on any error
set -e

# Declare an array of tasks to perform on exit
declare -a on_exit_items

# This function is run on exit
function on_exit()
{
    for i in "${on_exit_items[@]}"
    do
        echo $i
        eval $i
    done
}

# Add to the list of tasks to run on exit
function add_on_exit_reverse()
{
    on_exit_items=("$*" "${on_exit_items[@]}")
    if [[ $n -eq 0 ]]; then
        trap on_exit EXIT
    fi
}

function build
{
   # Set the INTERLOCK_LOCAL_REPO environment variable
   export INTERLOCK_LOCAL_REPO=/mnt/interlock

   # Set the USBARMORY_GIT environment variable
   export USBARMORY_GIT=/mnt/usbarmory

   # Change to the buildroot directory
   cd /mnt/buildroot

   # Clean up
   make clean

   # Generate the configuration
   make BR2_EXTERNAL=${USBARMORY_GIT}/software/buildroot usbarmory_mark_one_defconfig

   # Build the image
   make BR2_EXTERNAL=${USBARMORY_GIT}/software/buildroot
}

function mount_device
{
   # The following needs to be done due to this issue in Docker: 
   # https://github.com/docker/docker/issues/16160
   # Basically, when a new device is created on the host,
   # it doesn't appear in the device list of the container.
   # This function will manually create the device node.
   # It assumes that first entry in the device mapper is the LVM volume
   # inside /mnt/luks/container. Untested if you are using LVM on the host!

   MAJOR=`cat /sys/block/dm-0/dev | awk -F ':' '{print $1}'`
   MINOR=`cat /sys/block/dm-0/dev | awk -F ':' '{print $2}'`

   mkdir -p /dev/lvmvolume

   if [ ! -f /dev/lvmvolume/test ]; then
      mknod /dev/lvmvolume/test b ${MAJOR} ${MINOR} || true
      add_on_exit_reverse rm -f /dev/lvmvolume/test
   fi
}

function create
{
   # Create the container if it doesn't exist
   dd if=/dev/zero of=/mnt/luks/container bs=1M count=100

   # Loop it to a device
   losetup /dev/loop0 /mnt/luks/container

   # Create a physical volume
   pvcreate /dev/loop0

   # Create a virtual group
   vgcreate lvmvolume /dev/loop0

   # Activate the volume group
   vgchange -a y lvmvolume

   # Create a logical volume
   lvcreate -Z n -L 90M -n test lvmvolume

   # Activate the logical volume
   lvchange -a y lvmvolume

   # Create the device node
   mount_device

   # Format it
   echo -n "test" | cryptsetup --cipher aes-xts-plain64 --key-size 256 --hash sha1 luksFormat /dev/lvmvolume/test

   # Open it
   echo -n "test" | cryptsetup luksOpen /dev/lvmvolume/test interlockfs

   # Create a filesystem
   mkfs.ext4 /dev/mapper/interlockfs

   # Close the container
   cryptsetup luksClose interlockfs

   # Deactivate the logical volume
   lvchange -a n lvmvolume

   # Deactivate the volume group
   vgchange -a n lvmvolume

   # Unmount the loop
   losetup -d /dev/loop0
}

function run
{
   # Change to the interlock directory
   cd /mnt/interlock

   # Compile the interlock application
   make

   # Create the container if it doesn't exist
   if [ ! -f /mnt/luks/container ]; then
      create
   fi

   # Loop to a device
   losetup /dev/loop0 /mnt/luks/container
   add_on_exit_reverse dmsetup remove_all
   add_on_exit_reverse losetup -d /dev/loop0

   # Activate the volume group
   vgchange -a y lvmvolume
   add_on_exit_reverse lvchange -a n lvmvolume
   
   # Activate the logical volume
   lvchange -a y lvmvolume
   add_on_exit_reverse vgchange -a n lvmvolume
   
   # Mount the device node
   mount_device

   # Start the interlock application
   mkdir -p certs
   ./interlock &
   PID=$!
   add_on_exit_reverse kill -9 ${PID}
   read
}

function reset
{
   losetup -D
   dmsetup remove_all -f
}

# Determine what to do
case "$1" in
   build)
      build
      ;;
   run)
      run
      ;;
   reset)
      reset
      ;;
   *)
      # Just start an interactive prompt
      /bin/bash
esac

