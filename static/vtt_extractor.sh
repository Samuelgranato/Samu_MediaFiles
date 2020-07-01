#!/bin/bash
FILES=*
for f in $FILES
do
  ffmpeg -i "$f" -map 0:s:0 "${f%%.*}.vtt"
	echo $f
done
