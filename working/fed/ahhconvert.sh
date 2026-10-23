#!/bin/bash

set -euo pipefail

for cmd in convert mogrify; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: ImageMagick ('$cmd') is not installed." >&2
        exit 1
    fi
done

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory." >&2
    exit 1
fi

process_file() {
    local jpg_file="$1"
    local dir
    local base
    local bmp_file

    dir="$(dirname "$jpg_file")"
    base="$(basename "$jpg_file" .jpg)"
    bmp_file="$dir/$base.bmp"

    echo "Processing: $jpg_file -> $bmp_file"

    magick "$jpg_file" \
        -fuzz 5% \
        -trim +repage \
        -resize 33.333% \
        -define bmp:format=bmp3 \
        "$bmp_file"
}

export -f process_file

find "$TARGET_DIR" -type f \( -iname '*.jpg' \) -print0 | \
    while IFS= read -r -d '' file; do
        process_file "$file"
	rm "$file"
    done

echo "Done."

