=======================================================
smc.freeimage - Semantics' FreeImage wrapper for Python
=======================================================

smc.freeimage is a Python interface to the FreeImage and LCMS2 libraries.


Features of FreeImage
=====================

FreeImage wraps mature and widely-used libraries like LibJPEG, LibOpenJPEG,
LibPNG, LibRaw, LibTIFF4, OpenEXR and zlib in a consistent, well documented
and powerful API.

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

 * fast, it avoids copying large amounts of data and releases the GIL whenever
   possible.

 * 64bit safe, tested on i386/X86 and AMD64/X86_64 systems

 * thread safe

 * wraps a large subset of FreeImage features

 * compatible with Python 2.6 to 3.3.


Performance
===========

smc.freeimage with libjpeg-turbo read JPEGs about three to six times faster
than PIL and writes JPEGs more than five times faster.

JPEG's restart markers are not compatible with libjpeg-turbo's Huffman
decoder optimization and reduce performance a lot. Please read the section
"Restart Makers" on the page http://www.libjpeg-turbo.org/About/Performance
for more information.

Python:
  2.7.3
read / write cycles::
  300
test image:
  1210x1778 24bpp JPEG (pon.jpg)
platform:
  Ubuntu 12.04 X86_64
hardware:
  Intel Xeon hexacore W3680@3.33GHz with 24 GB RAM

smc.freeimage, FreeImage 3.15.3 standard
----------------------------------------
 - read JPEG 12.857 sec
 - read JPEG 6.629 sec (resaved)
 - write JPEG 21.817 sec

smc.freeimage, FreeImage 3.15.3 with jpeg turbo
-----------------------------------------------
 - read JPEG 9.297 sec
 - read JPEG 3.909 sec (resaved)
 - write JPEG 5.857 sec
 - read LZW TIFF 17.947 sec
 - read biton G4 TIFF 2.068 sec
 - resize 3.850 sec (box)
 - resize 5.022 sec (bilinear)
 - resize 7.942 sec (bspline)
 - resize 7.222 sec (bicubic)
 - resize 7.941 sec (catmull rom spline)
 - resize 10.232 sec (lanczos3)
 - tiff numpy.asarray() with bytescale() 0.006 sec
 - tiff load + numpy.asarray() with bytescale() 18.043 sec

PIL 1.1.7
---------
 - read JPEG 30.389 sec
 - read JPEG 23.118 sec (resaved)
 - write JPEG 34.405 sec
 - read LZW TIFF 21.596 sec
 - read biton G4 TIFF: decoder group4 not available
 - resize 0.032 sec (nearest)
 - resize 1.074 sec (bilinear)
 - resize 2.924 sec (bicubic)
 - resize 8.056 sec (antialias)
 - tiff scipy fromimage() with bytescale() 1.165 sec
 - tiff scipy imread() with bytescale() 22.939 sec


Comparison to PIL (Pros and Cons)
=================================

Pros of smc.freeimage
---------------------

 * Faster! JPEG performance is about 3 to 6 times faster than PIL, numpy buffer
   access is more than 100 times faster and consumes less memory due to zero
   copy design.

 * Modern file formats! smc.freeimage supports JPEG 2000, HDR and EXR high
   dynamic range images and raw camera data (RAW).

 * Full baseline TIFF support! Contrary to PIL smc.freeimage supports all
   flavors of baseline TIFF like G3 and G4 compression and multipage TIFFs.

 * PEP 3118 buffer interface that exports images as 2d or 3d non-contiguous
   buffer.

 * Correct and optimized integration of a color management system (LittleCMS2)
   instead of lcms1 integration including caching of optimized
   transformations, in-place transformation and introspection of profiles.

 * Structured metadata access to EXIF, XMP and IPTC information, also supports
   fast loading of metadata without loading pixel data.

 * Lot's of color types! Bitmap (8bit) with 1, 4, 8, 16, 24 and 32 bits per
   pixel, (unsigned) int 16 and 32, float, double gray scale, complex, RGBA
   16bit and RGBA floats.

 * Static build support, no need for "make install". You just need a C99
   compatible C/C++ compiler, make and nasm (for FreeImage-Turob).


Cons of smc.freeimage
----------------------

 * Few image filters, no support for complex image filters in FreeImage

 * Low quality resize filters are slower than PIL's filters

 * No drawing API for primitives (lines, circles, boxes)

 * No text drawing support and libfreetype integration.

 * Still not feature complete and under development.


FreeImage + libjpeg-turbo
=========================

An experimental fork of FreeImage with libjpeg-turbo is available at
https://bitbucket.org/tiran/freeimageturbo


Testdata and Windows build files
================================

Neither the Windows build files nor the test images are included in the
source distribution. All files can be downloaded from
https://bitbucket.org/tiran/smc.freeimage .


Authors
=======

Christian Heimes

Dirk Rothe (testing and proposals)


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
