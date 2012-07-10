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
# Purpose     : Create PXI file from lcms.h and local definitions
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
"""Create lcms.pxi from header file
"""

from __future__ import with_statement
import re

LCMS_H = "windows/lcms2.h"
#DEFINITION = re.compile("DLL_API (.*)DLL_CALLCONV ([A-Za-z_0-9]*)\((.*)\)")
DEFINE_TYPE = re.compile("#define ((TYPE|cmsFLAGS|cmsERROR|INTENT|LCMS_USED)_[A-Za-z0-9_]*)[ \t]")

PXI = "smc/freeimage/lcms.pxi"
ENUM = "smc/freeimage/enums.py"
LCMSCONSTANTS = "smc/freeimage/lcmsconstants.c"

HEADER = """
cdef extern from *:
    ctypedef char* const_char_ptr "const char*"
    ctypedef char const_char "const char"
    ctypedef void* const_void_ptr "const void*"
    ctypedef struct const_struct "const struct"

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
        

    ctypedef enum cmsInfoType:
        cmsInfoDescription
        cmsInfoManufacturer
        cmsInfoModel
        cmsInfoCopyright
        
    # constants
    const_char_ptr cmsNoCountry
    cdef enum:
        cmsMAX_PATH
        LCMS_VERSION
    
    # profiles
    cdef cmsHPROFILE cmsOpenProfileFromFileTHR(cmsContext ContextID, const_char_ptr ICCProfile, const_char_ptr sAccess)
    cdef cmsHPROFILE cmsOpenProfileFromMemTHR(cmsContext ContextID, const_char_ptr MemPtr, cmsUInt32Number dwSize)
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
                             const_void_ptr InputBuffer,
                             void* OutputBuffer, 
                             cmsUInt32Number Size)
    
    ctypedef void (*cmsLogErrorHandlerFunction)(cmsContext ContextID, cmsUInt32Number ErrorCode, const_char_ptr Text)
    cdef void cmsSetLogErrorHandler(cmsLogErrorHandlerFunction Fn)
    
    # introspection
    cdef cmsBool cmsGetHeaderCreationDateTime(cmsHPROFILE hProfile, tm *Dest)
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
                                           const_char LanguageCode[3], const_char CountryCode[3],
                                           wchar_t* Buffer, cmsUInt32Number BufferSize)
    cdef cmsUInt32Number cmsMLUgetWide(const_cmsMLU* mlu,   
                                       const_char LanguageCode[3], const_char CountryCode[3], 
                                       wchar_t* Buffer, cmsUInt32Number BufferSize)
    
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

"""

CONSTANTS = []

def parse(fname):
    lines = []
    with open(fname) as f:
        for line in f:
            mo = DEFINE_TYPE.search(line)
            if mo is not None:
                typ = mo.group(1).strip()
                if typ.startswith("LCMS_DLL"):
                    continue
                CONSTANTS.append(typ)
                lines.append("    int %s" % typ)

    return lines


def update_lcmsconstants_c(fname):
    lines = []
    with open(fname) as f:
        for line in f:
            lines.append(line.rstrip())
            if 'MARKER' in line:
                break
    for typ in CONSTANTS:
        lines.append('    PyModule_AddIntConstant(m, "%s", %s);' %
                         (typ, typ))
    lines.append('}\n\n')
    with open(fname, 'w') as f:
        f.write('\n'.join(lines))

if __name__ == "__main__":
    with open(PXI, "w") as f:
        f.write(HEADER)
        f.write('\n'.join(parse(LCMS_H)))
        f.write('\n')
    update_lcmsconstants_c(LCMSCONSTANTS)
