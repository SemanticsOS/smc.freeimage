#!/usr/bin/env python2.7
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
# Purpose     : distutils setup routines
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
import os
import sys
import shutil
import struct
from glob import glob

iswindows = (sys.platform == "win32")
is64 = (struct.calcsize("P") * 8 == 64)
VLS_ENV = os.environ.get("VLS_ENV")

import Cython.Distutils
from Cython.Distutils import build_ext
# aliases for 
sys.modules["Pyrex"] = Cython
sys.modules["Pyrex.Distutils"] = Cython.Distutils

try:
    import setuptools
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension
else:
    from setuptools import setup
    from setuptools.extension import Extension

from distutils.dep_util import newer_group
from distutils.ccompiler import new_compiler


def findlib(libname, library_dirs=None, **kwargs):
    """Find shared library
    """
    compiler = new_compiler()
    dirs = []
    if library_dirs:
        dirs.extend(library_dirs)
    if compiler.library_dirs:
        dirs.etend(compiler.library_dirs)
    dirs.extend(["/lib", "/usr/lib"])
    if is64:
        dirs.extend(["/lib64", "/usr/lib64", "/usr/local/lib64"])
    else:
        dirs.extend(["/lib32", "/usr/lib32", "/usr/local/lib32"])
    return compiler.find_library_file(dirs, libname)


fi_ext_extras = dict(
    depends=["smc/freeimage/freeimage.pxd",
             "smc/freeimage/_lcms.pxi",
             "smc/freeimage/lcms.pxd",
             "smc/freeimage/smc_fi.pxd",
             "smc/freeimage/smc_fi.h"],
    )

def merge(**kwargs):
    """Merge config values with fi_ext_extras
    """
    for key, values in kwargs.items():
        fi_ext_extras.setdefault(key, []).extend(values)

if iswindows:
    merge(include_dirs=["windows"],
          library_dirs=["windows/x86"] if not is64 else ["windows/x86_64"],
          libraries=["lcms2", "user32"], # "freeimage" later
          define_macros=[("CMS_DLL", "1")],
          extra_link_args=["/NODEFAULTLIB:libcmt"]
    )
else:
    merge(libraries=["lcms2"], # "freeimage" later
          # LCMS2 requires a C99 compiler, add debug symbols
          extra_compile_args=["-std=gnu99", "-g", "-O2"],
          define_macros=[],
          extra_link_args=["-g"]
    )

if VLS_ENV is not None:
    merge(include_dirs=[os.path.join(VLS_ENV, "include")],
          library_dirs=[os.path.join(VLS_ENV, "lib")],
          #rpath=[os.path.join(VLS_ENV, "lib")],
    )

# try to find freeimage with libjpeg-turbo
turbo = findlib("freeimageturbo", **fi_ext_extras)
if turbo:
    print("*** FreeImage with libjpeg-turbo found at %s, using turbo" % turbo)
    merge(libraries=["freeimageturbo"],
          define_macros=[("FREEIMAGE_TURBO", 1)]
    )
else:
    print("*** FreeImage with libjpeg-turbo not found")
    merge(libraries=["freeimage"],
          define_macros=[("FREEIMAGE_TURBO", 0)]
    )


# Cython and distutils sometimes don't pick up that _freeimage.c is outdated
if os.path.isfile("smc/freeimage/_freeimage.c"):
    files = glob("smc/freeimage/*.pyx") + glob("smc/freeimage/*.px?")
    if newer_group(files, "smc/freeimage/_freeimage.c"):
        print("unlink smc/freeimage/_freeimage.c")
        os.unlink("smc/freeimage/_freeimage.c")


setup_info = dict(
    name="smc.freeimage",
    version="0.1",
    ext_modules=[
        Extension("smc.freeimage._freeimage", ["smc/freeimage/_freeimage.pyx"],
                  **fi_ext_extras),
        Extension("smc.freeimage.ficonstants", ["smc/freeimage/ficonstants.c"],
                  **fi_ext_extras),
        Extension("smc.freeimage.lcmsconstants", ["smc/freeimage/lcmsconstants.c"],
                  **fi_ext_extras),
    ],
    setup_requires=["setuptools>=0.6c11", "Cython>=0.16"],
    packages=["smc.freeimage"],
    namespace_packages=["smc"],
    #package_data = {
    #    "smc.freeimage.tests": ["*.jpg", "*.tiff"],
    #    "smc.freeimage": ["*.c", "*.px?", "*.pyx"],
    #    },
    zip_safe=False,
    cmdclass={"build_ext": build_ext},
    author="semantics GmbH / Christian Heimes",
    author_email="c.heimes@semantics.de",
    maintainer="Christian Heimes",
    maintainer_email="c.heimes@semantics.de",
    url="https://bitbucket.org/tiran/smc.freeimage",
    keywords="freeimage lcms image jpeg tiff png pil icc",
    license="FIPL or GPL",
    description="Python wrapper for FreeImage and LCMS2 libraries",
    long_description=open("README.txt").read(),
    classifiers=(
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: Other/Proprietary License",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Natural Language :: English",
        "Operating System :: Microsoft :: Windows",
        "Operating System :: POSIX",
        "Operating System :: OS Independent",
        "Programming Language :: Cython",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.2",
        "Programming Language :: C",
        "Topic :: Multimedia :: Graphics",
        "Topic :: Software Development :: Libraries :: Python Modules"
    ),
)

if iswindows:
    if is64:
        shutil.copy("windows/x86_64/FreeImage.dll", "smc/freeimage/")
        shutil.copy("windows/x86_64/lcms2.dll", "smc/freeimage/")
    else:
        shutil.copy("windows/x86/FreeImage.dll", "smc/freeimage/")
        shutil.copy("windows/x86/lcms2.dll", "smc/freeimage/")
    pd = setup_info.setdefault("package_data", {})
    pd_sf = pd.setdefault("smc.freeimage", [])
    pd_sf.append("FreeImage.dll")
    pd_sf.append("lcms2.dll")

setup(**setup_info)

#if iswindows:
#    os.unlink("smc/freeimage/FreeImage.dll")
#    os.unlink("smc/freeimage/lcms2.dll")

