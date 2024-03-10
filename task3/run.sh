#!/usr/bin/bash

declare -a COMPILERS

while [[ $# -gt 0 ]]; do
	case "$1" in
		-s|--source)
			SOURCE_DIR="$2"
			shift 2
			;;
		-a|--archive)
			ARCHIVE_NAME="$2"
			shift 2
			;;
		-c|--compiler)
			IFS='=' read -r ext command <<< "$2"
			COMPILERS["$ext"]+="$command"
			shift 
			;;
		*)
			shift
			;;
	esac
done

if [ -z "$SOURCE_DIR" ] || [ -z "$ARCHIVE_NAME" ] || [ -z "$COMPILERS" ]; then
    echo "Error: parameters"
    exit 1
fi

TEMP_DIR=$(mktemp -d)
for ext in "${!COMPILERS[@]}"; do
    command="${COMPILERS[$ext]}"
    find "$SOURCE_DIR" -name "*.$ext" -print0 | while IFS= read -r -d '' file; do
        target_dir="$TEMP_DIR/$(dirname "$file")"
        mkdir -p "$target_dir" &&
        $command "$file" -o "$target_dir/$(basename "$file" ".$ext").exe"
    done
done

tar -zcf "$ARCHIVE_NAME.tar.gz" -C "$TEMP_DIR" .


echo "COMPLETE"
