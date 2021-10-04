#!/bin/bash

FPATH="/home/kashz/Desktop/PG/intelligence/pdfs/*"

for f in $FPATH
do
	exiftool $f | grep Creator | cut -d ":" -f 2 | xargs >> creator.txt
done
