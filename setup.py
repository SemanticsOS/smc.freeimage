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
import io
from glob import glob

HERE = os.path.dirname(os.path.abspath(__file__))
IS_WINDOWS = (sys.platform == "win32")
IS_64 = (struct.calcsize("P") * 8 == 64)
VLS_ENV = os.environ.get("VLS_ENV")

if "--static" in sys.argv:
    sys.argv.remove("--static")
    STATIC = True
else:
    STATIC = False

if "--without-turbo" in sys.argv:
    sys.argv.remove("--without-turbo")
    WITHOUT_TURBO = True
else:
    WITHOUT_TURBO = False


try:
    import Cython.Distutils
except ImportError:
    from distutils.command.build_ext import build_ext
    HAS_CYTHON = False
else:
    HAS_CYTHON = True
    from Cython.Distutils import build_ext
    # aliases for setuptools
    sys.modules["Pyrex"] = Cython
    sys.modules["Pyrex.Distutils"] = Cython.Distutils


try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension
else:
    from setuptools.extension import Extension

from distutils.dep_util import newer_group
from distutils.ccompiler import new_compiler

def getLongDescription():
    parts = []
    for name in "README.txt", "CHANGES.txt":
        with io.open(name, "r") as f:
            parts.append(f.read())
    return "\n".join(parts)


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
    if IS_64:
        dirs.extend(["/lib64", "/usr/lib64", "/usr/local/lib64"])
    else:
        dirs.extend(["/lib32", "/usr/lib32", "/usr/local/lib32"])
    return compiler.find_library_file(dirs, libname)

fi_ext_extras = dict(
    depends=["smc/freeimage/freeimage.pxd",
             "smc/freeimage/_lcms.pxi",
             "smc/freeimage/lcms.pxd",
             "smc/freeimage/smc_fi.pxd",
             "smc/freeimage/smc_fi.h"])
fi_ext_extra_objects = []


def addshared():
    """Link against shared libfreeimage(turbo) and LCMS2 libs
    """
    # try to find freeimage with libjpeg-turbo
    if WITHOUT_TURBO:
        turbo = False
    else:
        turbo = findlib("freeimageturbo", fi_ext_extras.get("library_dirs"))
    if turbo:
        print("*** FreeImage with libjpeg-turbo found at %s, using turbo" % turbo)
        merge(libraries=["freeimageturbo"],
              define_macros=[("FREEIMAGE_TURBO", 1)])
    else:
        print("*** FreeImage with libjpeg-turbo not found")
        merge(libraries=["freeimage"],
              define_macros=[("FREEIMAGE_TURBO", 0)])
    merge(libraries=["lcms2"],
          define_macros=[("CMS_DLL", "1")])
    return bool(turbo)


def addstatic():
    """Link against shared libfreeimage(turbo) and LCMS2 libs

    binaries must be compiled with -fPIC
    """
    if not WITHOUT_TURBO and os.path.isfile("static/libfreeimageturbo.a"):
        fi_ext_extra_objects.append("static/libfreeimageturbo.a")
        merge(define_macros=[("FREEIMAGE_TURBO", 1)])
        turbo = True
    else:
        fi_ext_extra_objects.append("static/libfreeimage.a")
        merge(define_macros=[("FREEIMAGE_TURBO", 0)])
        turbo = False
    fi_ext_extra_objects.append("static/liblcms2.a")
    # FreeImage needs C++ standard library
    merge(libraries=["stdc++"],
          include_dirs=["static"])
    return turbo


def merge(**kwargs):
    """Merge config values with fi_ext_extras
    """
    for key, values in kwargs.items():
        fi_ext_extras.setdefault(key, []).extend(values)


if IS_WINDOWS:
    merge(include_dirs=["windows"],
          library_dirs=["windows/x86"] if not IS_64 else ["windows/x86_64"],
          libraries=["user32"],
          extra_link_args=["/NODEFAULTLIB:libcmt"])
else:
    merge(# LCMS2 requires a C99 compiler, add debug symbols
          extra_compile_args=["-std=gnu99", "-g", "-O2"],
          extra_link_args=["-g"])

# custom code for Visual Library
if VLS_ENV is not None:
    merge(include_dirs=[os.path.join(VLS_ENV, "include")],
          library_dirs=[os.path.join(VLS_ENV, "lib")],
          runtime_library_dirs=[os.path.join(VLS_ENV, "lib")])

# build static or shared extension?
if STATIC:
    HAS_TURBO = addstatic()
else:
    HAS_TURBO = addshared()

# Cython and distutils sometimes don't pick up that _freeimage.c is outdated
if HAS_CYTHON:
    if os.path.isfile("smc/freeimage/_freeimage.c"):
        files = glob("smc/freeimage/*.pyx") + glob("smc/freeimage/*.px?")
        if newer_group(files, "smc/freeimage/_freeimage.c"):
            print("unlink smc/freeimage/_freeimage.c")
            os.unlink("smc/freeimage/_freeimage.c")

if HAS_CYTHON:
    freeimage_files = ["smc/freeimage/_freeimage.pyx"]
else:
    freeimage_files = ["smc/freeimage/_freeimage.c"]


setup_info = dict(
    name="smc.freeimage",
    version="0.2",
    ext_modules=[
        Extension("smc.freeimage._freeimage", freeimage_files,
                  extra_objects=fi_ext_extra_objects, **fi_ext_extras),
        Extension("smc.freeimage.ficonstants", ["smc/freeimage/ficonstants.c"],
                  **fi_ext_extras),
        Extension("smc.freeimage.lcmsconstants", ["smc/freeimage/lcmsconstants.c"],
                  **fi_ext_extras)],
    setup_requires=["setuptools>=0.6c11", "Cython>=0.16"],
    packages=["smc.freeimage"],
    namespace_packages=["smc"],
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
    long_description=getLongDescription(),
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

if IS_WINDOWS:
    fidll = "FreeImageTurbo.dll" if HAS_TURBO else "FreeImage.dll"
    if IS_64:
        shutil.copy("windows/x86_64/%s" % fidll, "smc/freeimage/")
        shutil.copy("windows/x86_64/lcms2.dll", "smc/freeimage/")
    else:
        shutil.copy("windows/x86/%s" % fidll, "smc/freeimage/")
        shutil.copy("windows/x86/lcms2.dll", "smc/freeimage/")
    pd = setup_info.setdefault("package_data", {})
    pd_sf = pd.setdefault("smc.freeimage", [])
    pd_sf.append(fidll)
    pd_sf.append("lcms2.dll")

setup(**setup_info)

#if IS_WINDOWS:
#    os.unlink("smc/freeimage/%s" % fidll)
#    os.unlink("smc/freeimage/lcms2.dll")
