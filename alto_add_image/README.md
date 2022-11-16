Script to add image name to an ALTO document, by adding a `/alto/Description/sourceImageInformation element`, intended to be used with exports from Transkribus.

**NB that any existing `sourceImageInformation` element in the ALTO will be silently replaced.**

The script tries to find the image name from the METS file; if no file is provided, then it simply assumes that the ALTO file and
the image file have the same name, replacing `.xml` with the appropriate extension. Most of the work is done in calculating the variable
$imagefilename.

The analysis of the METS code is complicated significantly by several facts:

1. Transkribus output is inconsistent in treatment of spaces in filenames. At present, it leaves spaces in image names but
converts them to URI encoding (`%20`) in the ALTO file names. If this changes in future then the code will need to be modified.
Ideally it should check for spaces and encode if any are found, except that presumably other characters are also sometimes encoded
and sometimes not, so simply looking for spaces is not sufficient.
1. In the eScriptorium workflow, we convert spaces to underscores in all filenames (that is, the actual files, not what is found
in the various XML). The current code assumes this and so adds underscores as appropriate.
1. The Transkribus METS output does not include any indication of which `fptr` in the `structMap` corresponds to which type of file
(ALTO, image etc.). We could guess this from the ID format, but this is not robust to any future changes in Transkribus output.
Instead, the `fileGrp`s have to be searched for the `file` `@ID`s and the `fileGrp` `@ID` used to determine the type.

The code should be relatively robust, but a few improvements are still needed:

* A parameter could allow the user to choose behaviour if the METS can't be found (use XML filename or do nothing).
* Could check for existing `sourceImageInformation` and give a warning if present.
* ...


Peter A. Stokes, AOROC EPHE-PSL, 2022
