#!/bin/sh
ORIG_IFS=$IFS
IFS='&'
go=go.sh
rm -f $go
touch $go
script=markdown.sh
dir=$1
class=$2
if [ ."$class". = .. ]
then
#  class=`ls -1 \\\"$dir\\\" | tr \"-_\" \"  \" | cut -f1 -d\" \" | sort | uniq -c | sort -n | rev | cut -f1 -d\" \" | rev | tail -1`
  esc=$dir
  files=$(ls -1 "$esc")
  clean=$(echo "$files" | tr "_-" "  " | cut -f1 -d" ")
  sorted=$(echo "$clean" | sort | uniq -c | sort -n)
  cut=$(echo "$sorted" | rev | cut -f1 -d" " | rev)
  last=$(echo "$cut" | tail -1)
  class=$last
fi
echo "$class"
for i in $dir/$class\ Lecture\ *.doc
do
  base=$(basename "$i")
#  infile=\"`echo $base | sed "s/\([()]\)/\\\1/g"`\"
  infile=\"$i\"
  outfile=$(echo "$base" | cut -f3- -d" " | cut -f1 -d"." | tr "A-Z -" "a-z__" | tr -d "()")
  echo sh $script "$infile" "$outfile" >> $go
done
sh $go
rm $go
IFS=$ORIG_IFS
