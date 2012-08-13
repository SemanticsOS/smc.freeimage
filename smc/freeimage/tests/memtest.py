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
# Purpose     : memory load tester
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
import sys
import unittest2
import tempfile
import shutil
import gc

from smc.freeimage import Image
from smc.freeimage.tests import test_main
from smc.freeimage.tests.common import IMG

if sys.platform == "win32": # pragma: no cover
    import win32process
    import win32api


def proc_status():
    info = {}
    with open("/proc/%i/status" % os.getpid()) as fh:
        for line in fh:
            try:
                key, value = line.split(":")
            except ValueError:
                # may happen under great load?
                continue
            value = value.strip()
            if value.endswith(' kB'):
                value = value[:-3]
                try:
                    value = float(value) / 1024.0
                except ValueError:
                    continue
            info[key.strip()] = value
    return info


def win32_status(): # pragma: no cover
    info = {}
    hProcess = win32api.GetCurrentProcess()
    pmi = win32process.GetProcessMemoryInfo(hProcess)
    for key, value in pmi.items():
        if key != "PageFaultCount":
            # values in bytes
            value = value / (1024.0 ** 2)
        info[key] = value
    return info


class LoadTest(object):
    def __init__(self, func, *args, **kwargs):
        self.func = func
        self.args = args
        self.kwargs = kwargs
        self.tmpdir = None

    def setUp(self):
        pass

    def tearDown(self):
        if self.tmpdir is not None:
            shutil.rmtree(self.tmpdir)

    if sys.platform == "win32":
        @classmethod
        def log(cls, round):
            gc.collect()
            info = win32_status()
            info.update(round=round, fi=sys.getrefcount(Image))
            print("%(round)i: peak %(PeakWorkingSetSize)0.3f, working "
                  "%(WorkingSetSize)0.3f, image ref %(fi)i" % info)

    else:
        @classmethod
        def log(self, round):
            gc.collect()
            info = proc_status()
            info.update(round=round, fi=sys.getrefcount(Image))
            print("%(round)i: virtual %(VmSize)0.3f, resident %(VmRSS)0.3f, "
                  "image ref %(fi)i" % info)

    def __call__(self, rounds=100, log=5):
        self.setUp()
        try:
            for i in range(rounds):
                if (i % log) == 0:
                    self.log(i)
                self.func(*self.args, **self.kwargs)
        finally:
            self.tearDown()


def rotateex():
    def func():
        img = Image(IMG)
        new = img.rotateEx(0.5, 1, 1, 2, 2)
        img.close()
        new.save(os.path.join(loadtest.tmpdir, "rotated.jpg"))
        new.close()

    #loadtest = LoadTest(img.rotateEx, 30.0, 5, 5, 10, 10)
    loadtest = LoadTest(func)
    loadtest.tmpdir = tempfile.mkdtemp()
    loadtest(rounds=50, log=1)


def cycle_test(rounds=50):
    suite = test_main()
    runner = unittest2.TextTestRunner(verbosity=1)
    loadtest = LoadTest(runner.run, suite)
    loadtest(rounds=rounds, log=1)


if __name__ == "__main__":
    #rotateex()
    cycle_test()
