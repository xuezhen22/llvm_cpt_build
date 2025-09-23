#!/bin/bash

set +x
set -euo pipefail

# dir
CASE_NAMES="/nfs/home/xuezhen/pro/gen_cpt/gen_llvm_txt/case_names.txt"
CMD_FILE="/nfs/home/xuezhen/pro/gen_cpt/gen_llvm_txt/final_cmd.txt"


LINUX_GCPT_BIN_DIR="/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/LibCheckpointAlpha/build"
RUN_SCRIPT="/nfs/home/xuezhen/pro/gen_cpt/linux_prepare/riscv-rootfs/rootfsimg/run.sh"
LLVM_TS_GCPT_BINS="/nfs/home/xuezhen/pro/gen_cpt/llvmTS_gcpt_bins"

mapfile -t case_names < $CASE_NAMES
mapfile -t cmds < $CMD_FILE

mkdir -p "$LLVM_TS_GCPT_BINS"

> "$RUN_SCRIPT"

for idx in "${!case_names[@]}"; do
  crt_case_name=${case_names[$idx]}
  crt_cmd=${cmds[$idx]}
  crt_elf_path=$(echo "$crt_cmd" | awk '{print $2}')

  if [[ -e $LLVM_TS_GCPT_BINS/"$crt_case_name.bin" ]]; then
    rm $LLVM_TS_GCPT_BINS/"$crt_case_name.bin"
  fi

  # echo "$crt_case_name"
  # echo "$crt_cmd"
  # echo "$crt_elf_path"

  cat > "$RUN_SCRIPT" << EOF
#!/bin/sh

set -x
md5sum $crt_elf_path/$crt_case_name
date -R
/spec_common/before_workload
$crt_cmd
date -R
set +x
/spec_common/trap
echo '======= finish $crt_case_name ======='
EOF

  cd ${RISCV_LINUX_HOME}
  make -j16
  # get the size of image
  IMG="${RISCV_LINUX_HOME}/arch/riscv/boot/Image"
  IMG_SIZE=$(stat -c%s "$IMG")
  FDT_ADDR=$(( ((IMG_SIZE + 2*1024*1024 + 0x80000000 + 0x100000 - 1) / 0x100000) * 0x100000 ))

  rm -rf $OPENSBI_HOME/build
  cd $OPENSBI_HOME
  make PLATFORM=generic FW_PAYLOAD_PATH=$RISCV_LINUX_HOME/arch/riscv/boot/Image \
  FW_FDT_PATH=$WORKLOAD_BUILD_ENV_HOME/dts/build/xiangshan.dtb \
  FW_PAYLOAD_OFFSET=0x100000 FW_PAYLOAD_FDT_ADDR=$(printf "0x%x" "$FDT_ADDR") -j10
  cd $GCPT_HOME
  make clean
  make GCPT_PAYLOAD_PATH=$OPENSBI_HOME/build/platform/generic/firmware/fw_payload.bin

  if [[ -f "$LINUX_GCPT_BIN_DIR/gcpt.bin" ]]; then
    cp "$LINUX_GCPT_BIN_DIR/gcpt.bin" "$LLVM_TS_GCPT_BINS"/"$crt_case_name.bin"
    echo "✅✅✅ generated $crt_case_name.bin!!! ✅✅✅"
  else
    echo "⚠️⚠️⚠️ Warning: $LINUX_GCPT_BIN_DIR/gcpt.bin of "$crt_case_name" not exist!! exit the program."
    exit 1
  fi
done < $CMD_FILE

echo "💗💗💗 output-dir: $LLVM_TS_GCPT_BINS 💗💗💗"