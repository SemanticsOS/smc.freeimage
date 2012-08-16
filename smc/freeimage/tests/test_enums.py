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
# Purpose     : enum unit tests
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

from smc.freeimage import enums
from smc.freeimage.tests.common import owner, unittest2, run_tests

ENUMS = ['CONSTANTS', 'FI_COLOR', 'FI_COLOR_CHANNEL', 'FI_COLOR_TYPE',
         'FI_DITHER', 'FI_FILTER', 'FI_FORMAT',
         'FI_JPEG_OPERATION', 'FI_MDMODEL',
         'FI_MDTYPE', 'FI_QUANTIZE', 'FI_TMO',
         'FI_TYPE',
         ]


class TestEnums(unittest2.TestCase):

    @owner("c.heimes")
    def test___all__(self):
        self.assertEqual(sorted(ENUMS), sorted(enums.__all__))

    @owner("c.heimes")
    def test_class(self):
        for cname in ENUMS:
            cls = getattr(enums, cname)
            self.assert_(issubclass(cls, object))

    @owner("c.heimes")
    def test_attrs(self):
        for cname in ENUMS:
            cls = getattr(enums, cname)
            for name, value in cls.__dict__.items():
                if name.startswith("_"):
                    continue
                self.assert_(name[0].isupper(), name)
                self.assert_(isinstance(value, int), (name, type(value)))


def test_main():
    suite = unittest2.TestSuite()
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(TestEnums))
    return suite

if __name__ == "__main__": # pragma: no cover
    run_tests(test_main())
