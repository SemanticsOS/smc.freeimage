=======================================================
smc.freeimage - Semantics' FreeImage wrapper for Python
=======================================================

smc.freeimage is a Python interface to the FreeImage library. 


Features of FreeImage
=====================

 * reading of 32 file formats and writing of 19 file formats as of
   FreeImage 3.15.3, including JPEG 2000, multiple subformats of TIFF 
   including G3/G4 fax compression and JPEG subsampling.
   
 * pixel depths from 1-32 bpp standard images up to formats like
   RGBAF and 2x64complex.
   
 * multi page images
 
 * Metadata (e.g. EXIF, IPTC/NAA, GeoTIFF, XMP) and ICC
 
 * Color adjustment, conversion and channel processing
 
 * High Dynamic Range (HDR) image processing and tone mapping
 
However FreeImage doesn't support advanced image processing, bitmap drawing
and vector graphics.


Features of smc.freeimage
=========================

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
 
