#!/bin/sh

##########
###
### Set up initial values
###
##########

# List/table of classes (CSV)
classes=grading/classes.txt

# Table of grades per student per course (CSV)
grades=grading/grades.txt

# Downcase the course reference number
course=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Pull off the semester code
term=$(echo "$2" | tr -d -c '0-9')

# Get the expected output delimiter, a tab if not supplied
delim=$3

##########
###
### Provide defaults for missing parameters
###
##########

if [ ".$delim." = ".." ]
then
  delim="\t"
fi

# Guess at the current semester if not supplied
if [ ".$term." = ".." ]
then
  # Pick up parts of the date, two digit year and the month
  yy=$(date +%y)
  mm=$(date +%m)

  # Winter session is 1, Spring is 2, Summer is 3, Fall is 4
  # If it's still 0, your calendar is stranger than mine
  t=0
  if [ "$mm" -eq 1 ]
  then
    t=1
  elif [ "$mm" -gt 1 -a "$mm" -lt 6 ]
  then
    t=2
  elif [ "$mm" -lt 9 ]
  then
    t=3
  elif [ "$mm" -lt 13 ]
  then
    t=4
  fi

  # Append the term to the year
  term=$yy$t
fi

# If no course is supplied, check the classes available for the semester
if [ ".$course." = ".." ]
then
  nlines=$(grep -c "$term" "$classes")

  # if there's only one, go with it; if not, show the options and bail
  if [ "$nlines" -ne 1 ]
  then
    grep "$term" "$classes" | cut -f1,3 -d','
    exit
  fi
fi

# Get the course reference number(s) for the semester
course=$(grep "$term" "$classes" | cut -f3 -d',')

# Get the length of the longest name in the class
maxname=$(grep "$course" "$grades" | cut -f1 -d',' | tr -d ' ' | tr 'a-zA-Z' '-' | sort -r | head -1 | wc -c)

# Disassemble the course information to pass on to the awk code
classline=$(grep "$term" "$classes" | grep -i "$course" | sort -u)
cref=$(echo "$classline" | cut -f3 -d',')
ghw=$(echo "$classline" | cut -f4 -d',')
gx1=$(echo "$classline" | cut -f5 -d',')
gx2=$(echo "$classline" | cut -f6 -d',')
nx1=$(echo "$classline" | cut -f7 -d',')
nx2=$(echo "$classline" | cut -f8 -d',')

##########
###
### Process the data
###
##########

# Set up the variables to pass into awk
vars="-vnamewid=$maxname -vpcHw=$ghw -vpcX1=$gx1 -vpcX2=$gx2 -vnx1=$nx1 -vnx2=$nx2 -vodelim=$delim -vcref=$cref"

# Pull the grades for the class and process them
grep "$cref" "$grades" | awk $vars 'BEGIN {
 FS = ","
 OFS = "\t"

 # Format the name
 if (odelim != "\t" && odelim != "")
   {
    # Should replace the passed-in delimiter
    OFS = odelim
    fmt = "%s" odelim
   }
 else
   {
    fmt = "%-" namewid "s"
   }
 printf fmt, "Name"

 # Print a header line and separator
 # Should use the passed-in delimiter
 if (OFS == "\t")
    printf "      "
 printf "HW%s Mid%s Fin%s Esc%s Avg%sL%s( A / B / C )\n", OFS, OFS, OFS, OFS, OFS, OFS
 if (OFS == "\t")
   {
    for (i=0; i<namewid; i++)
      {
       printf "-"
      }
    printf "     -----\t-----\t-----\t----\t------\t--\t-------------\n"
   }

 # If either exam has no parts listed, assume each is one piece
 if (nx1 == 0 || nx1 == "")
    nx1 = 1
 if (nx2 == 0 || nx2 == "")
    nx2 = 1
}

# Deal with the grade components
($2 == cref) {
 # Total and count up the homework assignments
 hwtotal = 0
 start = 3
 hwmax = NF - (nx1 + nx2)
 hwcount = 0
 for (i = start; i <= hwmax; ++i) {
    hwtotal += $i
    if (trim($i) != "") {
      hwcount += 1
    }
 }
 fields = hwmax - start
 hwtotal = hwtotal + fields + hwcount
 avgHw = hwtotal * pcHw / fields / 10

 # Total the midterm exam components
 x1total = 0
 x1max = hwmax + nx1
 for (i = hwmax + 1; i <= x1max; ++i)
    x1total += $i
 avgX1 = x1total * pcX1 / 100

 # Total the final exam components
 x2total = 0
 x2max = h1max + nx2
 for (i = x1max + 1; i <= NF; ++i)
    x2total += $i
 avgX2 = x2total * pcX2 / 100

 # Figure out the points to return if the student improves
 esc = 0
 if (hwcount == fields + 1 && x2total > 75) {
    esc = 100 - x1total
    if (esc > 0) {
      esc = 2 * sqrt(esc) * pcX1 / 100
    }
 }

 # Get the final score
 total = avgHw + avgX1 + avgX2 + esc

 # Set thresholds for letter grades
 grA  = 95
 grAm = 90
 grBp = 86
 grB  = 83
 grBm = 80
 grCp = 73
 grC  = 66
 grCm = 60

 # Calculate the required final exam grade for an A, B, and C
 forA = (grA - avgHw - avgX1) * 100 / pcX2
 forB = (grB - avgHw - avgX1) * 100 / pcX2
 forC = (grC - avgHw - avgX1) * 100 / pcX2

 # Find the appropriate letter grade
 if (total >= grA)
    letter = "A"
 else if (total >= grAm)
    letter = "A-"
 else if (total >= grBp)
    letter = "B+"
 else if (total >  grB)
    letter = "B"
 else if (total >= grBm)
    letter = "B-"
 else if (total >  grCp)
    letter = "C+"
 else if (total >= grC)
    letter = "C"
 else if (total >= grCm)
    letter = "C-"
 else
    letter = "F"

 # Dump the information for the student
 printf fmt, trim($1)
 if (OFS == "\t")
    printf "     "
 printf "%5.2f%s", avgHw, OFS
 printf "%5.2f%s", avgX1, OFS
 printf "%5.2f%s", avgX2, OFS
 printf "%4.1f%s", esc, OFS
 printf "%6.2f%s", total, OFS
 printf "%s", letter, OFS

 # Only print requirements if the student has not already surpassed it
 if (total < grA) {
  printf "%s(%3.0f", OFS, forA
  if (total < grB) {
    printf "/%3.0f", forB
    if (total < grC) {
      printf "/%3.0f", forC
    }
  }
  printf ")\n"
 }
 else {
  printf "\n"
 }
}

function trim(str) {
  gsub(/^[ \t]+/,"", str)
  gsub(/[ \t]+$/,"", str)
  return str
}'

