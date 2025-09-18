#!/bin/bash

export ARCH=riscv
export RISCV_LINUX_HOME=/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/linux-6.10.3
export RISCV_ROOTFS_HOME=/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/riscv-rootfs
export WORKLOAD_BUILD_ENV_HOME=/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/nemu_board
export OPENSBI_HOME=/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/opensbi
export RISCV=/nfs/home/xuezhen/tools/riscv_build_linux
export GCPT_HOME=/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/LibCheckpointAlpha
export CROSS_COMPILE=$RISCV/bin/riscv64-unknown-linux-gnu-