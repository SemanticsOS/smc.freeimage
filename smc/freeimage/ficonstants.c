/*
=============================================================================
 Copyright   : (c) 2008 semantics GmbH. All Rights Reserved.
 Rep./File   : $URL$
 Date        : $Date$
 Author      : Christian Heimes
 License     : FreeImage Public License (FIPL)
               GNU General Public License (GPL)
 Worker      : $Author$
 Revision    : $Rev$
 Purpose     : Simpe C module to expose FI constants and enums
=============================================================================

 COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT
 WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT
 LIMITATION, WARRANTIES THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE,
 FIT FOR A PARTICULAR PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE
 QUALITY AND PERFORMANCE OF THE COVERED CODE IS WITH YOU. SHOULD ANY COVERED
 CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY
 OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR
 CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF
 THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
 THIS DISCLAIMER.
*/

#include "Python.h"
#include "FreeImage.h"

#if FREEIMAGE_MAJOR_VERSION != 3 || FREEIMAGE_MINOR_VERSION < 15
    #error Your FreeImage.h is too old. At least 3.11 is required.
#endif

static PyMethodDef ficonstants_methods[] = {
    {NULL, NULL}    /* sentinel */
};

PyDoc_STRVAR(module_doc,
"FreeImage constants.\n\
\n\
This module exposes all FreeImage integer constants. It can either be \n\
used directly or through the freeimage.enums module.");

#if PY_MAJOR_VERSION >= 3


static struct PyModuleDef moduledef = {
        PyModuleDef_HEAD_INIT,
        "ficonstants",
        module_doc,
        -1,
        ficonstants_methods,
        NULL,
        NULL,
        NULL,
        NULL
};

#define INITERROR return NULL

PyObject *
PyInit_ficonstants(void)

#else
#define INITERROR return


void
initficonstants(void)
#endif
{
    PyObject *m;
#if PY_MAJOR_VERSION >= 3
    m = PyModule_Create(&moduledef);
#else
    m = Py_InitModule3("ficonstants", ficonstants_methods, module_doc);
#endif
    if (m == NULL)
        INITERROR;

#if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
    PyModule_AddStringConstant(m, "COLORORDER", "BGR");
#else
    PyModule_AddStringConstant(m, "COLORORDER", "RGB");
#endif


    /* MARKER, the rest of the file is autogenerated! */

    /* Enum: FREE_IMAGE_FORMAT */
    PyModule_AddIntConstant(m, "FIF_UNKNOWN", FIF_UNKNOWN);
    PyModule_AddIntConstant(m, "FIF_BMP", FIF_BMP);
    PyModule_AddIntConstant(m, "FIF_ICO", FIF_ICO);
    PyModule_AddIntConstant(m, "FIF_JPEG", FIF_JPEG);
    PyModule_AddIntConstant(m, "FIF_JNG", FIF_JNG);
    PyModule_AddIntConstant(m, "FIF_KOALA", FIF_KOALA);
    PyModule_AddIntConstant(m, "FIF_LBM", FIF_LBM);
    PyModule_AddIntConstant(m, "FIF_IFF", FIF_IFF);
    PyModule_AddIntConstant(m, "FIF_MNG", FIF_MNG);
    PyModule_AddIntConstant(m, "FIF_PBM", FIF_PBM);
    PyModule_AddIntConstant(m, "FIF_PBMRAW", FIF_PBMRAW);
    PyModule_AddIntConstant(m, "FIF_PCD", FIF_PCD);
    PyModule_AddIntConstant(m, "FIF_PCX", FIF_PCX);
    PyModule_AddIntConstant(m, "FIF_PGM", FIF_PGM);
    PyModule_AddIntConstant(m, "FIF_PGMRAW", FIF_PGMRAW);
    PyModule_AddIntConstant(m, "FIF_PNG", FIF_PNG);
    PyModule_AddIntConstant(m, "FIF_PPM", FIF_PPM);
    PyModule_AddIntConstant(m, "FIF_PPMRAW", FIF_PPMRAW);
    PyModule_AddIntConstant(m, "FIF_RAS", FIF_RAS);
    PyModule_AddIntConstant(m, "FIF_TARGA", FIF_TARGA);
    PyModule_AddIntConstant(m, "FIF_TIFF", FIF_TIFF);
    PyModule_AddIntConstant(m, "FIF_WBMP", FIF_WBMP);
    PyModule_AddIntConstant(m, "FIF_PSD", FIF_PSD);
    PyModule_AddIntConstant(m, "FIF_CUT", FIF_CUT);
    PyModule_AddIntConstant(m, "FIF_XBM", FIF_XBM);
    PyModule_AddIntConstant(m, "FIF_XPM", FIF_XPM);
    PyModule_AddIntConstant(m, "FIF_DDS", FIF_DDS);
    PyModule_AddIntConstant(m, "FIF_GIF", FIF_GIF);
    PyModule_AddIntConstant(m, "FIF_HDR", FIF_HDR);
    PyModule_AddIntConstant(m, "FIF_FAXG3", FIF_FAXG3);
    PyModule_AddIntConstant(m, "FIF_SGI", FIF_SGI);
    PyModule_AddIntConstant(m, "FIF_EXR", FIF_EXR);
    PyModule_AddIntConstant(m, "FIF_J2K", FIF_J2K);
    PyModule_AddIntConstant(m, "FIF_JP2", FIF_JP2);
    PyModule_AddIntConstant(m, "FIF_PFM", FIF_PFM);
    PyModule_AddIntConstant(m, "FIF_PICT", FIF_PICT);
    PyModule_AddIntConstant(m, "FIF_RAW", FIF_RAW);
    PyModule_AddIntConstant(m, "FIF_WEBP", FIF_WEBP);
    PyModule_AddIntConstant(m, "FIF_JXR", FIF_JXR);
    PyModule_AddIntConstant(m, "FIF_LOAD_NOPIXELS", FIF_LOAD_NOPIXELS);

    /* Enum: FREE_IMAGE_QUANTIZE */
    PyModule_AddIntConstant(m, "FIQ_WUQUANT", FIQ_WUQUANT);
    PyModule_AddIntConstant(m, "FIQ_NNQUANT", FIQ_NNQUANT);

    /* Enum: FREE_IMAGE_FILTER */
    PyModule_AddIntConstant(m, "FILTER_BOX", FILTER_BOX);
    PyModule_AddIntConstant(m, "FILTER_BICUBIC", FILTER_BICUBIC);
    PyModule_AddIntConstant(m, "FILTER_BILINEAR", FILTER_BILINEAR);
    PyModule_AddIntConstant(m, "FILTER_BSPLINE", FILTER_BSPLINE);
    PyModule_AddIntConstant(m, "FILTER_CATMULLROM", FILTER_CATMULLROM);
    PyModule_AddIntConstant(m, "FILTER_LANCZOS3", FILTER_LANCZOS3);

    /* Enum: FREE_IMAGE_TYPE */
    PyModule_AddIntConstant(m, "FIT_UNKNOWN", FIT_UNKNOWN);
    PyModule_AddIntConstant(m, "FIT_BITMAP", FIT_BITMAP);
    PyModule_AddIntConstant(m, "FIT_UINT16", FIT_UINT16);
    PyModule_AddIntConstant(m, "FIT_INT16", FIT_INT16);
    PyModule_AddIntConstant(m, "FIT_UINT32", FIT_UINT32);
    PyModule_AddIntConstant(m, "FIT_INT32", FIT_INT32);
    PyModule_AddIntConstant(m, "FIT_FLOAT", FIT_FLOAT);
    PyModule_AddIntConstant(m, "FIT_DOUBLE", FIT_DOUBLE);
    PyModule_AddIntConstant(m, "FIT_COMPLEX", FIT_COMPLEX);
    PyModule_AddIntConstant(m, "FIT_RGB16", FIT_RGB16);
    PyModule_AddIntConstant(m, "FIT_RGBA16", FIT_RGBA16);
    PyModule_AddIntConstant(m, "FIT_RGBF", FIT_RGBF);
    PyModule_AddIntConstant(m, "FIT_RGBAF", FIT_RGBAF);

    /* Enum: FREE_IMAGE_COLOR_CHANNEL */
    PyModule_AddIntConstant(m, "FICC_RGB", FICC_RGB);
    PyModule_AddIntConstant(m, "FICC_RED", FICC_RED);
    PyModule_AddIntConstant(m, "FICC_GREEN", FICC_GREEN);
    PyModule_AddIntConstant(m, "FICC_BLUE", FICC_BLUE);
    PyModule_AddIntConstant(m, "FICC_ALPHA", FICC_ALPHA);
    PyModule_AddIntConstant(m, "FICC_BLACK", FICC_BLACK);
    PyModule_AddIntConstant(m, "FICC_REAL", FICC_REAL);
    PyModule_AddIntConstant(m, "FICC_IMAG", FICC_IMAG);
    PyModule_AddIntConstant(m, "FICC_MAG", FICC_MAG);
    PyModule_AddIntConstant(m, "FICC_PHASE", FICC_PHASE);

    /* Enum: FREE_IMAGE_DITHER */
    PyModule_AddIntConstant(m, "FID_FS", FID_FS);
    PyModule_AddIntConstant(m, "FID_BAYER4x4", FID_BAYER4x4);
    PyModule_AddIntConstant(m, "FID_BAYER8x8", FID_BAYER8x8);
    PyModule_AddIntConstant(m, "FID_CLUSTER6x6", FID_CLUSTER6x6);
    PyModule_AddIntConstant(m, "FID_CLUSTER8x8", FID_CLUSTER8x8);
    PyModule_AddIntConstant(m, "FID_CLUSTER16x16", FID_CLUSTER16x16);
    PyModule_AddIntConstant(m, "FID_BAYER16x16", FID_BAYER16x16);

    /* Enum: FREE_IMAGE_COLOR */
    PyModule_AddIntConstant(m, "FI_COLOR_IS_RGB_COLOR", FI_COLOR_IS_RGB_COLOR);
    PyModule_AddIntConstant(m, "FI_COLOR_IS_RGBA_COLOR", FI_COLOR_IS_RGBA_COLOR);
    PyModule_AddIntConstant(m, "FI_COLOR_FIND_EQUAL_COLOR", FI_COLOR_FIND_EQUAL_COLOR);
    PyModule_AddIntConstant(m, "FI_COLOR_ALPHA_IS_INDEX", FI_COLOR_ALPHA_IS_INDEX);
    PyModule_AddIntConstant(m, "FI_COLOR_PALETTE_SEARCH_MASK", FI_COLOR_PALETTE_SEARCH_MASK);

    /* Enum: FREE_IMAGE_TMO */
    PyModule_AddIntConstant(m, "FITMO_DRAGO03", FITMO_DRAGO03);
    PyModule_AddIntConstant(m, "FITMO_REINHARD05", FITMO_REINHARD05);
    PyModule_AddIntConstant(m, "FITMO_FATTAL02", FITMO_FATTAL02);

    /* Enum: FREE_IMAGE_MDTYPE */
    PyModule_AddIntConstant(m, "FIDT_NOTYPE", FIDT_NOTYPE);
    PyModule_AddIntConstant(m, "FIDT_BYTE", FIDT_BYTE);
    PyModule_AddIntConstant(m, "FIDT_ASCII", FIDT_ASCII);
    PyModule_AddIntConstant(m, "FIDT_SHORT", FIDT_SHORT);
    PyModule_AddIntConstant(m, "FIDT_LONG", FIDT_LONG);
    PyModule_AddIntConstant(m, "FIDT_RATIONAL", FIDT_RATIONAL);
    PyModule_AddIntConstant(m, "FIDT_SBYTE", FIDT_SBYTE);
    PyModule_AddIntConstant(m, "FIDT_UNDEFINED", FIDT_UNDEFINED);
    PyModule_AddIntConstant(m, "FIDT_SSHORT", FIDT_SSHORT);
    PyModule_AddIntConstant(m, "FIDT_SLONG", FIDT_SLONG);
    PyModule_AddIntConstant(m, "FIDT_SRATIONAL", FIDT_SRATIONAL);
    PyModule_AddIntConstant(m, "FIDT_FLOAT", FIDT_FLOAT);
    PyModule_AddIntConstant(m, "FIDT_DOUBLE", FIDT_DOUBLE);
    PyModule_AddIntConstant(m, "FIDT_IFD", FIDT_IFD);
    PyModule_AddIntConstant(m, "FIDT_PALETTE", FIDT_PALETTE);
    PyModule_AddIntConstant(m, "FIDT_LONG8", FIDT_LONG8);
    PyModule_AddIntConstant(m, "FIDT_SLONG8", FIDT_SLONG8);
    PyModule_AddIntConstant(m, "FIDT_IFD8", FIDT_IFD8);

    /* Enum: FREE_IMAGE_JPEG_OPERATION */
    PyModule_AddIntConstant(m, "FIJPEG_OP_NONE", FIJPEG_OP_NONE);
    PyModule_AddIntConstant(m, "FIJPEG_OP_FLIP_H", FIJPEG_OP_FLIP_H);
    PyModule_AddIntConstant(m, "FIJPEG_OP_FLIP_V", FIJPEG_OP_FLIP_V);
    PyModule_AddIntConstant(m, "FIJPEG_OP_TRANSPOSE", FIJPEG_OP_TRANSPOSE);
    PyModule_AddIntConstant(m, "FIJPEG_OP_TRANSVERSE", FIJPEG_OP_TRANSVERSE);
    PyModule_AddIntConstant(m, "FIJPEG_OP_ROTATE_90", FIJPEG_OP_ROTATE_90);
    PyModule_AddIntConstant(m, "FIJPEG_OP_ROTATE_180", FIJPEG_OP_ROTATE_180);
    PyModule_AddIntConstant(m, "FIJPEG_OP_ROTATE_270", FIJPEG_OP_ROTATE_270);

    /* Enum: FREE_IMAGE_MDMODEL */
    PyModule_AddIntConstant(m, "FIMD_NODATA", FIMD_NODATA);
    PyModule_AddIntConstant(m, "FIMD_COMMENTS", FIMD_COMMENTS);
    PyModule_AddIntConstant(m, "FIMD_EXIF_MAIN", FIMD_EXIF_MAIN);
    PyModule_AddIntConstant(m, "FIMD_EXIF_EXIF", FIMD_EXIF_EXIF);
    PyModule_AddIntConstant(m, "FIMD_EXIF_GPS", FIMD_EXIF_GPS);
    PyModule_AddIntConstant(m, "FIMD_EXIF_MAKERNOTE", FIMD_EXIF_MAKERNOTE);
    PyModule_AddIntConstant(m, "FIMD_EXIF_INTEROP", FIMD_EXIF_INTEROP);
    PyModule_AddIntConstant(m, "FIMD_IPTC", FIMD_IPTC);
    PyModule_AddIntConstant(m, "FIMD_XMP", FIMD_XMP);
    PyModule_AddIntConstant(m, "FIMD_GEOTIFF", FIMD_GEOTIFF);
    PyModule_AddIntConstant(m, "FIMD_ANIMATION", FIMD_ANIMATION);
    PyModule_AddIntConstant(m, "FIMD_CUSTOM", FIMD_CUSTOM);
    PyModule_AddIntConstant(m, "FIMD_EXIF_RAW", FIMD_EXIF_RAW);

    /* Enum: FREE_IMAGE_COLOR_TYPE */
    PyModule_AddIntConstant(m, "FIC_MINISWHITE", FIC_MINISWHITE);
    PyModule_AddIntConstant(m, "FIC_MINISBLACK", FIC_MINISBLACK);
    PyModule_AddIntConstant(m, "FIC_RGB", FIC_RGB);
    PyModule_AddIntConstant(m, "FIC_PALETTE", FIC_PALETTE);
    PyModule_AddIntConstant(m, "FIC_RGBALPHA", FIC_RGBALPHA);
    PyModule_AddIntConstant(m, "FIC_CMYK", FIC_CMYK);

    /* Enum: CONSTANTS */
    PyModule_AddIntConstant(m, "FREEIMAGE_MAJOR_VERSION", FREEIMAGE_MAJOR_VERSION);
    PyModule_AddIntConstant(m, "FREEIMAGE_MINOR_VERSION", FREEIMAGE_MINOR_VERSION);
    PyModule_AddIntConstant(m, "FREEIMAGE_RELEASE_SERIAL", FREEIMAGE_RELEASE_SERIAL);
    PyModule_AddIntConstant(m, "FREEIMAGE_COLORORDER_BGR", FREEIMAGE_COLORORDER_BGR);
    PyModule_AddIntConstant(m, "FREEIMAGE_COLORORDER_RGB", FREEIMAGE_COLORORDER_RGB);
    PyModule_AddIntConstant(m, "FREEIMAGE_COLORORDER", FREEIMAGE_COLORORDER);
    PyModule_AddIntConstant(m, "FI_RGBA_RED", FI_RGBA_RED);
    PyModule_AddIntConstant(m, "FI_RGBA_GREEN", FI_RGBA_GREEN);
    PyModule_AddIntConstant(m, "FI_RGBA_BLUE", FI_RGBA_BLUE);
    PyModule_AddIntConstant(m, "FI_RGBA_ALPHA", FI_RGBA_ALPHA);
    PyModule_AddIntConstant(m, "FI_RGBA_RED_MASK", FI_RGBA_RED_MASK);
    PyModule_AddIntConstant(m, "FI_RGBA_GREEN_MASK", FI_RGBA_GREEN_MASK);
    PyModule_AddIntConstant(m, "FI_RGBA_BLUE_MASK", FI_RGBA_BLUE_MASK);
    PyModule_AddIntConstant(m, "FI_RGBA_ALPHA_MASK", FI_RGBA_ALPHA_MASK);
    PyModule_AddIntConstant(m, "FI_RGBA_RED_SHIFT", FI_RGBA_RED_SHIFT);
    PyModule_AddIntConstant(m, "FI_RGBA_GREEN_SHIFT", FI_RGBA_GREEN_SHIFT);
    PyModule_AddIntConstant(m, "FI_RGBA_BLUE_SHIFT", FI_RGBA_BLUE_SHIFT);
    PyModule_AddIntConstant(m, "FI_RGBA_ALPHA_SHIFT", FI_RGBA_ALPHA_SHIFT);
    PyModule_AddIntConstant(m, "FI16_555_RED_MASK", FI16_555_RED_MASK);
    PyModule_AddIntConstant(m, "FI16_555_GREEN_MASK", FI16_555_GREEN_MASK);
    PyModule_AddIntConstant(m, "FI16_555_BLUE_MASK", FI16_555_BLUE_MASK);
    PyModule_AddIntConstant(m, "FI16_555_RED_SHIFT", FI16_555_RED_SHIFT);
    PyModule_AddIntConstant(m, "FI16_555_GREEN_SHIFT", FI16_555_GREEN_SHIFT);
    PyModule_AddIntConstant(m, "FI16_555_BLUE_SHIFT", FI16_555_BLUE_SHIFT);
    PyModule_AddIntConstant(m, "FI16_565_RED_MASK", FI16_565_RED_MASK);
    PyModule_AddIntConstant(m, "FI16_565_GREEN_MASK", FI16_565_GREEN_MASK);
    PyModule_AddIntConstant(m, "FI16_565_BLUE_MASK", FI16_565_BLUE_MASK);
    PyModule_AddIntConstant(m, "FI16_565_RED_SHIFT", FI16_565_RED_SHIFT);
    PyModule_AddIntConstant(m, "FI16_565_GREEN_SHIFT", FI16_565_GREEN_SHIFT);
    PyModule_AddIntConstant(m, "FI16_565_BLUE_SHIFT", FI16_565_BLUE_SHIFT);
    PyModule_AddIntConstant(m, "FIICC_DEFAULT", FIICC_DEFAULT);
    PyModule_AddIntConstant(m, "FIICC_COLOR_IS_CMYK", FIICC_COLOR_IS_CMYK);
    PyModule_AddIntConstant(m, "BMP_DEFAULT", BMP_DEFAULT);
    PyModule_AddIntConstant(m, "BMP_SAVE_RLE", BMP_SAVE_RLE);
    PyModule_AddIntConstant(m, "CUT_DEFAULT", CUT_DEFAULT);
    PyModule_AddIntConstant(m, "DDS_DEFAULT", DDS_DEFAULT);
    PyModule_AddIntConstant(m, "EXR_DEFAULT", EXR_DEFAULT);
    PyModule_AddIntConstant(m, "EXR_FLOAT", EXR_FLOAT);
    PyModule_AddIntConstant(m, "EXR_NONE", EXR_NONE);
    PyModule_AddIntConstant(m, "EXR_ZIP", EXR_ZIP);
    PyModule_AddIntConstant(m, "EXR_PIZ", EXR_PIZ);
    PyModule_AddIntConstant(m, "EXR_PXR24", EXR_PXR24);
    PyModule_AddIntConstant(m, "EXR_B44", EXR_B44);
    PyModule_AddIntConstant(m, "EXR_LC", EXR_LC);
    PyModule_AddIntConstant(m, "FAXG3_DEFAULT", FAXG3_DEFAULT);
    PyModule_AddIntConstant(m, "GIF_DEFAULT", GIF_DEFAULT);
    PyModule_AddIntConstant(m, "GIF_LOAD256", GIF_LOAD256);
    PyModule_AddIntConstant(m, "GIF_PLAYBACK", GIF_PLAYBACK);
    PyModule_AddIntConstant(m, "HDR_DEFAULT", HDR_DEFAULT);
    PyModule_AddIntConstant(m, "ICO_DEFAULT", ICO_DEFAULT);
    PyModule_AddIntConstant(m, "ICO_MAKEALPHA", ICO_MAKEALPHA);
    PyModule_AddIntConstant(m, "IFF_DEFAULT", IFF_DEFAULT);
    PyModule_AddIntConstant(m, "J2K_DEFAULT", J2K_DEFAULT);
    PyModule_AddIntConstant(m, "JP2_DEFAULT", JP2_DEFAULT);
    PyModule_AddIntConstant(m, "JPEG_DEFAULT", JPEG_DEFAULT);
    PyModule_AddIntConstant(m, "JPEG_FAST", JPEG_FAST);
    PyModule_AddIntConstant(m, "JPEG_ACCURATE", JPEG_ACCURATE);
    PyModule_AddIntConstant(m, "JPEG_CMYK", JPEG_CMYK);
    PyModule_AddIntConstant(m, "JPEG_QUALITYSUPERB", JPEG_QUALITYSUPERB);
    PyModule_AddIntConstant(m, "JPEG_QUALITYGOOD", JPEG_QUALITYGOOD);
    PyModule_AddIntConstant(m, "JPEG_QUALITYNORMAL", JPEG_QUALITYNORMAL);
    PyModule_AddIntConstant(m, "JPEG_QUALITYAVERAGE", JPEG_QUALITYAVERAGE);
    PyModule_AddIntConstant(m, "JPEG_QUALITYBAD", JPEG_QUALITYBAD);
    PyModule_AddIntConstant(m, "JPEG_PROGRESSIVE", JPEG_PROGRESSIVE);
    PyModule_AddIntConstant(m, "JPEG_OPTIMIZE", JPEG_OPTIMIZE);
    PyModule_AddIntConstant(m, "JPEG_BASELINE", JPEG_BASELINE);
    PyModule_AddIntConstant(m, "JPEG_GREYSCALE", JPEG_GREYSCALE);
    PyModule_AddIntConstant(m, "JPEG_SUBSAMPLING_411", JPEG_SUBSAMPLING_411);
    PyModule_AddIntConstant(m, "JPEG_SUBSAMPLING_420", JPEG_SUBSAMPLING_420);
    PyModule_AddIntConstant(m, "JPEG_SUBSAMPLING_422", JPEG_SUBSAMPLING_422);
    PyModule_AddIntConstant(m, "JPEG_SUBSAMPLING_444", JPEG_SUBSAMPLING_444);
    PyModule_AddIntConstant(m, "KOALA_DEFAULT", KOALA_DEFAULT);
    PyModule_AddIntConstant(m, "LBM_DEFAULT", LBM_DEFAULT);
    PyModule_AddIntConstant(m, "MNG_DEFAULT", MNG_DEFAULT);
    PyModule_AddIntConstant(m, "PCD_DEFAULT", PCD_DEFAULT);
    PyModule_AddIntConstant(m, "PCD_BASE", PCD_BASE);
    PyModule_AddIntConstant(m, "PCD_BASEDIV4", PCD_BASEDIV4);
    PyModule_AddIntConstant(m, "PCD_BASEDIV16", PCD_BASEDIV16);
    PyModule_AddIntConstant(m, "PCX_DEFAULT", PCX_DEFAULT);
    PyModule_AddIntConstant(m, "PICT_DEFAULT", PICT_DEFAULT);
    PyModule_AddIntConstant(m, "PNG_DEFAULT", PNG_DEFAULT);
    PyModule_AddIntConstant(m, "PNG_IGNOREGAMMA", PNG_IGNOREGAMMA);
    PyModule_AddIntConstant(m, "PNG_Z_BEST_SPEED", PNG_Z_BEST_SPEED);
    PyModule_AddIntConstant(m, "PNG_Z_DEFAULT_COMPRESSION", PNG_Z_DEFAULT_COMPRESSION);
    PyModule_AddIntConstant(m, "PNG_Z_BEST_COMPRESSION", PNG_Z_BEST_COMPRESSION);
    PyModule_AddIntConstant(m, "PNG_Z_NO_COMPRESSION", PNG_Z_NO_COMPRESSION);
    PyModule_AddIntConstant(m, "PNG_INTERLACED", PNG_INTERLACED);
    PyModule_AddIntConstant(m, "PNM_DEFAULT", PNM_DEFAULT);
    PyModule_AddIntConstant(m, "PNM_SAVE_RAW", PNM_SAVE_RAW);
    PyModule_AddIntConstant(m, "PNM_SAVE_ASCII", PNM_SAVE_ASCII);
    PyModule_AddIntConstant(m, "PSD_DEFAULT", PSD_DEFAULT);
    PyModule_AddIntConstant(m, "PSD_CMYK", PSD_CMYK);
    PyModule_AddIntConstant(m, "PSD_LAB", PSD_LAB);
    PyModule_AddIntConstant(m, "RAS_DEFAULT", RAS_DEFAULT);
    PyModule_AddIntConstant(m, "RAW_DEFAULT", RAW_DEFAULT);
    PyModule_AddIntConstant(m, "RAW_PREVIEW", RAW_PREVIEW);
    PyModule_AddIntConstant(m, "RAW_DISPLAY", RAW_DISPLAY);
    PyModule_AddIntConstant(m, "RAW_HALFSIZE", RAW_HALFSIZE);
    PyModule_AddIntConstant(m, "RAW_UNPROCESSED", RAW_UNPROCESSED);
    PyModule_AddIntConstant(m, "SGI_DEFAULT", SGI_DEFAULT);
    PyModule_AddIntConstant(m, "TARGA_DEFAULT", TARGA_DEFAULT);
    PyModule_AddIntConstant(m, "TARGA_LOAD_RGB888", TARGA_LOAD_RGB888);
    PyModule_AddIntConstant(m, "TARGA_SAVE_RLE", TARGA_SAVE_RLE);
    PyModule_AddIntConstant(m, "TIFF_DEFAULT", TIFF_DEFAULT);
    PyModule_AddIntConstant(m, "TIFF_CMYK", TIFF_CMYK);
    PyModule_AddIntConstant(m, "TIFF_PACKBITS", TIFF_PACKBITS);
    PyModule_AddIntConstant(m, "TIFF_DEFLATE", TIFF_DEFLATE);
    PyModule_AddIntConstant(m, "TIFF_ADOBE_DEFLATE", TIFF_ADOBE_DEFLATE);
    PyModule_AddIntConstant(m, "TIFF_NONE", TIFF_NONE);
    PyModule_AddIntConstant(m, "TIFF_CCITTFAX3", TIFF_CCITTFAX3);
    PyModule_AddIntConstant(m, "TIFF_CCITTFAX4", TIFF_CCITTFAX4);
    PyModule_AddIntConstant(m, "TIFF_LZW", TIFF_LZW);
    PyModule_AddIntConstant(m, "TIFF_JPEG", TIFF_JPEG);
    PyModule_AddIntConstant(m, "TIFF_LOGLUV", TIFF_LOGLUV);
    PyModule_AddIntConstant(m, "WBMP_DEFAULT", WBMP_DEFAULT);
    PyModule_AddIntConstant(m, "WEBP_DEFAULT", WEBP_DEFAULT);
    PyModule_AddIntConstant(m, "WEBP_LOSSLESS", WEBP_LOSSLESS);
    PyModule_AddIntConstant(m, "JXR_DEFAULT", JXR_DEFAULT);
    PyModule_AddIntConstant(m, "JXR_LOSSLESS", JXR_LOSSLESS);
    PyModule_AddIntConstant(m, "JXR_PROGRESSIVE", JXR_PROGRESSIVE);
    PyModule_AddIntConstant(m, "XBM_DEFAULT", XBM_DEFAULT);
    PyModule_AddIntConstant(m, "XPM_DEFAULT", XPM_DEFAULT);
#if PY_MAJOR_VERSION >= 3
    return m;
#endif
}
