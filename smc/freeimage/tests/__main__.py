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
try:
    import unittest2
except ImportError:
    import unittest as unittest2

from smc.freeimage.tests import test_main

if __name__ == "__main__": # pragma: no cover
    unittest2.TextTestRunner(verbosity=2).run(test_main())
