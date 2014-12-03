ClassManagement
===============

After teaching for years, I got tired of updating my lecture notes when changing systems and word processors.  I worked in WordPerfect to Microsoft Word to LibreOffice, and maybe a few others in between.  No LaTeX?  It seemed like a nice idea, but I wasn't aware of any convenient PC-based system and it wasn't popular at my school, which was run mostly by engineers.

That has changed, so this is my attempt to future-proof the notes.  Various shell scripts grab the text out of the notes, convert them to [Markdown](http://daringfireball.net/projects/markdown/) for permanent storage (and suitable for version control), and process them into PDF packages with everything needed for the night.

Right now, it's a hodge-podge of small scripts tuned specifically for my existing setup, but hopefully will be generalized and modernized quickly.

markdown.sh
-----------

This script gets the ball rolling.  It takes a Microsoft Word document as an input, converts it to plain text, and indents the ordered lists to show up properly.

This assumes that lecture points are organized along the lines of what I've done for many years...

    1.  Main Point.
        a)  Subsidiary topic.
            i.  Minor issues.

The script also assumes that you have [antiword](http://www.winfield.demon.nl/) installed.

Due to _antiword_ not being built for the purpose, the resulting output file is only Markdown in terms of the ordered lists.  Any use of bold, italics, or different typefaces must be handled manually.

textgen.sh
----------

While _markdown_ simply strips the text out of a single document, _textgen_ takes a target directory and uses or derives a common prefix to convert many files via the _markdown_ script.  To work, it presumes a common format for source files, in the form `CREF Lecture X (Title).doc`, where

 - `CREF` is a course reference number,

 - `X` is a number, and

 - `Title` indicates the lecture contents.

Converting a file with such a name will produce a Markdown-formatted file named like `X_title.md`.

The script actually operates by generating a temporary script, which is executed and deleted behind the scenes.

note.sh
-------

The _note_ script takes a set of lecture notes or supplemental material in Markdown format (with GPP preprocessor directives) as input and outputs a converted file in the specified format.  If the input material doubles as notes and a handout, the script generates both.

Invoke it with:

    note.sh input_file.md output_type class_name

For example, a typical run might look like:

    $ sh ../note.sh 06a_parameters.markdown pdf cs0000
    DONE with outline!
    
    $ l cs*
    cs0000_06a_parameters_outline.pdf  cs0000_06a_parameters.pdf

The script assumes that you have [GPP](http://en.nothingisreal.com/wiki/GPP) the Generic Preprocessor and [Pandoc](http://johnmacfarlane.net/pandoc/) installed.  Pandoc's template files are also assumed to be in a sister folder to the Markdown documents.

getpdf.sh
---------

The _getpdf_ script leverages _`node.sh`_ to generate and package everything needed for a lecture into one PDF package.  Looking for the (zero-padded, two-digit) lecture number, it creates each component, plus a blank attendance sheet for the first night.

A typical session might look like:

    $ sh ../getpdf.sh 04 cs0000
    DONE with outline!
    DONE!
    PDF DONE!
    PDF DONE!
    
    $ ls CS*
    CS0000_L04.pdf

The script assumes that you have [PDFtk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) installed.

Please note that, in calling `pdftk`, the script intentionally avoids quoting `$pdflist` against the judgment of any semantic checker (such as `shellcheck`).  In this case, word splitting is a requirement, because the variable holds multiple file names.  As a result, this presumably means that the PDF files to assemble may not have spaces in them.  My source files have no spaces, so this is no danger.

findgrades.sh
-------------

The _findgrades_ script is a stripped-down, single-purpose database for processing class grades.  The required data is spread across three files:

 - _`classes.txt`_ identifies each class along with the layout of grades for the class.  Its format is `CREF,TERM,SECTION,Homework,Midterm,Final,MidtermComponents,FinalComponents` (example:  `cs6033,092,2031LI,20,40,40,1,3`), as follows.

   - The _course reference number_ (CREF) identifies the course, something like _cs101_, but can literally be anything.

   - The _term_ identifies which semester the course is/was given, following the codes used by my school.  This should be a three-digit number where the first two digits are the last two digits of the year and the final digit is the semester number, 1 for winter, 2 for spring, 3 for summer, or 4 for fall.  Can theoretically be anything, but _findgrades_ will guess the current semester if not given anything explicit.  The example above is spring (`2`) of 2009.

   - The _section_ is whatever magic identifier is used for students to register for that class, where there are choices.  Again, this could be anything and will probably be unused except for reporting.

   - _Homework_ is the percent of the final grade contributed by average homework scores.

   - _Midterm_ is the percent of the final grade contributed by the midterm exam grade.

   - _Final_ is the percent of the final grade contributed by the final exam grade.

   - _Midterm components_ counts the number of separate scores totalling the midterm exam grade.  Likely to be `1` most of the time, but accounts for exams that include multiple parts.

   - _Final components_, like the midterm, counts the number of separate scores totalling the final exam grade.  Likely to be `1` most of the time, but accounts for exams that include multiple parts.

 - _`students.txt`_ contains contact information for each student, in the form `Last,FirstPlus,StudentID,Phone,EMail` (example:  `Kent,Clark N. (Superman),657001938,2925551234,ckent@dailyplanet.com`), as follows.

   - _Last Name_ is the student's family name.

   - _First Name_ is the student's given name, plus any other information.  Generally, whatever is in parentheses should be the student's preferred mode of address.

   - _Student ID_ is exactly what it sounds like, either issued by the school or (if your data is very old) possibly a Social Security Number as in the example above.

   - _Telephone Number_ is hopefully self-explanatory.

   - _E-Mail Address_ should also be self-explanatory.

   - __Note__ that it is not used by the _findgrades_ script, but rather is a simple format to connect the students with grades.

   - __Also note__ that my school banned communication with students regarding grades _except_ in person or where contact information was gathered on the student's first attending class.  This is why _`getpdf.sh`_ adds an attendance sheet to the first night's bundle, even though I never check attendance.

 - _`grades.txt`_, lastly, contains each student's grades for each course taken.  The format here is more free-form, because different courses have different assignments.  However, generally, they look something like `Name,Section,Extra,Homework+,Midterm+,Final+` (example: `Kent,12345,14,10,10,10,10,94,97`) as follows.

   - _Name_ is however you identify students.  I use last names unless there are multiples in the class.

   - _Section_ is the magic identifier from _`classes.txt`_, so the script knows what to look for.

   - _Extra Credit_ points get added to the homework total in my classes.  If you need something else, the _awk_ code will need to change.

   - Some number of _homework grades_, graded in my classes on a 0-10 scale.  The script considers whatever isn't another field to be a homework grade.

   - Some number of _midterm exam component grades_, which need to match whatever count you provided in _`classes.txt`_.

   - Some number of _final exam component grades_, which also need to match the count provided in _`classes.txt`_.

Please note that the script determines the grades based on whatever I last used to calculate them, including extra credit, points added for extreme improvement, and so forth.  If your grading policy is different, it needs to change in the _awk_ code.

Invoking _findgrades_ produces a table summarizing class performance, with tallies for the homework, midterm, final, any additional points (again, for improvement), a letter grade, and a final column to show the grade needed on the final for an __A__, __B__, or __C__, given the current conditions, in case that information is needed before the final.

A typical session might look something like the following.

    $ sh findgrades.sh cs9801 142
    Name             HW	     Mid	 Fin	 Esc	 Avg	L	( A / B / C )
    -----------     -----	-----	-----	----	------	--	-------------
    Browning        27.75	34.00	34.00	 0.0	 95.75	A
    Cabrera         36.25	36.00	37.20	 2.5	111.98	A
    Frazier         39.25	28.00	38.40	 4.4	110.03	A
    Hutchinson      25.75	34.00	36.40	 0.0	 96.15	A
    Jiminez         24.75	34.00	32.80	 0.0	 91.55	A-	( 91)
    Lee             34.00	38.00	41.60	 1.8	115.39	A
    Moran           28.00	38.00	39.60	 0.0	105.60	A
    Savage          33.25	38.00	36.00	 0.0	107.25	A
    Whitaker        29.25	20.00	20.00	 0.0	 69.25	C	(114/ 84)

If no arguments are given, the script will guess at the current semester (as I write this, it's December of 2014 or `144`).  If there is only one class available for that semester, it will process grades for that class.  If there are multiple possibilities, it will list them, instead.

