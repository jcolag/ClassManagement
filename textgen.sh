#!/bin/sh

##########
###
### Set up initial values
###
##########

# Stash the internal field separator and replace it with an ampersand
ORIG_IFS=$IFS
IFS='&'

# Set up for the output script
go=go.sh
rm -f $go
touch $go

# Conversion script to leverage
script=markdown.sh

# Location of the files
dir=$1

# Default course reference number
class=$2

# Without a default course...
if [ ."$class". = .. ]
then
  # Get the list of files in the target directory
  esc=$dir
  files=$(ls -1 "$esc")

  # Get the most common file prefix
  clean=$(echo "$files" | tr "_-" "  " | cut -f1 -d" ")
  sorted=$(echo "$clean" | sort | uniq -c | sort -n)
  cut=$(echo "$sorted" | rev | cut -f1 -d" " | rev)
  last=$(echo "$cut" | tail -1)
  class=$last
fi

# Confirm the class
#echo "$class"

# Each file of lecture notes in the target directory...
for i in $dir/$class\ Lecture\ *.doc
do
  # Trim off any folder content
  base=$(basename "$i")

  # Quote the name
  infile=\"$i\"

  # Output file is named for everything between "Lecture" and the
  #   extension, with no punctuation or capitalization and delimiters
  #   converted to underscores
  outfile=$(echo "$base" | cut -f3- -d" " | cut -f1 -d"." | tr "A-Z -" "a-z__" | tr -d "()")

  # Add conversion to output script
  echo sh $script "$infile" "$outfile" >> $go
done

# Run and delete the conversion script
sh $go
rm $go

# Replace the field separator
IFS=$ORIG_IFS

