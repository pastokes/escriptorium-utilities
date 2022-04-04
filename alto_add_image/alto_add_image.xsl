<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/"
    xmlns:xlink="http://www.w3.org/1999/xlink" xpath-default-namespace="http://www.loc.gov/standards/alto/ns-v4#"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns="http://www.loc.gov/standards/alto/ns-v4#" exclude-result-prefixes="#all" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Script to add image name to an ALTO document, by adding a /alto/Description/sourceImageInformation element, intended to be used with
                exports from Transkribus.</xd:p>

            <xd:p>
                <xd:b>NB that any existing sourceImageInformation element in the ALTO will be silently replaced.</xd:b>
            </xd:p>

            <xd:p>The script tries to find the image name from the METS file; if no file is provided, then it simply assumes that the ALTO file and
                the image file have the same name, replacing .xml with the appropriate extension. Most of the work is done in calculating the variable
                $imagefilename.</xd:p>

            <xd:p>The analysis of the METS code is complicated significantly by several facts:</xd:p>
            <xd:ul>
                <xd:li>Transkribus output is inconsistent in treatment of spaces in filenames. At present, it leaves spaces in image names but
                    converts them to URI encoding (%20) in the ALTO file names. If this changes in future then the code will need to be modified.
                    Ideally it should check for spaces and encode if any are found, except that presumably other characters are also sometimes encoded
                    and sometimes not, so simply looking for spaces is not sufficient.</xd:li>
                <xd:li>In the eScriptorium workflow, we convert spaces to underscores in all filenames (that is, the actual files, not what is found
                    in the various XML). The current code assumes this and so adds underscores as appropriate.</xd:li>
                <xd:li>The Transkribus METS output does not include any indication of which fptr in the structMap corresponds to which type of file
                    (ALTO, image etc.). We could guess this from the ID format, but this is not robust to any future changes in Transkribus output.
                    Instead, the fileGrps have to be searched for the file IDs and the fileGrp ID used to determine the type.</xd:li>
            </xd:ul>
            <xd:p>Peter A. Stokes, EPHE, 2022</xd:p>
        </xd:desc>
        <xd:param name="metsloc">
            <xd:p>The path to the METS XML file. Leave empty if no METS file is available.</xd:p>
        </xd:param>
        <xd:param name="extension">
            <xd:p>The extension to be used for the image file name if no METS file is available (.jpeg by default).</xd:p>
        </xd:param>
    </xd:doc>

    <xd:doc>
        <xd:desc>
            <xd:p>The extension to be used for the image file name if no METS file is available (.jpeg by default).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="extension">.jpeg</xsl:param>

    <xd:doc>
        <xd:desc>
            <xd:p>The name of the ALTO file (i.e. the XML file being processed), including any processing such as converting underscores to escaped
                spaces.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="altofilename">
        <xsl:value-of select="replace(encode-for-uri(tokenize(base-uri(.), '/')[last()]), '_', '%20')"/>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>The path to the METS XML file. By default, try in the Leave empty if no METS file is available.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="metsloc" as="xs:string" select="concat(substring-before(base-uri(.), replace($altofilename, '%20', '_')), '../mets.xml')"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Local copy of the METS document, to avoid reloading.</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>
            <xd:p> The image filename obtained from the METS document:</xd:p>
            <xd:ul>
                <xd:li>Load the METS document and cache in a local variable -> $metsDoc</xd:li>
                <xd:li>Get the ALTO file ID from the ALTO file group based on the XML filename -> $altoID</xd:li>
                <xd:li>From structMap, find the DIV containing the ALTO ID and then extract the image ID by checking which sibling ID is also in the
                    IMG fileGrp -> imageID</xd:li>
                <xd:li>From the IMG fileGrp, get the image filename from the matching @href -> $tempImgFilename</xd:li>
                <xd:li>Run any conversions on METS version of filename (e.g. replace spaces with underscores)</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="imagefilename">
        <xsl:choose>
            <xsl:when test="not(document($metsloc))">
                <!-- No METS file: assume the image name matches that of the ALTO file name -->
                <xsl:value-of select="concat(substring-before($altofilename, '.xml'), $extension, 'xxx')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="metsDoc" select="doc($metsloc)"/>
                <!-- Find the image file name from the METS document -->
                <xsl:variable name="altoID">
                    <xsl:value-of
                        select="$metsDoc//mets:fileGrp[@ID = 'ALTO']/mets:file[mets:FLocat/@xlink:href = concat('alto/', $altofilename)]/@ID"/>
                </xsl:variable>
                <xsl:variable name="imageID">
                    <xsl:value-of
                        select="$metsDoc//mets:structMap//mets:div[mets:fptr/mets:area/@FILEID = $altoID]/mets:fptr/mets:area/@FILEID[. = $metsDoc//mets:fileGrp[@ID = 'IMG']/mets:file/@ID]"
                    />
                </xsl:variable>
                <xsl:variable name="tempImgFilename">
                    <xsl:value-of select="$metsDoc//mets:fileGrp[@ID = 'IMG']/mets:file[@ID = $imageID]/mets:FLocat/@xlink:href"/>
                </xsl:variable>
                <xsl:value-of select="replace($tempImgFilename, ' ', '_')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>Replaces existing Description element with a new sourceImageInformation element. Assumes that existng Description element can
                contain MeasurementUnit, OCRProcessing, and/or Processing in that order. May need to modify depending on (implementation of) version
                of ALTO</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Description">
        <xsl:copy>
            <xsl:copy-of select="@* | MeasurementUnit"/>
            <sourceImageInformation>
                <fileName>
                    <xsl:value-of select="$imagefilename"/>
                </fileName>
            </sourceImageInformation>
            <xsl:copy-of select="OCRProcessing | Processing"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Copy all other elements and attributes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()" priority="-99">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
