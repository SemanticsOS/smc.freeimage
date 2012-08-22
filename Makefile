# -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : Makefile
#=============================================================================

PYTHON=python2.7
SETUPFLAGS=
COMPILEFLAGS=

.PHONY: inplace static all rebuild test_inplace test valgrind clean realclean 
.PHONY: sdist pxd benchmark sphinx upload_sphinx


inplace:
	$(PYTHON) setup.py $(SETUPFLAGS) build_ext -i $(COMPILEFLAGS)

static:
	$(PYTHON) setup.py $(SETUPFLAGS) build_ext -i --static $(COMPILEFLAGS)

all: inplace

rebuild: clean all

test_inplace: inplace
	$(PYTHON) -m smc.freeimage.tests.__main__

test: test_inplace

valgrind: inplace
	valgrind --tool=memcheck --leak-check=full \
	    --num-callers=30 --suppressions=valgrind-python.supp \
	    $(PYTHON) -m smc.freeimage.tests.__main__

clean:
	find . \( -name '*.o' -or -name '*.so' -or -name '*.py[cod]' \) -delete
	rm -f smc/freeimage/_freeimage.c

realclean: clean
	rm -rf build
	rm -rf dist
	rm -f TAGS tags
	$(PYTHON) setup.py clean -a

sdist:
	$(PYTHON) setup.py sdist --format=gztar
	$(PYTHON) setup.py sdist --format=zip

sphinx:
	$(PYTHON) setup.py sphinx

upload_sphinx:
	$(PYTHON) setup.py sphinx upload_sphinx
 
pxd:
	$(PYTHON) fi2pxd.py
	$(PYTHON) lcms2pxd.py

benchmark: inplace
	@echo "FreeImage"
	$(PYTHON) -m timeit -s "from smc.freeimage.tests.benchmark import fi" "fi()"
	@echo "PIL"
	$(PYTHON) -m timeit -s "from smc.freeimage.tests.benchmark import pil" "pil()"
