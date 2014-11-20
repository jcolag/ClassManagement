#!/bin/sh
class=$2
attend=
if [ ".$1." = ".01." ]
then
  attend=../common/attendance.pdf
fi
for i in $1*
do
  sh ../note.sh "$i" pdf "$class"
done
listing=$(mktemp).lecture.txt
save=
touch "$listing"
for i in ${class}_${1}*.pdf
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
pdfs=$save $attend "$pdfs"
classuc=$(echo "$class" | tr '[:lower:]' '[:upper:]')
#echo PDFS=$pdfs
pdftk $pdfs output "${classuc}_L${1}".pdf
rm -f "$listing"
rm "${class}_${1}"*.pdf

