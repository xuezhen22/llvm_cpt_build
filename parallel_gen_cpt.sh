#!/bin/bash
set -euo pipefail
set -x

GEN_CPT_SCRIPT="${GEN_CPT_SCRIPT:-/nfs/home/xuezhen/pro/gen_cpt/nemu_gen_cpt.sh}"
WORKLOAD_LIST="${WORKLOAD_LIST:-/nfs/home/xuezhen/pro/gen_cpt/gen_llvm_txt/case_names.txt}"
THREAD_NUM="${THREAD_NUM:-251}"   # 并发数

[[ -f "$GEN_CPT_SCRIPT" ]] || { echo "script not found: $GEN_CPT_SCRIPT"; exit 1; }
[[ -f "$WORKLOAD_LIST"  ]] || { echo "list not found:   $WORKLOAD_LIST";  exit 1; }

cat $WORKLOAD_LIST | parallel -j $THREAD_NUM $GEN_CPT_SCRIPT