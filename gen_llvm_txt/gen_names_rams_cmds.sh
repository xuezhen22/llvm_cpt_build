#!bin/bash

set -euo pipefail
set +x

LLVM_TS_BUILD="/nfs/home/xuezhen/pro/gen_cpt/llvmTS_build"


list_file_in_ram_new() {
  local elf_dir="$1"
  local crt_case_name="$2"

  echo "# $crt_case_name"
  echo "dir /spec/$crt_case_name 755 0 0"

  while IFS= read -r dir; do
    dir_name=${dir#*$elf_dir/}
    if echo "$dir_name" | grep -q "CMakeFiles"; then
      # echo "😇 $a_item_name"
      continue
    fi
    echo "dir /spec/$crt_case_name/$dir_name 755 0 0"
  done < <(find "$elf_dir" -mindepth 1 -type d)

  while IFS= read -r file; do
    file_name=${file#*$elf_dir/}
    if echo "$file_name" | grep -q "\.test\|\.reference_output\|\.cmake\|\.sh\|\.time\|\.size\|Makefile"; then
      # echo "😇 $a_item_name"
      continue
    fi
    echo "file /spec/$crt_case_name/$file_name $file 755 0 0"
  done < <(find "$elf_dir" -type f)
}


touch ram_init.txt
touch final_cmd.txt
touch case_names.txt
# touch tmp.txt
> ram_init.txt
> final_cmd.txt
> case_names.txt
# > tmp.txt

find "$LLVM_TS_BUILD" -type f -name "*.test" | while read -r test_file; do
  base_folder=$(dirname $test_file)
  # echo "$test_file" >> tmp.txt
  if [[ $base_folder == "/nfs/home/xuezhen/pro/gen_cpt/llvmTS_build/tools"* ]]; then
    continue
  fi

  first_line=$(head -n 1 "$test_file")

  case_name=$(echo "$first_line" | grep -oE '[^ ]+/[^ ]+' | head -n1 | xargs -I{} basename -- {})
  input_file_args="${first_line#*$case_name}"
  input_file_args0=$(echo "$input_file_args" | tr -d ' <')
  if [[ -z ${input_file_args0// } ]]; then
    echo "file /spec/$case_name /nfs/home/xuezhen/pro/gen_cpt/llvmTS_elfs/$case_name 755 0 0" >> ram_init.txt
    echo "cd /spec && ./$case_name" >> final_cmd.txt
    echo "$case_name" >> case_names.txt
    continue
  fi

  echo "$case_name" >> case_names.txt

  the_elf_path=$(find $LLVM_TS_BUILD -type f -name "$case_name")
  the_elf_dir=$(dirname $the_elf_path)

  if grep -qw $case_name only_args_case_names.txt; then
    echo "file /spec/$case_name /nfs/home/xuezhen/pro/gen_cpt/llvmTS_elfs/$case_name 755 0 0" >> ram_init.txt
    echo "cd /spec && ./$case_name $input_file_args" >> final_cmd.txt
  else
    list_file_in_ram_new $the_elf_dir $case_name >> ram_init.txt
    echo "cd /spec/$case_name && ./$case_name $input_file_args" >> final_cmd.txt
  fi

done
