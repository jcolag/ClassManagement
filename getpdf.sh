#!/bin/sh
lecture=$1
class=$2
attend=
if [ ".$lecture." = ".01." ]
then
  attend=../common/attendance.pdf
fi
for i in $lecture*
do
  sh ../note.sh "$i" pdf "$class"
done
listing=$(mktemp).lecture.txt
save=
touch "$listing"
for i in ${class}_${lecture}*.pdf
do
  base=$(echo "$i" | cut -f1 -d'.')
  ext=$(echo "$i" | cut -f2- -d'.')
  if [ -f "${base}_outline.$ext" ]
  then
    save=$i
  else
    echo "$i" >> "$listing"
  fi
done
pdfs=$(tr '\n' ' ' < "$listing")
pdflist=$save $attend "$pdfs"
classuc=$(echo "$class" | tr '[:lower:]' '[:upper:]')
pdftk $pdflist output "${classuc}_L${lecture}".pdf
rm -f "$listing"
rm "${class}_${lecture}"*.pdf

