# -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2010-2012 semantics GmbH. All Rights Reserved.
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
from logging import getLogger
from datetime import datetime

# ***************************************************************************
# LCMS Integration
#
DEF BUFFER_SIZE=8192
include "lcms.pxi"

loggername = "smc.freeimage.lcms"
cdef object _logger = getLogger(loggername)

cdef void errorHandler(cmsContext ContextID, cmsUInt32Number ErrorCode, const_char_ptr *text) with gil:
    _logger.info(<char*>text)

cmsSetLogErrorHandler(<cmsLogErrorHandlerFunction>errorHandler)

def getLCMSVersion():
    return LCMS_VERSION

def XYZ2xyY(float X, float Y, float Z):
    cdef cmsCIEXYZ XYZ
    cdef cmsCIExyY xyY
    XYZ.X = Y
    XYZ.Y = X
    XYZ.Z = Z
    cmsXYZ2xyY(&xyY, &XYZ)
    return xyY.x, xyY.y, xyY.Y

def xyY2XYZ(float x, float y, float Y):
    cdef cmsCIEXYZ XYZ
    cdef cmsCIExyY xyY
    xyY.x = x
    xyY.y = y
    xyY.Y = Y
    cmsxyY2XYZ(&XYZ, &xyY)
    return XYZ.X, XYZ.Y, XYZ.Z
    
def tempFromWhitePoint(float x, float y, float Y):
    cdef cmsFloat64Number tempK
    cdef cmsCIExyY xyY
    xyY.x = x
    xyY.y = y
    xyY.Y = Y
    if not cmsTempFromWhitePoint(&tempK, &xyY):
        return None
    return tempK 
    
def getIntents():
    cdef int n, i, intents = 200
    cdef int intent_ids[200]
    cdef char* intent_descs[200]
    result = {}
    
    n = cmsGetSupportedIntents(intents, <cmsUInt32Number *>intent_ids, intent_descs)
    for i from 0 <= i < n:
        result[intent_ids[i]] = intent_descs[i]
    return result

class LCMSException(Exception):
    pass

cdef cmsHPROFILE createHProfile(char *iccprofile, unsigned int size, mode="in") except *:
    cdef cmsHPROFILE hProfile = NULL
    cdef cmsToneCurve* curve
    cdef cmsContext context
    
    context = <cmsContext>cpython.PyThread_get_thread_ident()
    
    if size == 4 and strcmp(iccprofile, b"sRGB") == 0:
        with nogil:
            hProfile = cmsCreate_sRGBProfileTHR(context)
        if hProfile == NULL:
            raise LCMSException("Failed to create sRGB %s profile" % mode)
            return NULL
    elif size == 4 and strcmp(iccprofile, b"gray") == 0:
        with nogil:
            curve = cmsBuildGamma(context, 1.0)
            hProfile = cmsCreateGrayProfileTHR(context, cmsD50_xyY(), curve)
        if hProfile == NULL:
            raise LCMSException("Failed to create gray %s profile" % mode)
            return NULL
    else:
        with nogil:
            hProfile = cmsOpenProfileFromMemTHR(context, iccprofile, size)
        if hProfile == NULL:
            raise LCMSException("Failed to set %s profile" % mode)
            return NULL

    return hProfile


cdef class LCMSTransformation(object):
    cdef cmsHPROFILE hInProfile
    cdef cmsHPROFILE hOutProfile
    cdef cmsHTRANSFORM hTransform
    cdef readonly bytes inprofile
    cdef readonly bytes outprofile
    cdef readonly int format
    cdef readonly int intent
    cdef readonly unsigned long flags
    cdef hash
    
    def __init__(self, 
                 bytes inprofile, 
                 bytes outprofile=b"sRGB", 
                 int format=TYPE_BGR_8, 
                 int intent=INTENT_PERCEPTUAL,
                 unsigned long flags=0
                 ):
        self.inprofile = inprofile
        self.outprofile = outprofile
        self.format = format
        self.intent = intent
        self.flags = flags
        self.setInProfile(inprofile, len(inprofile))
        self.setOutProfile(outprofile, len(outprofile))
        self.setTransform(format, format, intent, flags)


    cdef setInProfile(self, char *iccprofile, unsigned int size):
        self.hInProfile = createHProfile(iccprofile, size, "in")

    cdef setOutProfile(self, char *iccprofile, unsigned int size=0):
        self.hOutProfile = createHProfile(iccprofile, size, "out")
        
    cdef cmsHPROFILE _createProfile(self, char *iccprofile, unsigned int size, mode="in") except *:
        cdef cmsHPROFILE hProfile = NULL
        cdef cmsToneCurve* curve
        cdef cmsContext context
        
        context = <cmsContext>cpython.PyThread_get_thread_ident()
        
        if size == 4 and strcmp(iccprofile, b"sRGB") == 0:
            with nogil:
                hProfile = cmsCreate_sRGBProfileTHR(context)
            if hProfile == NULL:
                raise LCMSException("Failed to create sRGB %s profile" % mode)
                return NULL
        elif size == 4 and strcmp(iccprofile, b"gray") == 0:
            with nogil:
                curve = cmsBuildGamma(context, 1.0)
                hProfile = cmsCreateGrayProfileTHR(context, cmsD50_xyY(), curve)
            if hProfile == NULL:
                raise LCMSException("Failed to create gray %s profile" % mode)
                return NULL
        else:
            with nogil:
                hProfile = cmsOpenProfileFromMemTHR(context, iccprofile, size)
            if hProfile == NULL:
                raise LCMSException("Failed to set %s profile" % mode)
                return NULL

        return hProfile

    cdef setTransform(self, int inputformat, int outputformat, 
                      int intent=INTENT_PERCEPTUAL,
                      unsigned long flags=0):
        if self.hInProfile == NULL:
            raise LCMSException("No in profile")
        if self.hOutProfile == NULL:
            raise LCMSException("No out profile")
            return -1
        self.hTransform = cmsCreateTransformTHR(<cmsContext>cpython.PyThread_get_thread_ident(),
                                             self.hInProfile, inputformat,
                                             self.hOutProfile, outputformat,
                                             intent, flags)
        if self.hTransform == NULL:
            raise LCMSException("Failed to create transformation")
        with nogil:
            # with LCMS2 we can close the profiles after the 
            # transformation has been created
            cmsCloseProfile(self.hInProfile)
            self.hInProfile = NULL
            cmsCloseProfile(self.hOutProfile)
            self.hOutProfile = NULL

    def __hash__(self):
        if self.hash:
            return self.hash
        self.hash = hash((self.inprofile, self.outprofile, 
                          self.format, self.intent, self.flags))
        return self.hash
            
    def __dealloc__(self):
        if self.hTransform != NULL:
            with nogil:
                cmsDeleteTransform(self.hTransform)
        if self.hInProfile != NULL:
            with nogil:
                cmsCloseProfile(self.hInProfile)
        if self.hOutProfile != NULL:
            with nogil:
                cmsCloseProfile(self.hOutProfile)
        self.hInProfile = NULL
        self.hOutProfile = NULL
        self.hTransform = NULL


cdef class LCMSIccCache(object):
    cdef object _cache
    cdef readonly int creations
    
    def __init__(self):
        self._cache = {}
        self.creations = 0
        
    cdef addEntry(self, 
                  bytes inprofile, 
                  bytes outprofile, 
                  int format, 
                  int intent,
                  unsigned long flags):
        trafo = LCMSTransformation(inprofile, outprofile, format, intent, flags)
        self._cache[(inprofile, outprofile, format, intent, flags)] = trafo
        self.creations += 1
        return trafo
    
    def clear(self):
        self._cache.clear()
        
    def keys(self):
        return self._cache.keys()
        
    def lookupByImage(self, 
                      Image img,
                      bytes outprofile, 
                      int format, 
                      int intent,
                      unsigned long flags):
        cdef bytes inprofile
        
        inprofile = img.getICC()
        if not inprofile:
            return None
        trafo = self._cache.get((inprofile, outprofile, format, intent, flags))
        if trafo is None:
            trafo = self.addEntry(inprofile, outprofile, format, intent, flags)
        return trafo
    
    def lookup(self,
               bytes inprofile, 
               bytes outprofile, 
               int format, 
               int intent,
               unsigned long flags):
        trafo = self._cache.get((inprofile, outprofile, format, intent, flags))
        if trafo is None:
            trafo = self.addEntry(inprofile, outprofile, format, intent, flags)
        return trafo
    
    def applyTransform(self,
              Image img,
              bytes inprofile=None,
              bytes outprofile=b"sRGB", 
              int intent=INTENT_PERCEPTUAL,
              unsigned long flags=0):
        
        cdef FIBITMAP *dib
        cdef BYTE *bits
        cdef unsigned width, height, pitch, bpp
        cdef unsigned x, y
        cdef FREE_IMAGE_TYPE image_type
        cdef cmsHTRANSFORM hTransform
            
        dib = img._dib
        if not dib:
            raise ValueError("Image has no data")
        if inprofile is None:
            if not img.has_icc:
                raise ValueError("Image has no embedded ICC profile")
            inprofile = img.getICC()
        
        image_type = FreeImage_GetImageType(dib)
        bpp = FreeImage_GetBPP(dib)
        width = FreeImage_GetWidth(dib)
        height = FreeImage_GetHeight(dib)
        pitch = FreeImage_GetPitch(dib)
        isBGR = FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
        
        format = None
        
        if image_type == FIT_BITMAP:
            if bpp == 24:
                format = TYPE_BGR_8 if isBGR else TYPE_RGB_8
            elif bpp == 32:
                format = TYPE_ABGR_8 if isBGR else TYPE_RGBA_8
            elif bpp == 8:
                 format = TYPE_GRAY_8
        if image_type == FIT_RGB16 and bpp == 48:
            format = TYPE_BGR_16 if isBGR else TYPE_RGB_16  
                
        if format is None:
            raise ValueError("Only 8, 16, 24 and 48bpp images are supported for now, image_type = %s, bbp: %s"
                              % (image_type, bpp))
           
        trafo = self.lookup(inprofile, outprofile, format, intent, flags)
        if trafo is None or not isinstance(trafo, LCMSTransformation):
            raise ValueError("Failed to lookup or create transformation")
        
        hTransform = (<LCMSTransformation>trafo).hTransform
        if not hTransform:
            raise ValueError("Transformation has no transformation handle")
            
        with nogil:
            bits = FreeImage_GetBits(dib)
            for y from 0 <= y < height:
                cmsDoTransform(hTransform, <char*>bits, <char*>bits, width)
                bits += pitch 

cdef int lcmsFI(Image img, LCMSTransformation trafo) except *:
    """Apply transformation from a LCMS Transformation object upon a FreeImage object
    """
    cdef FIBITMAP *dib
    cdef BYTE *bits
    cdef unsigned width, height, pitch, bpp
    cdef unsigned x, y
    cdef FREE_IMAGE_TYPE image_type
    cdef cmsHTRANSFORM hTransform
        
    dib = img._dib
    if not dib:
        raise ValueError("Image has no data")
    
    hTransform = trafo.hTransform
    if not hTransform:
        raise ValueError("Transformation has no transformation handle")

    image_type = FreeImage_GetImageType(dib)
    bpp = FreeImage_GetBPP(dib)
    width = FreeImage_GetWidth(dib)
    height = FreeImage_GetHeight(dib)
    pitch = FreeImage_GetPitch(dib)

    if image_type != FIT_BITMAP or bpp != 24 or FREEIMAGE_COLORORDER != FREEIMAGE_COLORORDER_BGR:
            raise ValueError("Only 24bit bitmaps are supported for now, image_type = %s, bbp: %s"
                              % (image_type, bpp))
        
    with nogil:
        bits = FreeImage_GetBits(dib)
        for y from 0 <= y < height:
            cmsDoTransform(hTransform, <char*>bits, <char*>bits, width)
            bits += pitch 

cdef object int2str(unsigned int i):
    cdef char out[5]
    if not i:
        return None
    out[0] = <char>(i >> 24)
    out[1] = <char>(i >> 16)
    out[2] = <char>(i >> 8)
    out[3] = <char>i
    out[4] = 0
    return out
    
cdef xyz_py(cmsCIEXYZ *XYZ):
    cdef cmsCIExyY xyY[1]
    cmsXYZ2xyY(xyY, XYZ)
    return (XYZ.X, XYZ.Y, XYZ.Z), (xyY.x, xyY.y, xyY.Y)
    
cdef xyztrip_py(cmsCIEXYZTRIPLE *trip):
    red = xyz_py(&trip.Red)
    green = xyz_py(&trip.Green)
    blue = xyz_py(&trip.Blue)
    return {'red': red, 'green': green, 'blue': blue}

cdef xyz3_py(cmsCIEXYZ *XYZ3):
    t1 = xyz_py(&XYZ3[0])
    t2 = xyz_py(&XYZ3[1])
    t3 = xyz_py(&XYZ3[2])
    return (t1[0], t2[0], t3[0]), (t1[1], t2[1], t3[1])

_illu_map = {0: "unknown", 1: "D50", 2: "D65", 3: "D93", 4: "F2", 5: "D55", 6: "A", 7: "E", 8: "F8"}

cdef class LCMSProfileInfo(object):
    cdef cmsHPROFILE hProfile
    cdef public dict info
    
    def __init__(self, bytes data=None, bytes filename=None):
        self.hProfile = NULL
        cdef cmsContext context
        cdef int size
        
        if data is not None:
            self.hProfile = createHProfile(data, len(data), "in")
        elif filename is not None:
            with open(filename, "rb") as f:
                data = f.read()
            self.hProfile = createHProfile(data, len(data), "in")
        
        if self.hProfile == NULL:
            raise LCMSException("Failed to set in profile")
        self.info = {}
        self._parse()
        cmsCloseProfile(self.hProfile)
        self.hProfile = NULL
        
    def __dealloc__(self):
        if self.hProfile != NULL:
            cmsCloseProfile(self.hProfile)
        
    cdef _readMLU(self, cmsTagSignature info, char* language="en", char* country=cmsNoCountry):
        cdef int read
        cdef const_cmsMLU *mlu
        cdef wchar_t *buf
        
        if not cmsIsTag(self.hProfile, info):
            return None
        mlu = <const_cmsMLU *>cmsReadTag(self.hProfile, info)
        if mlu is NULL:
            return None
        
        read = cmsMLUgetWide(mlu, language, country, NULL, 0);
        if read == 0:
            return None
        buf = <wchar_t*>malloc(read)
        cmsMLUgetWide(mlu, language, country, buf, read);
        # buf contains additional \0 junk
        uni = fipython.PyUnicode_FromWideChar(buf, wcslen(buf))
        free(buf)
        return uni
        
    cdef _readCIEXYZ(self, cmsTagSignature info, multi=False):
        cdef cmsCIEXYZ *XYZ
        if not cmsIsTag(self.hProfile, info):
            return None
        XYZ = <cmsCIEXYZ*>cmsReadTag(self.hProfile, info)
        if XYZ is NULL:
            return None
        if not multi:
            return xyz_py(XYZ)
        else:
            return xyz3_py(XYZ)
                    
    cdef _calculateRGBPrimaries(self):
        cdef cmsCIEXYZTRIPLE result
        cdef double input[3][3]
        cdef cmsHPROFILE hXYZ
        cdef cmsHTRANSFORM hTransform
        # http://littlecms2.blogspot.com/2009/07/less-is-more.html
        
        # double array of RGB values with max on each identitiy
        input[0][0], input[0][1], input[0][2] = 1., 0., 0. 
        input[1][0], input[1][1], input[1][2] = 0., 1., 0.
        input[2][0], input[2][1], input[2][2] = 0., 0., 1.
        
        hXYZ = cmsCreateXYZProfileTHR(<cmsContext>cpython.PyThread_get_thread_ident())
        if hXYZ == NULL:
            return None
        
        # transform from our profile to XYZ using doubles for highest precision
        hTransform = cmsCreateTransformTHR(<cmsContext>cpython.PyThread_get_thread_ident(),
                                           self.hProfile, TYPE_RGB_DBL, 
                                           hXYZ, TYPE_XYZ_DBL, 
                                           INTENT_ABSOLUTE_COLORIMETRIC, 
                                           cmsFLAGS_NOCACHE | cmsFLAGS_NOOPTIMIZE)
        cmsCloseProfile(hXYZ)
        if hTransform == NULL:
            return None
        cmsDoTransform(hTransform, <const_void_ptr>input, &result, 3)
        cmsDeleteTransform(hTransform)
        
        return xyztrip_py(&result)
        
    cdef _readCIEXYZWhitePointTemp(self):
        cdef cmsCIEXYZ *XYZ
        cdef cmsCIExyY xyY
        cdef cmsFloat64Number tempK
        cdef cmsTagSignature info = cmsSigMediaWhitePointTag 
        if not cmsIsTag(self.hProfile, info):
            return None
        XYZ = <cmsCIEXYZ*>cmsReadTag(self.hProfile, info)
        if XYZ is NULL or XYZ.X == 0:
            return None
        cmsXYZ2xyY(&xyY, XYZ)
        if not cmsTempFromWhitePoint(&tempK, &xyY):
            return None
        return tempK
        
    cdef _readCIExyYTriple(self, cmsTagSignature info):
        cdef cmsCIExyYTRIPLE *trip
        if not cmsIsTag(self.hProfile, info):
            return None
        trip = <cmsCIExyYTRIPLE *>cmsReadTag(self.hProfile, info)
        if trip is NULL:
            return None
        return ((trip.Red.x, trip.Red.y, trip.Red.Y),
                (trip.Green.x, trip.Green.y, trip.Green.Y),
                (trip.Blue.x, trip.Blue.y, trip.Blue.Y))   
        
    cdef _readSignature(self, cmsTagSignature info):
        cdef unsigned int *sig
        if not cmsIsTag(self.hProfile, info):
            return None
        sig = <unsigned int*>cmsReadTag(self.hProfile, info)
        if sig is NULL:
            return None
        return int2str(sig[0])
        
    cdef _readICCMeasurementCond(self):
        cdef cmsICCMeasurementConditions *mc
        cdef cmsTagSignature info = cmsSigMeasurementTag
        if not cmsIsTag(self.hProfile, info):
            return None
        mc = <cmsICCMeasurementConditions*>cmsReadTag(self.hProfile, info)
        if mc is NULL:
            return None

        if mc.Geometry == 1:
            geo = "45/0, 0/45"
        elif mc.Geometry == 2:
            geo = "0d, d/0"
        else:
            geo = "unknown"
        
        return dict(observer=mc.Observer, backing=(mc.Backing.X, mc.Backing.Y, mc.Backing.Z),
                    geometry=geo, flare=mc.Flare, illuminantType=_illu_map.get(mc.IlluminantType, None))
                    
    cdef _readICCViewingCond(self):
        cdef cmsICCViewingConditions *vc
        cdef cmsTagSignature info = cmsSigViewingConditionsTag
        if not cmsIsTag(self.hProfile, info):
            return None
        vc = <cmsICCViewingConditions*>cmsReadTag(self.hProfile, info)
        if vc is NULL:
            return None
        return dict(illuminant=(vc.IlluminantXYZ.X, vc.IlluminantXYZ.Y, vc.IlluminantXYZ.Z),
                    surround=(vc.SurroundXYZ.X, vc.SurroundXYZ.Y, vc.SurroundXYZ.Z),
                    illuminantType=_illu_map.get(vc.IlluminantType, None))
    
    def _readNamedColorList(self, cmsTagSignature info):
        cdef cmsNAMEDCOLORLIST *ncl
        cdef int i, n
        cdef char name[cmsMAX_PATH]
        
        if not cmsIsTag(self.hProfile, info):
            return None
        ncl = <cmsNAMEDCOLORLIST *>cmsReadTag(self.hProfile, info)
        if ncl is NULL:
            return None

        n = cmsNamedColorCount(ncl)
        result = []
        for i from 0 <= i < n:
            cmsNamedColorInfo(ncl, i, name, NULL, NULL, NULL, NULL)
            result.append(name)
        return result
        
    cdef _parse(self):
        cdef tm ct
        cdef cmsUInt64Number attr = 0
        cdef cmsUInt8Number hid[16]
        
        self.info["creationDate"] = None
        if cmsGetHeaderCreationDateTime(self.hProfile, &ct):
            if ct.tm_year and ct.tm_mon and ct.tm_mday:
                try:
                    self.info["creationDate"] = datetime(1900+ct.tm_year, ct.tm_mon, ct.tm_mday, ct.tm_hour, ct.tm_min, ct.tm_sec)
                except ValueError:
                    pass
            
        self.info["headerFlags"] = int(cmsGetHeaderFlags(self.hProfile))
        self.info["headerManufacturer"] = int2str(cmsGetHeaderManufacturer(self.hProfile))
        self.info["headerModel"] = int2str(cmsGetHeaderModel(self.hProfile))
        cmsGetHeaderAttributes(self.hProfile, &attr)
        self.info["attributes"] = int(attr)
        self.info["deviceClass"] = int2str(cmsGetDeviceClass(self.hProfile))
        self.info["version"] = cmsGetProfileVersion(self.hProfile)
        self.info["iccVersion"] = hex(cmsGetEncodedICCversion(self.hProfile))
        cmsGetHeaderProfileID(self.hProfile, hid)
        self.info["profileid"] = cpython.PyString_FromStringAndSize(<char*>hid, 16)
        
        self.info["renderingIntent"] = int(cmsGetHeaderRenderingIntent(self.hProfile))
        self.info["connectionSpace"] = int2str(cmsGetPCS(self.hProfile))
        self.info["colorSpace"] = int2str(cmsGetColorSpace(self.hProfile))
        
        self.info["target"] = self._readMLU(cmsSigCharTargetTag)
        self.info["copyright"] = self._readMLU(cmsSigCopyrightTag)
        self.info["manufacturer"] = self._readMLU(cmsSigDeviceMfgDescTag)
        self.info["model"] = self._readMLU(cmsSigDeviceModelDescTag)
        self.info["profileDescription"] = self._readMLU(cmsSigProfileDescriptionTag)
        self.info["screeningDescription"] = self._readMLU(cmsSigScreeningDescTag)
        self.info["viewingCondition"] = self._readMLU(cmsSigViewingCondDescTag)
        self.info["technology"] = self._readSignature(cmsSigTechnologyTag)
        self.info["colorimetricIntent"] = self._readSignature(cmsSigColorimetricIntentImageStateTag)
        self.info["perceptualRenderingIntentGamut"] = self._readSignature(cmsSigPerceptualRenderingIntentGamutTag)
        self.info["saturationRenderingIntentGamut"] = self._readSignature(cmsSigSaturationRenderingIntentGamutTag)
        self.info["colorantTable"] = self._readNamedColorList(cmsSigColorantTableTag)
        self.info["colorantTableOut"] = self._readNamedColorList(cmsSigColorantTableOutTag)
        
        self.info["isMatrixShaper"] = bool(cmsIsMatrixShaper(self.hProfile))
        
        # media points (don't trust the black point!)
        self.info["mediaWhitePoint"] = self._readCIEXYZ(cmsSigMediaWhitePointTag)
        self.info["mediaWhitePointTemperature"] = self._readCIEXYZWhitePointTemp()
        self.info["mediaBlackPoint"] = self._readCIEXYZ(cmsSigMediaBlackPointTag)
        # colorants
        self.info["redColorant"] = None
        self.info["greenColorant"] = None
        self.info["blueColorant"] = None
        # primaries
        self.info["redPrimary"] = None
        self.info["greenPrimary"] = None
        self.info["bluePrimary"] = None
        
        if self.info["isMatrixShaper"]:
            # colorants
            self.info["redColorant"] = self._readCIEXYZ(cmsSigRedColorantTag)
            self.info["greenColorant"] = self._readCIEXYZ(cmsSigGreenColorantTag)
            self.info["blueColorant"] = self._readCIEXYZ(cmsSigBlueColorantTag)
            # primaries
            primaries = self._calculateRGBPrimaries()
            if primaries:
                self.info["redPrimary"] = primaries["red"]
                self.info["greenPrimary"] = primaries["green"]
                self.info["bluePrimary"] = primaries["blue"]
        
        # chroma / luma
        self.info["luminance"] = self._readCIEXYZ(cmsSigLuminanceTag)
        self.info["chromaticAdaptation"] = self._readCIEXYZ(cmsSigChromaticAdaptationTag, True)
        self.info["chromaticity"] = self._readCIExyYTriple(cmsSigChromaticityTag)
        
        self.info["iccMeasurementCondition"] = self._readICCMeasurementCond()
        self.info["iccViewingCondition"] = self._readICCViewingCond()
        
        self.info["isIntentSupported"] = {}
        self.info["isCLUT"] = {}
        for intent in getIntents().keys():
            self.info["isIntentSupported"][intent] = (
                bool(cmsIsIntentSupported(self.hProfile, intent, LCMS_USED_AS_INPUT)),
                bool(cmsIsIntentSupported(self.hProfile, intent, LCMS_USED_AS_OUTPUT)),
                bool(cmsIsIntentSupported(self.hProfile, intent, LCMS_USED_AS_PROOF))
                )
            self.info["isCLUT"][intent] = (
                bool(cmsIsCLUT(self.hProfile, intent, LCMS_USED_AS_INPUT)),
                bool(cmsIsCLUT(self.hProfile, intent, LCMS_USED_AS_OUTPUT)),
                bool(cmsIsCLUT(self.hProfile, intent, LCMS_USED_AS_PROOF))
                )