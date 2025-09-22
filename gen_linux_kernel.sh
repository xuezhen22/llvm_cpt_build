#!/bin/bash

set -euo pipefail

source export_cpt_var.sh

# rootfs
cd $RISCV_ROOTFS_HOME
make CROSS_COMPILE=$RISCV/bin/riscv64-unknown-linux-gnu-

#
cd $WORKLOAD_BUILD_ENV_HOME/dts
ln -sf platform_noop.dtsi platform.dtsi
bash build_single_core_for_nemu.sh

# kernel
cd $RISCV_LINUX_HOME
cp $WORKLOAD_BUILD_ENV_HOME/configs/xiangshan_defconfig $RISCV_LINUX_HOME/arch/riscv/configs/xiangshan_defconfig
make xiangshan_defconfig
make -j

# opsen-sbi
cd $OPENSBI_HOME
make PLATFORM=generic FW_PAYLOAD_PATH=$RISCV_LINUX_HOME/arch/riscv/boot/Image FW_FDT_PATH=$WORKLOAD_BUILD_ENV_HOME/dts/build/xiangshan.dtb FW_PAYLOAD_OFFSET=0x200000

# 接下来
# 重新配置内核
# cd $RISCV_LINUX_HOME
# make menuconfig
# general setup -> initial ram..
# 按需修改 ${RISCV_ROOTFS_HOME}/rootfsimg/initramfs-spec.txt
# make -j16



