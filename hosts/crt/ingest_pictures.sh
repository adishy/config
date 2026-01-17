#!/bin/bash

# Usage: ./organize_photos.sh /path/to/library [--reset]
TARGET_DIR=$(realpath "${1:-.}")
RESET_MODE=false

for arg in "$@"; do
    if [ "$arg" == "--reset" ]; then RESET_MODE=true; fi
done

echo "Target Directory: $TARGET_DIR"

# --- Phase 0: Emergency Filename Repair (Only if Reset) ---
# This strips colons and long strings to make files readable by the OS again.
if [ "$RESET_MODE" = true ]; then
    echo "--- Phase 0: Repairing broken filenames ---"
    # This renames files strictly to their internal timestamp to clear the mess.
    exiftool -r -P -overwrite_original \
        -api QuickTimeUTC \
        -d "%%Y%%m%%d_%%H%%M%%S%%-c.%%le" \
        '-filename<FileModifyDate' \
        '-filename<ModifyDate' \
        '-filename<CreateDate' \
        '-filename<DateTimeOriginal' \
        "$TARGET_DIR"
fi

# --- Phase 1: Metadata Merge (Google Takeout) ---
echo "--- Phase 1: Merging Google Takeout Metadata ---"
# -q -q suppresses the "File not found" warnings for missing JSONs
exiftool -r -P -overwrite_original -q -q -ext jpg -ext jpeg -ext png -ext heic -ext mp4 -ext mov \
    -tagsfromfile %d/%f.%e.json "-DateTimeOriginal<PhotoTakenTimeTimestamp" "-GeoClick<GeoLocation" \
    -tagsfromfile %d/%f.json "-DateTimeOriginal<PhotoTakenTimeTimestamp" "-GeoClick<GeoLocation" \
    "$TARGET_DIR"

# --- Phase 2: Exact Deduplication ---
echo "--- Phase 2: Removing Exact Duplicates ---"
czkawka_cli dup -d "$TARGET_DIR" -D AEB

# --- Phase 3: Organization & Renaming ---
if [ "$RESET_MODE" = true ]; then
    EXIF_CONDITION=""
    echo "--- Phase 3: MODE: RESET (Re-organizing all files) ---"
else
    # Skip files already in YYYY/YYYY-MM-DD structure
    EXIF_CONDITION="-if \$directory !~ /\/\d{4}\/\d{4}-\d{2}-\d{2}$/"
    echo "--- Phase 3: MODE: SAFE (Processing new files only) ---"
fi

exiftool -r -progress -P -overwrite_original \
    -api QuickTimeUTC \
    $EXIF_CONDITION \
    -d "$TARGET_DIR/%Y/%Y-%m-%d/%Y%m%d_%H%M%S%-c.%%le" \
    '-filename<FileModifyDate' \
    '-filename<ModifyDate' \
    '-filename<CreateDate' \
    '-filename<DateTimeOriginal' \
    -ext jpg -ext jpeg -ext png -ext heic -ext webp -ext gif -ext tif -ext tiff -ext bmp \
    -ext mp4 -ext mov -ext avi -ext mkv -ext m4v -ext 3gp -ext wmv -ext mpg -ext mpeg -ext mxf \
    "$TARGET_DIR"

# --- Phase 4: Perceptual Deduplication (Similar Images) ---
echo "--- Phase 4: Removing Similar Images (Perceptual) ---"
czkawka_cli image -d "$TARGET_DIR" -D AEB

# --- Phase 5: Cleanup ---
echo "--- Phase 5: Cleaning up Junk & Empty Folders ---"
find "$TARGET_DIR" -type f \( -name "Thumbs.db" -o -name "desktop.ini" -o -name "*.ithmb" -o -name "Photo Database" -o -name "*.json" \) -delete
czkawka_cli empty-folders -d "$TARGET_DIR" -D

echo "--- Process Complete ---"

