% Class Management Introduction
% John Colagioia
% Fall 2014
<#include "../gpp/macros.gpp">
##XX101 Lecture None <#space> Wednesday, 15 December 2014##
##Introductions and Definitions##

<#epigram Merely corroborative detail, intended to give artistic
  verisimilitude to an otherwise bald and unconvincing narrative.>

<#attribution Mikado, W. S. Gilbert>

0. This lecture is should illustrate the bulk of the toolchain in action.
I try to start every lecture with an item #0 to give context for the
remaining material.  Whatever number starts the numbered list, Pandoc uses
to start the converted list.
0. Headers:  <#note The first lines of each lecture file should be fairly
similar.>
    a) File Header:  <#note The very first lines---starting with a
`%`---are an optional header.  The title in the first line, especially, is
used in some conversions.>
    a) Macro File:  <#note Immediately following the header `#include`s
the GPP macros.>
    a) Lecture Titling:  <#note The standard title used is a second-level
(HTML `<h2></h2>`) header, with multiple parts.  Some of the effect I want
for my formatting is not the intended use-case for most typesetting, and
so requires some additional tinkering, sometimes.>
        i. Lecture Number:  <#note The course code and lecture number are
left-justified.>
        i. Date:  <#note Because of the `#space` macro, if the output
media supports it (e.g., _not_ HTML), the second half of the line is
right-justified.>
        i. Title:  <#note Subsequent title lines will be centered.>
    a) Epigram:  <#note For some course, a quote to introduce each night's
lecture can be appropriate.>
        i. Attribution:  <#note Be sure to get the attribution _right_
when possible, of course.>
0. Numbered List:  <#note Pandoc also handles counting each item after the
first, so it's generally most convenient to use the same number throughout
the notes, in case the item ordering needs to change.>
0. Lectures vs. Outlines:  <#note Because of the `#note` macro used in the
various items, the <#file markdown.sh> and <#file getpdf.sh> scripts will
convert this file twice.  One version will be a copy with the complete
text as would be obvious.  The other version will just be the skeletal
outline without the content embedded in `#note` following the headers.>
    a) Introduction:  <#note I tend to start the lecture with a brief
introduction that _does_ show up in the outline, usually with references
to supplemental reading like chapters in the textbook.>
    a) Homework:  <#note Any homework assignments obviously need to show
up in the outline, and make sense toward the end of the lecture.>
    a) Preview:  <#note The opposite of the Introduction, or maybe just
the introduction to the next lecture, for students who want to read
ahead.>
0. Syllabus:  <#note In <#file 01a_syllabus.md>, you will (unsurprisingly)
find a generic syllabus, which generally contains more formatting than a
typical lecture.>
0. Assembly:  <#note When generating a packet with <#file getpdf.sh>, the
result is organized as follows:>
    a) Notes:  <#note For each file with a `#note` macro (like this one),
the full-text version is filed first, under the assumption that it will
not be a part of the final handout.>
    a) Attendance Sheet:  <#note For the first lecture (those starting
with `01`, like this example), the full-text notes are followed by the
simple, stock attendance sheet found at <#file ../common/attendance.pdf>.
It is nothing more than a grid _probably_ created with some ancient
version of Microsoft Excel.>
    a) Handout:  <#note Every file associated with the lecture (other than
the full-text notes) are then added in name order.  For this example, that
is the example syllabus (`01a`), the outline form of these notes (`01b`),
and a sample program in an imaginary programming language (`01c`).>
0. Homework #1:  Generate the lecture notes and handout for this fake
lecture in PDF format using <#file note.sh>.  Generate a full night's
package, including the fake syllabus using <#file getpdf.sh>.
0. Coming Attractions:  That would be your job.  Go!  Be free!

