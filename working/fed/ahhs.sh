#!/bin/bash

set -euo pipefail

TARGET_DIR="$3"
new_n="$2"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory." >&2
    exit 1
fi

find "$TARGET_DIR" -type f -iname "$1"  -print0 | while IFS= read -r -d '' file; do
    dir="$(dirname "$file")"
    name="$(basename "$file")"
    new_name="${new_n}${name#feda}"

    if [ "$name" != "$new_name" ]; then
        mv -n -- "$file" "$dir/$new_name"
        echo "$file -> $dir/$new_name"
    fi
done

echo "Done."
