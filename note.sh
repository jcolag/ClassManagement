#!/bin/sh
base=`echo $1 | cut -f1 -d'.'`
class=`grep "Lecture [0-9]" $1 | sed 's/##[^0-9a-zA-Z].*//g' | tr 'A-Z' 'a-z' | tr -d '#' | cut -f1 -d':'`
docvars=
exam=`grep "Examination#" $1`
style=
stylevar=t
if [ ".$class." = ".." ]
then
  stylevar=f
  syllabus=`head -1 $1 | grep Syllabus`
  if [ ".$syllabus$exam." = ".." ]
  then
    stylevar=f
  else
    stylevar=s
  fi
fi
gpptype=-D`echo $2 | tr 'a-z' 'A-Z'`
size=`cat $1 | wc -l`
if [ ".$3." != ".." ]
then
  class=`echo $3 | tr 'A-Z' 'a-z'`
else
  class=c
fi
margin=1
if [ "$size" -le "9" ]
then
  margin=`grep "^\!" $1 | cut -f2 -d'@'`
  if [ ".$margin." = ".." ]
  then
    margin=1
  fi
fi
temptype=$2
if [ ".$temptype." = ".pdf." ]
then
  temptype=latex
fi
template=
if [ -f ../pandoc-templates/default.$temptype ]
then
  template=--template=../pandoc-templates/default
fi

# Just pass through any PDFs and bail
ext=`echo $1 | rev | cut -f1 -d'.' | rev`
if [ ".$ext." = ".pdf." ]
then
  cp $1 ${class}_$1
  echo PDF DONE!
  exit
fi

for vartext in `grep "^<!--" $1 | cut -c5- | rev | cut -c4- | rev`
do
  docvars=--variable=$vartext $docvars
done

if [ ".$stylevar." = ".t." ]
then
  style=--variable=style:lecture
elif [ ".$stylevar." = ".s." ]
then
  style=--variable=style:outline
fi
if [ ".$exam." = ".." ]
then
  font=
else
  font=--variable=fontsize:12pt
fi
gpp -H $gpptype $1 | pandoc $style $font $template --data-dir=../refs -s -S --ascii --variable=marg:$margin $docvars -o ${class}_${base}.$2

if [ "`grep "#note" $1 | wc -l`" = "0" ]
then
  echo DONE!
  exit
fi

# Remove delimited note text for lecture outline
if [ "$stylevar" = "t" ]
then
  style=--variable=style:outline
fi
gpp -H $gpptype -DOUTLINE $1 | pandoc --variable=fontsize:12pt $style $template --data-dir=../refs -s -S --ascii $docvars -o ${class}_${base}_outline.$2

echo DONE with outline!
