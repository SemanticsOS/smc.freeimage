.. smc.freeimage documentation master file, created by
   sphinx-quickstart on Tue Jul 10 12:39:04 2012.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to smc.freeimage's documentation!
=========================================

Contents:

.. toctree::
   :maxdepth: 2

Supported image formats
=======================

Image formats supported by FreeImage, PIL and ImageMagick

.. csv-table::
    :file: supported_filetypes.csv
    :delim: ;
    :quote: "
    :header-rows: 1
    :widths: 6,3,12,25,5,5,5,33

PIL has only a limited support for TIFF files. Some compression schemas and
multipage TIFFs aren't supported by PIL 1.1.7.

Image
=====

.. automodule:: smc.freeimage

.. autoclass:: Image
    :members:

.. autoclass:: Multipage
    :members:

.. autofunction:: jpegTransform

Format and color helpers
=========================

.. autoclass:: FormatInfo
    :members:

.. autoclass:: ImageDataRepresentation
    :members:

.. autofunction:: getColorOrder

.. autofunction:: getColorIndexRGBA

.. autofunction:: getColorMaskRGBA

.. autofunction:: getColorShiftRGBA

.. autofunction:: getColorMask555

.. autofunction:: getColorShift555

.. autofunction:: getColorMask565

.. autofunction:: getColorShift565

.. autofunction:: lookupX11Color

.. autofunction:: lookupSVGColor

Color Management
================

.. autoclass:: LCMSTransformation
    :members:

.. autoclass:: LCMSIccCache
    :members:

.. autoclass:: LCMSProfileInfo
    :members:

.. autofunction:: getLCMSVersion

.. autofunction:: XYZ2xyY

.. autofunction:: xyY2XYZ

.. autofunction:: getIntents


Other helper functions
======================

.. autofunction:: getVersion

.. autofunction:: getCompiledFor

.. autofunction:: getCopyright

.. autofunction:: hasJPEGTurbo


Exception
=========

.. autoexception:: FreeImageError

.. autoexception:: UnknownImageError

.. autoexception:: LoadError

.. autoexception:: SaveError

.. autoexception:: OperationError

.. autoexception:: LCMSException


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

