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
# Purpose     : benchmarks
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

from smc.freeimage import Image
from smc.freeimage.ficonstants import FILTER_CATMULLROM
from PIL.Image import open as pil_open
from PIL.Image import ANTIALIAS
import os

from smc.freeimage.tests.common import IMG, TESTDATA
OUT = os.path.join(TESTDATA, "tmpout.jpg")


def pil(src=IMG, dst=OUT, pil_open=pil_open):
    img = pil_open(src)
    for w, h in ((128, 182), (300, 427), (500, 712), (700, 997), (900, 1281)):
        new = img.resize((w, h), ANTIALIAS)
        new.save(dst)


def fi(src=IMG, dst=OUT, Image=Image):
    img = Image(src)
    for w, h in ((128, 182), (300, 427), (500, 712), (700, 997), (900, 1281)):
        new = img.resize(w, h, FILTER_CATMULLROM)
        new.save(dst)
