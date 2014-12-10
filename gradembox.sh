#!/bin/sh

##########
###
### Set up initial values
###
##########

##
## Arguments
##

# Course code
course=$1

# Semester code
term=$2

# Sender's e-mail address
fromemail=$3

# Sender's name
name=$4

# Default grade delimiter
delim=,

##
## Files
##

# Table of classes
classes=grading/classes.txt

# Table of students
students=grading/students.txt

# Table of enrollments
enroll=grading/enroll.txt

# Script to generate grades
gradescript=findgrades.sh

# Temporary grade output file
gradecsv=$(mktemp)

##
## Simple formatted items
##

# Course with uppercase letters
courseuc=$(echo "$course" | tr '[:lower:]' '[:upper:]')

# Date in standard format
now=$(date)

# Date in e-mail header format
msgnow=$(date +'%a, %d %b %Y %H:%M:%S %z')

# Name to use in closing
signoff=$(echo "$name" | cut -f1 -d' ')

##########
###
### Make sure all the relevant data is available
###
##########

# Grab the class information
classline=$(grep "$course,$term" "$classes")

# Get the section code for the class
section=$(echo "$classline" | cut -f3 -d',')

# Complain and bail if there are less than two parameters,
# since we're not going to get much accomplished
if [ ".$term." = ".." ]
then
  echo Run as
  echo "  $0 class term name e-mail"
  exit
fi

# Generate a default sender e-mail address if not given one;
# This is almost never going to be correct, these days
if [ ".$fromemail." = ".." ]
then
  fromemail=$(whoami)@$(dnsdomainname --long)
fi

# Use the user name as the sender's name, if nothing better is provided
if [ ".$name." = ".." ]
then
  name=$(id -urn)
  init=$(echo "$name" | cut -c1 | tr '[:lower:]' '[:upper:]')
  rem=$(echo "$name" | cut -c2-)
  name=$init$rem
fi

##########
###
### Generate the actual grades
###
##########

sh "$gradescript" "$course" "$term" "$delim" | tail -n+2 > "$gradecsv"

##########
###
### Iterate through the students and generate e-mails to them
###
##########

while IFS= read -r gradeline
do
  # The student's family name is the first element of the grade line
  student=$(echo "$gradeline" | cut -f1 -d',')

  # Use the name and section code to get the student enrollment
  enrollment=$(grep -E "$student,.*,$section" "$enroll")

  # Grab the student's ID number
  sid=$(echo "$enrollment" | cut -f2 -d',')

  # Get the student's full information
  studentline=$(grep ",$sid," "$students")

  # Student's last name (which we probably already have as "$student")
  lname=$(echo "$studentline" | cut -f1 -d',')

  # Student's first name
  fname=$(echo "$studentline" | cut -f2 -d',')

  # If there's anything in quotes or parentheses, it's probably the
  # preferred nickname; therwise, if the name has multiple words,
  # the first word is probably what to call the student
  friendly=$(echo "$fname" | tr '()' '""')
  quote=$(expr index "$friendly" '"')
  if [ "$quote" -gt 0 ]
  then
    friendly=$(echo "$friendly" | cut -f2 -d'"')
  else
    friendly=$(echo "$friendly" | cut -f1 -d' ')
  fi

  # Student e-mail
  email=$(echo "$studentline" | cut -f5 -d',')

  # Final exam grade, plus how to refer to it - a 90 versus an 80
  final=$(echo "$gradeline" | cut -f4 -d',' | tr -d ' ')
  artfin=a
  digit=$(echo "$avg" | cut -c1)
  if [ "$digit" = 8 ]
  then
    artfin=an
  fi

  # Grade for the class, and how to refer to it as above
  avg=$(echo "$gradeline" | cut -f6 -d',' | tr -d ' ')
  artavg=a
  digit=$(echo "$avg" | cut -c1)
  if [ "$digit" = 8 ]
  then
    artavg=an
  fi

  # Letter grade for the course, and how to refer to it as above
  gpa=$(echo "$gradeline" | cut -f7 -d',' | tr -d ' ')
  letter=$(echo "$gpa" | cut -c1)
  artgpa=a
  if [ "$letter" = "A" ] || [ "$letter" = "F" ]
  then
    artgpa=an
  fi

  # Print the header and message
  echo "From - $now"
  echo "Subject: $courseuc Final Grades"
  echo "From: $name <$fromemail>"
  echo "To: $fname $lname <$email>"
  echo "Date: $msgnow"
  echo ""
  echo "Hi, $friendly--"
  echo ""
  echo "This is to notify you of your grade.  You earned $artfin $final on"
  echo "the final exam.  With homework and extra credit, that brings your"
  echo "overall average to $artavg $avg, which is $artgpa $gpa."
  echo ""
  echo "                              --$signoff"
  echo ""
  echo ""
done < "$gradecsv"

##########
###
### Clean up
###
##########

# Delete the temporary grade file
rm -f "$gradecsv"

