## -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes, Dirk Rothe
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : ICC / LCMS unit tests
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

from __future__ import with_statement
import os
import tempfile
import datetime
#from time import time
#from pprint import pprint

from smc.freeimage import (LCMSTransformation, LCMSIccCache, LCMSProfileInfo,
                           getLCMSVersion)
from smc.freeimage import lcmsconstants as lcms
from smc.freeimage.tests.test_image import TestImageBase
from smc.freeimage.tests.common import owner, ICMS, unittest2, run_tests


class TestLCMS(TestImageBase):

    @owner("c.heimes")
    def test_lcms(self):
        self.tmpdir = tempfile.mkdtemp()
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_orig.jpg"))
        #start = time()
        self.tiff.iccTransform()
        #print time() - start
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_transform.jpg"))

    @owner("c.heimes")
    def test_lcmsVersion(self):
        self.assertEqual(getLCMSVersion(), 2030)

    @owner("c.heimes")
    def test_lcmsTrafo(self):
        self.tmpdir = tempfile.mkdtemp()
        icc = self.tiff.getICC()
        trafo = LCMSTransformation(icc)
        #start = time()
        self.tiff.iccTransform(trafo)
        #print time() - start
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_transform2.jpg"))

    @owner("c.heimes")
    def test_lcmsCreateTrafo(self):
        icc = self.tiff.getICC()
        #start = time()
        for _ in range(10):
            LCMSTransformation(icc)
        #print time() - start

    @owner("c.heimes")
    def test_lcmsIccCache(self):
        self.tmpdir = tempfile.mkdtemp()
        cache = LCMSIccCache()
        self.assertEqual(cache.creations, 0)
        self.assertEqual(list(cache), [])
        self.assertEqual(cache.keys(), [])
        icc = self.tiff.getICC()
        self.assertEqual(len(icc), 308804)
        cache.lookupByImage(self.tiff, b"sRGB", lcms.TYPE_BGR_8,
                            lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 1)
        self.assertEqual(list(cache), [(icc, b"sRGB", lcms.TYPE_BGR_8,
                                        lcms.INTENT_PERCEPTUAL, 0)])

        cache.lookupByImage(self.tiff, b"sRGB", lcms.TYPE_BGR_8,
                            lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 1)
        cache.lookup(icc, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 1)

        cache.clear()
        self.assertEqual(list(cache), [])
        cache.lookup(icc, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 2)
        entry = (icc, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(list(cache), [entry])
        self.assertEqual(cache.keys(), [entry])
        self.assertIn(entry, cache)

        cache.clear()
        #start = time()
        cache.applyTransform(self.tiff)
        cache.applyTransform(self.tiff, inprofile=self.tiff.getICC())
        self.assertEqual(cache.creations, 3)
        self.assertEqual(list(cache), [(icc, b"sRGB", lcms.TYPE_BGR_8,
                                        lcms.INTENT_PERCEPTUAL, 0)])
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_transform_cache.jpg"))
        self.assertEqual(cache.creations, 3)
        #print time() - start
        #
        #for i in range(5):
        #    start = time()
        #    cache.applyTransform(self.tiff)
        #    print time() - start
        cache.lookup(b"gray", b"gray", lcms.TYPE_GRAY_8, lcms.INTENT_PERCEPTUAL, 0)
        cache.lookup(b"sRGB", b"sRGB", lcms.TYPE_ABGR_8, lcms.INTENT_PERCEPTUAL, 0)
        cache.lookup(b"sRGB", b"sRGB", lcms.TYPE_BGR_16, lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 6)

        cache.clear()

    @owner("c.heimes")
    def test_lcmsProfileInfo(self):
        self.maxDiff = None
        icc = self.tiff.getICC()
        info = LCMSProfileInfo(data=icc)
        # xyY is (nan, nan, 0)
        self.assertEqual(info.info.pop("mediaBlackPoint")[0],
                         (0.0, 0.0, 0.0))
        self.assertEqual(info.info, {
            'attributes': 0,
            'blueColorant': ((0.0779876708984375, 0.0288238525390625, 0.787200927734375),
                             (0.08723331626557432,
                              0.03224099675712579,
                              0.0288238525390625)),
            'bluePrimary': ((0.027524196576962368,
                             0.025689563803155124,
                             0.21284289725940653),
                            (0.10345238800321421,
                             0.09655674107566031,
                             0.025689563803155124)),
            'chromaticAdaptation': (((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)),
                                    ((1.0, 0.0, 0.0), (0.0, 1.0, 1.0), (0.0, 0.0, 0.0))),
            'chromaticity': None,
            'colorSpace': 'RGB ',
            'colorantTable': None,
            'colorantTableOut': None,
            'colorimetricIntent': None,
            'connectionSpace': 'Lab ',
            'copyright': b'Copyright by LOGO GmbH, Steinfurt'.decode("utf-8"),
            'creationDate': datetime.datetime(2007, 5, 15, 14, 54, 48),
            'deviceClass': 'scnr',
            'greenColorant': ((0.435150146484375, 0.793792724609375, 0.0377044677734375),
                              (0.3435448314078857, 0.626688029297322, 0.793792724609375)),
            'greenPrimary': ((0.48265465727581613,
                              0.7099301967082283,
                              0.1347958887652112),
                             (0.3636143283773632,
                              0.5348353896093363,
                              0.7099301967082283)),
            'headerFlags': 0,
            'headerManufacturer': None,
            'headerModel': None,
            'iccMeasurementCondition': None,
            'iccVersion': 0x2400000,
            'iccViewingCondition': None,
            'isCLUT': {0: (True, False, True),
                       1: (True, False, True),
                       2: (True, False, True),
                       3: (True, False, True),
                       10: (False, False, True),
                       11: (False, False, True),
                       12: (False, False, True),
                       13: (False, False, True),
                       14: (False, False, True),
                       15: (False, False, True)},
            'isIntentSupported': {0: (True, True, True),
                                  1: (True, True, True),
                                  2: (True, True, True),
                                  3: (True, True, True),
                                  10: (True, True, True),
                                  11: (True, True, True),
                                  12: (True, True, True),
                                  13: (True, True, True),
                                  14: (True, True, True),
                                  15: (True, True, True)},
            'isMatrixShaper': True,
            'luminance': None,
            'manufacturer': None,
            'mediaWhitePoint': ((0.964202880859375, 1.0, 0.8249053955078125),
                                (0.3457029219802284, 0.3585375327567059, 1.0)),
            'mediaWhitePointTemperature': 5000.722328847392,
            'model': None,
            'perceptualRenderingIntentGamut': None,
            'profileDescription': b'OS10000_A2_B5_mG'.decode("utf-8"),
            'profileid': b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00',
            'redColorant': ((0.4510650634765625, 0.1773834228515625, 0.0),
                            (0.7177438935560628, 0.2822561064439373, 0.1773834228515625)),
            'redPrimary': ((0.39318906319522284,
                            0.22774360756557144,
                            0.018428141315212088),
                           (0.6149721030266726,
                            0.35620513998361475,
                            0.22774360756557144)),
            'renderingIntent': 0,
            'saturationRenderingIntentGamut': None,
            'screeningDescription': None,
            'target': None,
            'technology': None,
            'version': 2.4,
            'viewingCondition': None})

        for icm in ICMS:
            info = LCMSProfileInfo(filename=icm)


def test_main():
    suite = unittest2.TestSuite()
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(TestLCMS))
    return suite

if __name__ == "__main__": # pragma: no cover
    #unittest2.TextTestRunner(verbosity=2).run(test_main())
    suite = unittest2.TestSuite()
    #suite.addTest(TestLCMS("test_lcmsIccCache"))
    suite.addTest(TestLCMS("test_lcmsProfileInfo"))
    run_tests(suite)
