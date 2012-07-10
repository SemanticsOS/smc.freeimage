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

inplace:
	$(PYTHON) setup.py $(SETUPFLAGS) build_ext -i $(COMPILEFLAGS)

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

egg_info:
	$(PYTHON) setup.py egg_info

egg: egg_info inplace
	$(PYTHON) setup.py bdist_egg

develop: egg_info inplace
	$(PYTHON) setup.py develop

sdist: egg_info
	$(PYTHON) setup.py sdist
 
pxd:  
	$(PYTHON) fi2pxd.py
	$(PYTHON) lcms2pxd.py

benchmark: inplace
	@echo "FreeImage"
	$(PYTHON) -m timeit -s "from smc.freeimage.tests.benchmark import fi" "fi()"
	@echo "PIL"
	$(PYTHON) -m timeit -s "from smc.freeimage.tests.benchmark import pil" "pil()"
