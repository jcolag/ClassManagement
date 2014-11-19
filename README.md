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


