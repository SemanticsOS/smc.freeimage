## -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2010-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : unit tests
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
# testing package
__all__ = ["IMG", "TIFF", "BITON", "ICMS", "MULTIPAGE", "BUFFERTEST",
           "CMYK", "PY3", "owner", "unittest2"]
import os
import sys
from glob import glob

try:
    import unittest2
except ImportError:
    import unittest as unittest2


def run_tests(suite, verbosity=2): # pragma: no cover
    """Run tests
    """
    runner = unittest2.TextTestRunner(verbosity=verbosity)
    result = runner.run(suite)
    if not result.wasSuccessful():
        sys.exit(1)

def find_testdata(): # pragma: no cover
    """Find directory with testdata images
    """
    current = os.path.dirname(os.path.abspath(__file__))
    while True:
        testdata = os.path.join(current, "testdata")
        if os.path.isdir(testdata):
            return testdata
        parent = os.path.abspath(os.path.join(current, os.pardir))
        if parent == current:
            raise RuntimeError("Cannot find testdata directory")
        current = parent

PY3 = sys.version_info[0] == 3

TESTDATA = find_testdata()

IMG = os.path.join(TESTDATA, "pon.jpg")
TIFF = os.path.join(TESTDATA, "lzw_pon.tiff")
TIFF2 = os.path.join(TESTDATA, "non_pon_large.tiff")
BITON = os.path.join(TESTDATA, "1bpp.tiff")
MULTIPAGE = os.path.join(TESTDATA, "multipage.tiff")
BUFFERTEST = os.path.join(TESTDATA, "buffertest.tiff")
CMYK = os.path.join(TESTDATA, "cmyk.tiff")
ICMS = glob(os.path.join(TESTDATA, "*.icm"))


def owner(*args):
    """decorator to set owner of a test case
    """
    def wrapper(f):
        f._owner_of_test = args
        return f
    return wrapper

if __name__ == "__main__":
    print(TESTDATA)
