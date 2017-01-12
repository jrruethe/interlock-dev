# Development environment for Interlock using Docker

I wanted to add a feature to the Interlock application and test it without constantly switching to the USB Armory, so I made a Docker environment that will build and run the application with a small LUKS container. It will also build the USB Armory image for you.

## Getting started

1. Take a peek at the .gitmodules file and change the interlock url if desired
2. `git submodule init`
3. `git submodule update`
4. `cd interlock && git submodule update && cd ..`
5. Install Docker >1.9
6. `./build.sh`
7. `./interlock.sh build`
8. `./interlock.sh run`
9. Visit `https://127.0.0.1:4430` and use `test`:`test` to login

## Making edits to Interlock
All of the repositories necessary are included as submodules. The `usbarmory` fork has edits to the makefile to allow building an image from a local Interlock repository. Therefore, this local Interlock repository is now your playground.

## Commands

The scripts provided can do 3 things:

### `./interlock.sh run`
This will build Interlock for your host machine and run it with a small LUKS container. You can use your web browser pointed at 127.0.0.1:4430 to interact with the instance.

### `./interlock.sh build`
This will build the USB Armory image for ARM.

### `./interlock bash`
This will enter the Docker environment so you can run commands manually if you choose.

### `./interlock reset`
This will reset the mount in case something goes wrong

# WARNINGS
There is a bit of a nasty hack in the `entry.sh` script. Once inside the Docker environment, if a new device is created on the host (such as when an LVM device is mounted), the Docker environment doesn't get the update. Therefore, the hack is to quiery the Kernel's device mapper and manually create the device node so it can be mounted inside the container. The code is currently hardcoded to use the *first* LVM device it finds. My host system does not use LVM for its partitions, but if yours does this code may not work, or it may accidentally mount and overwrite the wrong disk! Please be careful.
