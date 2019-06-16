# AnyKernel3 Ramdisk Mod Script for A6020
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string= DarkKnight-kernel by hsj51
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=A6020
device.name2=a6020
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel install
dump_boot;
write_boot;
## end install

