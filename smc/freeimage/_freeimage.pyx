# -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes, Dirk Rothe
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : Cython wrapper for FreeImage library
#=============================================================================
#
# COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT
# LIMITATION, WARRANTIES THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE,
# FIT FOR A PARTICULAR PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE
# QUALITY AND PERFORMANCE OF THE COVERED CODE IS WITH YOU. SHOULD ANY COVERED
# CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY
# OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR
# CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF
# THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
# THIS DISCLAIMER.
#

#--- imports
#include "freeimage.pxi"
cimport cpython
cimport freeimage as fi
cimport smc_fi
from libc cimport stdio
from libc cimport stdlib
from libc cimport string


import sys as _sys
from logging import getLogger

#--- constants
__all__ = (
    "Image", "Multipage", "LCMSTransformation", "LCMSException",
    "FreeImageError", "UnknownImageError", "LoadError", "SaveError", "OperationError",
    "getVersion", "getCompiledFor", "getCopyright", "FormatInfo", "ImageDataRepresentation",
    "getColorIndexRGBA", "getColorMask555", "getColorMask565", "getColorMaskRGBA",
    "getColorOrder", "getColorShift555", "getColorShift565", "getColorShiftRGBA",
    "getFormatCount", "jpegTransform", "lookupX11Color", "lookupSVGColor",
    "LCMSIccCache", "LCMSProfileInfo", "XYZ2xyY", "xyY2XYZ", "getIntents", "getLCMSVersion",
    "hasJPEGTurbo",
    )

# ***
# forward declarations
cdef class Image
cdef class FormatInfo

cdef extern from "errno.h" nogil:
    int errno

cdef extern from "FreeImage.h":
    # WITH GIL!
    ctypedef void (*FreeImage_OutputMessageFunction)(fi.FREE_IMAGE_FORMAT, smc_fi.const_char_ptr )
    cdef void FreeImage_SetOutputMessage(void (*)(fi.FREE_IMAGE_FORMAT, smc_fi.const_char_ptr ))

cdef extern from "smc_fi.h" nogil:
    ctypedef fi.FIBITMAP* (*FI_ConvertFunction)(fi.FIBITMAP *dib)
    int FREEIMAGE_TURBO

cdef object funicode(smc_fi.const_char_ptr s, errors="strict"):
    """Unicode helper from lxml's apihelpers.pxi
    """
    cdef Py_ssize_t slen
    cdef smc_fi.const_char *spos
    cdef bint is_non_ascii
    if smc_fi.IS_PYTHON3:
        slen = string.strlen(s)
        return s[:slen].decode("utf-8", errors)
    spos = s
    is_non_ascii = 0
    while spos[0] != c'\0':
        if spos[0] & 0x80:
            is_non_ascii = 1
            break
        spos += 1
    while spos[0] != c'\0':
        spos += 1
    slen = spos - s
    if is_non_ascii:
        return s[:slen].decode("utf-8", errors)
    return <bytes>s[:slen]

cdef bytes _decodeFilename(object filename):
    #if filename is None:
    #    return None
    if cpython.PyBytes_Check(filename):
        return filename
    elif cpython.PyUnicode_Check(filename):
        # XXX try FS encoding first
        return filename.encode("utf-8")
    else:
        raise TypeError(filename)

# LCMS integration
IF 1:
    include "_lcms.pxi"
ELSE:
    cdef class LCMSTransformation(object):
        def __init__(self,
                     str inprofile,
                     str outprofile="sRGB",
                     int format=0,
                     int intent=0,
                     unsigned long flags=0
                     ):
            raise NotImplementedError

    class LCMSException(Exception):
        pass

    class LCMSIccCache(object):
        def __init__(self):
            raise NotImplementedError

    cdef int lcmsFI(Image img, LCMSTransformation trafo):
        raise NotImplementedError

    cdef class LCMSProfileInfo(object):
        def __init__(self, *args):
            raise NotImplementedError

    def XYZ2xyY(float X, float Y, float Z):
        raise NotImplementedError

    def xyY2XYZ(float x, float y, float Y):
        raise NotImplementedError


DEF INCH_METER = 0.0254
DEF METER_INCH = 39.3700787

DEF ERR_ARG = -1
DEF ERR_UNSUP = -2
DEF ERR_CLOSED = -3

_META_MODELS = {
    "FIMD_NODATA" : fi.FIMD_NODATA,
    "FIMD_COMMENTS" : fi.FIMD_COMMENTS,
    "FIMD_EXIF_MAIN" : fi.FIMD_EXIF_MAIN,
    "FIMD_EXIF_EXIF" : fi.FIMD_EXIF_EXIF,
    "FIMD_EXIF_GPS" : fi.FIMD_EXIF_GPS,
    "FIMD_EXIF_MAKERNOTE" : fi.FIMD_EXIF_MAKERNOTE,
    "FIMD_EXIF_INTEROP" : fi.FIMD_EXIF_INTEROP,
    "FIMD_IPTC" : fi.FIMD_IPTC,
    "FIMD_XMP" : fi.FIMD_XMP,
    "FIMD_GEOTIFF" : fi.FIMD_GEOTIFF,
    "FIMD_ANIMATION" : fi.FIMD_ANIMATION,
    "FIMD_CUSTOM" : fi.FIMD_CUSTOM,
    }

_COLOR_TYPE_NAMES = {
    fi.FIC_MINISWHITE : "White",
    fi.FIC_MINISBLACK : "Black",
    fi.FIC_RGB : "RGB",
    fi.FIC_PALETTE : "Palette",
    fi.FIC_RGBALPHA : "RGBA",
    fi.FIC_CMYK : "CMYK"
}

_BPP = (1, 4, 8, 16, 24, 32)

_IMAGE_TYPES = (
    (fi.FIT_BITMAP, "bitmap"),
    (fi.FIT_UINT16, "unsigned int16"),
    (fi.FIT_INT16, "int16"),
    (fi.FIT_UINT32, "unsigned int32"),
    (fi.FIT_INT32, "int32"),
    (fi.FIT_FLOAT, "float"),
    (fi.FIT_DOUBLE, "double"),
    (fi.FIT_COMPLEX, "complex"),
    (fi.FIT_RGB16, "RGB int16"),
    (fi.FIT_RGBA16, "RGBA int16"),
    (fi.FIT_RGBF, "RGB float"),
    (fi.FIT_RGBAF, "RGBA float"),
)


# ***************************************************************************
# error handling
# Errors are stored in a thread local storage (TLS)
#
# DESIGN FLAW, possible memory leak ahead!
#
# The error handling system uses Python's low level TLS API. It's one of the
# very few APIs that don't depend the GIL. In the unlucky case a thread reports
# an error but the error is never handled in the thread, some memory is be
# lost.

cdef int tls_key = -1

cdef struct SmcFiError:
    fi.FREE_IMAGE_FORMAT format
    char *msg
    int msglen


cdef void clearError():
    global tls_key
    cdef SmcFiError *old

    old = <SmcFiError*>cpython.PyThread_get_key_value(tls_key)
    if old != NULL:
        # must free() value first, it's not freed by delete_key_value()
        if old.msg != NULL:
            stdlib.free(old.msg)
        stdlib.free(old)
        cpython.PyThread_delete_key_value(tls_key)


cdef void setError(fi.FREE_IMAGE_FORMAT format, smc_fi.const_char_ptr msg):
    cdef SmcFiError *error

    # clear error first, otherwise I can't set a new value
    clearError()

    error = <SmcFiError*>stdlib.malloc(sizeof(SmcFiError))
    if error == NULL:
        # error but can't report it here :/
        return

    error.msglen = string.strlen(msg)
    error.format = format
    error.msg = <char*>stdlib.malloc((error.msglen+1) * sizeof(char))
    if error.msg == NULL:
        stdlib.free(error)
        return
    string.strncpy(error.msg, msg, error.msglen)
    error.msg[error.msglen] = 0 # terminate string

    cpython.PyThread_set_key_value(tls_key, <void*>error)


cdef char* getError():
    # Returns either NULL or a malloc'ed char array
    # The caller is responsible to free the char*
    cdef char *msg
    cdef SmcFiError *error

    error = <SmcFiError*>cpython.PyThread_get_key_value(tls_key)

    if error == NULL:
        return NULL
    else:
        msg = error.msg
        error.msg = NULL
        clearError()
        return msg


cdef initErrorHandler():
    global tls_key
    if tls_key != -1:
        raise RuntimeError("Already initializes")
    # Initialize Python's threading API first. Sorry, there is no way
    # around it.
    cpython.PyThread_init_thread()
    tls_key = cpython.PyThread_create_key()
    FreeImage_SetOutputMessage(&setError)


#--- exceptions

def dispatchFIError(cls, *args):
    cdef char* err

    # get error message from FreeImage
    err = getError()
    if err != NULL:
        fimsg = unicode(err, "utf-8")
        stdlib.free(err)
        err = NULL
    else:
        fimsg = None

    # it's a memory error if the message contains words like
    # 'DIB allocation failed', 'allocate' and 'memory'
    # 'No space for raster buffer'
    # 'DIB allocation failed'
    # 'Not enough memory'
    if fimsg:
        fimsgl = fimsg.lower()
        for msg in ("allocate", "allocation", "memory", "no space"):
            if msg in fimsgl:
                # it's some kind of memory error
                return FreeImageMemoryError(*args, fimsg=fimsg)

    return cls(*args, fimsg=fimsg)


class FreeImageError(Exception):
    def __init__(self, *args, fimsg=None):
        if fimsg is not None:
            args = args + (fimsg,)
        self.fimsg = fimsg
        super(FreeImageError, self).__init__(*args)


class UnknownImageError(FreeImageError):
    pass


class LoadError(FreeImageError):
    pass


class SaveError(FreeImageError):
    pass


class OperationError(FreeImageError):
    pass


class FreeImageMemoryError(FreeImageError, MemoryError):
    pass


#--- wrappers

#cdef class _FiRGBQuad:
#    cdef fi.RGBQUAD* quad
#
#    def __init__(self):
#        self.quad = NULL
#
#    cdef void setData(self, fi.RGBQUAD* quad):
#        self.quad = quad
#
#    def __repr__(self):
#        if self.quad == NULL:
#            return "<FIRGBQuad(NULL)>"
#        return ("<FIRGBQuad(red:%i, green:%i, blue:%i, reserved:%i)>" %
#                self.red, self.green, self.blue, self.reserved
#                )
#
#    property red:
#        def __get__(self):
#            if self.quad == NULL:
#                raise ValueError("Empty")
#            return self.quad.rgbRed
#
#    property green:
#        def __get__(self):
#            if self.quad == NULL:
#                raise ValueError("Empty")
#            return self.quad.rgbGreen
#
#    property blue:
#        def __get__(self):
#            if self.quad == NULL:
#                raise ValueError("Empty")
#            return self.quad.rgbBlue
#
#    property reserved:
#        def __get__(self):
#            if self.quad == NULL:
#                raise ValueError("Empty")
#            return self.quad.rgbReserved
#
#cdef _FiRGBQuad FiRGBQuad(fi.RGBQUAD* quad):
#    cdef _FiRGBQuad rgb
#    rgb = _FiRGBQuad()
#    rgb.setData(quad)
#    return rgb

cdef class _DibWrapper:
    """Wrapper for bitmaps
    """
    cdef fi.FIBITMAP* dib
    cdef Image oldimg


cdef _DibWrapper DibWrapper(fi.FIBITMAP* dib, oldimg):
    """Factory to wrap a bitmap in an object
    """
    cdef _DibWrapper dw
    dw = _DibWrapper()
    dw.dib = dib
    dw.oldimg = oldimg
    return dw


cdef class _BitmapInfo:
    """Wrapper for bitmap info header
    """
    cdef readonly fi.DWORD size
    cdef readonly fi.LONG  width
    cdef readonly fi.LONG  height
    cdef readonly fi.WORD  planes
    cdef readonly fi.WORD  bit_count
    cdef readonly fi.DWORD compression
    cdef readonly fi.DWORD size_image
    cdef readonly fi.LONG  xppm
    cdef readonly fi.LONG  yppm
    cdef readonly fi.DWORD colors_used
    cdef readonly fi.DWORD colors_important

    def __repr__(self):
        return ("<BitmapInfo size=%lu, width=%ld, height=%ld, planes=%d,"
        " bit_count=%d, compression=%lu, size_image=%lu, xppm=%d,"
        " yppm=%d, colors_used=%lu, colors_important=%lu>" % (
        self.size, self.width, self.height, self.planes, self.bit_count,
        self.compression, self.size_image, self.xppm, self.yppm,
        self.colors_used, self.colors_important
    ))


cdef _BitmapInfo BitmapInfo(fi.BITMAPINFOHEADER *header):
    """Factory to wrap a bitmap info header
    """
    cdef _BitmapInfo bi
    bi = _BitmapInfo()
    bi.size = header.biSize
    bi.width = header.biWidth
    bi.height = header.biHeight
    bi.planes = header.biPlanes
    bi.bit_count = header.biBitCount
    bi.compression = header.biCompression
    bi.size_image = header.biSizeImage
    bi.xppm = header.biXPelsPerMeter
    bi.yppm = header.biYPelsPerMeter
    bi.colors_used = header.biClrUsed
    bi.colors_important = header.biClrImportant
    return bi


#cdef class FITag:
#    cdef fi.FITAG* tag
#    def __init__(self):
#        self.tag = NULL
#
#    #cdef void setData(self, fi.FITAG* tag):
#    #    self.tag = tag
#
#cdef _FITag FITag(fi.FITAG* tag):
#    cdef _FITag t
#    t = _FITag()
#    t.setData(tag)
#    return t


cdef class _MemoryIO:
    """Memory IO interface to an image

    A memory IO object is the preferred way to access a loaded image from
    Python. It provides a high-performance interface to the FreeImage memory
    subsystem. The image is available through a read only buffer, a file like
    object as well as as a string.
    """
    cdef fi.FIMEMORY *_mem
    cdef readonly int size
    cdef fi.FREE_IMAGE_FORMAT _format
    cdef Image _img

    def __init__(self, Image img not None, int format=-1, int flags=0):
        cdef fi.FIMEMORY *mem = NULL
        self._mem = NULL

        img._check_access(1)
        if format == fi.FIF_UNKNOWN:
            self._format = img._format
            # sensible default
            if self._format == fi.FIF_ICO:
                self._format = fi.FIF_PNG
        else:
            self._format = <fi.FREE_IMAGE_FORMAT>format

        if self._format < 0 or self._format > fi.FreeImage_GetFIFCount():
            raise ValueError("Invalid image format")

        mem = fi.FreeImage_OpenMemory(NULL, 0)
        if mem == NULL:
            raise dispatchFIError(FreeImageMemoryError, "fi.FreeImage_OpenMemory() has failed")

        if not fi.FreeImage_SaveToMemory(self._format, img._dib, mem, flags):
            fi.FreeImage_CloseMemory(mem)
            mem = NULL
            raise dispatchFIError(OperationError, "Can't save image to memory")

        fi.FreeImage_SeekMemory(mem, 0, stdio.SEEK_END)
        self.size = fi.FreeImage_TellMemory(mem)
        fi.FreeImage_SeekMemory(mem, 0, stdio.SEEK_SET)
        self._mem = mem

        # keep a reference to the image and increase the buffer counter
        # This avoid images from being closed while a buffer still points to
        # its data.
        self._img = img
        self._img._buffer_count += 1


    def __dealloc__(self):
        if self._mem != NULL:
            fi.FreeImage_CloseMemory(self._mem)
        self._mem = NULL
        self._img._buffer_count -= 1

    def __getreadbuffer__(self, int index, void **ptr):
        cdef fi.DWORD size
        if index != 0:
            raise SystemError("accessing non-existent string segment")
        fi.FreeImage_AcquireMemory(self._mem, <fi.BYTE**>ptr, &size)
        return size

    def __getsegcount__(self, Py_ssize_t *lenp):
        cdef long pos
        cdef Py_ssize_t len

        if lenp:
            len = <Py_ssize_t>self.size
            lenp = &len

        return 1

    def __str__(self):
        cdef char *buf
        cdef Py_ssize_t size

        # Access raw data though the FI memory io API and Python buffer API
        # Data is copied exactly ONE time in PyBytes_FromStringAndSize.
        # Neither the buffer API nor the MemoryIO API copies the data.
        smc_fi.PyObject_AsReadBuffer(self, <smc_fi.const_void_ptr *>&buf, &size)
        return cpython.PyBytes_FromStringAndSize(buf, size)

    property format:
        def __get__(self):
            return self._format

    def tell(self):
        """tell() -> int

        current file position
        """
        return fi.FreeImage_TellMemory(self._mem)

    def seek(self, int offset, unsigned whence=stdio.SEEK_SET):
        """seek(offset [, whence]) -> None

        Move to new file position.
        """
        if whence < stdio.SEEK_SET or whence > stdio.SEEK_END:
            raise ValueError("whence must be 0, 1 or 2")
        if not fi.FreeImage_SeekMemory(self._mem, offset, whence):
            raise dispatchFIError(OperationError, "Failure during seek")

    def read(self, signed size=-1):
        """read([size]) -> data
        """
        cdef unsigned amount
        cdef object result
        cdef char* buf
        cdef int pos, rsize

        rsize = size
        if rsize == 0:
            return ''
        elif rsize == -1:
            rsize = self.size
        elif rsize < 0:
            raise ValueError("Invalid size")

        # read up the EOF max
        pos = fi.FreeImage_TellMemory(self._mem)
        if (self.size - pos) < rsize:
            rsize = self.size - pos

        # allocate buffer
        result = cpython.PyBytes_FromStringAndSize(NULL, rsize)
        buf = cpython.PyBytes_AsString(result)
        # ATTENTION! I'm using a nasty but useful trick here.
        # The pay load (obsval) of a PyBytes object is (ab)used as target
        # buffer. PyBytes_FromStringAndSize() with NULL as first arguments
        # allocates the space for the data segment but doesn't initialize it.
        # PyBytes_AsString() gives direct access to the pay load. FI_ReadMemory
        # stores the image data directly into the string and thus avoids another
        # copy operation.
        amount = fi.FreeImage_ReadMemory(buf, <unsigned>rsize, 1, self._mem)
        # no data, invalid data
        if amount == 0:
            raise IOError("Failed to read %i bytes (requested %i)" %
                          (rsize, size))
        return result

###
cdef int floodfill(fi.FIBITMAP* dib, unsigned red, unsigned green, unsigned blue, unsigned alpha) nogil:
    """fill bitmap with the given colors

    only implemented for 24bit RGB images atm
    """
    cdef fi.BYTE *bits
    cdef fi.BYTE *pixel
    cdef unsigned width, height, pitch, bpp
    cdef unsigned x, y
    cdef fi.FREE_IMAGE_TYPE image_type

    if red < 0 or green < 0 or blue < 0 or alpha < 0:
        return ERR_ARG

    width = fi.FreeImage_GetWidth(dib)
    height = fi.FreeImage_GetHeight(dib)
    pitch = fi.FreeImage_GetPitch(dib)
    image_type = fi.FreeImage_GetImageType(dib)
    bpp = fi.FreeImage_GetBPP(dib)

    if image_type == fi.FIT_BITMAP and bpp == 24:
        if red > 255 or green > 255 or blue > 255 or alpha:
            return ERR_ARG

        bits = fi.FreeImage_GetBits(dib)
        for y from 0 <= y < height:
            pixel = bits
            for x from 0 <= x < width:
                pixel[fi.FI_RGBA_BLUE] = blue
                pixel[fi.FI_RGBA_GREEN] = green
                pixel[fi.FI_RGBA_RED] = red
                pixel += 3
            # next line
            bits += pitch

        return 0

    return ERR_UNSUP


cdef class Multipage:
    """Multipage image support
    """
    cdef fi.FREE_IMAGE_FORMAT _format
    cdef char* _filename
    cdef fi.FIMULTIBITMAP* _mp

    def __init__(self, filename, int flags = 0):
        cdef char* cfilename
        cdef stdio.FILE *tmpf

        bfilename = _decodeFilename(filename)
        cfilename = <char*>bfilename
        # try to open the file - will raise an exception if file can't be read
        tmpf = stdio.fopen(cfilename, "r")
        if tmpf == NULL:
            cpython.PyErr_SetFromErrnoWithFilename(IOError, bfilename)
        else:
            stdio.fclose(tmpf)

        self._filename = cfilename
        self._format = fi.FreeImage_GetFileType(cfilename, 0)
        if self._format == fi.FIF_UNKNOWN:
            raise dispatchFIError(UnknownImageError, filename)
        with nogil:
            self._mp = fi.FreeImage_OpenMultiBitmap(self._format, self._filename,
                                                    False, True, False, flags)
        if self._mp == NULL:
            raise dispatchFIError(LoadError, filename)

    def __dealloc__(self):
        fi.FreeImage_CloseMultiBitmap(self._mp, 0)

    def __len__(self):
        return fi.FreeImage_GetPageCount(self._mp)

    def __getitem__(self, int page):
        cdef fi.FIBITMAP* dib
        cdef Image img

        if page >= fi.FreeImage_GetPageCount(self._mp):
            raise KeyError(page)

        dib = fi.FreeImage_LockPage(self._mp, page)
        if dib == NULL:
            raise dispatchFIError(LoadError, "page %i" % page)
        img = Image(_bitmap=DibWrapper(dib, None))
        img._mp = self
        return img

    def __iter__(self):
        for page in range(len(self)):
            yield self[page]

    property filename:
        """filename
        """
        def __get__(self):
            return funicode(self._filename)

    property size:
        """size -> (width: int, height: int)
        """
        def __get__(self):
            return self.width, self.height

    property format:
        """format -> int (fi.FIF_*)

        Format is the image format like fi.FIF_JPEG or fi.FIF_PNG.
        """
        def __get__(self):
            return self._format

    def getLockedPageNumbers(self):
        cdef int count
        cdef int* pages
        cdef int i

        if not fi.FreeImage_GetLockedPageNumbers(self._mp, NULL, &count):
            raise dispatchFIError(FreeImageError, "GetLockedPageNumbers")

        pages = <int*>stdlib.malloc(count * sizeof(int))
        if not fi.FreeImage_GetLockedPageNumbers(self._mp, pages, &count):
            raise dispatchFIError(FreeImageError, "GetLockedPageNumbers")

        result = []
        for i from 0 <= i < count:
            result.append(pages[i])

        stdlib.free(pages)
        return sorted(result)


#--- Image
cdef void removeAllMetadata(fi.FIBITMAP *dib):
    """Remove ICC profile and metadata
    """
    fi.FreeImage_DestroyICCProfile(dib)
    for model in _META_MODELS.values():
        fi.FreeImage_SetMetadata(<fi.FREE_IMAGE_MDMODEL>model, dib, NULL, NULL)

cdef int cloneICCProfile(fi.FIBITMAP *src, fi.FIBITMAP *dst):
    """Clone ICC profile from src to dst
    """
    cdef fi.FIICCPROFILE* icc
    icc = fi.FreeImage_GetICCProfile(src)
    if icc != NULL:
        fi.FreeImage_CreateICCProfile(dst, icc.data, icc.size)
        return 1
    else:
        fi.FreeImage_DestroyICCProfile(dst)
        return 0

def _new_image(unsigned width, unsigned height, unsigned bpp,
              unsigned red_mask = 0, unsigned green_mask = 0, unsigned blue_mask = 0):
        cdef fi.FIBITMAP* dib
        cdef Image img
        with nogil:
            dib = fi.FreeImage_Allocate(width, height, bpp, red_mask, green_mask, blue_mask)

        if dib == NULL:
            raise dispatchFIError(LoadError, "Unable to allocate image")

        return Image(_bitmap=DibWrapper(dib, None))


cdef class Image:
    """Image(filename[, buffer=None[, flags=0]])

    Create a new Image. Either filename or buffer must applied.
    """
    cdef readonly unsigned int width
    cdef readonly unsigned int height
    #cdef readonly Py_ssize_t bitsize
    cdef fi.FREE_IMAGE_FORMAT _format
    cdef char* _filename
    cdef fi.FIBITMAP* _dib
    cdef fi.FIICCPROFILE* _icc
    cdef Multipage _mp
    cdef bint _changed

    # buffer interface
    cdef unsigned int _buffer_count
    cdef Py_ssize_t[3] _shape
    cdef Py_ssize_t[3] _strides
    cdef Py_ssize_t[3] _suboffsets
    cdef __cythonbufferdefaults__ = {"ndim": 2, "mode": "c"}

    def __init__(self, filename=None, buffer=None, _DibWrapper _bitmap = None,
                  int fd=-2, int flags = 0):
        if (bool(filename) + bool(_bitmap is not None) +
            bool(buffer is not None) + bool(fd != -2)) != 1:
            raise ValueError("Exactly one argument must be applied")
        if filename:
            self.from_filename(filename, flags)
        if buffer:
            self.from_buffer(buffer, flags)
        if _bitmap:
            if flags:
                raise ValueError("Flags argument not used")
            self.from_bitmap(_bitmap)
        if fd != -2:
            self.from_fd(fd, flags)
        self._buffer_count = 0

    new = staticmethod(_new_image)

    cdef from_filename(self, filename, int flags):
        cdef char* cfilename
        cdef stdio.FILE *tmpf

        bfilename = _decodeFilename(filename)
        cfilename = <char*>bfilename
        # try to open the file - will raise an exception if file can't be read
        tmpf = stdio.fopen(cfilename, "r")
        if tmpf == NULL:
            cpython.PyErr_SetFromErrnoWithFilename(IOError, bfilename)
        else:
            stdio.fclose(tmpf)

        self._filename = cfilename
        self._format = fi.FreeImage_GetFileType(cfilename, 0)
        if self._format == fi.FIF_UNKNOWN:
            raise dispatchFIError(UnknownImageError, filename)
        with nogil:
            self._dib = fi.FreeImage_Load(self._format, self._filename, flags)
        if self._dib == NULL:
            raise dispatchFIError(LoadError, filename)
        self._init_infos()

    cdef from_bitmap(self, _DibWrapper bitmap):
        if bitmap.dib == NULL:
            raise dispatchFIError(LoadError, "DIB")
        self._dib = bitmap.dib
        self._filename = "<bitmap>"
        if bitmap.oldimg:
            self._format = bitmap.oldimg._format
            self.dpi_x = bitmap.oldimg.dpi_x
            self.dpi_y = bitmap.oldimg.dpi_y
        else:
            # sensible default
            self._format = fi.FIF_PNG
        self._init_infos()

    cdef from_buffer(self, object obj, int flags):
        cdef Py_ssize_t size
        cdef fi.BYTE *buffer
        cdef fi.FIMEMORY *mem

        smc_fi.PyObject_AsReadBuffer(obj, <smc_fi.const_void_ptr *>&buffer, &size)
        mem = fi.FreeImage_OpenMemory(buffer, size)
        if mem == NULL:
            raise dispatchFIError(FreeImageMemoryError, "fi.FreeImage_OpenMemory() has failed")
        self._format = fi.FreeImage_GetFileTypeFromMemory(mem, 0)
        if self._format == fi.FIF_UNKNOWN:
            fi.FreeImage_CloseMemory(mem)
            mem = NULL
            raise dispatchFIError(UnknownImageError, "<buffer>")

        self._dib = fi.FreeImage_LoadFromMemory(self._format, mem, flags)
        fi.FreeImage_CloseMemory(mem)

        self._filename = ""
        self._init_infos()

    cdef _init_infos(self):
        self.width = fi.FreeImage_GetWidth(self._dib)
        self.height = fi.FreeImage_GetHeight(self._dib)
        #self.bitsize = self.height * fi.FreeImage_GetPitch(self._dib)
        self._icc = NULL
        self._mp = None
        self._changed = False

    def close(self):
        """close() -> None

        Close the image and free all resources. The close operation fails when
        a buffer is still using the image data.
        """
        if self._buffer_count:
            raise dispatchFIError(OperationError, "Image is still access from %i buffer%s." %
                                 (self._buffer_count,
                                  's' if self._buffer_count > 1 else ''))
        if self._dib is not NULL:
            if self._mp is None:
                # not member of a multipage bitmap
                with nogil:
                    fi.FreeImage_Unload(self._dib)
                    self._dib = NULL
            else:
                with nogil:
                    fi.FreeImage_UnlockPage(self._mp._mp, self._dib, self._changed)
                #self._mp = None

    cdef int _check_access(self, bint pixels) except -1:
        if self._dib == NULL:
            raise IOError("Operation on closed image")
            #return -1
        if pixels and not fi.FreeImage_HasPixels(self._dib):
            raise IOError("Image has no pixel data loaded")
            #return -1
        return 0

    def __dealloc__(self):
        self.close()

    def __sizeof__(self):
        cdef Py_ssize_t cls, data
        cls = (4 * 2 # 4 ints
               + 3 * 8 # three points
               + len(self._filename) # filename
               )
        if self._dib != NULL and fi.FreeImage_HasPixels(self._dib):
            # doesn't take alignment into account, might be larger
            data = self.bpp * self.width * self.height // 8
        else:
            data = 0
        return cls + data

    def __repr__(self):
        return "<%s %ix%i %ibpp (%s; %s) at 0x%x>" % (self.__class__.__name__,
            self.width, self.height, self.bpp, self.mimetype,
            self.color_type_name, id(self))


    # context wrapper
    def __enter__(self):
        self._check_access(0)
        return self

    def __exit__(self, exc, value, tb):
        self.close()

    # buffer interface
    def __getbuffer__(self, cpython.Py_buffer* buffer, int flags):
        cdef fi.BYTE *data
        cdef unsigned bitspp
        cdef fi.FREE_IMAGE_TYPE image_type
        cdef Py_ssize_t width, height, pitch
        cdef Py_ssize_t itemsize = 0, pixelcount = 0

        self._check_access(1)

        if not flags & cpython.PyBUF_RECORDS_RO:
            raise BufferError("Only strided and shaped buffers with format are supported")

        image_type = fi.FreeImage_GetImageType(self._dib)
        # cast width, height and pitch to signed size
        width = <Py_ssize_t>fi.FreeImage_GetWidth(self._dib)
        height = <Py_ssize_t>fi.FreeImage_GetHeight(self._dib)
        pitch = <Py_ssize_t>fi.FreeImage_GetPitch(self._dib)
        # data points to first element of last line in memory
        # the last line in memory is the top line of the image as FreeImage
        # stores pixel data upside down
        data = fi.FreeImage_GetScanLine(self._dib, height-1)

        if width == 0 or height == 0:
            # shouldn't be possible, paranoid
            raise BufferError("Can't create buffer of image with zero height or width")

        # bitmap
        if image_type == fi.FIT_BITMAP:
            # 8bit unsigned int
            bitspp = fi.FreeImage_GetBPP(self._dib)
            if bitspp == 24:
                buffer.format = b"B"
                itemsize = 1
                pixelcount = 3
            elif bitspp == 8:
                buffer.format = b"B"
                itemsize = 1
                pixelcount = 1
            elif bitspp == 32:
                buffer.format = b"B"
                itemsize = 1
                pixelcount = 4
            elif bitspp == 16:
                # 555 or 565
                buffer.format = b"H"
                itemsize = 2
                pixelcount = 1
            else:
                raise BufferError("Bitmap with %i bpp not supported" % bitspp)
        elif image_type == fi. FIT_UINT16:
            buffer.format = b"I"
            itemsize = 4
            pixelcount = 1
        elif image_type == fi. FIT_INT16:
            buffer.format = b"i"
            itemsize = 4
            pixelcount = 1
        elif image_type == fi. FIT_UINT32:
            buffer.format = b"Q"
            itemsize = 8
            pixelcount = 1
        elif image_type == fi. FIT_INT32:
            buffer.format = b"q"
            itemsize = 8
            pixelcount = 1
        elif image_type == fi. FIT_FLOAT:
            buffer.format = b"f"
            itemsize = 4
            pixelcount = 1
        elif image_type == fi. FIT_DOUBLE:
            buffer.format = b"d"
            itemsize = 8
            pixelcount = 1
        elif image_type == fi. FIT_COMPLEX:
            buffer.format = b"d"
            itemsize = 8
            pixelcount = 2
        elif image_type == fi. FIT_RGB16:
            buffer.format = b"H"
            itemsize = 2
            pixelcount = 3
        elif image_type == fi. FIT_RGBA16:
            buffer.format = b"H"
            itemsize = 2
            pixelcount = 4
        elif image_type == fi. FIT_RGBF:
            buffer.format = b"f"
            itemsize = 4
            pixelcount = 3
        elif image_type == fi. FIT_RGBAF:
            buffer.format = b"f"
            itemsize = 4
            pixelcount = 4

        if itemsize == 0 or pixelcount == 0:
            raise BufferError("Unknown or unsupported image type %i" % image_type)

        buffer.buf = data
        buffer.obj = self
        buffer.len = width * height * pixelcount * itemsize
        buffer.readonly = 0
        buffer.shape = self._shape
        buffer.strides = self._strides
        buffer.itemsize = itemsize
        buffer.suboffsets = NULL
        buffer.internal = NULL

        if pixelcount == 1:
            buffer.ndim = 2
            self._shape[0] = height
            self._shape[1] = width
            self._strides[0] = -pitch # negative pitch to compensate for upside down
            self._strides[1] = 1
        else:
            buffer.ndim = 3
            self._shape[0] = height
            self._shape[1] = width
            self._shape[2] = pixelcount
            self._strides[0] = -pitch # negative pitch to compensate for upside down
            self._strides[1] = pixelcount
            self._strides[2] = itemsize

        self._buffer_count += 1

    def __releasebuffer__(self, cpython.Py_buffer* buffer):
        if buffer.obj is not self:
            raise BufferError("%r is not %r" % (buffer.obj, self))
        self._buffer_count -= 1

    ## old buffer API for PIL
    #def __getreadbuffer__(self, int segment, void **ptr):
    #    cdef fi.BYTE *bits
    #
    #    if segment != 0:
    #        raise SystemError("accessing non-existent string segment")
    #
    #    self._check_access(1)
    #    bits = fi.FreeImage_GetBits(self._dib)
    #    ptr = <void**>&bits
    #
    #    return self.bitsize
    #
    #def __getwritebuffer__(self, int segment, void **ptr):
    #    cdef fi.BYTE *bits
    #
    #    if segment != 0:
    #        raise SystemError("accessing non-existent string segment")
    #
    #    self._check_access(1)
    #    bits = fi.FreeImage_GetBits(self._dib)
    #    ptr = <void**>&bits
    #
    #    return self.bitsize
    #s
    #def __getsegcount__(self, Py_ssize_t *lenp):
    #    if lenp:
    #        lenp = &self.bitsize
    #    return 1


    # **********************************************************************
    # Info

    property filename:
        """filename
        """
        def __get__(self):
            return funicode(self._filename)

    property size:
        """size -> (width: int, height: int)
        """
        def __get__(self):
            return self.width, self.height

    property pitch:
        """pitch -> int

        Get pitch of scan lines (width + padding)
        """
        def __get__(self):
            self._check_access(1)
            return fi.FreeImage_GetPitch(self._dib)

    property format:
        """format -> int (fi.FIF_*)

        Format is the image format like fi.FIF_JPEG or fi.FIF_PNG.
        """
        def __get__(self):
            return self._format

    property type:
        """type -> int (fi.FIT_*)

        Type referes to the data type of the image like fi.FIT_BITMAP or fi.FIT_RGBF.
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_GetImageType(self._dib)

    property mimetype:
        """mimetype -> str

        mimetype of the image, e.g. image/jpeg
        """
        def __get__(self):
            return funicode(fi.FreeImage_GetFIFMimeType(self._format))

    property dpi_x:
        """dpi_x -> int

        Dots per inch (x axis)
        """
        def __get__(self):
            self._check_access(0)
            return round(fi.FreeImage_GetDotsPerMeterX(self._dib) * INCH_METER)

        def __set__(self, float dpi):
            if dpi < 0:
                raise ValueError("DPI must be positive or zero.")
            self._check_access(1)
            fi.FreeImage_SetDotsPerMeterX(self._dib, int(round(dpi * METER_INCH)))

    property dpi_y:
        """dpi_y -> int

        Dots per inch (y axis)
        """
        def __get__(self):
            self._check_access(0)
            return round(fi.FreeImage_GetDotsPerMeterY(self._dib) * INCH_METER)

        def __set__(self, float dpi):
            if dpi < 0:
                raise ValueError("DPI must be positive or zero.")
            self._check_access(1)
            fi.FreeImage_SetDotsPerMeterY(self._dib, int(round(dpi * METER_INCH)))

    property dpi:
        """dpi -> (dpi_x: int, dpi_y: int)
        """
        def __get__(self):
            return self.dpi_x, self.dpi_y

    property dpm_x:
        """dpm_x -> int

        Dots per meter (x axis)
        """
        def __get__(self):
            self._check_access(0)
            return int(fi.FreeImage_GetDotsPerMeterX(self._dib))

        def __set__(self, unsigned dpm):
            self._check_access(1)
            fi.FreeImage_SetDotsPerMeterX(self._dib, dpm)

    property dpm_y:
        """dpm_y -> int

        Dots per meter (y axis)
        """
        def __get__(self):
            self._check_access(0)
            return int(fi.FreeImage_GetDotsPerMeterY(self._dib))

        def __set__(self, unsigned dpm):
            self._check_access(1)
            fi.FreeImage_SetDotsPerMeterY(self._dib, dpm)

    property dpm:
        """dpm -> (dpm_x: int, dpm_y: int)
        """
        def __get__(self):
            return self.dpm_x, self.dpm_y

    property colors_used:
        """colors_used -> int

        Returns number of colors used in the image (palette-size) or 0 for
        high color images.
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_GetColorsUsed(self._dib)

    property bpp:
        """bpp -> int

        bits per pixel
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_GetBPP(self._dib)

    property has_icc:
        """has_icc -> bool

        Returns true if the image has an ICC profile
        """
        def __get__(self):
            if self._icc is NULL:
                self._check_access(0)
                with nogil:
                    self._icc = fi.FreeImage_GetICCProfile(self._dib)
            if self._icc.data:
                return True
            else:
                return False

    property icc_cmyk:
        """icc_cmyk -> bool
        """
        def __get__(self):
            if self._icc is NULL:
                self._check_access(0)
                with nogil:
                    self._icc = fi.FreeImage_GetICCProfile(self._dib)
            if self._icc is NULL:
                return None
            if (self._icc.flags & fi.FIICC_COLOR_IS_CMYK) == fi.FIICC_COLOR_IS_CMYK:
                return True
            else:
                return False

    property color_type:
        """color_type -> int (fi.FIC_*)

        Get color type of the image, e.g. fi.FIC_MINISBLACK, fi.FIC_RGB, fi.FIC_CMYK ...
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_GetColorType(self._dib)

    property color_type_name:
        """color_type_name -> str
        """
        def __get__(self):
            cdef fi.FREE_IMAGE_COLOR_TYPE ct
            self._check_access(0)
            ct = fi.FreeImage_GetColorType(self._dib)
            return _COLOR_TYPE_NAMES.get(ct, "UNKNOWN")

    property is_transparent:
        """is_transparent -> bool
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_IsTransparent(self._dib)

    property has_bg_color:
        """has_bg_color -> bool
        """
        def __get__(self):
            self._check_access(0)
            return fi.FreeImage_HasBackgroundColor(self._dib)

    property rgb_mask:
        """Get bitmask for red, green and blue channel
        """
        def __get__(self):
            self._check_access(0)
            if fi.FreeImage_GetColorType(self._dib) != fi.FIC_RGB:
                return None
            return (fi.FreeImage_GetRedMask(self._dib),
                    fi.FreeImage_GetGreenMask(self._dib),
                    fi.FreeImage_GetBlueMask(self._dib))

    property colororder:
        """Get color order (BGR or RGB)

        The color order depends on the endianess of the system
        """
        def __get__(self):
            if fi.FREEIMAGE_COLORORDER == fi.FREEIMAGE_COLORORDER_BGR:
                return "BGR"
            else:
                return "RGB"

    property has_pixels:
        """Check if image is loaded with fi.FIF_LOAD_NOPIXELS

        @return: True if image has pixel and isn't loaded with fi.FIF_LOAD_NOPIXELS
        """
        def __get__(self):
            self._check_access(0)
            return bool(fi.FreeImage_HasPixels(self._dib))

    property closed:
        """closed -> bool
        """
        def __get__(self):
            return self._dib == NULL

    # **********************************************************************
    # fill with colors
    def floodfill(self, int red, int green, int blue):
        """floodfill(red, green, blue) -> None

        Fill the entire image
        """
        self._check_access(1)
        result = floodfill(self._dib, red, green, blue, 0)
        if result == ERR_ARG:
            raise ValueError("Wrong arguments, colors must be between 0% and 100%")
        if result == ERR_UNSUP:
            raise NotImplementedError("floodfill for type: %i, bpp:  %i" %
                (fi.FreeImage_GetImageType(self._dib), self.bpp))


    # **********************************************************************
    # save
    def save(self, filename, int format=-1, int flags=0):
        """save(filename[, format=-1[, flags=0]])

        Save image to file
        """
        cdef fi.BOOL result
        cdef char* cfilename
        self._check_access(1)

        filename = _decodeFilename(filename)
        cfilename = <char*>filename
        if format == -1:
            format = fi.FreeImage_GetFIFFromFilename(cfilename)
        if format < 0 or format > fi.FreeImage_GetFIFCount() - 1:
            raise ValueError("Invalid format %i" % format)
        with nogil:
            result = fi.FreeImage_Save(<fi.FREE_IMAGE_FORMAT>format, self._dib,
                                       cfilename, flags)
        if not result:
            raise dispatchFIError(SaveError, "Failed to save image to file '%s'" % filename)

    def toBuffer(self, int format=-1, int flags=0):
        """toBuffer([format=-1[, flags=0]] -> _MemoryIO instance

        Access raw data of the image as read-only buffer or file like object
        """
        if smc_fi.IS_PYTHON3:
            raise NotImplementedError("tuBuffer() not implemented for 3.x yet")
        self._check_access(1)
        return _MemoryIO(self, format, flags)

    def toPIL(self, int format=-1, int flags=0):
        """toPIL([format=-1[, flags=0]] -> PIL image
        """
        from PIL.Image import open as pil_open
        buffer = self.toBuffer(format, flags)
        return pil_open(buffer)

    def getRaw(self):
        """Get raw data

        Returns raw image data as bytes. It's up to you to interpret the raw
        bytes according to image type, bpp, color order and stride padding.

        @note: FreeImage stores the lines upside down
        @return: copy of raw image data
        @rtype: bytes
        """
        cdef fi.BYTE *bits
        cdef unsigned height, pitch

        self._check_access(1)

        bits = fi.FreeImage_GetBits(self._dib)
        height = fi.FreeImage_GetHeight(self._dib)
        pitch = fi.FreeImage_GetPitch(self._dib)
        barray = cpython.PyBytes_FromStringAndSize(<char*>bits, height*pitch)
        return barray

    # **********************************************************************
    # scale
    def resize(self, int width, int height, int filter=fi.FILTER_BOX):
        """resize(width: int, height: int[, filter=FILTER_BOX]) -> new image
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)

        if width <= 0 or height <= 0:
            raise ValueError("negative sizes are not supported")

        with nogil:
            dib = fi.FreeImage_Rescale(self._dib, width, height, <fi.FREE_IMAGE_FILTER>filter)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to resize image")
        return Image(_bitmap=DibWrapper(dib, self))


    # **********************************************************************
    # Copy / Paste / Crop

    def paste(self, Image src not None, unsigned left, unsigned top, unsigned alpha = 256):
        """paste(src: Image, left: int, top: int[, alpha=256]) -> None

        Paste source image into this image.

        alpha: 0 to 255 for alpha blending or 256 for combination.
        """
        cdef int result
        self._check_access(1)
        if src._dib == NULL:
            raise IOError("Operation on closed source image")
        with nogil:
            result = fi.FreeImage_Paste(self._dib, src._dib, left, top, alpha)
        if not result:
            raise dispatchFIError(OperationError, "Failed to paste image")

    def clone(self):
        """clone() -> new image

        @note: clone uses low level FI functions to clone metadata and ICC, too.
        """
        cdef fi.FIBITMAP* dib
        cdef Image clone

        self._check_access(1)
        with nogil:
            dib = fi.FreeImage_Clone(self._dib)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to clone image")
        clone = Image(_bitmap=DibWrapper(dib, self))
        #clone._filename = self._filename
        return clone

    def crop(self, int left, int top, int right, int bottom):
        """crop(left: int, top: int, right: int, bottom: int) -> new image
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        if right == -1 and bottom == -1:
            right = self.width
            bottom = self.height
        if left < 0 or top < 0 or right < 0 or bottom < 0:
            raise ValueError("Boundaries must be larger than 0")
        # XXX more checks
        with nogil:
            dib = fi.FreeImage_Copy(self._dib, left, top, right, bottom)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to copy image")
        # we are not interested in ICC profiles in cropped images
        removeAllMetadata(dib);
        return Image(_bitmap=DibWrapper(dib, self))

    # **********************************************************************
    # convert

    cdef Image convert_helper(self, FI_ConvertFunction conv):
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        with nogil:
            dib = conv(self._dib)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to convert image")
        return Image(_bitmap=DibWrapper(dib, self))

    def convert_4bits(self):
        """convert_4bits() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo4Bits)

    def convert_8bits(self):
        """convert_8bits() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo8Bits)

    def greyscale(self):
        """greyscale() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertToGreyscale)

    def convert_16bits555(self):
        """convert_16bits555() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo16Bits555)

    def convert_16bits565(self):
        """convert_16bits565() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo16Bits565)

    def convert_24bits(self):
        """convert_24bits() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo24Bits)

    def convert_32bits(self):
        """convert_32bits() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertTo32Bits)

    def convert_rgbf(self):
        """convert_rgbf() -> new image
        """
        return self.convert_helper(fi.FreeImage_ConvertToRGBF)

    def to_standard(self, bint scale_linear=True):
        """to_standard([scale_linear=True]) -> new image
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        with nogil:
            dib = fi.FreeImage_ConvertToStandardType(self._dib, scale_linear)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to convert image")
        return Image(_bitmap=DibWrapper(dib, self))

    def to_type(self, unsigned dst_type, bint scale_linear=True):
        """to_type(dst_type[, scale_linear=True]) -> new image
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        with nogil:
            dib = fi.FreeImage_ConvertToType(self._dib, <fi.FREE_IMAGE_TYPE>dst_type, scale_linear)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to convert image")
        return Image(_bitmap=DibWrapper(dib, self))

    def dither(self, unsigned dither_alg):
        """dither(dither_alg) -> new image

        Converts a bitmap to 1-bit monochrome bitmap using a dithering algorithm.
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        with nogil:
            dib = fi.FreeImage_Dither(self._dib, <fi.FREE_IMAGE_DITHER>dither_alg)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to dither image")
        return Image(_bitmap=DibWrapper(dib, self))

    def threshold(self, unsigned threshold):
        """threshold(threshold: int) -> new image

        Converts a bitmap to 1-bit monochrome bitmap

        @param threshold: 0 to 255
        """
        cdef fi.FIBITMAP* dib
        cdef Image new

        self._check_access(1)
        if threshold > 255:
            raise ValueError("Threshold must be between 0 and 255")
        with nogil:
            dib = fi.FreeImage_Threshold(self._dib, <fi.BYTE>threshold)

        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to applying threshold to image")
        return Image(_bitmap=DibWrapper(dib, self))


    # **********************************************************************
    # Rotation / mirroring

    def flipHorizontal(self):
        """flipHorizontal() -> new image
        """
        cdef Image copy
        copy = self.clone()
        with nogil:
            fi.FreeImage_FlipHorizontal(copy._dib)
        return copy

    def flipVertical(self):
        """flipVertical() -> new image
        """
        cdef Image copy
        copy = self.clone()
        with nogil:
            fi.FreeImage_FlipVertical(copy._dib)
        return copy

    def rotate(self, int angle):
        """rotate(angle: int) -> new image

        Only angles 90, 180 and 270 degrees are supported

        Warning: rotation will result in loose of metadata
        """
        cdef fi.FIBITMAP* dib

        self._check_access(1)
        if angle == -90:
            angle = 270
        if angle not in (90, 180, 270):
            raise ValueError("Only -90, 90, 180, 270 are supported")
        # FreeImage uses CCW angle, but we prefer CW angle
        if angle == 90:
            angle = 270
        elif angle == 270:
            angle = 90

        with nogil:
            dib = fi.FreeImage_Rotate(self._dib, angle, NULL)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to rotate image")
        cloneICCProfile(self._dib, dib)
        fi.FreeImage_CloneMetadata(dib, self._dib)
        return Image(_bitmap=DibWrapper(dib, self))

    def rotateEx(self, double angle, double x_shift=0, double y_shift=0,
                    double x_origin=0, double y_origin=0, bint use_mask=True):
        """ rotate(angle: double, ...) -> new image

        wrapper around fi.FreeImage_RotateEx

        angle: angle in degree
        """
        cdef fi.FIBITMAP* dib

        self._check_access(1)

        with nogil:
            dib = fi.FreeImage_RotateEx(self._dib, angle, x_shift, y_shift,
                                        x_origin, y_origin, use_mask)
        if dib == NULL:
            raise dispatchFIError(OperationError, "Failed to rotate image")
        cloneICCProfile(self._dib, dib)
        fi.FreeImage_CloneMetadata(dib, self._dib)
        return Image(_bitmap=DibWrapper(dib, self))

    # **********************************************************************
    # ICC

    def getICC(self):
        """getICC() -> str

        Return ICC profile a byte string
        """
        cdef fi.FIICCPROFILE* icc
        if not self.has_icc:
            return None
        return cpython.PyBytes_FromStringAndSize(<char *>self._icc.data,
                                                 self._icc.size)

    #def setICC(self, str profile):
    #    """setICC()
    #
    #    Set ICC profile as byte string
    #    """
    #    cdef char *cp = cpython.PyBytes_AsString(profile)
    #    self._check_access(0)
    #    self._icc = fi.FreeImage_CreateICCProfile(self._dib, <char*>cp, len(profile))


    def removeICC(self):
        """Remove ICC profile
        """
        self._check_access(0)
        self._icc = NULL
        fi.FreeImage_DestroyICCProfile(self._dib)


    def iccTransform(self, LCMSTransformation trafo=None):
        """Apply an LCMS transformation
        """
        self._check_access(1)
        if trafo is None:
            trafo = LCMSTransformation(self.getICC(), b"sRGB")
        lcmsFI(self, trafo)

    # **********************************************************************
    # Metadata

    def getMetadataCount(self):
        """getMetadataCount() -> dict

        Count number of metadata for each model
        """
        counts = {}
        self._check_access(0)
        for name, model in _META_MODELS.items():
            counts[name] = int(fi.FreeImage_GetMetadataCount(model, self._dib))
        return counts

    def getMetadata(self, binary=False, errors="strict"):
        """getMetadata() -> dict

        @param binary: if true, return values as binary instead of unicode string
        @param strict: encoding error handling for unicode string conversion
        """
        cdef fi.FIMETADATA *handle = NULL
        cdef fi.FITAG *tag
        cdef char *key, *string, *descr
        metas = {}

        self._check_access(0)
        for name, model in _META_MODELS.items():
            handle = fi.FreeImage_FindFirstMetadata(model, self._dib, &tag)
            if handle == NULL:
                continue
            meta = metas.setdefault(name, {})
            while 1:
                key = <char *>fi.FreeImage_GetTagKey(tag)
                string = <char *>fi.FreeImage_TagToString(model, tag, NULL)
                descr = <char *>fi.FreeImage_GetTagDescription(tag)
                if binary:
                    value = string
                else:
                    value = funicode(string)
                if descr != NULL:
                    meta[funicode(key)] = value, funicode(descr)
                else:
                    meta[funicode(key)] = value, None
                if not fi.FreeImage_FindNextMetadata(handle, &tag):
                    fi.FreeImage_FindCloseMetadata(handle)
                    break

        return metas

    def copyMetadataFrom(self, Image src not None):
        self._check_access(0)
        if src._dib == NULL:
            raise IOError("Operation on closed source image")
        if not fi.FreeImage_CloneMetadata(self._dib, src._dib):
            raise dispatchFIError(OperationError, "Failed to copy metadata")

    def clearMetadata(self):
        self._check_access(0)
        for name, model in _META_MODELS.items():
            if not fi.FreeImage_SetMetadata(model, self._dib, NULL, NULL):
                raise dispatchFIError(OperationError, "Failed to delete metadata model %s" % name)

    def getInfoHeader(self):
        """getInfoHeader() -> BitmapInfo instance
        """
        cdef fi.BITMAPINFOHEADER *header
        self._check_access(0)
        header = fi.FreeImage_GetInfoHeader(self._dib)
        return BitmapInfo(header)

    # **********************************************************************
    # Color adjustment

    def adjustColors(self, float brightness=0.0, float contrast=0.0,
                    float gamma=1.0, invert=0):
        """adjustColors(brightness=0.0, contrast=0.0, gamma=1.0,
                        invert=False) -> None
        """
        cdef int _invert

        self._check_access(1)

        _invert = cpython.PyObject_IsTrue(invert)
        if brightness < -100.0 or brightness > +100.0:
            raise ValueError("Brightness must be between -100. and +100. "
                             "(percentage)")
        if contrast < -100.0 or contrast > +100.0:
            raise ValueError("Contrast must be between -100 and +100 "
                             "(percentage)")
        if gamma <= 0.0:
            raise ValueError("Gamma must be greater than 0.")

        if not fi.FreeImage_AdjustColors(self._dib, brightness, contrast,
                                      gamma, invert):
            raise dispatchFIError( OperationError, "Failed to adjust color.")

    def adjustGamma(self, float gamma=1.0):
        """adjustGamma(gamma=1.0) -> None
        """
        self.adjustColors(gamma=gamma)

    def adjustBrightness(self, float brigthness=0.0):
        """adjustBrightness(brigthness=0.0) -> None
        """
        self.adjustColors(brigthness=brigthness)

    def adjustContrast(self, float contrast=0.0):
        """adjustContrast(contrast=0.0) -> None
        """
        self.adjustColors(contrast=contrast)

    def invert(self):
        """invert() -> None
        """
        self.adjustColors(invert=1)

    def getHistogram(self, int channel=fi.FICC_BLACK):
        """getHistogramm([channel=fi.FICC_BLACK]) -> list[256]
        """
        cdef int bpp, i
        cdef fi.DWORD hist[256]

        self._check_access(1)
        bpp = fi.FreeImage_GetBPP(self._dib)

        if bpp == 24 or bpp == 32:
            if not (channel == fi.FICC_BLACK or channel == fi.FICC_RED or
                    channel == fi.FICC_GREEN or channel == fi.FICC_BLUE):
                raise ValueError("%i bpp image supports histogram for red, "
                                 "green, blue or black channels only, got %i."
                                 % (bpp, channel))
        elif bpp == 8:
            if channel != fi.FICC_BLACK:
                raise ValueError("8 bpp image supports histogram for black "
                                 "channel only, got %i." % channel)
        else:
            raise ValueError("%i bpp is not supported by histogram function."
                             % bpp)
        if not fi.FreeImage_GetHistogram(self._dib, hist,
                                         <fi.FREE_IMAGE_COLOR_CHANNEL>channel):
            raise dispatchFIError(OperationError, "Failed to retrieve histogram.")

        # TODO: use PyList_New?
        result = []
        for i from 0 <= i < 256:
            result.append(int(hist[i]))

        return result

    # **********************************************************************
    # draw
    def hline(self, unsigned y, unsigned xstart, signed xend, unsigned linewidth=1,
              unsigned red=0, unsigned green=0, unsigned blue=0):
        cdef fi.FREE_IMAGE_TYPE image_type
        cdef unsigned width, height, bpp
        cdef fi.RGBQUAD color
        cdef int ys

        self._check_access(1)
        image_type = fi.FreeImage_GetImageType(self._dib)
        width = fi.FreeImage_GetWidth(self._dib)
        height = fi.FreeImage_GetHeight(self._dib)
        bpp = fi.FreeImage_GetBPP(self._dib)

        if y > height:
            raise ValueError("y must be smaller than height of image")
        if xend == -1:
            xend = width
        if xstart >= xend:
            raise ValueError("x start must be smaller than x end")
        if linewidth < 0 or linewidth >= height:
            raise ValueError("Invalid line height")

        ys = y
        if linewidth > 2:
            ys -= linewidth / 2
        if ys < 0:
            ys = 0
        if ys + linewidth > height:
            ys -= (ys + linewidth) - height

        if image_type == fi.FIT_BITMAP and bpp == 24:
            color.rgbBlue = blue
            color.rgbRed = red
            color.rgbGreen = green
            color.rgbReserved = 0
            #_sys.stderr.write("%s- %s-%s" % (ys, ys+linewidth, xstart, xend))
            self.hline_rgb24(&color, linewidth, ys, xstart, xend)
        #elif image_type == fi.FIT_BITMAP and bpp == 1:
        #    # bitonal bitmap
        #    self.hline_1bpp(red, linewidth, ys, xstart, xend)
        elif image_type == fi.FIT_BITMAP and bpp == 8:
            # monochrome 8bit bitmap
            self.hline_mono(red & 0xff, linewidth, ys, xstart, xend)
        else:
            raise NotImplementedError("hline for type: %i, bpp:  %i" %
                 (fi.FreeImage_GetImageType(self._dib), self.bpp))

    cdef int hline_rgb24(self, fi.RGBQUAD *color, unsigned linewidth,
                   unsigned y0, unsigned xs, unsigned xe):
        """Horizontal line for RGB images

        Draws line on coordinate y from xs to xe
        """
        cdef fi.BYTE *pixel
        cdef unsigned x, y
        cdef fi.FIBITMAP* dib

        self._check_access(1)
        dib = self._dib

        with nogil:
            for y from y0 <= y < y0+linewidth:
                pixel = fi.FreeImage_GetScanLine(dib, y)
                for x from 0 <= x < xe - xs:
                        pixel[fi.FI_RGBA_BLUE] = color.rgbBlue
                        pixel[fi.FI_RGBA_GREEN] = color.rgbGreen
                        pixel[fi.FI_RGBA_RED] = color.rgbRed
                        pixel += 3
        return 0

    cdef int hline_mono(self, fi.BYTE color, unsigned linewidth,
                   unsigned y0, unsigned xs, unsigned xe):
        """Horizontal line for mono color images

        Draws line on coordinate y from xs to xe
        """
        cdef fi.BYTE *pixel
        cdef unsigned x, y
        cdef fi.FIBITMAP* dib

        self._check_access(1)
        dib = self._dib

        with nogil:
            for y from y0 <= y < y0+linewidth:
                pixel = fi.FreeImage_GetScanLine(dib, y)
                for x from 0 <= x < xe - xs:
                        pixel[0] = color
                        pixel += 1
        return 0

#    cdef int hline_1bpp(self, fi.BYTE color, unsigned linewidth,
#                   unsigned y0, unsigned xs, unsigned xe):
#        """Horizontal line for b/w images
#
#        Draws line on coordinate y from xs to xe
#        """
#        cdef fi.BYTE *pixel
#        cdef unsigned x, y
#        cdef fi.FIBITMAP* dib
#
#        self._check_access(1)
#        dib = self._dib
#
#        # not yet implemented
#        return 0
#
#        with nogil:
#            for y from y0 <= y < y0+linewidth:
#                pixel = fi.FreeImage_GetScanLine(dib, y)
#                for x from 0 <= x < xe - xs:
#                        pixel[0] = color
#                        pixel += 1
#        return 0


    def vline(self, unsigned x, unsigned ystart, signed yend, unsigned linewidth=1,
              unsigned red=0, unsigned green=0, unsigned blue=0):
        cdef fi.FREE_IMAGE_TYPE image_type
        cdef unsigned width, height, bpp
        cdef fi.RGBQUAD color
        cdef int xs

        self._check_access(1)
        image_type = fi.FreeImage_GetImageType(self._dib)
        width = fi.FreeImage_GetWidth(self._dib)
        height = fi.FreeImage_GetHeight(self._dib)
        bpp = fi.FreeImage_GetBPP(self._dib)

        if x > width:
            raise ValueError("x must be smaller than width of image")
        if yend == -1:
            yend = height
        if ystart >= yend:
            raise ValueError("y start must be smaller than y end")
        if linewidth < 0 or linewidth >= width:
            raise ValueError("Invalid line width")

        xs = x
        if linewidth > 2:
            xs -= linewidth / 2
        if xs < 0:
            xs = 0
        if xs + linewidth > width:
            xs -= (xs + linewidth) - width

        #if xs < 0 or (xs + linewidth) > width:
        #    raise ValueError("xs: %s, width: %s" % (xs, width))
        #if ystart < 0 or yend > height:
        #    raise ValueError

        if image_type == fi.FIT_BITMAP and bpp == 24:
            color.rgbBlue = blue
            color.rgbRed = red
            color.rgbGreen = green
            color.rgbReserved = 0
            #_sys.stderr.write("%s-%s %s-%s" % (xs, xs+linewidth, ystart, yend))
            self.vline_rgb24(&color, linewidth, xs, ystart, yend)
        #elif image_type == fi.FIT_BITMAP and bpp == 1:
        #    # bitonal bitmap
        #    self.vline_1bpp(red, linewidth, xs, ystart, yend)
        elif image_type == fi.FIT_BITMAP and bpp == 8:
            # monochrome 8bit bitmap
            self.vline_mono(red & 0xff, linewidth, xs, ystart, yend)
        else:
            raise NotImplementedError("vline for type: %i, bpp:  %i" %
                                      (image_type, bpp))


    cdef int vline_rgb24(self, fi.RGBQUAD *color, unsigned linewidth,
                   unsigned x0, unsigned ys, unsigned ye):
        """Vertical line for RGB images

        Draws line on coordinate y from xs to xe
        """
        cdef fi.BYTE *pixel
        cdef unsigned x, y
        cdef fi.FIBITMAP* dib

        self._check_access(1)
        dib = self._dib

        with nogil:
            for y from ys <= y < ye:
                pixel = fi.FreeImage_GetScanLine(dib, y)
                pixel += x0 * 3
                for x from 0 <= x < linewidth:
                    pixel[fi.FI_RGBA_BLUE] = color.rgbBlue
                    pixel[fi.FI_RGBA_GREEN] = color.rgbGreen
                    pixel[fi.FI_RGBA_RED] = color.rgbRed
                    pixel += 3
        return 0

    cdef int vline_mono(self, fi.BYTE color, unsigned linewidth,
                   unsigned x0, unsigned ys, unsigned ye):
        """Vertical line for mono color images

        Draws line on coordinate y from xs to xe
        """
        cdef fi.BYTE *pixel
        cdef unsigned x, y
        cdef fi.FIBITMAP* dib

        self._check_access(1)
        dib = self._dib

        with nogil:
            for y from ys <= y < ye:
                pixel = fi.FreeImage_GetScanLine(dib, y)
                pixel += x0
                for x from 0 <= x < linewidth:
                    pixel[0] = color
                    pixel += 1
        return 0

#    cdef int vline_1bpp(self, fi.BYTE color, unsigned linewidth,
#                   unsigned x0, unsigned ys, unsigned ye):
#        """Vertical line for b/w images
#
#        Draws line on coordinate y from xs to xe
#        """
#        cdef fi.BYTE *pixel
#        cdef unsigned x, y
#        cdef fi.FIBITMAP* dib
#
#        self._check_access(1)
#        dib = self._dib
#
#        # not yet implemented
#        return 0
#
#        with nogil:
#            for y from ys <= y < ye:
#                pixel = fi.FreeImage_GetScanLine(dib, y)
#                pixel += x0
#                for x from 0 <= x < linewidth:
#                    pixel[0] = color
#                    pixel += 1
#        return 0

# Format Info

def FormatInfo_from_filename(cls, filename):
    """from_filename(filename) -> FormatInfo instance

    Guess format from filename
    """
    filename = _decodeFilename(filename)
    format = fi.FreeImage_GetFIFFromFilename(filename)
    return cls(format)

def FormatInfo_from_file(cls, filename):
    """from_file(path) -> FormatInfo instance

    Guess format from file
    """
    filename = _decodeFilename(filename)
    format = fi.FreeImage_GetFileType(filename, 0)
    return cls(format)

def FormatInfo_from_mimetype(cls, mime):
    """from_mimetype(mime) -> FormatInfo instance

    Guess format from mime type string
    """
    mime = _decodeFilename(mime)
    format = fi.FreeImage_GetFIFFromMime(mime)
    return cls(format)

def FormatInfo_list(cls):
    """Iterate over all supported formats
    """
    return [cls(format) for format in range(fi.FreeImage_GetFIFCount())]


cdef class FormatInfo:
    cdef readonly fi.FREE_IMAGE_FORMAT format
    cdef readonly object name

    def __init__(self, int format):
        cdef char* name
        if format == fi.FIF_UNKNOWN:
            raise dispatchFIError(OperationError, "Unable to detect format.")

        self.format = <fi.FREE_IMAGE_FORMAT>format
        name = <char*>fi.FreeImage_GetFormatFromFIF(self.format)
        if name is NULL:
            raise ValueError("Invalid format %i" % format)
        self.name = funicode(name)

    from_filename = classmethod(FormatInfo_from_filename)
    from_file = classmethod(FormatInfo_from_file)
    from_mimetype = classmethod(FormatInfo_from_mimetype)
    list = classmethod(FormatInfo_list)

    def __int__(self):
        return self.format

    if smc_fi.IS_PYTHON3:
        def __unicode__(self):
            return self.name
    else:
        def __str__(self):
            return self.name

    def __repr__(self):
        return "<FormatInfo '%s' (%i)>" % (self.name, self.format)

    property mimetype:
        def __get__(self):
            cdef char* mimetype
            mimetype = <char*>fi.FreeImage_GetFIFMimeType(self.format)
            if mimetype is NULL:
                return None
            else:
                return funicode(mimetype)

    property description:
        def __get__(self):
            cdef char* desc
            desc = <char*>fi.FreeImage_GetFIFDescription(self.format)
            if desc is NULL:
                return None
            else:
                return funicode(desc)

    property magic_reg_expr:
        def __get__(self):
            cdef char* regexpr
            regexpr = <char*>fi.FreeImage_GetFIFRegExpr(self.format)
            if regexpr is NULL:
                return None
            else:
                return regexpr

    property supports_reading:
        def __get__(self):
            return fi.FreeImage_FIFSupportsReading(self.format)

    property supports_writing:
        def __get__(self):
            return fi.FreeImage_FIFSupportsWriting(self.format)

    property supports_icc:
        def __get__(self):
            return fi.FreeImage_FIFSupportsICCProfiles(self.format)

    property supports_nopixels:
        def __get__(self):
            return fi.FreeImage_FIFSupportsNoPixels(self.format)

    property extensions:
        def __get__(self):
            cdef char* exts
            exts = <char*>fi.FreeImage_GetFIFExtensionList(self.format)
            return [funicode(ext) for ext in exts.split(b',')]

    property supported_export_types:
        def __get__(self):
            return [name for fit, name in _IMAGE_TYPES
                    if fi.FreeImage_FIFSupportsExportType(self.format,
                                                          <fi.FREE_IMAGE_TYPE>fit)]

    property supported_export_bpp:
        def __get__(self):
            return [bpp for bpp in _BPP
                    if fi.FreeImage_FIFSupportsExportBPP(self.format, bpp)]

    def getExtensions(self):
        return self.extensions

    def getSupportsExportType(self, int fit):
        if fit < 0 or fit > fi.FIT_RGBAF:
            raise ValueError("Invalid type %i" % fit)
        return fi.FreeImage_FIFSupportsExportType(self.format,
                                                  <fi.FREE_IMAGE_TYPE>fit)

    def getSupportsExportBPP(self, int bpp):
        return fi.FreeImage_FIFSupportsExportBPP(self.format, bpp)


# image data representation helper

def ImageDataRepresentation_fromImage(cls, Image img):
    return ImageDateRepresentation_fromDib(cls, img._dib)

cdef ImageDateRepresentation_fromDib(cls, fi.FIBITMAP *dib):
    cdef fi.FREE_IMAGE_TYPE image_type
    cdef fi.FREE_IMAGE_COLOR_TYPE color_type
    cdef unsigned int bpp=0

    image_type = fi.FreeImage_GetImageType(dib)
    if image_type == fi.FIT_BITMAP:
        bpp = fi.FreeImage_GetBPP(dib)
        # special handling for 32bpp as FreeImage scans an image for used alpha channel
        if bpp == 32:
            if fi.FreeImage_GetICCProfile(dib).flags & fi.FIICC_COLOR_IS_CMYK:
                color_type = fi.FIC_CMYK
            else:
                color_type = fi.FIC_RGBALPHA
        else:
            color_type = fi.FreeImage_GetColorType(dib)
    else:
        color_type = fi.FreeImage_GetColorType(dib)

    return cls(image_type, color_type, bpp)


DEF FORMAT_LENGTH = 2
DEF MODE_LENGTH = 8
DEF PIXEL_LAYOUT_LENGTH = 8

cdef class ImageDataRepresentation:
    # FreeImage image / color type
    cdef readonly fi.FREE_IMAGE_TYPE image_type
    cdef readonly fi.FREE_IMAGE_COLOR_TYPE color_type
    cdef readonly unsigned int bpp

    # buffer protocol information
    cdef readonly char format[FORMAT_LENGTH]
    cdef readonly Py_ssize_t itemsize
    cdef readonly Py_ssize_t pixelcount

    # PIL compatible mode
    cdef readonly char mode[MODE_LENGTH]

    # LCMS
    cdef readonly unsigned int lcms_type

    # pixel layout
    # b: b/w or gray scale, min is black
    # w: b/w or gray scale, min is white (inverted)
    # p: palette
    # RGB: RGB
    # BGR: RGB inverted byte order
    # RGBA: RGB with alpa channel
    # BGRA: RGBA inverted byte order
    # RGBX: RGB with unused alpa channel
    # BGRX: RGBX inverted byte order
    # CMYK
    cdef readonly char pixel_layout[PIXEL_LAYOUT_LENGTH]

    # TODO: TIFF supports more color spaces like YCbCr and three L*a*b but
    # FreeImage doesn't handle them yet. See PhotometricInterpretation

    fromImage = classmethod(ImageDataRepresentation_fromImage)

    def __init__(self, int image_type, int color_type, int bpp=0):
        cdef bint rgb_order, minisblack
        cdef bytes format, pixel_layout, mode

        self.image_type = <fi.FREE_IMAGE_TYPE>image_type
        self.color_type = <fi.FREE_IMAGE_COLOR_TYPE>color_type
        self.bpp = bpp

        if self.image_type == fi.FIT_BITMAP:
            if bpp not in (1, 4, 8, 16, 24, 32):
                raise ValueError("bitmap must have bpp value of 1, 4, 8, 16, 24 or 32")
        elif bpp != 0:
            raise ValueError("non bitmap must have no bpp value")

        string.strncpy(self.format, b"", FORMAT_LENGTH)
        self.itemsize = 0
        self.pixelcount = 0
        string.strncpy(self.mode, b"", MODE_LENGTH)
        self.lcms_type = 0
        string.strncpy(self.pixel_layout, b"", PIXEL_LAYOUT_LENGTH)

        rgb_order = fi.FREEIMAGE_COLORORDER == fi.FREEIMAGE_COLORORDER_RGB
        minisblack = color_type != fi.FIC_MINISWHITE

        # set pixel data
        if color_type == fi.FIC_MINISBLACK:
            pixel_layout = b"b"
        elif color_type == fi.FIC_MINISWHITE:
            pixel_layout = b"w"
        elif color_type == fi.FIC_PALETTE:
            pixel_layout = b"P"
            mode = b"P"
        elif color_type == fi.FIC_RGB:
            if rgb_order:
                pixel_layout = b"RGB" if bpp != 32 else b"RGBX"
            else:
                pixel_layout = b"BGR" if bpp != 32 else b"BGRX"
            mode = b"RGB" if bpp != 32 else b"RGBX"
        elif color_type == fi.FIC_RGBALPHA:
            if rgb_order:
                pixel_layout = b"RGBA"
            else:
                pixel_layout = b"BGRA"
            mode = b"RGBA"
        elif color_type == fi.FIC_CMYK:
            pixel_layout = b"CMYK"
            mode = b"CMYK"
        else:
            raise ValueError("invalid color type %i" % color_type)

        # bitmap
        if image_type == fi.FIT_BITMAP:
            if bpp == 1:
                # buffer not supported
                mode = b"1"
            elif bpp == 4:
                # buffer not supported
                #mode = ???
                pass
            elif bpp == 8:
                format = b"B"
                self.itemsize = 1
                self.pixelcount = 1
                self.lcms_type = lcms.TYPE_GRAY_8 if minisblack else lcms.TYPE_GRAY_8_REV
            elif bpp == 16:
                # 555 or 565
                format = b"H"
                self.itemsize = 2
                self.pixelcount = 1
                mode = b""
                pixel_layout = b"" # XXX
            elif bpp == 24:
                format = b"B"
                self.itemsize = 1
                self.pixelcount = 3
                self.lcms_type = lcms.TYPE_RGB_8 if rgb_order else lcms.TYPE_BGR_8
            elif bpp == 32:
                format = b"B"
                self.itemsize = 1
                self.pixelcount = 4
                if color_type == fi.FIC_CMYK:
                    self.lcms_type = lcms.TYPE_CMYK_8
                else:
                    self.lcms_type = lcms.TYPE_RGBA_8 if rgb_order else lcms.TYPE_BGRA_8
        # other
        elif image_type == fi. FIT_UINT16:
            format = b"I"
            self.itemsize = 4
            self.pixelcount = 1
            #mode = b"I;16"
            mode = b""
            #self.lcms_type = lcms.TYPE_GRAY_16
        elif image_type == fi. FIT_INT16:
            format = b"i"
            self.itemsize = 4
            self.pixelcount = 1
            mode = b"I;16" # XXX endian?
            self.lcms_type = lcms.TYPE_GRAY_16
        elif image_type == fi. FIT_UINT32:
            format = b"Q"
            self.itemsize = 8
            self.pixelcount = 1
            #mode = b"I;32"
            mode = b""
        elif image_type == fi. FIT_INT32:
            format = b"q"
            self.itemsize = 8
            self.pixelcount = 1
            #mode = b"I;32"
            mode = b""
        elif image_type == fi. FIT_FLOAT:
            format = b"f"
            self.itemsize = 4
            self.pixelcount = 1
            mode = b"F"
            self.lcms_type = lcms.TYPE_GRAY_FLT
        elif image_type == fi. FIT_DOUBLE:
            format = b"d"
            self.itemsize = 8
            self.pixelcount = 1
            #mode = b"D"
            mode = b""
            self.lcms_type = lcms.TYPE_GRAY_DBL
        elif image_type == fi. FIT_COMPLEX:
            format = b"d"
            self.itemsize = 8
            self.pixelcount = 2
            mode = b""
        elif image_type == fi. FIT_RGB16:
            format = b"H"
            self.itemsize = 2
            self.pixelcount = 3
            mode = b""
            self.lcms_type = lcms.TYPE_RGB_16 if rgb_order else lcms.TYPE_BGR_16
        elif image_type == fi. FIT_RGBA16:
            format = b"H"
            self.itemsize = 2
            self.pixelcount = 4
            mode = b""
            if color_type == fi.FIC_CMYK:
                self.lcms_type = lcms.TYPE_CMYK_16
            else:
                self.lcms_type = lcms.TYPE_RGBA_16 if rgb_order else lcms.TYPE_BGRA_16
        elif image_type == fi. FIT_RGBF:
            format = b"f"
            self.itemsize = 4
            self.pixelcount = 3
            mode = b""
            self.lcms_type = lcms.TYPE_RGB_FLT
        elif image_type == fi. FIT_RGBAF:
            format = b"f"
            self.itemsize = 4
            self.pixelcount = 4
            mode = b""
            if color_type == fi.FIC_CMYK:
                self.lcms_type = lcms.TYPE_CMYK_FLT
            else:
                self.lcms_type = lcms.TYPE_RGBA_FLT

        string.strncpy(self.format, <char*>format, FORMAT_LENGTH)
        string.strncpy(self.mode, <char*>mode, MODE_LENGTH)
        string.strncpy(self.pixel_layout, <char*>pixel_layout, PIXEL_LAYOUT_LENGTH)

    def __repr__(self):
        return ("<ImageDataRepresentation image_type=%i, color_type=%i, bpp=%i, "
                "format='%s', itemsize=%i, pixelcount=%i, mode='%s', "
                "lcms_type=%i, pixel_layout='%s'>" %
                (self.image_type, self.color_type, self.bpp,
                 self.format.decode("ascii"), self.itemsize, self.pixelcount,
                 self.mode.decode("ascii"), self.lcms_type,
                 self.pixel_layout.decode("ascii")))


#--- module functions
def getVersion():
    """getVersion() -> str

    Get version of loaded freeimage library
    """
    return funicode(fi.FreeImage_GetVersion())

def getCompiledFor():
    """getCompiledFor() -> tuple(major, minor, serial)
    """
    return (fi.FREEIMAGE_MAJOR_VERSION,
            fi.FREEIMAGE_MINOR_VERSION,
            fi.FREEIMAGE_RELEASE_SERIAL)

def getCopyright():
    """getCopyright() -> str
    """
    return funicode(fi.FreeImage_GetCopyrightMessage())

def getFormatCount():
    """getFormatCount() -> int
    """
    return fi.FreeImage_GetFIFCount()

def getColorOrder():
    """Get color order or RGB data

    The color order is platform dependent.

      big endian: RGB(A)
      little endian: BGR(A)

    Windows and X86 platforms are usually little endian machines while
    PowerPC is usually big endian. ARM processors support both endianess.

    @return: either "RGB" or "BGR"
    @rtype: str
    """
    if fi.FREEIMAGE_COLORORDER == fi.FREEIMAGE_COLORORDER_RGB:
        return "RGB"
    else:
        return "BGR"

def getColorIndexRGBA():
    """Get index of RGBA quad

    @return: R, G, B, A
    @rtype: tuple of four ints
    """
    return fi.FI_RGBA_RED, fi.FI_RGBA_GREEN, fi.FI_RGBA_BLUE, fi.FI_RGBA_ALPHA

def getColorMaskRGBA():
    """Get color mask of RGBA quad

    @return: R, G, B, A
    @rtype: tuple of four ints
    """
    return (<unsigned long>fi.FI_RGBA_RED_MASK,
            <unsigned long>fi.FI_RGBA_GREEN_MASK,
            <unsigned long>fi.FI_RGBA_BLUE_MASK,
            <unsigned long>fi.FI_RGBA_ALPHA_MASK)

def getColorShiftRGBA():
    """Get color shift of RGBA quad

    @return: R, G, B, A
    @rtype: tuple of four ints
    """
    return (fi.FI_RGBA_RED_SHIFT,
            fi.FI_RGBA_GREEN_SHIFT,
            fi.FI_RGBA_BLUE_SHIFT,
            fi.FI_RGBA_ALPHA_SHIFT)

def getColorMask555():
    """Get color mask of 16bit 555 image

    @return: R, G, B
    @rtype: tuple of three ints
    """
    return fi.FI16_555_RED_MASK, fi.FI16_555_GREEN_MASK, fi.FI16_555_BLUE_MASK

def getColorShift555():
    """Get color shift of 16bit 555 image

    @return: R, G, B
    @rtype: tuple of three ints
    """
    return fi.FI16_555_RED_SHIFT, fi.FI16_555_GREEN_SHIFT, fi.FI16_555_BLUE_SHIFT

def getColorMask565():
    """Get color mask of 16bit 565 image

    @return: R, G, B
    @rtype: tuple of three ints
    """
    return fi.FI16_565_RED_MASK, fi.FI16_565_GREEN_MASK, fi.FI16_565_BLUE_MASK

def getColorShift565():
    """Get color shift of 16bit 565 image

    @return: R, G, B
    @rtype: tuple of three ints
    """
    return fi.FI16_565_RED_SHIFT, fi.FI16_565_GREEN_SHIFT, fi.FI16_565_BLUE_SHIFT

def lookupX11Color(name):
    """lookupX11Color(name) -> (r, g, b)
    """
    cdef fi.BYTE red, green, blue
    name = _decodeFilename(name)
    if not fi.FreeImage_LookupX11Color(name, &red, &green, &blue):
        raise dispatchFIError(OperationError, "Cannot lookup X11 color %s" % name)
    return (red, green, blue)

def lookupSVGColor(name):
    """lookupSVGColor(name) -> (r, g, b)
    """
    cdef fi.BYTE red, green, blue
    name = _decodeFilename(name)
    if not fi.FreeImage_LookupSVGColor(name, &red, &green, &blue):
        raise dispatchFIError(OperationError, "Cannot lookup SVG color %s" % name)
    return (red, green, blue)

def jpegTransform(src, dst, unsigned int op, unsigned int perfect=0):
    """jpegTransform(source: str, destination: str, op: int) -> None

    Perform lossless rotation or flipping on a JPEG image

    @param src: path to source image
    @type src: str
    @param dst: path to destination file, can be the same file as src
    @typ dst: str
    @param op: a FIJPEG_OP_* constant
    @param perfect: if true raises an exception if image has odd iMCU
        aligned (see PDF)
    """
    cdef fi.BOOL result
    cdef char* csrc
    cdef char* cdst

    bsrc = _decodeFilename(src)
    bdst = _decodeFilename(dst)

    if op > fi.FIJPEG_OP_ROTATE_270:
        raise ValueError("OP not in range 0-7")

    csrc = bsrc
    cdst = bdst

    with nogil:
        result = fi.FreeImage_JPEGTransform(csrc,
                                            cdst,
                                            <fi.FREE_IMAGE_JPEG_OPERATION>op,
                                            perfect)
    if not result:
        raise dispatchFIError(OperationError, "JPEG Transformation of '%s' to '%s' with op "
                             "'%i' failed." % (src, dst, op))

def hasJPEGTurbo():
    """Is FreeImage compiled against libjeg-turbo
    """
    return bool(FREEIMAGE_TURBO)

cdef void initialize():
    """Initialize FreeImage
    """
    # 0: load all plugins
    fi.FreeImage_Initialise(0)
    initErrorHandler()

initialize()
