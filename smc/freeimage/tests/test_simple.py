## -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : unit tests for simple and misc code
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
try:
    import unittest2
except ImportError:
    import unittest as unittest2

import sys
from smc import freeimage
from smc.freeimage import FormatInfo, OperationError
from smc.freeimage import ficonstants as fi
from smc.freeimage import enums
from smc.freeimage.tests.test_image import IMG
from smc.freeimage.tests.common import owner

class SimpleStuff(unittest2.TestCase):
    @owner("c.heimes")
    def test_getVersion(self):
        self.assert_(isinstance(freeimage.getVersion(), str))
        self.assert_(freeimage.getVersion() in ["3.15.3"],
                     freeimage.getVersion())

    @owner("c.heimes")
    def test_getCopyright(self):
        self.assert_(isinstance(freeimage.getCopyright(), str))
        self.assert_("FreeImage" in freeimage.getCopyright())

    @owner("c.heimes")
    def test_getCompiledFor(self):
        self.assert_(isinstance(freeimage.getCompiledFor(), tuple))
        self.assert_(freeimage.getCompiledFor() in [(3, 15, 3)],
                     freeimage.getCompiledFor())

    @owner("c.heimes")
    def test_freeimage_turbo(self):
        if sys.platform == "win32":
            self.assertFalse(freeimage.hasJPEGTurbo())
        else:
            self.assertTrue(freeimage.hasJPEGTurbo())

    @owner("c.heimes")
    def test_formatinfo(self):
        info = FormatInfo(fi.FIF_JPEG)
        self.assertEqual(int(info), fi.FIF_JPEG)
        self.assertEqual(info.format, fi.FIF_JPEG)
        self.assertEqual(info.mimetype, "image/jpeg")
        self.assertEqual(info.name, "JPEG")
        self.assertEqual(info.description, "JPEG - JFIF Compliant")
        self.assertEqual(info.magic_reg_expr, b"^\xff\xd8\xff")
        self.assert_(info.supports_reading)
        self.assert_(info.supports_writing)
        self.assert_(info.supports_icc)
        self.assert_(info.supports_nopixels)
        self.assertEqual(info.getExtensions(), ['jpg', 'jif', 'jpeg', 'jpe'])
        self.assert_(info.getSupportsExportType(fi.FIT_BITMAP))
        self.assert_(info.getSupportsExportBPP(24))

        info = FormatInfo(fi.FIF_TIFF)
        self.assert_(info.supports_nopixels)

        info = FormatInfo.from_filename(IMG)
        self.assertEqual(info.format, fi.FIF_JPEG)

        info = FormatInfo.from_file(IMG)
        self.assertEqual(info.format, fi.FIF_JPEG)

        info = FormatInfo.from_mimetype("image/jpeg")
        self.assertEqual(info.format, fi.FIF_JPEG)

        try:
            FormatInfo.from_mimetype("image/invalid")
        except OperationError:
            err = sys.exc_info()[1]
            self.assertEqual(err.args, ('Unable to detect format.',))
        else:
            self.fail("OperationError expected")

        try:
            FormatInfo.from_filename(__file__)
        except OperationError:
            err = sys.exc_info()[1]
            self.assertEqual(err.args, ('Unable to detect format.',))
        else:
            self.fail("OperationError expected")

        try:
            FormatInfo.from_file(__file__)
        except OperationError:
            err = sys.exc_info()[1]
            self.assertEqual(err.args, ('Unable to detect format.',))
        else:
            self.fail("OperationError expected")


    @owner("c.heimes")
    def test_getFormatCount(self):
        self.assertEqual(freeimage.getFormatCount(), 35)
        self.assertEqual(freeimage.getFormatCount(), fi.FIF_RAW + 1)

    @owner("c.heimes")
    def test_lookupColor(self):
        self.assertEqual(freeimage.lookupX11Color("black"), (0, 0, 0))
        self.assertEqual(freeimage.lookupX11Color("orange"), (255, 165, 0))
        self.assertRaises(TypeError, freeimage.lookupX11Color, None)

        self.assertEqual(freeimage.lookupSVGColor("black"), (0, 0, 0))
        self.assertEqual(freeimage.lookupSVGColor("lemonchiffon"),
                         (255, 250, 205))
        self.assertRaises(TypeError, freeimage.lookupSVGColor, None)


def test_main():
    suite = unittest2.TestSuite()
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(SimpleStuff))
    return suite

if __name__ == "__main__": # pragma: no cover
    unittest2.TextTestRunner(verbosity=2).run(test_main())
