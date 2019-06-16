#!/bin/bash
# Script to build flashable RebornKernel zip for A6020
# Place this script in the Root dir of your kernel

BUILD_START=$(date +"%s")

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Kernel details
KERNEL_NAME="Hrutvik"
VERSION="A6020"
DATE=$(date +"%d-%m-%Y")
DEVICE="A6020"
FINAL_ZIP=$KERNEL_NAME-$VERSION-$DATE-$DEVICE.zip
defconfig=reborn_A6020_defconfig

# Toolchain repo
TOOLCHAIN_REPO="https://github.com/krasCGQ/aarch64-linux-android"

# Dirs
KERNEL_DIR=$(pwd)
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
KERNEL_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz.dtb
UPLOAD_DIR=$KERNEL_DIR/OUTPUT/$DEVICE
TC=$KERNEL_DIR/gcc8

# Export
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-opt-linux-android-
export KBUILD_BUILD_USER="hsj51"
export KBUILD_BUILD_HOST="HrutvikJ"

if [ ! -d "$TOOLCHAIN" ]; then git clone -b opt-gnu-8.x $TC_REPO $TOOLCHAIN; fi

## Functions ##

# Make kernel
function make_kernel() {
  mkdir -p out
  echo -e "$cyan***********************************************"
  echo -e "          Initializing defconfig          "
  echo -e "***********************************************$nocol"
  make O=out $defconfig 
  echo -e "$cyan***********************************************"
  echo -e "             Building kernel          "
  echo -e "***********************************************$nocol"
  make O=out -j`nproc --all`
  if ! [ -a $KERNEL_IMG ];
  then
    echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
  fi
}

# Making zip
function make_zip() {
mkdir -p tmp_mod
make -j`nproc --all` modules_install INSTALL_MOD_PATH=tmp_mod INSTALL_MOD_STRIP=1
find tmp_mod/ -name '*.ko' -type f -exec cp '{}' $ANYKERNEL_DIR/modules/system/lib/modules/ \;
cp $KERNEL_IMG $ANYKERNEL_DIR
mkdir -p $UPLOAD_DIR
cd $ANYKERNEL_DIR
zip -r9 UPDATE-AnyKernel3.zip * -x README UPDATE-AnyKernel3.zip
mv $ANYKERNEL_DIR/UPDATE-AnyKernel2.zip $UPLOAD_DIR/$FINAL_ZIP
rm -rf $KERNEL_DIR/tmp_mod
cd $UPLOAD_DIR
}

# Options
function options() {
echo -e "$cyan***********************************************"
  echo "               Compiling RebornKernel                "
  echo -e "***********************************************$nocol"
  echo -e " "
  echo -e " Select one of the following types of build : "
  echo -e " 1.Dirty"
  echo -e " 2.Clean"
  echo -n " Your choice : "
  read ch

  echo -e " Select if you want zip or just kernel : "
  echo -e " 1.Get flashable zip"
  echo -e " 2.Get kernel only"
  echo -n " Your choice : "
  read ziporkernel

case $ch in
  1) echo -e "$cyan***********************************************"
     echo -e "          	Dirty          "
     echo -e "***********************************************$nocol"
     make_kernel;;
  2) echo -e "$cyan***********************************************"
     echo -e "          	Clean          "
     echo -e "***********************************************$nocol"
     make clean
     make mrproper
     rm -rf tmp_mod
     make_kernel;;
esac

if [ "$ziporkernel" = "1" ]; then
     echo -e "$cyan***********************************************"
     echo -e "     Making flashable zip        "
     echo -e "***********************************************$nocol"
     make_zip
else
     echo -e "$cyan***********************************************"
     echo -e "     Building Kernel only        "
     echo -e "***********************************************$nocol"
fi
}

# Clean Up
function cleanup(){
rm -rf $KERNEL_IMG
}

options
cleanup
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
