#!/bin/sh
# Extract text content from MS Word lecture file
antiword -s -m 8859-1.txt "$1" | sed 's/^[0-9][0-9]*\. /0. /g' | sed 's/^  *[a-z]) /    a) /g' | sed 's/^  *[ivx][ivx]*\. /        i. /g' | sed 's/^  *\([^ ][^).]\)/\1/g' > "$2".md
