#!/bin/sh
classes=grading/classes.txt
students=grading/students.txt
grades=grading/grades.txt

course=`echo $1 | tr 'A-Z' 'a-z'`
term=`echo $2 | tr -d -c '[0-9]'`
delim=$3

if [ .$delim. = .. ]
then
  delim="\t"
fi

if [ .$term. = .. ]
then
  yy=`date +%y`
  mm=`date +%m`
  t=0
  if [ $mm -eq 1 ]
  then
    t=1
  elif [ $mm -gt 1 -a $mm -lt 6 ]
  then
    t=2
  elif [ $mm -lt 9 ]
  then
    t=3
  elif [ $mm -lt 13 ]
  then
    t=4
  fi
  term=$yy$t
fi

if [ .$course. = .. ]
then
  nlines=`grep $term $classes | wc -l`
  if [ $nlines -ne 1 ]
  then
    grep $term $classes | cut -f1,3 -d','
    exit
  fi
fi

course=`grep $term $classes | cut -f3 -d','`
maxname=`grep $course $grades | cut -f1 -d',' | tr -d ' ' | tr 'a-zA-Z' '-' | sort -r | head -1 | wc -c`

classline=`grep $term $classes | grep -i $course | sort -u`
cref=`echo $classline | cut -f3 -d','`
ghw=`echo $classline | cut -f4 -d','`
gx1=`echo $classline | cut -f5 -d','`
gx2=`echo $classline | cut -f6 -d','`
nx1=`echo $classline | cut -f7 -d','`
nx2=`echo $classline | cut -f8 -d','`
vars="-vnamewid=$maxname -vpcHw=$ghw -vpcX1=$gx1 -vpcX2=$gx2 -vnx1=$nx1 -vnx2=$nx2 -vodelim=$delim -vcref=$cref"

grep $cref $grades | awk $vars 'BEGIN {
 FS = ","
 OFS = "\t"
 if (odelim != "\t" && odelim != "")
   {
    OFS = odelim
    fmt = "%s" odelim
   }
 else
   {
    fmt = "%-" namewid "s"
   }
 printf fmt, "Name"
 printf "      HW\t Mid\t Fin\t Esc\t Avg\tL\t( A / B / C )\n"
 for (i=0; i<namewid; i++)
   {
    printf "-"
   }
 printf "     -----\t-----\t-----\t----\t------\t--\t-------------\n"

 if (nx1 == 0 || nx1 == "")
    nx1 = 1
 if (nx2 == 0 || nx2 == "")
    nx2 = 1
}

($2 == cref) {
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

 x1total = 0
 x1max = hwmax + nx1
 for (i = hwmax + 1; i <= x1max; ++i)
    x1total += $i
 avgX1 = x1total * pcX1 / 100

 x2total = 0
 x2max = h1max + nx2
 for (i = x1max + 1; i <= NF; ++i)
    x2total += $i
 avgX2 = x2total * pcX2 / 100

 esc = 0
 if (hwcount == fields + 1 && x2total > 75) {
    esc = 100 - x1total
    if (esc > 0) {
      esc = 2 * sqrt(esc) * pcX1 / 100
    }
 }

 total = avgHw + avgX1 + avgX2 + esc

 grA  = 95
 grAm = 90
 grBp = 86
 grB  = 83
 grBm = 80
 grCp = 73
 grC  = 66
 grCm = 60

 forA = (grA - avgHw - avgX1) * 100 / pcX2
 forB = (grB - avgHw - avgX1) * 100 / pcX2
 forC = (grC - avgHw - avgX1) * 100 / pcX2

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

 printf fmt, trim($1)
 printf "     %5.2f\t%5.2f\t%5.2f", avgHw, avgX1, avgX2
 printf "\t%4.1f\t%6.2f\t%s", esc, total, letter
 if (total < grA) {
  printf "\t(%3.0f", forA
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

