#!/bin/bash

root_path=$(dirname "$(readlink -f "$0")")
valid_install_list=$($root_path/conf/valid_install_list.sh)

for target in $valid_install_list; do
  echo ">>> install '$target'"
  $root_path/src/$target
done

