=======================================================
smc.freeimage - Semantics' FreeImage wrapper for Python
=======================================================

smc.freeimage is a Python interface to the FreeImage and LCMS2 libraries.


Features of FreeImage
=====================

FreeImage wraps mature and widely-used libraries like LibJPEG, LibOpenJPEG,
LibPNG, LibRaw, LibTIFF4, OpenEXR and zlib in a consistent and powerful set
of APIs. 

http://freeimage.sourceforge.net/

 * Reading of 35 file formats and writing of more than 19 file formats as of
   FreeImage 3.15.3, including JPEG 2000, multiple subformats of TIFF 
   with G3/G4 fax compression and JPEG subsampling.
   
 * pixel depths from 1-32 bpp standard images up to formats like
   RGBAF and 2x64complex.
   
 * multi page images
 
 * Metadata (e.g. EXIF, IPTC/NAA, GeoTIFF, XMP) and ICC
 
 * Color adjustment, conversion and channel processing
 
 * Image resizing and rotation
 
 * High Dynamic Range (HDR) image processing and tone mapping
 
 * RAW camera files
 
Contrary to PIL it doesn't contain advanced image filters or drawing 
functions. FreeImage focuses on file formats


Features of LCMS2
=================

LCMS2 is a color management engine that implements V2 and V4 ICC profiles up
to V4.3. It supports transformation, proofing and introspection of profiles
for a large variety of color formats and targets.

http://www.littlecms.com/ 


Features of smc.freeimage
=========================

smc.freeimage is developed as part of the closed source Visual Library
framework.

 * mostly written with Cython with some lines of handwritten C Code and some
   Python helpers.
   
 * fast. It avoids copying large amounts of data and releases the GIL whenever
   possible.
   
 * 64bit safe, tested on i386/X86 and AMD64/X86_64 systems
 
 * thread safe

 * Wraps a large subset of FreeImage features


Authors
=======

Christian Heimes
Dirk Rothe


Copyright
=========
 
Copyright (C) 2008-2012 semantics GmbH. All Rights Reserved.::

  semantics
  Kommunikationsmanagement GmbH
  Viktoriaallee 45
  D-52066 Aachen
  Germany

  Tel.: +49 241 89 49 89 29
  eMail: info(at)semantics.de
  http://www.semantics.de/
 
