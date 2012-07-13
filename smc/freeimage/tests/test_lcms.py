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

#@PydevCodeAnalysisIgnore
from __future__ import with_statement
import os
import sys
try:
    import unittest2
except ImportError:
    import unittest as unittest2

import tempfile
import shutil
from time import time
from glob import glob
from pprint import pprint

from smc.freeimage import *
from smc.freeimage import ficonstants as fi
from smc.freeimage import lcmsconstants as lcms
from smc.freeimage.tests.test_image import TestImageBase
from smc.freeimage.tests.common import owner, ICMS

class TestLCMS(TestImageBase):

    @owner("c.heimes")
    def test_lcms(self):
        self.tmpdir = tempfile.mkdtemp()
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_orig.jpg"))
        start = time()
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
        start = time()
        self.tiff.iccTransform(trafo)
        #print time() - start
        self.tiff.save(os.path.join(self.tmpdir, "lzw_pon_transform2.jpg"))

    @owner("c.heimes")
    def test_lcmsCreateTrafo(self):
        icc = self.tiff.getICC()
        start = time()
        for i in range(10):
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
        cache.lookupByImage(self.tiff, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)
        self.assertEqual(cache.creations, 1)
        self.assertEqual(list(cache), [(icc, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)])

        cache.lookupByImage(self.tiff, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)
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
        start = time()
        cache.applyTransform(self.tiff)
        cache.applyTransform(self.tiff, inprofile=self.tiff.getICC())
        self.assertEqual(cache.creations, 3)
        self.assertEqual(list(cache), [(icc, b"sRGB", lcms.TYPE_BGR_8, lcms.INTENT_PERCEPTUAL, 0)])
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
        icc = self.tiff.getICC()
        info = LCMSProfileInfo(data=icc)
        #pprint(getIntents())
        #pprint(info.info)

        for icm in ICMS:
            #print icm
            info = LCMSProfileInfo(filename=icm)
            #pprint(info.info)


def test_main():
    suite = unittest2.TestSuite()
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(TestLCMS))
    return suite

if __name__ == "__main__": # pragma: no cover
    #unittest2.TextTestRunner(verbosity=2).run(test_main())
    suite = unittest2.TestSuite()
    #suite.addTest(TestLCMS("test_lcmsIccCache"))
    suite.addTest(TestLCMS("test_lcmsProfileInfo"))
    unittest2.TextTestRunner(verbosity=2).run(suite)
