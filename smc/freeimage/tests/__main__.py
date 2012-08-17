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
# Purpose     : unit tests
#=============================================================================

import sys
from smc.freeimage.tests.common import unittest2, run_tests
from smc.freeimage.tests import test_main

if __name__ == "__main__": # pragma: no cover
    if "-q" in sys.argv:
        verbosity = 1
    else:
        verbosity = 2
    run_tests(test_main(), verbosity)
