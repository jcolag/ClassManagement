#!/bin/sh

##########
###
### Set up initial values
###
##########

# Lecture number, zero-padded
lecture=$1

# Class reference number
class=$2

# Same reference, with uppercase letters
classuc=$(echo "$class" | tr '[:lower:]' '[:upper:]')

# Temporary file name
listing=$(mktemp).lecture.txt

# Attendance file if first night
attend=
if [ ".$lecture." = ".01." ]
then
  attend=../common/attendance.pdf
fi

##########
###
### Set up PDF files for the evening
###
##########

for i in $lecture*
do
  sh ../note.sh "$i" pdf "$class"
done

##########
###
### Create a listing of generated files
###
##########

# Outline file, if any
save=

# Create a file for output list
touch "$listing"

# Dump file names to temporary list except for outline
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

# Combine outline, attendance, and other files in that order
pdflist=$save $attend "$pdfs"

# Combine the listed PDF files
pdftk $pdflist output "${classuc}_L${lecture}".pdf

# Clean up intermediate and temporary files
rm -f "$listing"
rm "${class}_${lecture}"*.pdf

