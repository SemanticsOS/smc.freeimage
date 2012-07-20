# -*- coding: utf-8 -*-
#=============================================================================
# Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
# Rep./File   : $URL$
# Date        : $Date$
# Author      : Christian Heimes
# License     : FreeImage Public License (FIPL)
#               GNU General Public License (GPL)
# Worker      : $Author$
# Revision    : $Rev$
# Purpose     : small subset of the Python API for Cython extensions 
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

from libc cimport stddef

cdef extern from "smc_fi.h" nogil:
    cdef bint IS_PYTHON3
    cdef bint SMC_FI_BIG_ENDIAN

cdef extern from "wchar.h" nogil:
    cdef size_t wcslen(stddef.wchar_t * s)

cdef extern from "time.h" nogil:
    cdef struct tm:
        int tm_sec
        int tm_min
        int tm_hour
        int tm_mday
        int tm_mon
        int tm_year

cdef extern from "inttypes.h":
    ctypedef long int32_t
    ctypedef unsigned short uint8_t
    ctypedef unsigned int uint16_t
    ctypedef unsigned long uint32_t

cdef extern from *:
    ctypedef char* const_char_ptr "const char*"
    ctypedef char const_char "const char"
    ctypedef void* const_void_ptr "const void*"
    ctypedef struct const_struct "const struct"

cdef extern from "Python.h":
    # unicode
    object PyUnicode_FromWideChar(stddef.wchar_t *w, Py_ssize_t size)
    # buffer
    int PyObject_AsReadBuffer (object, void **, Py_ssize_t *) except -1

