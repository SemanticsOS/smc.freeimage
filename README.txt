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


Performance
===========

smc.freeimage with libjpeg-turbo read JPEGs about three to six times faster
than PIL and writes JPEGs more than five times faster.

JPEG's restart markers are not compatible with libjpeg-turbo's Huffman
decoder optimization and reduce performance a lot. Please read the section
"Restart Makers" on the page http://www.libjpeg-turbo.org/About/Performance
for more information.

Python 2.7.3
read / write cycles: 300
test image: 1210x1778 24bpp JPEG (pon.jpg)
platform: Ubuntu 12.04 X86_64
hardware: Intel Xeon hexacore W3680@3.33GHz with 24 GB RAM

smc.freeimage, FreeImage 3.15.3 with jpeg turbo
 - read 9.237 sec
 - read 3.858 sec (w/o restart markers)
 - write 5.870 sec
smc.freeimage, FreeImage 3.15.3 standard
 - read 12.857 sec
 - read 6.629 sec (resaved)
 - write 21.817 sec
PIL 1.1.7
 - read 30.505 sec
 - read 22.998 sec (resaved)
 - write 34.439 sec


FreeImage + libjpeg-turbo
=========================

An experimental fork of FreeImage with libjpeg-turbo is available at
https://bitbucket.org/tiran/freeimageturbo


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
 
