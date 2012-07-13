
from libc cimport stddef
cimport smc_fi


cdef extern from "lcms2.h" nogil:

    # base types
    ctypedef int   cmsBool
    ctypedef void* cmsHANDLE
    ctypedef void* cmsHPROFILE
    ctypedef void* cmsHTRANSFORM
    ctypedef void* cmsContext
    
    ctypedef unsigned int cmsUInt16Number
    ctypedef unsigned long cmsUInt32Number
    ctypedef unsigned long long cmsUInt64Number
    ctypedef double cmsFloat64Number
    ctypedef unsigned char cmsUInt8Number
    ctypedef cmsUInt32Number cmsSignature
    ctypedef long cmsInt32Number

    cdef struct cmsMLU:
        pass
    ctypedef cmsMLU const_cmsMLU "const cmsMLU"

    ctypedef struct cmsNAMEDCOLORLIST:
        pass

    ctypedef struct cmsCIEXYZ:
        cmsFloat64Number X
        cmsFloat64Number Y
        cmsFloat64Number Z

    ctypedef struct cmsCIExyY:
        cmsFloat64Number x
        cmsFloat64Number y
        cmsFloat64Number Y

    ctypedef struct cmsCIELab:
        cmsFloat64Number L
        cmsFloat64Number a
        cmsFloat64Number b

    ctypedef struct cmsCIEXYZTRIPLE:
        cmsCIEXYZ Red
        cmsCIEXYZ Green
        cmsCIEXYZ Blue

    ctypedef struct cmsCIExyYTRIPLE:
        cmsCIExyY Red
        cmsCIExyY Green
        cmsCIExyY Blue

    ctypedef struct cmsICCMeasurementConditions:
        cmsUInt32Number  Observer # 0 = unknown, 1=CIE 1931, 2=CIE 1964
        cmsCIEXYZ        Backing # Value of backing
        cmsUInt32Number  Geometry # 0=unknown, 1=45/0, 0/45 2=0d, d/0
        cmsFloat64Number Flare # 0..1.0
        cmsUInt32Number  IlluminantType

    ctypedef struct cmsICCViewingConditions:
        cmsCIEXYZ IlluminantXYZ
        cmsCIEXYZ SurroundXYZ
        cmsUInt32Number IlluminantType

    ctypedef struct cmsToneCurve:
        pass

    # enums
    ctypedef enum cmsProfileClassSignature:
        cmsSigInputClass 
        cmsSigDisplayClass
        cmsSigOutputClass
        cmsSigLinkClass
        cmsSigAbstractClass
        cmsSigColorSpaceClass
        cmsSigNamedColorClass

    ctypedef enum cmsColorSpaceSignature:
        cmsSigXYZData # XYZ 
        cmsSigLabData # Lab 
        cmsSigLuvData # Luv 
        cmsSigYCbCrData # YCbr
        cmsSigYxyData # Yxy 
        cmsSigRgbData # RGB 
        cmsSigGrayData # GRAY
        cmsSigHsvData # HSV 
        cmsSigHlsData # HLS 
        cmsSigCmykData # CMYK
        cmsSigCmyData # CMY 
        cmsSigMCH1Data # MCH1 
        cmsSigMCH2Data # MCH2   
        cmsSigMCH3Data # MCH3 
        cmsSigMCH4Data # MCH4      
        cmsSigMCH5Data # MCH5 
        cmsSigMCH6Data # MCH6 
        cmsSigMCH7Data # MCH7 
        cmsSigMCH8Data # MCH8 
        cmsSigMCH9Data # MCH9 
        cmsSigMCHAData # MCHA 
        cmsSigMCHBData # MCHB 
        cmsSigMCHCData # MCHC 
        cmsSigMCHDData # MCHD 
        cmsSigMCHEData # MCHE 
        cmsSigMCHFData # MCHF 
        cmsSigNamedData # nmcl
        cmsSig1colorData # 1CLR 
        cmsSig2colorData # 2CLR
        cmsSig3colorData # 3CLR
        cmsSig4colorData # 4CLR
        cmsSig5colorData # 5CLR
        cmsSig6colorData # 6CLR
        cmsSig7colorData # 7CLR
        cmsSig8colorData # 8CLR
        cmsSig9colorData # 9CLR
        cmsSig10colorData # ACLR
        cmsSig11colorData # BCLR
        cmsSig12colorData # CCLR
        cmsSig13colorData # DCLR
        cmsSig14colorData # ECLR
        cmsSig15colorData # FCLR
        cmsSigLuvKData # LuvK

    ctypedef enum cmsTagTypeSignature:
        cmsSigChromaticityType # chrm
        cmsSigColorantOrderType # clro
        cmsSigColorantTableType # clrt
        cmsSigCrdInfoType # crdi
        cmsSigCurveType # curv
        cmsSigDataType # data
        cmsSigDictType # dict
        cmsSigDateTimeType # dtim
        cmsSigDeviceSettingsType # devs
        cmsSigLut16Type # mft2
        cmsSigLut8Type # mft1
        cmsSigLutAtoBType # mAB 
        cmsSigLutBtoAType # mBA 
        cmsSigMeasurementType # meas
        cmsSigMultiLocalizedUnicodeType # mluc
        cmsSigMultiProcessElementType # mpet
        cmsSigNamedColorType # ncol -- DEPRECATED!
        cmsSigNamedColor2Type # ncl2
        cmsSigParametricCurveType # para
        cmsSigProfileSequenceDescType # pseq
        cmsSigProfileSequenceIdType # psid
        cmsSigResponseCurveSet16Type # rcs2
        cmsSigS15Fixed16ArrayType # sf32
        cmsSigScreeningType # scrn
        cmsSigSignatureType # sig 
        cmsSigTextType # text
        cmsSigTextDescriptionType # desc
        cmsSigU16Fixed16ArrayType # uf32
        cmsSigUcrBgType # bfd 
        cmsSigUInt16ArrayType # ui16
        cmsSigUInt32ArrayType # ui32
        cmsSigUInt64ArrayType # ui64
        cmsSigUInt8ArrayType # ui08 
        cmsSigVcgtType # vcgt
        cmsSigViewingConditionsType # view
        cmsSigXYZType # XYZ 

    ctypedef enum cmsTagSignature:
        cmsSigAToB0Tag # A2B0 
        cmsSigAToB1Tag # A2B1
        cmsSigAToB2Tag # A2B2 
        cmsSigBlueColorantTag # bXYZ
        cmsSigBlueMatrixColumnTag # bXYZ
        cmsSigBlueTRCTag # bTRC
        cmsSigBToA0Tag # B2A0
        cmsSigBToA1Tag # B2A1
        cmsSigBToA2Tag # B2A2
        cmsSigCalibrationDateTimeTag # calt
        cmsSigCharTargetTag # targ 
        cmsSigChromaticAdaptationTag # chad
        cmsSigChromaticityTag # chrm
        cmsSigColorantOrderTag # clro
        cmsSigColorantTableTag # clrt
        cmsSigColorantTableOutTag # clot
        cmsSigColorimetricIntentImageStateTag # ciis
        cmsSigCopyrightTag # cprt
        cmsSigCrdInfoTag # crdi 
        cmsSigDataTag # data 
        cmsSigDateTimeTag # dtim 
        cmsSigDeviceMfgDescTag # dmnd
        cmsSigDeviceModelDescTag # dmdd
        cmsSigDeviceSettingsTag # devs 
        cmsSigDToB0Tag # D2B0
        cmsSigDToB1Tag # D2B1
        cmsSigDToB2Tag # D2B2
        cmsSigDToB3Tag # D2B3
        cmsSigBToD0Tag # B2D0
        cmsSigBToD1Tag # B2D1
        cmsSigBToD2Tag # B2D2
        cmsSigBToD3Tag # B2D3
        cmsSigGamutTag # gamt
        cmsSigGrayTRCTag # kTRC
        cmsSigGreenColorantTag # gXYZ
        cmsSigGreenMatrixColumnTag # gXYZ
        cmsSigGreenTRCTag # gTRC
        cmsSigLuminanceTag # lumi
        cmsSigMeasurementTag # meas
        cmsSigMediaBlackPointTag # bkpt
        cmsSigMediaWhitePointTag # wtpt
        cmsSigNamedColorTag # ncol // Deprecated by the ICC
        cmsSigNamedColor2Tag # ncl2
        cmsSigOutputResponseTag # resp
        cmsSigPerceptualRenderingIntentGamutTag # rig0
        cmsSigPreview0Tag # pre0
        cmsSigPreview1Tag # pre1
        cmsSigPreview2Tag # pre2
        cmsSigProfileDescriptionTag # desc
        cmsSigProfileSequenceDescTag # pseq
        cmsSigProfileSequenceIdTag # psid
        cmsSigPs2CRD0Tag # psd0 
        cmsSigPs2CRD1Tag # psd1 
        cmsSigPs2CRD2Tag # psd2 
        cmsSigPs2CRD3Tag # psd3 
        cmsSigPs2CSATag # ps2s 
        cmsSigPs2RenderingIntentTag # ps2i 
        cmsSigRedColorantTag # rXYZ
        cmsSigRedMatrixColumnTag # rXYZ
        cmsSigRedTRCTag # rTRC
        cmsSigSaturationRenderingIntentGamutTag # rig2
        cmsSigScreeningDescTag # scrd 
        cmsSigScreeningTag # scrn 
        cmsSigTechnologyTag # tech
        cmsSigUcrBgTag # bfd  
        cmsSigViewingCondDescTag # vued
        cmsSigViewingConditionsTag # view
        cmsSigVcgtTag # vcgt
        cmsSigMetaTag # meta

    ctypedef enum cmsInfoType:
        cmsSigDigitalCamera # dcam
        cmsSigFilmScanner # fscn
        cmsSigReflectiveScanner # rscn
        cmsSigInkJetPrinter # ijet
        cmsSigThermalWaxPrinter # twax
        cmsSigElectrophotographicPrinter # epho
        cmsSigElectrostaticPrinter # esta
        cmsSigDyeSublimationPrinter # dsub
        cmsSigPhotographicPaperPrinter # rpho
        cmsSigFilmWriter # fprn
        cmsSigVideoMonitor # vidm
        cmsSigVideoCamera # vidc
        cmsSigProjectionTelevision # pjtv
        cmsSigCRTDisplay # CRT 
        cmsSigPMDisplay # PMD 
        cmsSigAMDisplay # AMD 
        cmsSigPhotoCD # KPCD
        cmsSigPhotoImageSetter # imgs
        cmsSigGravure # grav
        cmsSigOffsetLithography # offs
        cmsSigSilkscreen # silk
        cmsSigFlexography # flex
        cmsSigMotionPictureFilmScanner # mpfs
        cmsSigMotionPictureFilmRecorder # mpfr
        cmsSigDigitalMotionPictureCamera # dmpc
        cmsSigDigitalCinemaProjector # dcpj

    ctypedef enum cmsPlatformSignature:
        cmsSigMacintosh # APPL
        cmsSigMicrosoft # MSFT
        cmsSigSolaris # SUNW
        cmsSigSGI # SGI 
        cmsSigTaligent # TGNT
        cmsSigUnices # *nix

    ctypedef enum cmsStageSignature:
        cmsSigCurveSetElemType # cvst
        cmsSigMatrixElemType # matf
        cmsSigCLutElemType # clut
        cmsSigBAcsElemType # bACS
        cmsSigEAcsElemType # eACS
        #Custom from here, not in the ICC Spec
        cmsSigXYZ2LabElemType # l2x 
        cmsSigLab2XYZElemType # x2l 
        cmsSigNamedColorElemType # ncl 
        cmsSigLabV2toV4 # 2 4 
        cmsSigLabV4toV2 # 4 2 
        # Identities
        cmsSigIdentityElemType # idn 

    ctypedef enum cmsCurveSegSignature:
        cmsSigFormulaCurveSeg # parf
        cmsSigSampledCurveSeg # samf
        cmsSigSegmentedCurve # curf

    ctypedef enum cmsInfoType:
        cmsInfoDescription
        cmsInfoManufacturer
        cmsInfoModel
        cmsInfoCopyright

    # constants
    smc_fi.const_char_ptr cmsNoCountry
    cdef enum:
        cmsMAX_PATH
        LCMS_VERSION

    # profiles
    cdef cmsHPROFILE cmsOpenProfileFromFileTHR(cmsContext ContextID, smc_fi.const_char_ptr ICCProfile, smc_fi.const_char_ptr sAccess)
    cdef cmsHPROFILE cmsOpenProfileFromMemTHR(cmsContext ContextID, smc_fi.const_char_ptr MemPtr, cmsUInt32Number dwSize)
    cdef cmsBool cmsCloseProfile(cmsHPROFILE hProfile)

    #cdef cmsHPROFILE cmsCreateRGBProfile(LPcmsCIExyY WhitePoint,
    #                                     LPcmsCIExyYTRIPLE Primaries,
    #                                     LPGAMMATABLE TransferFunction[3])
    cdef cmsHPROFILE cmsCreateGrayProfileTHR(cmsContext ContextID,
                                             cmsCIExyY* WhitePoint,
                                             cmsToneCurve* TransferFunction)
    #cdef cmsHPROFILE cmsCreateGrayProfile(LPcmsCIExyY WhitePoint,
    #                                      LPGAMMATABLE TransferFunction)
    #cdef cmsHPROFILE cmsCreateLinearizationDeviceLink(icColorSpaceSignature ColorSpace,
    #                                                  LPGAMMATABLE TransferFunctions[])
    #cdef cmsHPROFILE cmsCreateInkLimitingDeviceLink(icColorSpaceSignature ColorSpace,
    #                                                double Limit)
    #cdef cmsHPROFILE cmsCreateLabProfile(LPcmsCIExyY WhitePoint)
    #cdef cmsHPROFILE cmsCreateLab4Profile(LPcmsCIExyY WhitePoint)
    cdef cmsHPROFILE cmsCreateXYZProfileTHR(cmsContext ContextID)
    cdef cmsHPROFILE cmsCreate_sRGBProfileTHR(cmsContext ContextID)
    #cdef cmsHPROFILE cmsCreateBCHSWabstractProfile(int nLUTPoints,
    #                                               double Bright,
    #                                               double Contrast,
    #                                               double Hue,
    #                                               double Saturation,
    #                                               int TempSrc,
    #                                               int TempDest)

    cdef cmsHPROFILE cmsCreateNULLProfileTHR(cmsContext ContextID)
    cdef cmsToneCurve* cmsBuildGamma(cmsContext ContextID, cmsFloat64Number Gamma)
    cdef cmsCIExyY* cmsD50_xyY()

    # transformation
    cdef cmsHTRANSFORM cmsCreateTransformTHR(
                                          cmsContext ContextID,
                                          cmsHPROFILE Input,
                                          cmsUInt32Number InputFormat,
                                          cmsHPROFILE Output,
                                          cmsUInt32Number OutputFormat,
                                          int Intent,
                                          cmsUInt32Number dwFlags)
    cdef void cmsDeleteTransform(cmsHTRANSFORM hTransform)
    cdef void cmsDoTransform(cmsHTRANSFORM hTransform,
                             smc_fi.const_void_ptr InputBuffer,
                             void* OutputBuffer, 
                             cmsUInt32Number Size)

    ctypedef void (*cmsLogErrorHandlerFunction)(cmsContext ContextID, cmsUInt32Number ErrorCode, smc_fi.const_char_ptr Text)
    cdef void cmsSetLogErrorHandler(cmsLogErrorHandlerFunction Fn)

    # introspection
    cdef cmsBool cmsGetHeaderCreationDateTime(cmsHPROFILE hProfile, smc_fi.tm *Dest)
    cdef cmsUInt32Number cmsGetHeaderFlags(cmsHPROFILE hProfile)
    cdef cmsUInt32Number cmsGetHeaderManufacturer(cmsHPROFILE hProfile)
    cdef cmsUInt32Number cmsGetHeaderModel(cmsHPROFILE hProfile)
    cdef void cmsGetHeaderAttributes(cmsHPROFILE hProfile, cmsUInt64Number* Flags)
    cdef cmsProfileClassSignature cmsGetDeviceClass(cmsHPROFILE hProfile)
    cdef cmsFloat64Number cmsGetProfileVersion(cmsHPROFILE hProfile)
    cdef cmsUInt32Number cmsGetEncodedICCversion(cmsHPROFILE hProfile)
    cdef void cmsGetHeaderProfileID(cmsHPROFILE hProfile, cmsUInt8Number* ProfileID)
    cdef cmsUInt32Number cmsGetHeaderRenderingIntent(cmsHPROFILE hProfile)

    cdef cmsInt32Number cmsGetTagCount(cmsHPROFILE hProfile)
    cdef cmsTagSignature cmsGetTagSignature(cmsHPROFILE hProfile, cmsUInt32Number n)
    cdef cmsBool cmsIsTag(cmsHPROFILE hProfile, unsigned int sig)
    cdef void* cmsReadTag(cmsHPROFILE hProfile, unsigned int sig)
    cdef cmsUInt32Number cmsGetProfileInfo(cmsHPROFILE hProfile, cmsTagSignature Info, 
                                           smc_fi.const_char LanguageCode[3], smc_fi.const_char CountryCode[3],
                                           stddef.wchar_t* Buffer, cmsUInt32Number BufferSize)
    cdef cmsUInt32Number cmsMLUgetWide(const_cmsMLU* mlu,   
                                       smc_fi.const_char LanguageCode[3], smc_fi.const_char CountryCode[3], 
                                       stddef.wchar_t* Buffer, cmsUInt32Number BufferSize)

    cdef cmsUInt32Number cmsGetSupportedIntents(cmsUInt32Number nMax, cmsUInt32Number* Codes, char** Descriptions)
    cdef cmsBool cmsIsIntentSupported(cmsHPROFILE hProfile, cmsUInt32Number Intent, int UsedDirection)
    cdef cmsBool cmsIsMatrixShaper(cmsHPROFILE hProfile)
    cdef cmsBool cmsIsCLUT(cmsHPROFILE hProfile, cmsUInt32Number Intent, int UsedDirection)
    cdef cmsColorSpaceSignature cmsGetPCS(cmsHPROFILE hProfile)
    cdef cmsColorSpaceSignature cmsGetColorSpace(cmsHPROFILE hProfile)

    cdef void cmsXYZ2xyY(cmsCIExyY* Dest, cmsCIEXYZ* Source)
    cdef void cmsxyY2XYZ(cmsCIEXYZ* Dest, cmsCIExyY* Source)
    cdef cmsBool cmsTempFromWhitePoint(cmsFloat64Number* TempK, cmsCIExyY* WhitePoint)

    cdef cmsUInt32Number cmsNamedColorCount(cmsNAMEDCOLORLIST* v)
    cdef cmsBool cmsNamedColorInfo(cmsNAMEDCOLORLIST* NamedColorList, cmsUInt32Number nColor, 
                                   char* Name, char* Prefix, char* Suffix,
                                   cmsUInt16Number* PCS, cmsUInt16Number* Colorant)

    int lcmsSignature
    int TYPE_GRAY_8
    int TYPE_GRAY_8_REV
    int TYPE_GRAY_16
    int TYPE_GRAY_16_REV
    int TYPE_GRAY_16_SE
    int TYPE_GRAYA_8
    int TYPE_GRAYA_16
    int TYPE_GRAYA_16_SE
    int TYPE_GRAYA_8_PLANAR
    int TYPE_GRAYA_16_PLANAR
    int TYPE_RGB_8
    int TYPE_RGB_8_PLANAR
    int TYPE_BGR_8
    int TYPE_BGR_8_PLANAR
    int TYPE_RGB_16
    int TYPE_RGB_16_PLANAR
    int TYPE_RGB_16_SE
    int TYPE_BGR_16
    int TYPE_BGR_16_PLANAR
    int TYPE_BGR_16_SE
    int TYPE_RGBA_8
    int TYPE_RGBA_8_PLANAR
    int TYPE_RGBA_16
    int TYPE_RGBA_16_PLANAR
    int TYPE_RGBA_16_SE
    int TYPE_ARGB_8
    int TYPE_ARGB_16
    int TYPE_ABGR_8
    int TYPE_ABGR_16
    int TYPE_ABGR_16_PLANAR
    int TYPE_ABGR_16_SE
    int TYPE_BGRA_8
    int TYPE_BGRA_16
    int TYPE_BGRA_16_SE
    int TYPE_CMY_8
    int TYPE_CMY_8_PLANAR
    int TYPE_CMY_16
    int TYPE_CMY_16_PLANAR
    int TYPE_CMY_16_SE
    int TYPE_CMYK_8
    int TYPE_CMYKA_8
    int TYPE_CMYK_8_REV
    int TYPE_YUVK_8
    int TYPE_CMYK_8_PLANAR
    int TYPE_CMYK_16
    int TYPE_CMYK_16_REV
    int TYPE_YUVK_16
    int TYPE_CMYK_16_PLANAR
    int TYPE_CMYK_16_SE
    int TYPE_KYMC_8
    int TYPE_KYMC_16
    int TYPE_KYMC_16_SE
    int TYPE_KCMY_8
    int TYPE_KCMY_8_REV
    int TYPE_KCMY_16
    int TYPE_KCMY_16_REV
    int TYPE_KCMY_16_SE
    int TYPE_CMYK5_8
    int TYPE_CMYK5_16
    int TYPE_CMYK5_16_SE
    int TYPE_KYMC5_8
    int TYPE_KYMC5_16
    int TYPE_KYMC5_16_SE
    int TYPE_CMYK6_8
    int TYPE_CMYK6_8_PLANAR
    int TYPE_CMYK6_16
    int TYPE_CMYK6_16_PLANAR
    int TYPE_CMYK6_16_SE
    int TYPE_CMYK7_8
    int TYPE_CMYK7_16
    int TYPE_CMYK7_16_SE
    int TYPE_KYMC7_8
    int TYPE_KYMC7_16
    int TYPE_KYMC7_16_SE
    int TYPE_CMYK8_8
    int TYPE_CMYK8_16
    int TYPE_CMYK8_16_SE
    int TYPE_KYMC8_8
    int TYPE_KYMC8_16
    int TYPE_KYMC8_16_SE
    int TYPE_CMYK9_8
    int TYPE_CMYK9_16
    int TYPE_CMYK9_16_SE
    int TYPE_KYMC9_8
    int TYPE_KYMC9_16
    int TYPE_KYMC9_16_SE
    int TYPE_CMYK10_8
    int TYPE_CMYK10_16
    int TYPE_CMYK10_16_SE
    int TYPE_KYMC10_8
    int TYPE_KYMC10_16
    int TYPE_KYMC10_16_SE
    int TYPE_CMYK11_8
    int TYPE_CMYK11_16
    int TYPE_CMYK11_16_SE
    int TYPE_KYMC11_8
    int TYPE_KYMC11_16
    int TYPE_KYMC11_16_SE
    int TYPE_CMYK12_8
    int TYPE_CMYK12_16
    int TYPE_CMYK12_16_SE
    int TYPE_KYMC12_8
    int TYPE_KYMC12_16
    int TYPE_KYMC12_16_SE
    int TYPE_XYZ_16
    int TYPE_Lab_8
    int TYPE_LabV2_8
    int TYPE_ALab_8
    int TYPE_ALabV2_8
    int TYPE_Lab_16
    int TYPE_LabV2_16
    int TYPE_Yxy_16
    int TYPE_YCbCr_8
    int TYPE_YCbCr_8_PLANAR
    int TYPE_YCbCr_16
    int TYPE_YCbCr_16_PLANAR
    int TYPE_YCbCr_16_SE
    int TYPE_YUV_8
    int TYPE_YUV_8_PLANAR
    int TYPE_YUV_16
    int TYPE_YUV_16_PLANAR
    int TYPE_YUV_16_SE
    int TYPE_HLS_8
    int TYPE_HLS_8_PLANAR
    int TYPE_HLS_16
    int TYPE_HLS_16_PLANAR
    int TYPE_HLS_16_SE
    int TYPE_HSV_8
    int TYPE_HSV_8_PLANAR
    int TYPE_HSV_16
    int TYPE_HSV_16_PLANAR
    int TYPE_HSV_16_SE
    int TYPE_NAMED_COLOR_INDEX
    int TYPE_XYZ_FLT
    int TYPE_XYZA_FLT
    int TYPE_Lab_FLT
    int TYPE_LabA_FLT
    int TYPE_GRAY_FLT
    int TYPE_RGB_FLT
    int TYPE_RGBA_FLT
    int TYPE_CMYK_FLT
    int TYPE_XYZ_DBL
    int TYPE_Lab_DBL
    int TYPE_GRAY_DBL
    int TYPE_RGB_DBL
    int TYPE_CMYK_DBL
    int cmsERROR_UNDEFINED
    int cmsERROR_FILE
    int cmsERROR_RANGE
    int cmsERROR_INTERNAL
    int cmsERROR_NULL
    int cmsERROR_READ
    int cmsERROR_SEEK
    int cmsERROR_WRITE
    int cmsERROR_UNKNOWN_EXTENSION
    int cmsERROR_COLORSPACE_CHECK
    int cmsERROR_ALREADY_DEFINED
    int cmsERROR_BAD_SIGNATURE
    int cmsERROR_CORRUPTION_DETECTED
    int cmsERROR_NOT_SUITABLE
    int LCMS_USED_AS_INPUT
    int LCMS_USED_AS_OUTPUT
    int LCMS_USED_AS_PROOF
    int INTENT_PERCEPTUAL
    int INTENT_RELATIVE_COLORIMETRIC
    int INTENT_SATURATION
    int INTENT_ABSOLUTE_COLORIMETRIC
    int INTENT_PRESERVE_K_ONLY_PERCEPTUAL
    int INTENT_PRESERVE_K_ONLY_RELATIVE_COLORIMETRIC
    int INTENT_PRESERVE_K_ONLY_SATURATION
    int INTENT_PRESERVE_K_PLANE_PERCEPTUAL
    int INTENT_PRESERVE_K_PLANE_RELATIVE_COLORIMETRIC
    int INTENT_PRESERVE_K_PLANE_SATURATION
    int cmsFLAGS_NOCACHE
    int cmsFLAGS_NOOPTIMIZE
    int cmsFLAGS_NULLTRANSFORM
    int cmsFLAGS_GAMUTCHECK
    int cmsFLAGS_SOFTPROOFING
    int cmsFLAGS_BLACKPOINTCOMPENSATION
    int cmsFLAGS_NOWHITEONWHITEFIXUP
    int cmsFLAGS_HIGHRESPRECALC
    int cmsFLAGS_LOWRESPRECALC
    int cmsFLAGS_8BITS_DEVICELINK
    int cmsFLAGS_GUESSDEVICECLASS
    int cmsFLAGS_KEEP_SEQUENCE
    int cmsFLAGS_FORCE_CLUT
    int cmsFLAGS_CLUT_POST_LINEARIZATION
    int cmsFLAGS_CLUT_PRE_LINEARIZATION
    int cmsFLAGS_NODEFAULTRESOURCEDEF
