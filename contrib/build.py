#!/usr/bin/env python
# build helper script

import sys
import os
import subprocess
import shutil
import logging


BASEDIR = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
SMCFI = os.path.join(BASEDIR, "smc", "freeimage")
PYTHONS = ["python2.6", "python2.7", "python3.2", "python3.3"]
WINDOWS = sys.platform == "win32"

logging.basicConfig()


def cleanup_dir(dname):
    dname = os.path.join(BASEDIR, dname)
    if os.path.isdir(dname):
        shutil.rmtree(dname)

def cleanup_exts():
    for fname in os.listdir(SMCFI):
        fname = os.path.join(SMCFI, fname)
        if fname.endswith((".so", ".dylib", ".pyd")):
            os.unlink(fname)

def _runpy(python, *args):
    cmd = [python]
    cmd.extend(args)
    env = os.environ.copy()
    for key in list(env):
        if key.upper().startswith("PYTHON"):
            env.pop(key)
    env["PYTHONPATH"] = BASEDIR
    popen = subprocess.Popen(cmd,
                             stdout=subprocess.PIPE,
                             cwd=BASEDIR,
                             env=env)
    stdout, stderr = popen.communicate()
    if popen.returncode:
        print(stdout)
        raise subprocess.CalledProcessError(popen.returncode, cmd)
    return 0

def runtests(python):
    _runpy(python, "setup.py", "build", "build_ext", "--inplace")
    _runpy(python, "-m", "smc.freeimage.tests.__main__", "-q")

def bdist_wininst(python, upload=False):
    args = []
    if upload:
        args.append("upload")
    _runpy(python, "setup.py", "bdist_wininst", *args)
    _runpy(python, "setup.py", "bdist_egg", *args)

def sdist(upload, sign):
    args = []
    if upload:
        args.append("upload")
    if sign:
        args.append("--sign")
    _runpy(sys.executable, "setup.py", "sdist", "--formats=gztar", *args)
    _runpy(sys.executable, "setup.py", "sdist", "--formats=zip", *args)

def getUnixPythons():
    """Find python on Unix
    """
    pythons = []
    for python in PYTHONS:
        for path in os.environ["PATH"].split(os.pathsep):
            fullpath = os.path.join(path, python)
            if os.path.isfile(fullpath):
                pythons.append(fullpath)
                break
    return pythons

def getWindowsPythons():
    """Find Python on Windows

    XXX: use winreg here
    """
    paths = [p for p in (os.environ.get("ProgramFiles(x86)"),
                         os.environ.get("ProgramFiles"))
             if p and os.path.exists(p)]
    pythons = []
    for python in PYTHONS:
        pythondir = python.replace(".", "")
        for path in paths:
            pyexe = os.path.join(path, pythondir, "python.exe")
            if os.path.isfile(pyexe):
                pythons.append(pyexe)
    return pythons

def main(upload_bdist=False, upload_sdist=False):
    if WINDOWS:
        pythons = getWindowsPythons()
    else:
        pythons = getUnixPythons()

    print("Pythons:")
    for python in pythons:
        print("    %s" % python)

    if upload_sdist:
        sdist(upload_sdist, sign=True)

    cleanup_dir("build")
    cleanup_dir("dist")

    fails = []

    for python in pythons:
        print("\n")
        print(python)
        print("-" * len(python))
        cleanup_exts()
        try:
            runtests(python)
            if WINDOWS:
                bdist_wininst(python, upload_bdist)
        except Exception:
            logging.exception("Failed %s" % python)
            fails.append(python)

    if fails:
        print("\nTests or build failed for %s" % ", ".join(fails))
        sys.exit(1)

if __name__ == "__main__":
    main()
