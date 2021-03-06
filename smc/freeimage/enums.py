
# WARNING! This is an autogenerated file!
from smc.freeimage import ficonstants as fi 

class _enums(object):
    pass


__all__ = ('CONSTANTS', 'FI_COLOR', 'FI_COLOR_CHANNEL', 'FI_COLOR_TYPE', 'FI_DITHER', 'FI_FILTER', 'FI_FORMAT', 'FI_JPEG_OPERATION', 'FI_MDMODEL', 'FI_MDTYPE', 'FI_QUANTIZE', 'FI_TMO', 'FI_TYPE')


class FI_FORMAT(_enums):
    FIF_UNKNOWN = fi.FIF_UNKNOWN
    FIF_BMP = fi.FIF_BMP
    FIF_ICO = fi.FIF_ICO
    FIF_JPEG = fi.FIF_JPEG
    FIF_JNG = fi.FIF_JNG
    FIF_KOALA = fi.FIF_KOALA
    FIF_LBM = fi.FIF_LBM
    FIF_IFF = fi.FIF_IFF
    FIF_MNG = fi.FIF_MNG
    FIF_PBM = fi.FIF_PBM
    FIF_PBMRAW = fi.FIF_PBMRAW
    FIF_PCD = fi.FIF_PCD
    FIF_PCX = fi.FIF_PCX
    FIF_PGM = fi.FIF_PGM
    FIF_PGMRAW = fi.FIF_PGMRAW
    FIF_PNG = fi.FIF_PNG
    FIF_PPM = fi.FIF_PPM
    FIF_PPMRAW = fi.FIF_PPMRAW
    FIF_RAS = fi.FIF_RAS
    FIF_TARGA = fi.FIF_TARGA
    FIF_TIFF = fi.FIF_TIFF
    FIF_WBMP = fi.FIF_WBMP
    FIF_PSD = fi.FIF_PSD
    FIF_CUT = fi.FIF_CUT
    FIF_XBM = fi.FIF_XBM
    FIF_XPM = fi.FIF_XPM
    FIF_DDS = fi.FIF_DDS
    FIF_GIF = fi.FIF_GIF
    FIF_HDR = fi.FIF_HDR
    FIF_FAXG3 = fi.FIF_FAXG3
    FIF_SGI = fi.FIF_SGI
    FIF_EXR = fi.FIF_EXR
    FIF_J2K = fi.FIF_J2K
    FIF_JP2 = fi.FIF_JP2
    FIF_PFM = fi.FIF_PFM
    FIF_PICT = fi.FIF_PICT
    FIF_RAW = fi.FIF_RAW
    FIF_WEBP = fi.FIF_WEBP
    FIF_JXR = fi.FIF_JXR
    FIF_LOAD_NOPIXELS = fi.FIF_LOAD_NOPIXELS


class FI_QUANTIZE(_enums):
    FIQ_WUQUANT = fi.FIQ_WUQUANT
    FIQ_NNQUANT = fi.FIQ_NNQUANT


class FI_FILTER(_enums):
    FILTER_BOX = fi.FILTER_BOX
    FILTER_BICUBIC = fi.FILTER_BICUBIC
    FILTER_BILINEAR = fi.FILTER_BILINEAR
    FILTER_BSPLINE = fi.FILTER_BSPLINE
    FILTER_CATMULLROM = fi.FILTER_CATMULLROM
    FILTER_LANCZOS3 = fi.FILTER_LANCZOS3


class FI_TYPE(_enums):
    FIT_UNKNOWN = fi.FIT_UNKNOWN
    FIT_BITMAP = fi.FIT_BITMAP
    FIT_UINT16 = fi.FIT_UINT16
    FIT_INT16 = fi.FIT_INT16
    FIT_UINT32 = fi.FIT_UINT32
    FIT_INT32 = fi.FIT_INT32
    FIT_FLOAT = fi.FIT_FLOAT
    FIT_DOUBLE = fi.FIT_DOUBLE
    FIT_COMPLEX = fi.FIT_COMPLEX
    FIT_RGB16 = fi.FIT_RGB16
    FIT_RGBA16 = fi.FIT_RGBA16
    FIT_RGBF = fi.FIT_RGBF
    FIT_RGBAF = fi.FIT_RGBAF


class FI_COLOR_CHANNEL(_enums):
    FICC_RGB = fi.FICC_RGB
    FICC_RED = fi.FICC_RED
    FICC_GREEN = fi.FICC_GREEN
    FICC_BLUE = fi.FICC_BLUE
    FICC_ALPHA = fi.FICC_ALPHA
    FICC_BLACK = fi.FICC_BLACK
    FICC_REAL = fi.FICC_REAL
    FICC_IMAG = fi.FICC_IMAG
    FICC_MAG = fi.FICC_MAG
    FICC_PHASE = fi.FICC_PHASE


class FI_DITHER(_enums):
    FID_FS = fi.FID_FS
    FID_BAYER4x4 = fi.FID_BAYER4x4
    FID_BAYER8x8 = fi.FID_BAYER8x8
    FID_CLUSTER6x6 = fi.FID_CLUSTER6x6
    FID_CLUSTER8x8 = fi.FID_CLUSTER8x8
    FID_CLUSTER16x16 = fi.FID_CLUSTER16x16
    FID_BAYER16x16 = fi.FID_BAYER16x16


class FI_COLOR(_enums):
    FI_COLOR_IS_RGB_COLOR = fi.FI_COLOR_IS_RGB_COLOR
    FI_COLOR_IS_RGBA_COLOR = fi.FI_COLOR_IS_RGBA_COLOR
    FI_COLOR_FIND_EQUAL_COLOR = fi.FI_COLOR_FIND_EQUAL_COLOR
    FI_COLOR_ALPHA_IS_INDEX = fi.FI_COLOR_ALPHA_IS_INDEX
    FI_COLOR_PALETTE_SEARCH_MASK = fi.FI_COLOR_PALETTE_SEARCH_MASK


class FI_TMO(_enums):
    FITMO_DRAGO03 = fi.FITMO_DRAGO03
    FITMO_REINHARD05 = fi.FITMO_REINHARD05
    FITMO_FATTAL02 = fi.FITMO_FATTAL02


class FI_MDTYPE(_enums):
    FIDT_NOTYPE = fi.FIDT_NOTYPE
    FIDT_BYTE = fi.FIDT_BYTE
    FIDT_ASCII = fi.FIDT_ASCII
    FIDT_SHORT = fi.FIDT_SHORT
    FIDT_LONG = fi.FIDT_LONG
    FIDT_RATIONAL = fi.FIDT_RATIONAL
    FIDT_SBYTE = fi.FIDT_SBYTE
    FIDT_UNDEFINED = fi.FIDT_UNDEFINED
    FIDT_SSHORT = fi.FIDT_SSHORT
    FIDT_SLONG = fi.FIDT_SLONG
    FIDT_SRATIONAL = fi.FIDT_SRATIONAL
    FIDT_FLOAT = fi.FIDT_FLOAT
    FIDT_DOUBLE = fi.FIDT_DOUBLE
    FIDT_IFD = fi.FIDT_IFD
    FIDT_PALETTE = fi.FIDT_PALETTE
    FIDT_LONG8 = fi.FIDT_LONG8
    FIDT_SLONG8 = fi.FIDT_SLONG8
    FIDT_IFD8 = fi.FIDT_IFD8


class FI_JPEG_OPERATION(_enums):
    FIJPEG_OP_NONE = fi.FIJPEG_OP_NONE
    FIJPEG_OP_FLIP_H = fi.FIJPEG_OP_FLIP_H
    FIJPEG_OP_FLIP_V = fi.FIJPEG_OP_FLIP_V
    FIJPEG_OP_TRANSPOSE = fi.FIJPEG_OP_TRANSPOSE
    FIJPEG_OP_TRANSVERSE = fi.FIJPEG_OP_TRANSVERSE
    FIJPEG_OP_ROTATE_90 = fi.FIJPEG_OP_ROTATE_90
    FIJPEG_OP_ROTATE_180 = fi.FIJPEG_OP_ROTATE_180
    FIJPEG_OP_ROTATE_270 = fi.FIJPEG_OP_ROTATE_270


class FI_MDMODEL(_enums):
    FIMD_NODATA = fi.FIMD_NODATA
    FIMD_COMMENTS = fi.FIMD_COMMENTS
    FIMD_EXIF_MAIN = fi.FIMD_EXIF_MAIN
    FIMD_EXIF_EXIF = fi.FIMD_EXIF_EXIF
    FIMD_EXIF_GPS = fi.FIMD_EXIF_GPS
    FIMD_EXIF_MAKERNOTE = fi.FIMD_EXIF_MAKERNOTE
    FIMD_EXIF_INTEROP = fi.FIMD_EXIF_INTEROP
    FIMD_IPTC = fi.FIMD_IPTC
    FIMD_XMP = fi.FIMD_XMP
    FIMD_GEOTIFF = fi.FIMD_GEOTIFF
    FIMD_ANIMATION = fi.FIMD_ANIMATION
    FIMD_CUSTOM = fi.FIMD_CUSTOM
    FIMD_EXIF_RAW = fi.FIMD_EXIF_RAW


class FI_COLOR_TYPE(_enums):
    FIC_MINISWHITE = fi.FIC_MINISWHITE
    FIC_MINISBLACK = fi.FIC_MINISBLACK
    FIC_RGB = fi.FIC_RGB
    FIC_PALETTE = fi.FIC_PALETTE
    FIC_RGBALPHA = fi.FIC_RGBALPHA
    FIC_CMYK = fi.FIC_CMYK


class CONSTANTS(_enums):
    FREEIMAGE_MAJOR_VERSION = fi.FREEIMAGE_MAJOR_VERSION
    FREEIMAGE_MINOR_VERSION = fi.FREEIMAGE_MINOR_VERSION
    FREEIMAGE_RELEASE_SERIAL = fi.FREEIMAGE_RELEASE_SERIAL
    FREEIMAGE_COLORORDER_BGR = fi.FREEIMAGE_COLORORDER_BGR
    FREEIMAGE_COLORORDER_RGB = fi.FREEIMAGE_COLORORDER_RGB
    FREEIMAGE_COLORORDER = fi.FREEIMAGE_COLORORDER
    FI_RGBA_RED = fi.FI_RGBA_RED
    FI_RGBA_GREEN = fi.FI_RGBA_GREEN
    FI_RGBA_BLUE = fi.FI_RGBA_BLUE
    FI_RGBA_ALPHA = fi.FI_RGBA_ALPHA
    FI_RGBA_RED_MASK = fi.FI_RGBA_RED_MASK
    FI_RGBA_GREEN_MASK = fi.FI_RGBA_GREEN_MASK
    FI_RGBA_BLUE_MASK = fi.FI_RGBA_BLUE_MASK
    FI_RGBA_ALPHA_MASK = fi.FI_RGBA_ALPHA_MASK
    FI_RGBA_RED_SHIFT = fi.FI_RGBA_RED_SHIFT
    FI_RGBA_GREEN_SHIFT = fi.FI_RGBA_GREEN_SHIFT
    FI_RGBA_BLUE_SHIFT = fi.FI_RGBA_BLUE_SHIFT
    FI_RGBA_ALPHA_SHIFT = fi.FI_RGBA_ALPHA_SHIFT
    FI16_555_RED_MASK = fi.FI16_555_RED_MASK
    FI16_555_GREEN_MASK = fi.FI16_555_GREEN_MASK
    FI16_555_BLUE_MASK = fi.FI16_555_BLUE_MASK
    FI16_555_RED_SHIFT = fi.FI16_555_RED_SHIFT
    FI16_555_GREEN_SHIFT = fi.FI16_555_GREEN_SHIFT
    FI16_555_BLUE_SHIFT = fi.FI16_555_BLUE_SHIFT
    FI16_565_RED_MASK = fi.FI16_565_RED_MASK
    FI16_565_GREEN_MASK = fi.FI16_565_GREEN_MASK
    FI16_565_BLUE_MASK = fi.FI16_565_BLUE_MASK
    FI16_565_RED_SHIFT = fi.FI16_565_RED_SHIFT
    FI16_565_GREEN_SHIFT = fi.FI16_565_GREEN_SHIFT
    FI16_565_BLUE_SHIFT = fi.FI16_565_BLUE_SHIFT
    FIICC_DEFAULT = fi.FIICC_DEFAULT
    FIICC_COLOR_IS_CMYK = fi.FIICC_COLOR_IS_CMYK
    BMP_DEFAULT = fi.BMP_DEFAULT
    BMP_SAVE_RLE = fi.BMP_SAVE_RLE
    CUT_DEFAULT = fi.CUT_DEFAULT
    DDS_DEFAULT = fi.DDS_DEFAULT
    EXR_DEFAULT = fi.EXR_DEFAULT
    EXR_FLOAT = fi.EXR_FLOAT
    EXR_NONE = fi.EXR_NONE
    EXR_ZIP = fi.EXR_ZIP
    EXR_PIZ = fi.EXR_PIZ
    EXR_PXR24 = fi.EXR_PXR24
    EXR_B44 = fi.EXR_B44
    EXR_LC = fi.EXR_LC
    FAXG3_DEFAULT = fi.FAXG3_DEFAULT
    GIF_DEFAULT = fi.GIF_DEFAULT
    GIF_LOAD256 = fi.GIF_LOAD256
    GIF_PLAYBACK = fi.GIF_PLAYBACK
    HDR_DEFAULT = fi.HDR_DEFAULT
    ICO_DEFAULT = fi.ICO_DEFAULT
    ICO_MAKEALPHA = fi.ICO_MAKEALPHA
    IFF_DEFAULT = fi.IFF_DEFAULT
    J2K_DEFAULT = fi.J2K_DEFAULT
    JP2_DEFAULT = fi.JP2_DEFAULT
    JPEG_DEFAULT = fi.JPEG_DEFAULT
    JPEG_FAST = fi.JPEG_FAST
    JPEG_ACCURATE = fi.JPEG_ACCURATE
    JPEG_CMYK = fi.JPEG_CMYK
    JPEG_QUALITYSUPERB = fi.JPEG_QUALITYSUPERB
    JPEG_QUALITYGOOD = fi.JPEG_QUALITYGOOD
    JPEG_QUALITYNORMAL = fi.JPEG_QUALITYNORMAL
    JPEG_QUALITYAVERAGE = fi.JPEG_QUALITYAVERAGE
    JPEG_QUALITYBAD = fi.JPEG_QUALITYBAD
    JPEG_PROGRESSIVE = fi.JPEG_PROGRESSIVE
    JPEG_OPTIMIZE = fi.JPEG_OPTIMIZE
    JPEG_BASELINE = fi.JPEG_BASELINE
    JPEG_GREYSCALE = fi.JPEG_GREYSCALE
    JPEG_SUBSAMPLING_411 = fi.JPEG_SUBSAMPLING_411
    JPEG_SUBSAMPLING_420 = fi.JPEG_SUBSAMPLING_420
    JPEG_SUBSAMPLING_422 = fi.JPEG_SUBSAMPLING_422
    JPEG_SUBSAMPLING_444 = fi.JPEG_SUBSAMPLING_444
    KOALA_DEFAULT = fi.KOALA_DEFAULT
    LBM_DEFAULT = fi.LBM_DEFAULT
    MNG_DEFAULT = fi.MNG_DEFAULT
    PCD_DEFAULT = fi.PCD_DEFAULT
    PCD_BASE = fi.PCD_BASE
    PCD_BASEDIV4 = fi.PCD_BASEDIV4
    PCD_BASEDIV16 = fi.PCD_BASEDIV16
    PCX_DEFAULT = fi.PCX_DEFAULT
    PICT_DEFAULT = fi.PICT_DEFAULT
    PNG_DEFAULT = fi.PNG_DEFAULT
    PNG_IGNOREGAMMA = fi.PNG_IGNOREGAMMA
    PNG_Z_BEST_SPEED = fi.PNG_Z_BEST_SPEED
    PNG_Z_DEFAULT_COMPRESSION = fi.PNG_Z_DEFAULT_COMPRESSION
    PNG_Z_BEST_COMPRESSION = fi.PNG_Z_BEST_COMPRESSION
    PNG_Z_NO_COMPRESSION = fi.PNG_Z_NO_COMPRESSION
    PNG_INTERLACED = fi.PNG_INTERLACED
    PNM_DEFAULT = fi.PNM_DEFAULT
    PNM_SAVE_RAW = fi.PNM_SAVE_RAW
    PNM_SAVE_ASCII = fi.PNM_SAVE_ASCII
    PSD_DEFAULT = fi.PSD_DEFAULT
    PSD_CMYK = fi.PSD_CMYK
    PSD_LAB = fi.PSD_LAB
    RAS_DEFAULT = fi.RAS_DEFAULT
    RAW_DEFAULT = fi.RAW_DEFAULT
    RAW_PREVIEW = fi.RAW_PREVIEW
    RAW_DISPLAY = fi.RAW_DISPLAY
    RAW_HALFSIZE = fi.RAW_HALFSIZE
    RAW_UNPROCESSED = fi.RAW_UNPROCESSED
    SGI_DEFAULT = fi.SGI_DEFAULT
    TARGA_DEFAULT = fi.TARGA_DEFAULT
    TARGA_LOAD_RGB888 = fi.TARGA_LOAD_RGB888
    TARGA_SAVE_RLE = fi.TARGA_SAVE_RLE
    TIFF_DEFAULT = fi.TIFF_DEFAULT
    TIFF_CMYK = fi.TIFF_CMYK
    TIFF_PACKBITS = fi.TIFF_PACKBITS
    TIFF_DEFLATE = fi.TIFF_DEFLATE
    TIFF_ADOBE_DEFLATE = fi.TIFF_ADOBE_DEFLATE
    TIFF_NONE = fi.TIFF_NONE
    TIFF_CCITTFAX3 = fi.TIFF_CCITTFAX3
    TIFF_CCITTFAX4 = fi.TIFF_CCITTFAX4
    TIFF_LZW = fi.TIFF_LZW
    TIFF_JPEG = fi.TIFF_JPEG
    TIFF_LOGLUV = fi.TIFF_LOGLUV
    WBMP_DEFAULT = fi.WBMP_DEFAULT
    WEBP_DEFAULT = fi.WEBP_DEFAULT
    WEBP_LOSSLESS = fi.WEBP_LOSSLESS
    JXR_DEFAULT = fi.JXR_DEFAULT
    JXR_LOSSLESS = fi.JXR_LOSSLESS
    JXR_PROGRESSIVE = fi.JXR_PROGRESSIVE
    XBM_DEFAULT = fi.XBM_DEFAULT
    XPM_DEFAULT = fi.XPM_DEFAULT

