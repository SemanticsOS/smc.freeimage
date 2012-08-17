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
# Purpose     : Cython wrapper for LCMS2 library
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
DEF BUFFER_SIZE = 8192
cimport lcms
cimport freeimage as fi
from libc cimport stddef
from libc cimport stdlib
from libc cimport string


loggername = "smc.freeimage.lcms"
cdef object _logger = getLogger(loggername)

cdef void errorHandler(lcms.cmsContext ContextID,
                       lcms.cmsUInt32Number ErrorCode,
                       smc_fi.const_char_ptr * text) with gil:
    _logger.info(< char *> text)

lcms.cmsSetLogErrorHandler(< lcms.cmsLogErrorHandlerFunction > errorHandler)

def getLCMSVersion():
    return lcms.LCMS_VERSION

def XYZ2xyY(float X, float Y, float Z):
    cdef lcms.cmsCIEXYZ XYZ
    cdef lcms.cmsCIExyY xyY
    XYZ.X = Y
    XYZ.Y = X
    XYZ.Z = Z
    lcms.cmsXYZ2xyY(& xyY, & XYZ)
    return xyY.x, xyY.y, xyY.Y

def xyY2XYZ(float x, float y, float Y):
    cdef lcms.cmsCIEXYZ XYZ
    cdef lcms.cmsCIExyY xyY
    xyY.x = x
    xyY.y = y
    xyY.Y = Y
    lcms.cmsxyY2XYZ(& XYZ, & xyY)
    return XYZ.X, XYZ.Y, XYZ.Z

def tempFromWhitePoint(float x, float y, float Y):
    cdef lcms.cmsFloat64Number tempK
    cdef lcms.cmsCIExyY xyY
    xyY.x = x
    xyY.y = y
    xyY.Y = Y
    if not lcms.cmsTempFromWhitePoint(& tempK, & xyY):
        return None
    return tempK

def getIntents():
    cdef int n, i, intents = 200
    cdef int intent_ids[200]
    cdef char * intent_descs[200]
    result = {}

    n = lcms.cmsGetSupportedIntents(intents,
                                    < lcms.cmsUInt32Number *> intent_ids,
                                    intent_descs)
    for i from 0 <= i < n:
        result[intent_ids[i]] = intent_descs[i]
    return result

class LCMSException(Exception):
    pass

cdef lcms.cmsHPROFILE createHProfile(char * iccprofile, unsigned int size, mode="in") except * :
    cdef lcms.cmsHPROFILE hProfile = NULL
    cdef lcms.cmsToneCurve * curve
    cdef lcms.cmsContext context

    context = < lcms.cmsContext > cpython.PyThread_get_thread_ident()

    if size == 4 and string.strcmp(iccprofile, b"sRGB") == 0:
        with nogil:
            hProfile = lcms.cmsCreate_sRGBProfileTHR(context)
        if hProfile == NULL:
            raise LCMSException("Failed to create sRGB %s profile" % mode)
            #return NULL
    elif size == 4 and string.strcmp(iccprofile, b"gray") == 0:
        with nogil:
            curve = lcms.cmsBuildGamma(context, 1.0)
            hProfile = lcms.cmsCreateGrayProfileTHR(context, lcms.cmsD50_xyY(), curve)
        if hProfile == NULL:
            raise LCMSException("Failed to create gray %s profile" % mode)
            #return NULL
    else:
        with nogil:
            hProfile = lcms.cmsOpenProfileFromMemTHR(context, iccprofile, size)
        if hProfile == NULL:
            raise LCMSException("Failed to set %s profile" % mode)
            #return NULL

    return hProfile


cdef class LCMSTransformation(object):
    cdef lcms.cmsHPROFILE hInProfile
    cdef lcms.cmsHPROFILE hOutProfile
    cdef lcms.cmsHTRANSFORM hTransform
    cdef readonly bytes inprofile
    cdef readonly bytes outprofile
    cdef readonly unsigned int format
    cdef readonly unsigned int intent
    cdef readonly unsigned long flags
    cdef hash

    def __init__(self,
                 bytes inprofile,
                 bytes outprofile=b"sRGB",
                 unsigned int format=lcms.TYPE_BGR_8,
                 unsigned int intent=lcms.INTENT_PERCEPTUAL,
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


    cdef setInProfile(self, char * iccprofile, unsigned int size):
        self.hInProfile = createHProfile(iccprofile, size, "in")

    cdef setOutProfile(self, char * iccprofile, unsigned int size=0):
        self.hOutProfile = createHProfile(iccprofile, size, "out")

    cdef lcms.cmsHPROFILE _createProfile(self, char * iccprofile, unsigned int size, mode="in") except * :
        cdef lcms.cmsHPROFILE hProfile = NULL
        cdef lcms.cmsToneCurve * curve
        cdef lcms.cmsContext context

        context = < lcms.cmsContext > cpython.PyThread_get_thread_ident()

        if size == 4 and string.strcmp(iccprofile, b"sRGB") == 0:
            with nogil:
                hProfile = lcms.cmsCreate_sRGBProfileTHR(context)
            if hProfile == NULL:
                raise LCMSException("Failed to create sRGB %s profile" % mode)
                #return NULL
        elif size == 4 and string.strcmp(iccprofile, b"gray") == 0:
            with nogil:
                curve = lcms.cmsBuildGamma(context, 1.0)
                hProfile = lcms.cmsCreateGrayProfileTHR(context, lcms.cmsD50_xyY(), curve)
            if hProfile == NULL:
                raise LCMSException("Failed to create gray %s profile" % mode)
                #return NULL
        else:
            with nogil:
                hProfile = lcms.cmsOpenProfileFromMemTHR(context, iccprofile, size)
            if hProfile == NULL:
                raise LCMSException("Failed to set %s profile" % mode)
                #return NULL

        return hProfile

    cdef setTransform(self, unsigned int inputformat, unsigned int outputformat,
                      unsigned int intent=lcms.INTENT_PERCEPTUAL,
                      unsigned long flags=0):
        if self.hInProfile == NULL:
            raise LCMSException("No in profile")
        if self.hOutProfile == NULL:
            raise LCMSException("No out profile")
            #return -1
        self.hTransform = lcms.cmsCreateTransformTHR(< lcms.cmsContext > cpython.PyThread_get_thread_ident(),
                                             self.hInProfile, inputformat,
                                             self.hOutProfile, outputformat,
                                             intent, flags)
        if self.hTransform == NULL:
            raise LCMSException("Failed to create transformation")
        with nogil:
            # with LCMS2 we can close the profiles after the
            # transformation has been created
            lcms.cmsCloseProfile(self.hInProfile)
            self.hInProfile = NULL
            lcms.cmsCloseProfile(self.hOutProfile)
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
                lcms.cmsDeleteTransform(self.hTransform)
        if self.hInProfile != NULL:
            with nogil:
                lcms.cmsCloseProfile(self.hInProfile)
        if self.hOutProfile != NULL:
            with nogil:
                lcms.cmsCloseProfile(self.hOutProfile)
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
                  unsigned int format,
                  unsigned int intent,
                  unsigned long flags):
        trafo = LCMSTransformation(inprofile, outprofile, format, intent, flags)
        self._cache[(inprofile, outprofile, format, intent, flags)] = trafo
        self.creations += 1
        return trafo

    def clear(self):
        self._cache.clear()

    def keys(self):
        return list(self._cache)

    def __iter__(self):
        return iter(self._cache)

    def __contains__(self, key):
        return key in self._cache

    def lookupByImage(self,
                      Image img,
                      bytes outprofile,
                      unsigned int format,
                      unsigned int intent,
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
               unsigned int format,
               unsigned int intent,
               unsigned long flags):
        trafo = self._cache.get((inprofile, outprofile, format, intent, flags))
        if trafo is None:
            trafo = self.addEntry(inprofile, outprofile, format, intent, flags)
        return trafo

    def applyTransform(self,
              Image img,
              bytes inprofile=None,
              bytes outprofile=b"sRGB",
              unsigned int intent=lcms.INTENT_PERCEPTUAL,
              unsigned long flags=0):

        cdef fi.FIBITMAP * dib
        cdef fi.BYTE * bits
        cdef unsigned width, height, pitch, bpp
        cdef unsigned x, y
        cdef fi.FREE_IMAGE_TYPE image_type
        cdef lcms.cmsHTRANSFORM hTransform

        dib = img._dib
        if not dib:
            raise ValueError("Image has no data")
        if inprofile is None:
            if not img.has_icc:
                raise ValueError("Image has no embedded ICC profile")
            inprofile = img.getICC()

        image_type = fi.FreeImage_GetImageType(dib)
        bpp = fi.FreeImage_GetBPP(dib)
        width = fi.FreeImage_GetWidth(dib)
        height = fi.FreeImage_GetHeight(dib)
        pitch = fi.FreeImage_GetPitch(dib)
        isBGR = fi.FREEIMAGE_COLORORDER == fi.FREEIMAGE_COLORORDER_BGR

        format = None

        if image_type == fi.FIT_BITMAP:
            if bpp == 24:
                format = lcms.TYPE_BGR_8 if isBGR else lcms.TYPE_RGB_8
            elif bpp == 32:
                format = lcms.TYPE_ABGR_8 if isBGR else lcms.TYPE_RGBA_8
            elif bpp == 8:
                 format = lcms.TYPE_GRAY_8
        if image_type == fi.FIT_RGB16 and bpp == 48:
            format = lcms.TYPE_BGR_16 if isBGR else lcms.TYPE_RGB_16

        if format is None:
            raise ValueError("Only 8, 16, 24 and 48bpp images are supported for now, image_type = %s, bbp: %s"
                              % (image_type, bpp))

        trafo = self.lookup(inprofile, outprofile, format, intent, flags)
        if trafo is None or not isinstance(trafo, LCMSTransformation):
            raise ValueError("Failed to lookup or create transformation")

        hTransform = (< LCMSTransformation > trafo).hTransform
        if not hTransform:
            raise ValueError("Transformation has no transformation handle")

        with nogil:
            bits = fi.FreeImage_GetBits(dib)
            for y from 0 <= y < height:
                lcms.cmsDoTransform(hTransform, < char *> bits, < char *> bits, width)
                bits += pitch

cdef int lcmsFI(Image img, LCMSTransformation trafo) except * :
    """Apply transformation from a LCMS Transformation object upon a FreeImage object
    """
    cdef fi.FIBITMAP * dib
    cdef fi.BYTE * bits
    cdef unsigned width, height, pitch, bpp
    cdef unsigned x, y
    cdef fi.FREE_IMAGE_TYPE image_type
    cdef lcms.cmsHTRANSFORM hTransform

    dib = img._dib
    if not dib:
        raise ValueError("Image has no data")

    hTransform = trafo.hTransform
    if not hTransform:
        raise ValueError("Transformation has no transformation handle")

    image_type = fi.FreeImage_GetImageType(dib)
    bpp = fi.FreeImage_GetBPP(dib)
    width = fi.FreeImage_GetWidth(dib)
    height = fi.FreeImage_GetHeight(dib)
    pitch = fi.FreeImage_GetPitch(dib)

    if image_type != fi.FIT_BITMAP or bpp != 24 or fi.FREEIMAGE_COLORORDER != fi.FREEIMAGE_COLORORDER_BGR:
            raise ValueError("Only 24bit bitmaps are supported for now, image_type = %s, bbp: %s"
                              % (image_type, bpp))

    with nogil:
        bits = fi.FreeImage_GetBits(dib)
        for y from 0 <= y < height:
            lcms.cmsDoTransform(hTransform, < char *> bits, < char *> bits, width)
            bits += pitch

cdef object int2ascii(unsigned int i):
    cdef char out[5]
    if not i:
        return None
    out[0] = < char > (i >> 24)
    out[1] = < char > (i >> 16)
    out[2] = < char > (i >> 8)
    out[3] = < char > i
    out[4] = 0
    if smc_fi.IS_PYTHON3:
        return out.decode("ascii")
    else:
        return out

cdef xyz_py(lcms.cmsCIEXYZ * XYZ):
    cdef lcms.cmsCIExyY xyY[1]
    lcms.cmsXYZ2xyY(xyY, XYZ)
    return (XYZ.X, XYZ.Y, XYZ.Z), (xyY.x, xyY.y, xyY.Y)

cdef xyztrip_py(lcms.cmsCIEXYZTRIPLE * trip):
    red = xyz_py(& trip.Red)
    green = xyz_py(& trip.Green)
    blue = xyz_py(& trip.Blue)
    return {'red': red, 'green': green, 'blue': blue}

cdef xyz3_py(lcms.cmsCIEXYZ * XYZ3):
    t1 = xyz_py(& XYZ3[0])
    t2 = xyz_py(& XYZ3[1])
    t3 = xyz_py(& XYZ3[2])
    return (t1[0], t2[0], t3[0]), (t1[1], t2[1], t3[1])

_illu_map = {0: "unknown", 1: "D50", 2: "D65", 3: "D93", 4: "F2", 5: "D55", 6: "A", 7: "E", 8: "F8"}

cdef class LCMSProfileInfo(object):
    cdef lcms.cmsHPROFILE hProfile
    cdef public dict info

    def __init__(self, bytes data=None, filename=None):
        self.hProfile = NULL
        cdef lcms.cmsContext context
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
        lcms.cmsCloseProfile(self.hProfile)
        self.hProfile = NULL

    def __dealloc__(self):
        if self.hProfile != NULL:
            lcms.cmsCloseProfile(self.hProfile)

    cdef _readMLU(self, lcms.cmsTagSignature info, char * language="en", char * country=lcms.cmsNoCountry):
        cdef int read
        cdef lcms.const_cmsMLU * mlu
        cdef stddef.wchar_t * buf

        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        mlu = < lcms.const_cmsMLU *> lcms.cmsReadTag(self.hProfile, info)
        if mlu is NULL:
            return None

        read = lcms.cmsMLUgetWide(mlu, language, country, NULL, 0);
        if read == 0:
            return None
        buf = < stddef.wchar_t *> stdlib.malloc(read)
        lcms.cmsMLUgetWide(mlu, language, country, buf, read);
        # buf contains additional \0 junk
        uni = smc_fi.PyUnicode_FromWideChar(buf, smc_fi.wcslen(buf))
        stdlib.free(buf)
        return uni

    cdef _readCIEXYZ(self, lcms.cmsTagSignature info, multi=False):
        cdef lcms.cmsCIEXYZ * XYZ
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        XYZ = < lcms.cmsCIEXYZ *> lcms.cmsReadTag(self.hProfile, info)
        if XYZ is NULL:
            return None
        if not multi:
            return xyz_py(XYZ)
        else:
            return xyz3_py(XYZ)

    cdef _calculateRGBPrimaries(self):
        cdef lcms.cmsCIEXYZTRIPLE result
        cdef double input[3][3]
        cdef lcms.cmsHPROFILE hXYZ
        cdef lcms.cmsHTRANSFORM hTransform
        # http://littlecms2.blogspot.com/2009/07/less-is-more.html

        # double array of RGB values with max on each identitiy
        input[0][0], input[0][1], input[0][2] = 1., 0., 0.
        input[1][0], input[1][1], input[1][2] = 0., 1., 0.
        input[2][0], input[2][1], input[2][2] = 0., 0., 1.

        hXYZ = lcms.cmsCreateXYZProfileTHR(< lcms.cmsContext > cpython.PyThread_get_thread_ident())
        if hXYZ == NULL:
            return None

        # transform from our profile to XYZ using doubles for highest precision
        hTransform = lcms.cmsCreateTransformTHR(< lcms.cmsContext > cpython.PyThread_get_thread_ident(),
                                           self.hProfile, lcms.TYPE_RGB_DBL,
                                           hXYZ, lcms.TYPE_XYZ_DBL,
                                           lcms.INTENT_ABSOLUTE_COLORIMETRIC,
                                           lcms.cmsFLAGS_NOCACHE | lcms.cmsFLAGS_NOOPTIMIZE)
        lcms.cmsCloseProfile(hXYZ)
        if hTransform == NULL:
            return None
        lcms.cmsDoTransform(hTransform, < smc_fi.const_void_ptr > input, & result, 3)
        lcms.cmsDeleteTransform(hTransform)

        return xyztrip_py(& result)

    cdef _readCIEXYZWhitePointTemp(self):
        cdef lcms.cmsCIEXYZ * XYZ
        cdef lcms.cmsCIExyY xyY
        cdef lcms.cmsFloat64Number tempK
        cdef lcms.cmsTagSignature info = lcms.cmsSigMediaWhitePointTag
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        XYZ = < lcms.cmsCIEXYZ *> lcms.cmsReadTag(self.hProfile, info)
        if XYZ is NULL or XYZ.X == 0:
            return None
        lcms.cmsXYZ2xyY(& xyY, XYZ)
        if not lcms.cmsTempFromWhitePoint(& tempK, & xyY):
            return None
        return tempK

    cdef _readCIExyYTriple(self, lcms.cmsTagSignature info):
        cdef lcms.cmsCIExyYTRIPLE * trip
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        trip = < lcms.cmsCIExyYTRIPLE *> lcms.cmsReadTag(self.hProfile, info)
        if trip is NULL:
            return None
        return ((trip.Red.x, trip.Red.y, trip.Red.Y),
                (trip.Green.x, trip.Green.y, trip.Green.Y),
                (trip.Blue.x, trip.Blue.y, trip.Blue.Y))

    cdef _readSignature(self, lcms.cmsTagSignature info):
        cdef unsigned int * sig
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        sig = < unsigned int *> lcms.cmsReadTag(self.hProfile, info)
        if sig is NULL:
            return None
        return int2ascii(sig[0])

    cdef _readICCMeasurementCond(self):
        cdef lcms.cmsICCMeasurementConditions * mc
        cdef lcms.cmsTagSignature info = lcms.cmsSigMeasurementTag
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        mc = < lcms.cmsICCMeasurementConditions *> lcms.cmsReadTag(self.hProfile, info)
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
        cdef lcms.cmsICCViewingConditions * vc
        cdef lcms.cmsTagSignature info = lcms.cmsSigViewingConditionsTag
        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        vc = < lcms.cmsICCViewingConditions *> lcms.cmsReadTag(self.hProfile, info)
        if vc is NULL:
            return None
        return dict(illuminant=(vc.IlluminantXYZ.X, vc.IlluminantXYZ.Y, vc.IlluminantXYZ.Z),
                    surround=(vc.SurroundXYZ.X, vc.SurroundXYZ.Y, vc.SurroundXYZ.Z),
                    illuminantType=_illu_map.get(vc.IlluminantType, None))

    def _readNamedColorList(self, lcms.cmsTagSignature info):
        cdef lcms.cmsNAMEDCOLORLIST * ncl
        cdef int i, n
        cdef char name[lcms.cmsMAX_PATH]

        if not lcms.cmsIsTag(self.hProfile, info):
            return None
        ncl = < lcms.cmsNAMEDCOLORLIST *> lcms.cmsReadTag(self.hProfile, info)
        if ncl is NULL:
            return None

        n = lcms.cmsNamedColorCount(ncl)
        result = []
        for i from 0 <= i < n:
            lcms.cmsNamedColorInfo(ncl, i, name, NULL, NULL, NULL, NULL)
            result.append(name)
        return result

    cdef _parse(self):
        cdef smc_fi.tm ct
        cdef lcms.cmsUInt64Number attr = 0
        cdef lcms.cmsUInt8Number hid[16]

        self.info["creationDate"] = None
        if lcms.cmsGetHeaderCreationDateTime(self.hProfile, & ct):
            if ct.tm_year and ct.tm_mon and ct.tm_mday:
                try:
                    self.info["creationDate"] = datetime(1900 + ct.tm_year, ct.tm_mon, ct.tm_mday, ct.tm_hour, ct.tm_min, ct.tm_sec)
                except ValueError:
                    pass

        self.info["headerFlags"] = int(lcms.cmsGetHeaderFlags(self.hProfile))
        self.info["headerManufacturer"] = int2ascii(lcms.cmsGetHeaderManufacturer(self.hProfile))
        self.info["headerModel"] = int2ascii(lcms.cmsGetHeaderModel(self.hProfile))
        lcms.cmsGetHeaderAttributes(self.hProfile, & attr)
        self.info["attributes"] = int(attr)
        self.info["deviceClass"] = int2ascii(lcms.cmsGetDeviceClass(self.hProfile))
        self.info["version"] = lcms.cmsGetProfileVersion(self.hProfile)
        self.info["iccVersion"] = int(lcms.cmsGetEncodedICCversion(self.hProfile))
        lcms.cmsGetHeaderProfileID(self.hProfile, hid)
        self.info["profileid"] = cpython.PyBytes_FromStringAndSize(< char *> hid, 16)

        self.info["renderingIntent"] = int(lcms.cmsGetHeaderRenderingIntent(self.hProfile))
        self.info["connectionSpace"] = int2ascii(lcms.cmsGetPCS(self.hProfile))
        self.info["colorSpace"] = int2ascii(lcms.cmsGetColorSpace(self.hProfile))

        self.info["target"] = self._readMLU(lcms.cmsSigCharTargetTag)
        self.info["copyright"] = self._readMLU(lcms.cmsSigCopyrightTag)
        self.info["manufacturer"] = self._readMLU(lcms.cmsSigDeviceMfgDescTag)
        self.info["model"] = self._readMLU(lcms.cmsSigDeviceModelDescTag)
        self.info["profileDescription"] = self._readMLU(lcms.cmsSigProfileDescriptionTag)
        self.info["screeningDescription"] = self._readMLU(lcms.cmsSigScreeningDescTag)
        self.info["viewingCondition"] = self._readMLU(lcms.cmsSigViewingCondDescTag)
        self.info["technology"] = self._readSignature(lcms.cmsSigTechnologyTag)
        self.info["colorimetricIntent"] = self._readSignature(lcms.cmsSigColorimetricIntentImageStateTag)
        self.info["perceptualRenderingIntentGamut"] = self._readSignature(lcms.cmsSigPerceptualRenderingIntentGamutTag)
        self.info["saturationRenderingIntentGamut"] = self._readSignature(lcms.cmsSigSaturationRenderingIntentGamutTag)
        self.info["colorantTable"] = self._readNamedColorList(lcms.cmsSigColorantTableTag)
        self.info["colorantTableOut"] = self._readNamedColorList(lcms.cmsSigColorantTableOutTag)

        self.info["isMatrixShaper"] = bool(lcms.cmsIsMatrixShaper(self.hProfile))

        # media points (don't trust the black point!)
        self.info["mediaWhitePoint"] = self._readCIEXYZ(lcms.cmsSigMediaWhitePointTag)
        self.info["mediaWhitePointTemperature"] = self._readCIEXYZWhitePointTemp()
        self.info["mediaBlackPoint"] = self._readCIEXYZ(lcms.cmsSigMediaBlackPointTag)
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
            self.info["redColorant"] = self._readCIEXYZ(lcms.cmsSigRedColorantTag)
            self.info["greenColorant"] = self._readCIEXYZ(lcms.cmsSigGreenColorantTag)
            self.info["blueColorant"] = self._readCIEXYZ(lcms.cmsSigBlueColorantTag)
            # primaries
            primaries = self._calculateRGBPrimaries()
            if primaries:
                self.info["redPrimary"] = primaries["red"]
                self.info["greenPrimary"] = primaries["green"]
                self.info["bluePrimary"] = primaries["blue"]

        # chroma / luma
        self.info["luminance"] = self._readCIEXYZ(lcms.cmsSigLuminanceTag)
        self.info["chromaticAdaptation"] = self._readCIEXYZ(lcms.cmsSigChromaticAdaptationTag, True)
        self.info["chromaticity"] = self._readCIExyYTriple(lcms.cmsSigChromaticityTag)

        self.info["iccMeasurementCondition"] = self._readICCMeasurementCond()
        self.info["iccViewingCondition"] = self._readICCViewingCond()

        self.info["isIntentSupported"] = {}
        self.info["isCLUT"] = {}
        for intent in getIntents().keys():
            self.info["isIntentSupported"][intent] = (
                bool(lcms.cmsIsIntentSupported(self.hProfile, intent, lcms.LCMS_USED_AS_INPUT)),
                bool(lcms.cmsIsIntentSupported(self.hProfile, intent, lcms.LCMS_USED_AS_OUTPUT)),
                bool(lcms.cmsIsIntentSupported(self.hProfile, intent, lcms.LCMS_USED_AS_PROOF))
                )
            self.info["isCLUT"][intent] = (
                bool(lcms.cmsIsCLUT(self.hProfile, intent, lcms.LCMS_USED_AS_INPUT)),
                bool(lcms.cmsIsCLUT(self.hProfile, intent, lcms.LCMS_USED_AS_OUTPUT)),
                bool(lcms.cmsIsCLUT(self.hProfile, intent, lcms.LCMS_USED_AS_PROOF))
                )
