#!/bin/bash

echo
echo "==========================="
echo "Check SPDX identifier"
echo "==========================="
echo

ERROR_FILES=""
FILES_TO_CHECK=`find . \
    -type f \( -name '*.sh' -o -name '*.py' -o -name 'Makefile' \) \
    \( -not -path "*/.*/*" -not -path "*/third_party/*" -not -path "*/env/*" -not -path "*/build/*" \)`

for file in $FILES_TO_CHECK; do
    echo "Checking $file"
    grep -q "SPDX-License-Identifier" $file || ERROR_FILES="$ERROR_FILES $file"
done

if [ ! -z "$ERROR_FILES" ]; then
    for file in $ERROR_FILES; do
        echo "ERROR: $file does not have license information."
    done
    return 1
fi

echo
echo "==========================="
echo "Check third party LICENSE"
echo "==========================="
echo

function check_if_submodule {
    for submodule in `git submodule --quiet foreach 'echo $sm_path'`; do
        if [ "$1" == "$submodule" ]; then
            return 1
        fi
    done
}

THIRD_PARTY_DIRS=`ls -d third_party/*`
ERROR_NO_LICENSE=""

for dir in $THIRD_PARTY_DIRS; do
    # Checks if we are not in a submodule
    if check_if_submodule $dir; then
        echo "Checking $dir"
        [ -f $dir/LICENSE ] || ERROR_NO_LICENSE="$ERROR_NO_LICENSE $dir"
    fi
done

if [ ! -z "$ERROR_NO_LICENSE" ]; then
    for dir in $ERROR_NO_LICENSE; do
        echo "ERROR: $dir does not have the LICENSE file."
    done
    return 1
fi

echo
echo "==========================="
echo "Check AUTHORS"
echo "==========================="
echo

if [ ! -f ./AUTHORS ]; then
    echo "ERROR: no AUTHORS file found."
    return 1
else
    echo "AUTHORS file found"
fi

