#!/usr/bin/env bash

STAGE_FILE=${1}

EXT="${STAGE_FILE##*.}"

TARFILE="${STAGE_FILE%%.$EXT}"
TAREXT="${TARFILE##*.}"

if [[ $TAREXT != "tar" ]]; then
	echo "The stage file you are trying to unpack (\`$STAGE_FILE\`) does not appear to be an archived TAR file"
else
	echo "Extracting \`${STAGE_FILE}\` inplace."
fi

if [ "$EXT" == "xz" ]; then
	tar -I 'xz -T0' -xvf "${STAGE_FILE}" --xattrs-include='*.*' --numeric-owner
elif [ "$EXT" == "zst" ]; then
        tar -I 'zstd -T0' -xvf "${STAGE_FILE}" --xattrs-include='*.*' --numeric-owner
elif [ "$EXT" == "bz2" ]; then
	tar -I pbzip2 -xvf "${STAGE_FILE}" --xattrs-include='*.*' --numeric-owner
elif [ "$EXT" == "gz" ]; then
	tar -I unpigz -xvf "${STAGE_FILE}" --xattrs-include='*.*' --numeric-owner
else
	echo "Not sure how to unpack \`${STAGE_FILE}\`"
fi
