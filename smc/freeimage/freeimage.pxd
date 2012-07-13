
from libc cimport stddef
cimport smc_fi


cdef extern from "FreeImage.h" nogil:
    ctypedef smc_fi.int32_t BOOL
    ctypedef smc_fi.uint8_t BYTE
    ctypedef smc_fi.uint16_t WORD
    ctypedef smc_fi.uint32_t DWORD
    ctypedef smc_fi.int32_t LONG

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


    # enums
    cdef enum FREE_IMAGE_FORMAT:
        FIF_UNKNOWN
        FIF_BMP
        FIF_ICO
        FIF_JPEG
        FIF_JNG
        FIF_KOALA
        FIF_LBM
        FIF_IFF
        FIF_MNG
        FIF_PBM
        FIF_PBMRAW
        FIF_PCD
        FIF_PCX
        FIF_PGM
        FIF_PGMRAW
        FIF_PNG
        FIF_PPM
        FIF_PPMRAW
        FIF_RAS
        FIF_TARGA
        FIF_TIFF
        FIF_WBMP
        FIF_PSD
        FIF_CUT
        FIF_XBM
        FIF_XPM
        FIF_DDS
        FIF_GIF
        FIF_HDR
        FIF_FAXG3
        FIF_SGI
        FIF_EXR
        FIF_J2K
        FIF_JP2
        FIF_PFM
        FIF_PICT
        FIF_RAW
        FIF_LOAD_NOPIXELS


    cdef enum FREE_IMAGE_QUANTIZE:
        FIQ_WUQUANT
        FIQ_NNQUANT


    cdef enum FREE_IMAGE_FILTER:
        FILTER_BOX
        FILTER_BICUBIC
        FILTER_BILINEAR
        FILTER_BSPLINE
        FILTER_CATMULLROM
        FILTER_LANCZOS3


    cdef enum FREE_IMAGE_TYPE:
        FIT_UNKNOWN
        FIT_BITMAP
        FIT_UINT16
        FIT_INT16
        FIT_UINT32
        FIT_INT32
        FIT_FLOAT
        FIT_DOUBLE
        FIT_COMPLEX
        FIT_RGB16
        FIT_RGBA16
        FIT_RGBF
        FIT_RGBAF


    cdef enum FREE_IMAGE_COLOR_CHANNEL:
        FICC_RGB
        FICC_RED
        FICC_GREEN
        FICC_BLUE
        FICC_ALPHA
        FICC_BLACK
        FICC_REAL
        FICC_IMAG
        FICC_MAG
        FICC_PHASE


    cdef enum FREE_IMAGE_DITHER:
        FID_FS
        FID_BAYER4x4
        FID_BAYER8x8
        FID_CLUSTER6x6
        FID_CLUSTER8x8
        FID_CLUSTER16x16
        FID_BAYER16x16


    cdef enum FREE_IMAGE_COLOR:
        FI_COLOR_IS_RGB_COLOR
        FI_COLOR_IS_RGBA_COLOR
        FI_COLOR_FIND_EQUAL_COLOR
        FI_COLOR_ALPHA_IS_INDEX
        FI_COLOR_PALETTE_SEARCH_MASK


    cdef enum FREE_IMAGE_TMO:
        FITMO_DRAGO03
        FITMO_REINHARD05
        FITMO_FATTAL02


    cdef enum FREE_IMAGE_MDTYPE:
        FIDT_NOTYPE
        FIDT_BYTE
        FIDT_ASCII
        FIDT_SHORT
        FIDT_LONG
        FIDT_RATIONAL
        FIDT_SBYTE
        FIDT_UNDEFINED
        FIDT_SSHORT
        FIDT_SLONG
        FIDT_SRATIONAL
        FIDT_FLOAT
        FIDT_DOUBLE
        FIDT_IFD
        FIDT_PALETTE
        FIDT_LONG8
        FIDT_SLONG8
        FIDT_IFD8


    cdef enum FREE_IMAGE_JPEG_OPERATION:
        FIJPEG_OP_NONE
        FIJPEG_OP_FLIP_H
        FIJPEG_OP_FLIP_V
        FIJPEG_OP_TRANSPOSE
        FIJPEG_OP_TRANSVERSE
        FIJPEG_OP_ROTATE_90
        FIJPEG_OP_ROTATE_180
        FIJPEG_OP_ROTATE_270


    cdef enum FREE_IMAGE_MDMODEL:
        FIMD_NODATA
        FIMD_COMMENTS
        FIMD_EXIF_MAIN
        FIMD_EXIF_EXIF
        FIMD_EXIF_GPS
        FIMD_EXIF_MAKERNOTE
        FIMD_EXIF_INTEROP
        FIMD_IPTC
        FIMD_XMP
        FIMD_GEOTIFF
        FIMD_ANIMATION
        FIMD_CUSTOM
        FIMD_EXIF_RAW


    cdef enum FREE_IMAGE_COLOR_TYPE:
        FIC_MINISWHITE
        FIC_MINISBLACK
        FIC_RGB
        FIC_PALETTE
        FIC_RGBALPHA
        FIC_CMYK


    cdef enum :
        FREEIMAGE_MAJOR_VERSION
        FREEIMAGE_MINOR_VERSION
        FREEIMAGE_RELEASE_SERIAL
        FREEIMAGE_COLORORDER_BGR
        FREEIMAGE_COLORORDER_RGB
        FREEIMAGE_COLORORDER
        FI_RGBA_RED
        FI_RGBA_GREEN
        FI_RGBA_BLUE
        FI_RGBA_ALPHA
        FI_RGBA_RED_MASK
        FI_RGBA_GREEN_MASK
        FI_RGBA_BLUE_MASK
        FI_RGBA_ALPHA_MASK
        FI_RGBA_RED_SHIFT
        FI_RGBA_GREEN_SHIFT
        FI_RGBA_BLUE_SHIFT
        FI_RGBA_ALPHA_SHIFT
        FI16_555_RED_MASK
        FI16_555_GREEN_MASK
        FI16_555_BLUE_MASK
        FI16_555_RED_SHIFT
        FI16_555_GREEN_SHIFT
        FI16_555_BLUE_SHIFT
        FI16_565_RED_MASK
        FI16_565_GREEN_MASK
        FI16_565_BLUE_MASK
        FI16_565_RED_SHIFT
        FI16_565_GREEN_SHIFT
        FI16_565_BLUE_SHIFT
        FIICC_DEFAULT
        FIICC_COLOR_IS_CMYK
        BMP_DEFAULT
        BMP_SAVE_RLE
        CUT_DEFAULT
        DDS_DEFAULT
        EXR_DEFAULT
        EXR_FLOAT
        EXR_NONE
        EXR_ZIP
        EXR_PIZ
        EXR_PXR24
        EXR_B44
        EXR_LC
        FAXG3_DEFAULT
        GIF_DEFAULT
        GIF_LOAD256
        GIF_PLAYBACK
        HDR_DEFAULT
        ICO_DEFAULT
        ICO_MAKEALPHA
        IFF_DEFAULT
        J2K_DEFAULT
        JP2_DEFAULT
        JPEG_DEFAULT
        JPEG_FAST
        JPEG_ACCURATE
        JPEG_CMYK
        JPEG_QUALITYSUPERB
        JPEG_QUALITYGOOD
        JPEG_QUALITYNORMAL
        JPEG_QUALITYAVERAGE
        JPEG_QUALITYBAD
        JPEG_PROGRESSIVE
        JPEG_OPTIMIZE
        JPEG_BASELINE
        JPEG_SUBSAMPLING_411
        JPEG_SUBSAMPLING_420
        JPEG_SUBSAMPLING_422
        JPEG_SUBSAMPLING_444
        KOALA_DEFAULT
        LBM_DEFAULT
        MNG_DEFAULT
        PCD_DEFAULT
        PCD_BASE
        PCD_BASEDIV4
        PCD_BASEDIV16
        PCX_DEFAULT
        PICT_DEFAULT
        PNG_DEFAULT
        PNG_IGNOREGAMMA
        PNG_Z_BEST_SPEED
        PNG_Z_DEFAULT_COMPRESSION
        PNG_Z_BEST_COMPRESSION
        PNG_Z_NO_COMPRESSION
        PNG_INTERLACED
        PNM_DEFAULT
        PNM_SAVE_RAW
        PNM_SAVE_ASCII
        PSD_DEFAULT
        PSD_CMYK
        PSD_LAB
        RAS_DEFAULT
        RAW_DEFAULT
        RAW_PREVIEW
        RAW_DISPLAY
        RAW_HALFSIZE
        SGI_DEFAULT
        TARGA_DEFAULT
        TARGA_LOAD_RGB888
        TARGA_SAVE_RLE
        TIFF_DEFAULT
        TIFF_CMYK
        TIFF_PACKBITS
        TIFF_DEFLATE
        TIFF_ADOBE_DEFLATE
        TIFF_NONE
        TIFF_CCITTFAX3
        TIFF_CCITTFAX4
        TIFF_LZW
        TIFF_JPEG
        TIFF_LOGLUV
        WBMP_DEFAULT
        XBM_DEFAULT
        XPM_DEFAULT


    # other
    cdef struct Plugin:
        pass

    ctypedef void (*FI_InitProc)(Plugin *plugin, int format_id)
    ctypedef void (*FreeImage_OutputMessageFunctionStdCall) (FREE_IMAGE_FORMAT fif, smc_fi.const_char_ptr msg)

    cdef void  FreeImage_Initialise(BOOL load_local_plugins_only)
    cdef void  FreeImage_DeInitialise()
    cdef char * FreeImage_GetVersion()
    cdef char * FreeImage_GetCopyrightMessage()
    cdef void  FreeImage_SetOutputMessageStdCall(FreeImage_OutputMessageFunctionStdCall omf)
    cdef void  FreeImage_OutputMessageProc(int fif, char *fmt, ...)
    cdef FIBITMAP * FreeImage_Allocate(int width, int height, int bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask)
    cdef FIBITMAP * FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask)
    cdef FIBITMAP *  FreeImage_Clone(FIBITMAP *dib)
    cdef void  FreeImage_Unload(FIBITMAP *dib)
    cdef BOOL  FreeImage_HasPixels(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_Load(FREE_IMAGE_FORMAT fif, char *filename, int flags)
    # cdef FIBITMAP * FreeImage_LoadU(FREE_IMAGE_FORMAT fif, wchar_t *filename, int flags)
    cdef FIBITMAP * FreeImage_LoadFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags)
    cdef BOOL  FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, char *filename, int flags)
    # cdef BOOL  FreeImage_SaveU(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, wchar_t *filename, int flags)
    cdef BOOL  FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FreeImageIO *io, fi_handle handle, int flags)
    cdef FIMEMORY * FreeImage_OpenMemory(BYTE *data, DWORD size_in_bytes)
    cdef void  FreeImage_CloseMemory(FIMEMORY *stream)
    cdef FIBITMAP * FreeImage_LoadFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags)
    cdef BOOL  FreeImage_SaveToMemory(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FIMEMORY *stream, int flags)
    cdef long  FreeImage_TellMemory(FIMEMORY *stream)
    cdef BOOL  FreeImage_SeekMemory(FIMEMORY *stream, long offset, int origin)
    cdef BOOL  FreeImage_AcquireMemory(FIMEMORY *stream, BYTE **data, DWORD *size_in_bytes)
    cdef unsigned  FreeImage_ReadMemory(void *buffer, unsigned size, unsigned count, FIMEMORY *stream)
    cdef unsigned  FreeImage_WriteMemory(void *buffer, unsigned size, unsigned count, FIMEMORY *stream)
    cdef FIMULTIBITMAP * FreeImage_LoadMultiBitmapFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags)
    cdef BOOL  FreeImage_SaveMultiBitmapToMemory(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FIMEMORY *stream, int flags)
    cdef FREE_IMAGE_FORMAT  FreeImage_RegisterLocalPlugin(FI_InitProc proc_address, char *format, char *description, char *extension, char *regexpr)
    cdef FREE_IMAGE_FORMAT  FreeImage_RegisterExternalPlugin(char *path, char *format, char *description, char *extension, char *regexpr)
    cdef int  FreeImage_GetFIFCount()
    cdef int  FreeImage_SetPluginEnabled(FREE_IMAGE_FORMAT fif, BOOL enable)
    cdef int  FreeImage_IsPluginEnabled(FREE_IMAGE_FORMAT fif)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFormat(char *format)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFIFFromMime(char *mime)
    cdef char * FreeImage_GetFormatFromFIF(FREE_IMAGE_FORMAT fif)
    cdef char * FreeImage_GetFIFExtensionList(FREE_IMAGE_FORMAT fif)
    cdef char * FreeImage_GetFIFDescription(FREE_IMAGE_FORMAT fif)
    cdef char * FreeImage_GetFIFRegExpr(FREE_IMAGE_FORMAT fif)
    cdef char * FreeImage_GetFIFMimeType(FREE_IMAGE_FORMAT fif)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFilename(char *filename)
    # cdef FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFilenameU(wchar_t *filename)
    cdef BOOL  FreeImage_FIFSupportsReading(FREE_IMAGE_FORMAT fif)
    cdef BOOL  FreeImage_FIFSupportsWriting(FREE_IMAGE_FORMAT fif)
    cdef BOOL  FreeImage_FIFSupportsExportBPP(FREE_IMAGE_FORMAT fif, int bpp)
    cdef BOOL  FreeImage_FIFSupportsExportType(FREE_IMAGE_FORMAT fif, FREE_IMAGE_TYPE type)
    cdef BOOL  FreeImage_FIFSupportsICCProfiles(FREE_IMAGE_FORMAT fif)
    cdef BOOL  FreeImage_FIFSupportsNoPixels(FREE_IMAGE_FORMAT fif)
    cdef FIMULTIBITMAP *  FreeImage_OpenMultiBitmap(FREE_IMAGE_FORMAT fif, char *filename, BOOL create_new, BOOL read_only, BOOL keep_cache_in_memory, int flags)
    cdef FIMULTIBITMAP *  FreeImage_OpenMultiBitmapFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags)
    cdef BOOL  FreeImage_SaveMultiBitmapToHandle(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FreeImageIO *io, fi_handle handle, int flags)
    cdef BOOL  FreeImage_CloseMultiBitmap(FIMULTIBITMAP *bitmap, int flags)
    cdef int  FreeImage_GetPageCount(FIMULTIBITMAP *bitmap)
    cdef void  FreeImage_AppendPage(FIMULTIBITMAP *bitmap, FIBITMAP *data)
    cdef void  FreeImage_InsertPage(FIMULTIBITMAP *bitmap, int page, FIBITMAP *data)
    cdef void  FreeImage_DeletePage(FIMULTIBITMAP *bitmap, int page)
    cdef FIBITMAP *  FreeImage_LockPage(FIMULTIBITMAP *bitmap, int page)
    cdef void  FreeImage_UnlockPage(FIMULTIBITMAP *bitmap, FIBITMAP *data, BOOL changed)
    cdef BOOL  FreeImage_MovePage(FIMULTIBITMAP *bitmap, int target, int source)
    cdef BOOL  FreeImage_GetLockedPageNumbers(FIMULTIBITMAP *bitmap, int *pages, int *count)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFileType(char *filename, int size)
    # cdef FREE_IMAGE_FORMAT  FreeImage_GetFileTypeU(wchar_t *filename, int size)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFileTypeFromHandle(FreeImageIO *io, fi_handle handle, int size)
    cdef FREE_IMAGE_FORMAT  FreeImage_GetFileTypeFromMemory(FIMEMORY *stream, int size)
    cdef FREE_IMAGE_TYPE  FreeImage_GetImageType(FIBITMAP *dib)
    cdef BOOL  FreeImage_IsLittleEndian()
    cdef BOOL  FreeImage_LookupX11Color(char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue)
    cdef BOOL  FreeImage_LookupSVGColor(char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue)
    cdef BYTE * FreeImage_GetBits(FIBITMAP *dib)
    cdef BYTE * FreeImage_GetScanLine(FIBITMAP *dib, int scanline)
    cdef BOOL  FreeImage_GetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value)
    cdef BOOL  FreeImage_GetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value)
    cdef BOOL  FreeImage_SetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value)
    cdef BOOL  FreeImage_SetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value)
    cdef unsigned  FreeImage_GetColorsUsed(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetBPP(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetWidth(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetHeight(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetLine(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetPitch(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetDIBSize(FIBITMAP *dib)
    cdef RGBQUAD * FreeImage_GetPalette(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetDotsPerMeterX(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetDotsPerMeterY(FIBITMAP *dib)
    cdef void  FreeImage_SetDotsPerMeterX(FIBITMAP *dib, unsigned res)
    cdef void  FreeImage_SetDotsPerMeterY(FIBITMAP *dib, unsigned res)
    cdef BITMAPINFOHEADER * FreeImage_GetInfoHeader(FIBITMAP *dib)
    cdef BITMAPINFO * FreeImage_GetInfo(FIBITMAP *dib)
    cdef FREE_IMAGE_COLOR_TYPE  FreeImage_GetColorType(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetRedMask(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetGreenMask(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetBlueMask(FIBITMAP *dib)
    cdef unsigned  FreeImage_GetTransparencyCount(FIBITMAP *dib)
    cdef BYTE *  FreeImage_GetTransparencyTable(FIBITMAP *dib)
    cdef void  FreeImage_SetTransparent(FIBITMAP *dib, BOOL enabled)
    cdef void  FreeImage_SetTransparencyTable(FIBITMAP *dib, BYTE *table, int count)
    cdef BOOL  FreeImage_IsTransparent(FIBITMAP *dib)
    cdef void  FreeImage_SetTransparentIndex(FIBITMAP *dib, int index)
    cdef int  FreeImage_GetTransparentIndex(FIBITMAP *dib)
    cdef BOOL  FreeImage_HasBackgroundColor(FIBITMAP *dib)
    cdef BOOL  FreeImage_GetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor)
    cdef BOOL  FreeImage_SetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor)
    cdef FIBITMAP * FreeImage_GetThumbnail(FIBITMAP *dib)
    cdef BOOL  FreeImage_SetThumbnail(FIBITMAP *dib, FIBITMAP *thumbnail)
    cdef FIICCPROFILE * FreeImage_GetICCProfile(FIBITMAP *dib)
    cdef FIICCPROFILE * FreeImage_CreateICCProfile(FIBITMAP *dib, void *data, long size)
    cdef void  FreeImage_DestroyICCProfile(FIBITMAP *dib)
    cdef void  FreeImage_ConvertLine1To4(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine8To4(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine16To4_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine16To4_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine24To4(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine32To4(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine1To8(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine4To8(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine16To8_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine16To8_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine24To8(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine32To8(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine1To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine4To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine8To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine16_565_To16_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine24To16_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine32To16_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine1To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine4To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine8To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine16_555_To16_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine24To16_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine32To16_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine1To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine4To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine8To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine16To24_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine16To24_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine32To24(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine1To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine4To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine8To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette)
    cdef void  FreeImage_ConvertLine16To32_555(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine16To32_565(BYTE *target, BYTE *source, int width_in_pixels)
    cdef void  FreeImage_ConvertLine24To32(BYTE *target, BYTE *source, int width_in_pixels)
    cdef FIBITMAP * FreeImage_ConvertTo4Bits(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertTo8Bits(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertToGreyscale(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertTo16Bits555(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertTo16Bits565(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertTo24Bits(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertTo32Bits(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ColorQuantize(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize)
    cdef FIBITMAP * FreeImage_ColorQuantizeEx(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize, int PaletteSize, int ReserveSize, RGBQUAD *ReservePalette)
    cdef FIBITMAP * FreeImage_Threshold(FIBITMAP *dib, BYTE T)
    cdef FIBITMAP * FreeImage_Dither(FIBITMAP *dib, FREE_IMAGE_DITHER algorithm)
    cdef FIBITMAP * FreeImage_ConvertFromRawBits(BYTE *bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown)
    cdef void  FreeImage_ConvertToRawBits(BYTE *bits, FIBITMAP *dib, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown)
    cdef FIBITMAP * FreeImage_ConvertToFloat(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertToRGBF(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertToUINT16(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertToRGB16(FIBITMAP *dib)
    cdef FIBITMAP * FreeImage_ConvertToStandardType(FIBITMAP *src, BOOL scale_linear)
    cdef FIBITMAP * FreeImage_ConvertToType(FIBITMAP *src, FREE_IMAGE_TYPE dst_type, BOOL scale_linear)
    cdef FIBITMAP * FreeImage_ToneMapping(FIBITMAP *dib, FREE_IMAGE_TMO tmo, double first_param, double second_param)
    cdef FIBITMAP * FreeImage_TmoDrago03(FIBITMAP *src, double gamma, double exposure)
    cdef FIBITMAP * FreeImage_TmoReinhard05(FIBITMAP *src, double intensity, double contrast)
    cdef FIBITMAP * FreeImage_TmoReinhard05Ex(FIBITMAP *src, double intensity, double contrast, double adaptation, double color_correction)
    cdef FIBITMAP * FreeImage_TmoFattal02(FIBITMAP *src, double color_saturation, double attenuation)
    cdef DWORD  FreeImage_ZLibCompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size)
    cdef DWORD  FreeImage_ZLibUncompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size)
    cdef DWORD  FreeImage_ZLibGZip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size)
    cdef DWORD  FreeImage_ZLibGUnzip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size)
    cdef DWORD  FreeImage_ZLibCRC32(DWORD crc, BYTE *source, DWORD source_size)
    cdef FITAG * FreeImage_CreateTag()
    cdef void  FreeImage_DeleteTag(FITAG *tag)
    cdef FITAG * FreeImage_CloneTag(FITAG *tag)
    cdef char * FreeImage_GetTagKey(FITAG *tag)
    cdef char * FreeImage_GetTagDescription(FITAG *tag)
    cdef WORD  FreeImage_GetTagID(FITAG *tag)
    cdef FREE_IMAGE_MDTYPE  FreeImage_GetTagType(FITAG *tag)
    cdef DWORD  FreeImage_GetTagCount(FITAG *tag)
    cdef DWORD  FreeImage_GetTagLength(FITAG *tag)
    cdef void * FreeImage_GetTagValue(FITAG *tag)
    cdef BOOL  FreeImage_SetTagKey(FITAG *tag, char *key)
    cdef BOOL  FreeImage_SetTagDescription(FITAG *tag, char *description)
    cdef BOOL  FreeImage_SetTagID(FITAG *tag, WORD id)
    cdef BOOL  FreeImage_SetTagType(FITAG *tag, FREE_IMAGE_MDTYPE type)
    cdef BOOL  FreeImage_SetTagCount(FITAG *tag, DWORD count)
    cdef BOOL  FreeImage_SetTagLength(FITAG *tag, DWORD length)
    cdef BOOL  FreeImage_SetTagValue(FITAG *tag, void *value)
    cdef FIMETADATA * FreeImage_FindFirstMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, FITAG **tag)
    cdef BOOL  FreeImage_FindNextMetadata(FIMETADATA *mdhandle, FITAG **tag)
    cdef void  FreeImage_FindCloseMetadata(FIMETADATA *mdhandle)
    cdef BOOL  FreeImage_SetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, char *key, FITAG *tag)
    cdef BOOL  FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, char *key, FITAG **tag)
    cdef unsigned  FreeImage_GetMetadataCount(FREE_IMAGE_MDMODEL model, FIBITMAP *dib)
    cdef BOOL  FreeImage_CloneMetadata(FIBITMAP *dst, FIBITMAP *src)
    cdef char*  FreeImage_TagToString(FREE_IMAGE_MDMODEL model, FITAG *tag, char *Make)
    cdef FIBITMAP * FreeImage_RotateClassic(FIBITMAP *dib, double angle)
    cdef FIBITMAP * FreeImage_Rotate(FIBITMAP *dib, double angle, void *bkcolor)
    cdef FIBITMAP * FreeImage_RotateEx(FIBITMAP *dib, double angle, double x_shift, double y_shift, double x_origin, double y_origin, BOOL use_mask)
    cdef BOOL  FreeImage_FlipHorizontal(FIBITMAP *dib)
    cdef BOOL  FreeImage_FlipVertical(FIBITMAP *dib)
    cdef BOOL  FreeImage_JPEGTransform(char *src_file, char *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect)
    # cdef BOOL  FreeImage_JPEGTransformU(wchar_t *src_file, wchar_t *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect)
    cdef FIBITMAP * FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter)
    cdef FIBITMAP * FreeImage_MakeThumbnail(FIBITMAP *dib, int max_pixel_size, BOOL convert)
    cdef BOOL  FreeImage_AdjustCurve(FIBITMAP *dib, BYTE *LUT, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef BOOL  FreeImage_AdjustGamma(FIBITMAP *dib, double gamma)
    cdef BOOL  FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage)
    cdef BOOL  FreeImage_AdjustContrast(FIBITMAP *dib, double percentage)
    cdef BOOL  FreeImage_Invert(FIBITMAP *dib)
    cdef BOOL  FreeImage_GetHistogram(FIBITMAP *dib, DWORD *histo, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef int  FreeImage_GetAdjustColorsLookupTable(BYTE *LUT, double brightness, double contrast, double gamma, BOOL invert)
    cdef BOOL  FreeImage_AdjustColors(FIBITMAP *dib, double brightness, double contrast, double gamma, BOOL invert)
    cdef unsigned  FreeImage_ApplyColorMapping(FIBITMAP *dib, RGBQUAD *srccolors, RGBQUAD *dstcolors, unsigned count, BOOL ignore_alpha, BOOL swap)
    cdef unsigned  FreeImage_SwapColors(FIBITMAP *dib, RGBQUAD *color_a, RGBQUAD *color_b, BOOL ignore_alpha)
    cdef unsigned  FreeImage_ApplyPaletteIndexMapping(FIBITMAP *dib, BYTE *srcindices,	BYTE *dstindices, unsigned count, BOOL swap)
    cdef unsigned  FreeImage_SwapPaletteIndices(FIBITMAP *dib, BYTE *index_a, BYTE *index_b)
    cdef FIBITMAP * FreeImage_GetChannel(FIBITMAP *dib, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef BOOL  FreeImage_SetChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef FIBITMAP * FreeImage_GetComplexChannel(FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef BOOL  FreeImage_SetComplexChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel)
    cdef FIBITMAP * FreeImage_Copy(FIBITMAP *dib, int left, int top, int right, int bottom)
    cdef BOOL  FreeImage_Paste(FIBITMAP *dst, FIBITMAP *src, int left, int top, int alpha)
    cdef FIBITMAP * FreeImage_Composite(FIBITMAP *fg, BOOL useFileBkg, RGBQUAD *appBkColor, FIBITMAP *bg)
    cdef BOOL  FreeImage_JPEGCrop(char *src_file, char *dst_file, int left, int top, int right, int bottom)
    # cdef BOOL  FreeImage_JPEGCropU(wchar_t *src_file, wchar_t *dst_file, int left, int top, int right, int bottom)
    cdef BOOL  FreeImage_PreMultiplyWithAlpha(FIBITMAP *dib)
    cdef BOOL  FreeImage_FillBackground(FIBITMAP *dib, void *color, int options)
    cdef FIBITMAP * FreeImage_EnlargeCanvas(FIBITMAP *src, int left, int top, int right, int bottom, void *color, int options)
    cdef FIBITMAP * FreeImage_AllocateEx(int width, int height, int bpp, RGBQUAD *color, int options, RGBQUAD *palette, unsigned red_mask, unsigned green_mask, unsigned blue_mask)
    cdef FIBITMAP * FreeImage_AllocateExT(FREE_IMAGE_TYPE type, int width, int height, int bpp, void *color, int options, RGBQUAD *palette, unsigned red_mask, unsigned green_mask, unsigned blue_mask)
    cdef FIBITMAP * FreeImage_MultigridPoissonSolver(FIBITMAP *Laplacian, int ncycle)
