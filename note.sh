#!/bin/sh

##########
###
### Set up initial values
###
##########

# Input file name
infile="$1"

# Base name (with path) of the input file
base=$(echo "$infile" | cut -f1 -d'.')

# Lecture line, normalized
class=$(grep "Lecture [0-9]" "$infile" | sed 's/##[^0-9a-zA-Z].*//g' | tr '[:upper:]' '[:lower:]' | tr -d '#' | cut -f1 -d':')

# Document-specific variables, set later if necessary
docvars=

# Exam line
exam=$(grep "Examination#" "$infile")

# Which style, set later
style=

# Style type: t = typical, s = syllabus, f = exam
stylevar=t
if [ ".$class." = ".." ]
then
  stylevar=f
  syllabus=$(head -1 "$infile" | grep Syllabus)
  if [ ".$syllabus$exam." = ".." ]
  then
    stylevar=f
  else
    stylevar=s
  fi
fi

# Output file type, for GPP macros
gpptype=-D$(echo "$2" | tr '[:lower:]' '[:upper:]')

# Number of lines in the input file
size=$(wc -l < "$infile")

# Output file prefix, c_ by default
if [ ".$3." != ".." ]
then
  class=$(echo "$3" | tr '[:upper:]' '[:lower:]')
else
  class=c
fi

# Page margin
margin=1
if [ "$size" -le "9" ]
then
  margin=$(grep "^\!" "$infile" | cut -f2 -d'@')
  if [ ".$margin." = ".." ]
  then
    margin=1
  fi
fi

# Output file type
outtype=$2
if [ ".$outtype." = ".pdf." ]
then
  outtype=latex
fi

# Pandoc template to use for conversion
template=
if [ -f ../pandoc-templates/default.$outtype ]
then
  template=--template=../pandoc-templates/default
fi

##########
###
### Just pass through any PDFs and bail
###
##########
ext=$(echo "$infile" | rev | cut -f1 -d'.' | rev)
if [ ".$ext." = ".pdf." ]
then
  cp "$infile" ${class}_"$infile"
  echo PDF DONE!
  exit
fi

##########
###
### Extract document-specific variables from input document
###
##########
for vartext in $(grep "^<!--" "$infile" | cut -c5- | rev | cut -c4- | rev)
do
  docvars="--variable=$vartext $docvars"
done

##########
###
### Set pandoc style parameter
###
##########
if [ ".$stylevar." = ".t." ]
then
  style=--variable=style:lecture
elif [ ".$stylevar." = ".s." ]
then
  style=--variable=style:outline
fi

##########
###
### Override font for exams
###
##########
if [ ".$exam." = ".." ]
then
  font=
else
  font=--variable=fontsize:12pt
fi

##########
###
### Preprocess and convert the file directly
###
### Note that $docvars contains multiple words, so should not be quoted.
###
##########
gpp -H "$gpptype" "$infile" | pandoc $style $font $template --data-dir=../refs -s -S --ascii --variable=marg:$margin $docvars -o "${class}_${base}.$2"

##########
###
### Quit if there's no detail to remove from the outline form
###
##########
if [ "$(grep -c "#note" "$infile")" = "0" ]
then
  echo DONE!
  exit
fi

##########
###
### Remove delimited note text for lecture outline
###
### Note that $docvars contains multiple words, so should not be quoted.
###
##########
if [ "$stylevar" = "t" ]
then
  style=--variable=style:outline
fi
gpp -H "$gpptype" -DOUTLINE "$infile" | pandoc --variable=fontsize:12pt $style $template --data-dir=../refs -s -S --ascii $docvars -o "${class}_${base}_outline.$2"

echo DONE with outline!
