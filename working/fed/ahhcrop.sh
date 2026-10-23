#!/bin/bash
set -euo pipefail

BG_COLOR="rgb(20,20,20)"
FUZZ="2%"
TARGET_DIR="${1:-.}"

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick (magick) is not installed." >&2
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory." >&2
    exit 1
fi

find "$TARGET_DIR" -type f -iname '*.bmp' -print0 | while IFS= read -r -d '' file; do
    dir="$(dirname "$file")"
    base="$(basename "$file" .bmp)"
    out="$dir/${base}_nobg.png"

    echo "Processing: $file -> $out"
    magick "$file" -fuzz "$FUZZ" -transparent "$BG_COLOR" "$out"
done

echo "Done."
