#!/bin/bash
source build/envsetup.sh >/dev/null && setpaths
TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`

#set jdk version
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

# source environment and chose target product
DEVICE=`get_build_var TARGET_PRODUCT`
BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
UBOOT_DEFCONFIG=rk322xh_box_defconfig
KERNEL_DEFCONFIG=rockchip_defconfig
KERNEL_DTS=rk3228h-evb
PACK_TOOL_DIR=RKTools/linux/Linux_Pack_Firmware
IMAGE_PATH=rockdev/Image-$TARGET_PRODUCT

lunch $DEVICE-$BUILD_VARIANT

# build uboot
echo "start build uboot"
cd u-boot && make distclean && make $UBOOT_DEFCONFIG && make ARCHV=aarch64 -j24 && cd -

# build kernel
echo "start build kernel"
cd kernel && make ARCH=arm64 $KERNEL_DEFCONFIG && make ARCH=arm64 $KERNEL_DTS.img -j24 && cd -

# build android
echo "start build android"
lunch rk3328_box-userdebug
#make clean
make -j8

# mkimage.sh
echo "make and copy android images"
./mkimage.sh
cp -f $IMAGE_PATH/* $PACK_TOOL_DIR/rockdev/Image/

# copy images to rockdev
echo "copy u-boot images"
cp u-boot/uboot.img $PACK_TOOL_DIR/rockdev/Image/
cp u-boot/RK3368MiniLoaderAll* $PACK_TOOL_DIR/rockdev/Image/RK3368MiniLoader.bin
cp u-boot/trust.img $PACK_TOOL_DIR/rockdev/Image/

echo "copy kernel images"
cp kernel/resource.img $PACK_TOOL_DIR/rockdev/Image
cp kernel/kernel.img $PACK_TOOL_DIR/rockdev/Image

echo "copy manifest.xml"
DATE=$(date  +%Y%m%d_%H%M)
cp manifest.xml $IMAGE_PATH/manifest_${DATE}.xml

#cd RKTools/linux/Linux_Pack_Firmware/rockdev && ./mkupdate.sh
#cp -f update.img ../../../../$IMAGE_PATH/
