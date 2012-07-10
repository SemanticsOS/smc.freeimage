#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : Create PXI file from FreeImage.h and local definitions
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
"""Create freeimage.pxi from header file
"""
import re

FREEIMAGE_H = "windows/FreeImage.h"
DEFINITION = re.compile("DLL_API (.*)DLL_CALLCONV ([A-Za-z_0-9]*)\((.*)\)")
FI_DEFAULT = re.compile(" FI_DEFAULT\(.*?\)")

PXD = "smc/freeimage/freeimage.pxd"
ENUM = "smc/freeimage/enums.py"
FICONSTANTS = "smc/freeimage/ficonstants.c"

HEADER = """
cdef extern from *:
    ctypedef char* const_char_ptr "const char*"
    ctypedef void* const_void_ptr "const void*"
    
cdef extern from "inttypes.h":
    ctypedef long int32_t
    ctypedef unsigned short uint8_t
    ctypedef unsigned int uint16_t
    ctypedef unsigned long uint32_t

#cdef extern from "wchar.h":
#    ctypedef char wchar_t

cdef extern from "FreeImage.h" nogil:
    ctypedef int32_t BOOL
    ctypedef uint8_t BYTE
    ctypedef uint16_t WORD
    ctypedef uint32_t DWORD
    ctypedef int32_t LONG
    
    # structs
    ctypedef struct FIBITMAP:
        void *data
    
    ctypedef struct FIMULTIBITMAP:
        void *data

    ctypedef struct RGBQUAD:
        BYTE rgbBlue
        BYTE rgbGreen
        BYTE rgbRed
        BYTE rgbReserved
    
    ctypedef struct RGBTRIPLE:
        BYTE rgbBlue
        BYTE rgbGreen
        BYTE rgbRed

    ctypedef struct BITMAPINFOHEADER:
        DWORD biSize
        LONG  biWidth 
        LONG  biHeight 
        WORD  biPlanes 
        WORD  biBitCount
        DWORD biCompression 
        DWORD biSizeImage 
        LONG  biXPelsPerMeter 
        LONG  biYPelsPerMeter 
        DWORD biClrUsed 
        DWORD biClrImportant
  
    ctypedef struct BITMAPINFO:
        BITMAPINFOHEADER bmiHeader 
        RGBQUAD          bmiColors[1]
        
    ctypedef struct FIRGB16:
        WORD red
        WORD green
        WORD blue
    
    ctypedef struct FIRGBA16:
        WORD red
        WORD green
        WORD blue
        WORD alpha
    
    ctypedef struct FIRGBF:
        float red
        float green
        float blue
    
    ctypedef struct FIRGBAF:
        float red
        float green
        float blue
        float alpha
    
    ctypedef struct FIRCOMPLEX:
        double r
        double i
    
    ctypedef struct FIICCPROFILE:
        WORD  flags
        DWORD size
        void  *data
    
    ctypedef struct FIMETADATA:
        void *data
    
    ctypedef struct FITAG:
        void *data

    cdef struct FIMEMORY:
        void *data
    
    # ********************
    # image io
    ctypedef void* fi_handle
    ctypedef unsigned (*FI_ReadProc) (void *buffer, unsigned size, unsigned count, fi_handle handle)
    ctypedef unsigned (*FI_WriteProc) (void *buffer, unsigned size, unsigned count, fi_handle handle)
    ctypedef int (*FI_SeekProc) (fi_handle handle, long offset, int origin)
    ctypedef long (*FI_TellProc) (fi_handle handle)

    cdef struct FreeImageIO:
        FI_ReadProc  read_proc
        FI_WriteProc write_proc
        FI_SeekProc  seek_proc
        FI_TellProc  tell_proc


"""

FOOTER = """
    # other
    cdef struct Plugin:
        pass

    ctypedef void (*FI_InitProc)(Plugin *plugin, int format_id)
    ctypedef void (*FreeImage_OutputMessageFunctionStdCall) (FREE_IMAGE_FORMAT fif, const_char_ptr msg)
    
"""

ENUMS = {
    'FREE_IMAGE_COLOR_CHANNEL' :
        ['FICC_RGB', 'FICC_RED', 'FICC_GREEN', 'FICC_BLUE', 'FICC_ALPHA',
         'FICC_BLACK', 'FICC_REAL', 'FICC_IMAG', 'FICC_MAG', 'FICC_PHASE'],
    'FREE_IMAGE_DITHER' :
        ['FID_FS', 'FID_BAYER4x4', 'FID_BAYER8x8', 'FID_CLUSTER6x6',
         'FID_CLUSTER8x8', 'FID_CLUSTER16x16', 'FID_BAYER16x16'],
    'FREE_IMAGE_FORMAT' :
        ['FIF_UNKNOWN', 'FIF_BMP', 'FIF_ICO', 'FIF_JPEG', 'FIF_JNG',
         'FIF_KOALA', 'FIF_LBM', 'FIF_IFF', 'FIF_MNG', 'FIF_PBM', 'FIF_PBMRAW',
         'FIF_PCD', 'FIF_PCX', 'FIF_PGM', 'FIF_PGMRAW', 'FIF_PNG', 'FIF_PPM',
         'FIF_PPMRAW', 'FIF_RAS', 'FIF_TARGA', 'FIF_TIFF', 'FIF_WBMP',
         'FIF_PSD', 'FIF_CUT', 'FIF_XBM', 'FIF_XPM', 'FIF_DDS', 'FIF_GIF',
         'FIF_HDR', 'FIF_FAXG3', 'FIF_SGI', 'FIF_EXR', 'FIF_J2K', 'FIF_JP2',
         'FIF_PFM', 'FIF_PICT', 'FIF_RAW', 'FIF_LOAD_NOPIXELS'],
    'FREE_IMAGE_QUANTIZE' : ['FIQ_WUQUANT', 'FIQ_NNQUANT'],
    'FREE_IMAGE_TMO' : ['FITMO_DRAGO03', 'FITMO_REINHARD05', 'FITMO_FATTAL02'],
    'FREE_IMAGE_FILTER' :
        ['FILTER_BOX', 'FILTER_BICUBIC', 'FILTER_BILINEAR', 'FILTER_BSPLINE',
         'FILTER_CATMULLROM', 'FILTER_LANCZOS3'],
    'FREE_IMAGE_TYPE' :
        ['FIT_UNKNOWN', 'FIT_BITMAP', 'FIT_UINT16', 'FIT_INT16', 'FIT_UINT32',
         'FIT_INT32', 'FIT_FLOAT', 'FIT_DOUBLE', 'FIT_COMPLEX', 'FIT_RGB16',
         'FIT_RGBA16', 'FIT_RGBF', 'FIT_RGBAF'],
    'FREE_IMAGE_MDTYPE' :
        ['FIDT_NOTYPE', 'FIDT_BYTE', 'FIDT_ASCII', 'FIDT_SHORT', 'FIDT_LONG',
         'FIDT_RATIONAL', 'FIDT_SBYTE', 'FIDT_UNDEFINED', 'FIDT_SSHORT',
         'FIDT_SLONG', 'FIDT_SRATIONAL', 'FIDT_FLOAT', 'FIDT_DOUBLE',
         'FIDT_IFD', 'FIDT_PALETTE', 'FIDT_LONG8', 'FIDT_SLONG8',
         'FIDT_IFD8'],
    'FREE_IMAGE_JPEG_OPERATION' :
        ['FIJPEG_OP_NONE', 'FIJPEG_OP_FLIP_H', 'FIJPEG_OP_FLIP_V',
         'FIJPEG_OP_TRANSPOSE', 'FIJPEG_OP_TRANSVERSE', 'FIJPEG_OP_ROTATE_90',
         'FIJPEG_OP_ROTATE_180', 'FIJPEG_OP_ROTATE_270'],
    'FREE_IMAGE_MDMODEL' :
        ['FIMD_NODATA', 'FIMD_COMMENTS', 'FIMD_EXIF_MAIN', 'FIMD_EXIF_EXIF',
         'FIMD_EXIF_GPS', 'FIMD_EXIF_MAKERNOTE', 'FIMD_EXIF_INTEROP',
         'FIMD_IPTC', 'FIMD_XMP', 'FIMD_GEOTIFF', 'FIMD_ANIMATION',
         'FIMD_CUSTOM', 'FIMD_EXIF_RAW'],
    'FREE_IMAGE_COLOR_TYPE' :
        ['FIC_MINISWHITE', 'FIC_MINISBLACK', 'FIC_RGB', 'FIC_PALETTE',
         'FIC_RGBALPHA', 'FIC_CMYK'],
    'FREE_IMAGE_COLOR':
        ['FI_COLOR_IS_RGB_COLOR', 'FI_COLOR_IS_RGBA_COLOR',
         'FI_COLOR_FIND_EQUAL_COLOR', 'FI_COLOR_ALPHA_IS_INDEX',
         'FI_COLOR_PALETTE_SEARCH_MASK'],
    'CONSTANTS' :
        ['FREEIMAGE_MAJOR_VERSION', 'FREEIMAGE_MINOR_VERSION',
         'FREEIMAGE_RELEASE_SERIAL',
         'FREEIMAGE_COLORORDER_BGR', 'FREEIMAGE_COLORORDER_RGB',
         'FREEIMAGE_COLORORDER',
         'FI_RGBA_RED', 'FI_RGBA_GREEN', 'FI_RGBA_BLUE', 'FI_RGBA_ALPHA',
         'FI_RGBA_RED_MASK', 'FI_RGBA_GREEN_MASK', 'FI_RGBA_BLUE_MASK',
         'FI_RGBA_ALPHA_MASK',
         'FI_RGBA_RED_SHIFT', 'FI_RGBA_GREEN_SHIFT', 'FI_RGBA_BLUE_SHIFT',
         'FI_RGBA_ALPHA_SHIFT',
         'FI16_555_RED_MASK', 'FI16_555_GREEN_MASK', 'FI16_555_BLUE_MASK',
         'FI16_555_RED_SHIFT', 'FI16_555_GREEN_SHIFT', 'FI16_555_BLUE_SHIFT',
         'FI16_565_RED_MASK', 'FI16_565_GREEN_MASK', 'FI16_565_BLUE_MASK',
         'FI16_565_RED_SHIFT', 'FI16_565_GREEN_SHIFT', 'FI16_565_BLUE_SHIFT',
         'FIICC_DEFAULT', 'FIICC_COLOR_IS_CMYK',
         'BMP_DEFAULT', 'BMP_SAVE_RLE',
         'CUT_DEFAULT',
         'DDS_DEFAULT',
         'EXR_DEFAULT', 'EXR_FLOAT', 'EXR_NONE', 'EXR_ZIP', 'EXR_PIZ',
         'EXR_PXR24', 'EXR_B44', 'EXR_LC',
         'FAXG3_DEFAULT',
         'GIF_DEFAULT', 'GIF_LOAD256', 'GIF_PLAYBACK',
         'HDR_DEFAULT',
         'ICO_DEFAULT', 'ICO_MAKEALPHA',
         'IFF_DEFAULT',
         'J2K_DEFAULT',
         'JP2_DEFAULT',
         'JPEG_DEFAULT', 'JPEG_FAST', 'JPEG_ACCURATE', 'JPEG_CMYK',
         'JPEG_QUALITYSUPERB', 'JPEG_QUALITYGOOD', 'JPEG_QUALITYNORMAL',
         'JPEG_QUALITYAVERAGE', 'JPEG_QUALITYBAD', 'JPEG_PROGRESSIVE', 'JPEG_OPTIMIZE',
         'JPEG_BASELINE',
         'JPEG_SUBSAMPLING_411', 'JPEG_SUBSAMPLING_420',
         'JPEG_SUBSAMPLING_422', 'JPEG_SUBSAMPLING_444',
         'KOALA_DEFAULT',
         'LBM_DEFAULT',
         'MNG_DEFAULT',
         'PCD_DEFAULT', 'PCD_BASE', 'PCD_BASEDIV4', 'PCD_BASEDIV16',
         'PCX_DEFAULT',
         'PICT_DEFAULT',
         'PNG_DEFAULT', 'PNG_IGNOREGAMMA', 'PNG_Z_BEST_SPEED', 'PNG_Z_DEFAULT_COMPRESSION',
         'PNG_Z_BEST_COMPRESSION', 'PNG_Z_NO_COMPRESSION', 'PNG_INTERLACED',
         'PNM_DEFAULT', 'PNM_SAVE_RAW', 'PNM_SAVE_ASCII',
         'PSD_DEFAULT', 'PSD_CMYK', 'PSD_LAB',
         'RAS_DEFAULT',
         'RAW_DEFAULT', 'RAW_PREVIEW', 'RAW_DISPLAY', 'RAW_HALFSIZE',
         'SGI_DEFAULT',
         'TARGA_DEFAULT', 'TARGA_LOAD_RGB888', 'TARGA_SAVE_RLE',
         'TIFF_DEFAULT', 'TIFF_CMYK', 'TIFF_PACKBITS', 'TIFF_DEFLATE',
         'TIFF_ADOBE_DEFLATE', 'TIFF_NONE', 'TIFF_CCITTFAX3',
         'TIFF_CCITTFAX4', 'TIFF_LZW', 'TIFF_JPEG', 'TIFF_LOGLUV',
         'WBMP_DEFAULT',
         'XBM_DEFAULT',
         'XPM_DEFAULT'],
}

ENUMS_PY_HEADER = """
# WARNING! This is an autogenerated file!
import ficonstants as fi 

class _enums(object):
    pass

"""

SKIP = set(("FreeImage_SetOutputMessage",))

def parse(fname):
    lines = []
    with open(fname) as f:
        for line in f:
            mo = DEFINITION.search(line)
            if mo is None:
                continue
            typ, func, args = mo.groups()
            type = typ.strip()
            func = func.strip()
            if func in SKIP:
                continue
            args = FI_DEFAULT.sub("", args.strip())
            if args == "void":
                args = ""
            out = "    cdef %s %s(%s)" % (typ, func, args)
            out = out.replace("const ", "")
            #line = line.replace("  ", " ")
            if "wchar_t" in line:
                # disable unicode / wchar_t functions
                lines.append(out.replace("cdef", "# cdef"))
            else:
                lines.append(out)
    return lines

def enums2classes():
    lines = []
    enums = dict((name, name.replace("FREE_IMAGE_", "FI_"))
                   for name in sorted(ENUMS))
    lines.append(ENUMS_PY_HEADER)
    lines.append("__all__ = ['%s']" % "', '".join(sorted(enums.values())))
    lines.append("\n")
    for key, consts in ENUMS.iteritems():
        lines.append("class %s(_enums):" % enums[key])
        for const in consts:
            lines.append("    %s = fi.%s" % (const, const))
        lines.append("\n")
    return lines

def enums2cdefs():
    lines = []
    lines.append("    # enums")
    for key, consts in ENUMS.iteritems():
        if key == "CONSTANTS":
            key = ""
        lines.append("    cdef enum %s:" % key)
        for const in consts:
            lines.append("        %s" % const)
        lines.append("\n")
    return lines

def update_ficonstants_c(fname=FICONSTANTS):
    lines = []
    with open(fname) as f:
        for line in f:
            lines.append(line.rstrip())
            if 'MARKER' in line:
                break
    for key, consts in ENUMS.iteritems():
        lines.append('\n    /* Enum: %s */' % key)
        for const in consts:
            lines.append('    PyModule_AddIntConstant(m, "%s", %s);' %
                         (const, const))
    lines.append('}\n')
    with open(fname, 'w') as f:
        f.write('\n'.join(lines))

if __name__ == "__main__":
    with open(PXD, "w") as f:
        f.write(HEADER)
        f.write('\n'.join(enums2cdefs()))
        f.write(FOOTER)
        f.write('\n'.join(parse(FREEIMAGE_H)))
        f.write('\n')
    with open(ENUM, "w") as f:
        f.write('\n'.join(enums2classes()))
    update_ficonstants_c()
