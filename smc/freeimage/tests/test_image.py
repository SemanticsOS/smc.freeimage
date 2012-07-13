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
# Purpose     : image unit tests
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

#@PydevCodeAnalysisIgnoreICC
from __future__ import with_statement
import os
import sys
try:
    import unittest2
except ImportError:
    import unittest as unittest2

import tempfile
import shutil
import time
from pprint import pprint

from smc.freeimage import *
from smc.freeimage import ficonstants as fi
from smc.freeimage.tests.common import owner, IMG, TIFF, TIFF2, BITON


class TestImageBase(unittest2.TestCase):
    image_names = ("img", "tiff") # "biton",
    remove_tmp = True

    def setUp(self):
        self._img = self._tiff = self._tiff2 = self._biton = None
        self.tmpdir = None

    def tearDown(self):
        # close images after test
        for name in ("_img", "_tiff", "_tiff2", "_biton"):
            img = getattr(self, name, None)
            if img is not None:
                img.close()
            setattr(self, name, None)

        if self.tmpdir is not None:
            if self.remove_tmp:
                shutil.rmtree(self.tmpdir)

    @property
    def img(self):
        if self._img is None:
            self._img = Image(IMG)
        return self._img

    @property
    def tiff(self):
        if self._tiff is None:
            self._tiff = Image(TIFF)
        return self._tiff

    @property
    def tiff2(self):
        if self._tiff2 is None:
            self._tiff2 = Image(TIFF2)
        return self._tiff2

    @property
    def biton(self):
        if self._biton is None:
            self._biton = Image(BITON)
        return self._biton

class TestImage(TestImageBase):
    @owner("c.heimes")
    def test00imagebase(self):
        self.assert_(isinstance(self.img, Image))
        self.assert_(isinstance(self.tiff, Image))
        self.assert_(isinstance(self.biton, Image))
        for name in self.image_names:
            self.assert_(isinstance(getattr(self, name), Image))

    def _test_jpeg(self, img):
        self.assertEqual(img.format, FI_FORMAT.FIF_JPEG)
        self.assertEqual(img.width, 1210)
        self.assertEqual(img.height, 1778)
        self.assertEqual(img.size, (1210, 1778))
        self.assertEqual(img.type, FI_TYPE.FIT_BITMAP)
        self.assertEqual(img.bpp, 24)
        self.assertEqual(img.dpi_x, 300.0)
        self.assertEqual(img.dpi_y, 300.0)
        self.assertEqual(img.dpi, (300.0, 300.0))
        self.assertEqual(img.dpm_x, 11811)
        self.assertEqual(img.dpm_y, 11811)
        self.assertEqual(img.dpm, (11811, 11811))
        self.assertEqual(img.icc_cmyk, None)
        self.assertEqual(img.has_icc, False)
        self.assertEqual(img.colors_used, 0)
        self.assertEqual(img.color_type, FI_COLOR_TYPE.FIC_RGB)
        self.assertEqual(img.color_type_name, "RGB")
        self.assertEqual(img.is_transparent, False)
        self.assertEqual(img.has_bg_color, False)
        self.assertEqual(img.colororder, "BGR")
        self.assertEqual(img.rgb_mask, (0xff0000, 0x00ff00, 0x0000ff))
        size = 3 * 1210 * 1778
        self.assertGreater(sys.getsizeof(img), size)
        self.assertLess(sys.getsizeof(img), size + 1024)
        self.assert_(repr(img))

    @owner("c.heimes")
    def test_open(self):
        self._test_jpeg(self.img)
        self.assertEqual(self.img.filename, IMG)
        self.assertTrue(self.img.has_pixels)

    @owner("c.heimes")
    def DISABLED_test_save_biton(self):
        grey = self.biton.greyscale()
        grey.save("/tmp/biton_grey.jpg")
        grey.save("/tmp/biton_grey.png")
        bpp = self.biton.convert_24bits()
        bpp.save("/tmp/biton_24bpp.jpg")
        bpp.save("/tmp/biton_24bpp.png")

    @owner("c.heimes")
    def test_tiff(self):
        img = self.tiff
        self.assertEqual(img.format, FI_FORMAT.FIF_TIFF)
        self.assertEqual(img.size, (1136, 1618))
        self.assertTrue(img.has_pixels)

    @owner("c.heimes")
    def test_loadnopixels(self):
        with Image(TIFF, flags=FI_FORMAT.FIF_LOAD_NOPIXELS) as img:
            self.assertFalse(img.has_pixels)
        with Image(BITON, flags=FI_FORMAT.FIF_LOAD_NOPIXELS) as img:
            self.assertFalse(img.has_pixels)
        with Image(IMG, flags=FI_FORMAT.FIF_LOAD_NOPIXELS) as img:
            self.assertFalse(img.has_pixels)

    @owner("c.heimes")
    def test_tiff(self):
        img = self.tiff
        self.assertEqual(img.format, FI_FORMAT.FIF_TIFF)
        self.assertEqual(img.size, (1136, 1618))


    @owner("c.heimes")
    def test_close(self):
        img = self.img
        img.close()
        img.close()

        self.assertRaises(IOError, img.clone)
        self.assertRaises(IOError, img.rotate, 90)

    @owner("c.heimes")
    def test_clone(self):
        img = self.img
        clone = img.clone()

        self.assertEqual(img.format, clone.format)
        self.assertEqual(img.size, clone.size)
        self.assertEqual(img.dpi, clone.dpi)
        self.assertEqual(img.bpp, clone.bpp)
        self.assertEqual(img.filename, clone.filename)

    @owner("c.heimes")
    def test_open_invalid(self):
        try:
            Image(__file__)
        except UnknownImageError:
            err = sys.exc_info()[1]
            self.assert_(isinstance(err, UnknownImageError))
            self.assertEqual(err.args, (__file__,))
        else:
            self.fail("UnknownImageError expected")

        self.assertRaises(IOError, Image, "/an/invalid/peg")

    @owner("c.heimes")
    def test_open_buffer(self):
        data = open(IMG, "rb").read()
        with Image(buffer=data) as img:
            self._test_jpeg(img)

    @owner("c.heimes")
    def test_open_buffer_invalid(self):
        self.assertRaises(TypeError, Image, buffer=object)
        self.assertRaises(TypeError, Image, buffer=object())

    @owner("c.heimes")
    def test_crop(self):
        img = self.img
        cpy = img.crop(0, 0, 100, 200)
        self.assertEqual(cpy.width, 100)
        self.assertEqual(cpy.height, 200)
        self.assertEqual(cpy.bpp, 24)
        self.assertEqual(cpy.dpi_x, 300.0)
        self.assertEqual(cpy.dpi_y, 300.0)
        self.assertEqual(cpy.has_icc, False)
        self.assertEqual(sum(cpy.getMetadataCount().values()), 0)
        cpy.close()

    @owner("c.heimes")
    def test_line(self):
        for name in self.image_names:
            img = getattr(self, name)
            img.hline(100, 0, -1, linewidth=10, red=200, green=200, blue=200)
            img.vline(100, 0, -1, linewidth=10, red=200, green=200, blue=200)
            if 0: # pragma: no cover
                if name == "biton":
                    img = img.convert_24bits()
                img.save("test_%s.jpg" % name, FI_FORMAT.FIF_JPEG)
                img.close()


    @owner("c.heimes")
    def test_resize(self):
        img = self.img
        cpy = img.resize(121, 178, FI_FILTER.FILTER_BILINEAR)
        self.assertEqual(cpy.width, 121)
        self.assertEqual(cpy.height, 178)
        self.assertEqual(cpy.bpp, 24)
        self.assertEqual(cpy.dpi_x, 300.0)
        self.assertEqual(cpy.dpi_y, 300.0)

    @owner("c.heimes")
    def test_save(self):
        img = self.img
        #test autodetect FIF
        self.tmpdir = tempfile.mkdtemp()
        jpg_file = os.path.join(self.tmpdir, "test_out.jpg")
        png_file = os.path.join(self.tmpdir, "test_out.png")
        j2k_file = os.path.join(self.tmpdir, "test_out.j2k")

        img.save(jpg_file)
        img.save(png_file)
        img.save(j2k_file)
        #assume the jpeg is more compressed than the png (since its lossy)
        self.assert_(os.path.getsize(jpg_file) < os.path.getsize(png_file))

        #test format parameter
        no_ext_file = os.path.join(self.tmpdir, "test_out")
        img.save(no_ext_file, format=FI_FORMAT.FIF_PNG)
        self.failUnlessEqual(os.path.getsize(no_ext_file),
                             os.path.getsize(png_file))

        #test flag parameter 
        previous_size = os.path.getsize(jpg_file)
        # only 50% jpeg quality
        img.save(jpg_file, format=FI_FORMAT.FIF_JPEG,
                 flags=CONSTANTS.JPEG_QUALITYNORMAL)
        self.assert_(os.path.getsize(jpg_file) < previous_size)
        # J2k Test
        img.save(j2k_file, format=FI_FORMAT.FIF_J2K)

    @owner("c.heimes")
    def test_toBuffer(self):
        for i in range(10):
            imgbuf = self.img.toBuffer()
        self.assertEqual(imgbuf.format, FI_FORMAT.FIF_JPEG)
        expected = 366202 if hasJPEGTurbo() else 366043
        self.assertEqual(imgbuf.size, expected)
        self.assertEqual(len(str(imgbuf)), expected)
        with Image(buffer=imgbuf) as newimg:
            self._test_jpeg(newimg)

    @owner("c.heimes")
    def test_toBuffer_file(self):
        #if sys.platform == 'win32':
        #    size = 366548
        size = 366202 if hasJPEGTurbo() else 366043

        imgbuf = self.img.toBuffer()
        self.assertEqual(imgbuf.format, FI_FORMAT.FIF_JPEG)
        self.assertEqual(imgbuf.tell(), 0)
        imgbuf.seek(0, 2)
        self.assertEqual(imgbuf.tell(), size)
        imgbuf.seek(0)

        self.assertEqual(imgbuf.tell(), 0)
        self.assertEqual(imgbuf.read(11), b'\xff\xd8\xff\xe0\x00\x10JFIF\x00')
        imgbuf.seek(0)

        self.assertEqual(len(imgbuf.read()), size)
        self.assertEqual(imgbuf.read(), b"")
        imgbuf.seek(0)

        self.assertEqual(len(imgbuf.read(size + 10)), size)

        imgbuf = self.img.toBuffer(format=fi.FIF_PNG)
        self.assertEqual(imgbuf.format, fi.FIF_PNG)
        self.assertEqual(imgbuf.read(4), b'\x89PNG')

    @owner("c.heimes")
    def test_toBuffer_PIL(self):
        try:
            from PIL.Image import open as pil_open
        except ImportError:
            return
        imgbuf = self.img.toBuffer()
        pilimg = pil_open(imgbuf)
        self.assertEqual(pilimg.format, 'JPEG')
        self.assertEqual(pilimg.size, self.img.size)
        del pilimg

        pilimg = self.img.toPIL(format=fi.FIF_PNG)
        self.assertEqual(pilimg.format, 'PNG')
        del pilimg

    @owner("c.heimes")
    def test_buffer_keepref(self):
        imgbuf1 = self.img.toBuffer()
        imgbuf2 = self.img.toBuffer()

        try:
            self.img.close()
        except OperationError:
            exc = sys.exc_info()[1]
            self.assertEqual(exc.args, ("Image is still access from 2 buffers.",))
        else:
            self.fail("An OperationError was expected")

        del imgbuf2
        try:
            self.img.close()
        except OperationError:
            exc = sys.exc_info()[1]
            self.assertEqual(exc.args, ("Image is still access from 1 buffer.",))
        else:
            self.fail("An OperationError was expected")

        del imgbuf1
        self.img.close()

    @owner("c.heimes")
    def test_convert(self):
        methods = ["greyscale", "convert_4bits", "convert_8bits",
                   "convert_16bits555", "convert_16bits565",
                   "convert_24bits", "convert_32bits",
                   "convert_rgbf"]
        img = self.img
        for methodname in methods:
            try:
                newimg = getattr(img, methodname)()
            finally:
                newimg.close()

    @owner("c.heimes")
    def test_new(self):
        img = Image.new(500, 500, 24)

        self.assertEqual(img.width, 500)
        self.assertEqual(img.height, 500)
        self.assertEqual(img.bpp, 24)

        #hmm, how to check this
        img.floodfill(0, 0, 0)

        #
        img.floodfill(0, 0, 0)
        cropped_img = self.img.crop(0, 0, 100, 100)
        img.paste(cropped_img, 0, 0)
        img.close()

        with Image.new(500, 500, 24) as img:
            self.assert_(isinstance(img, Image))
            self.assertEqual(img.size, (500, 500))
            self.failIf(img.closed)
        self.failUnless(img.closed)

    @owner("c.heimes")
    def test_rotation(self):
        #self.tmpdir = tempfile.mkdtemp()
        for i, img in enumerate((self.img, self.tiff, self.tiff2)):
            bpp = img.bpp
            size = img.size
            rsize = tuple(reversed(size))
            metadata = img.getMetadata()
            icc = img.getICC()
            #pprint(metadata)

            #basename = os.path.basename(img.filename)
            #prefix, ext = os.path.splitext(basename)
            #savename = os.path.join(self.tmpdir, "%s%%s%s" % (prefix, ext))

            # WARNING: although it may appear that all metadata are retained
            # in fact some metadata is lost since FreeImage is unable to
            # write some metadata sections for some formats.

            with img.rotate(180) as img180:
                self.assertEqual(img180.size, size)
                self.assertEqual(img180.bpp, bpp)
                self.assertEqual(img180.getMetadata(), metadata)
                self.assertEqual(img180.getICC(), icc)
                #img180.save(savename % "180")

            with img.rotate(90) as img90:
                self.assertEqual(img90.size, rsize)
                self.assertEqual(img90.bpp, bpp)
                self.assertEqual(img90.getMetadata(), metadata)
                self.assertEqual(img90.getICC(), icc)
                #img90.save(savename % "90")

            with img.rotate(270) as img270:
                self.assertEqual(img270.size, rsize)
                self.assertEqual(img270.bpp, bpp)
                self.assertEqual(img270.getMetadata(), metadata)
                self.assertEqual(img270.getICC(), icc)
                #img270.save(savename % "270")

            with img.flipHorizontal() as imgHor:
                self.assertEqual(imgHor.size, size)
                self.assertEqual(imgHor.bpp, bpp)
                self.assertEqual(imgHor.getMetadata(), metadata)
                self.assertEqual(imgHor.getICC(), icc)
                #imgHor.save(savename % "hor")

            with img.flipVertical() as imgVer:
                self.assertEqual(imgVer.size, size)
                self.assertEqual(imgVer.bpp, bpp)
                self.assertEqual(imgVer.getMetadata(), metadata)
                self.assertEqual(imgVer.getICC(), icc)
                #imgVer.save(savename % "vert")

            self.assertRaises(ValueError, img.rotate, 0)
            self.assertRaises(ValueError, img.rotate, 45)

    @owner("c.heimes")
    def test_rotate_ex(self):
        with self.img.rotateEx(30.0, 5, 5, 10, 10) as img:
            pass

    @owner("c.heimes")
    def test_jpegtransform(self):
        self.tmpdir = tempfile.mkdtemp()
        w, h = 0, 0
        #w, h = Image(IMG).size

        map = {"test90.jpg": (FI_JPEG_OPERATION.FIJPEG_OP_ROTATE_90, h, w),
               "test180.jpg": (FI_JPEG_OPERATION.FIJPEG_OP_ROTATE_180, h, w),
               "test270.jpg": (FI_JPEG_OPERATION.FIJPEG_OP_ROTATE_270, w, h),
               }
        for dst, (op, w, h) in map.items():
            fname = os.path.join(self.tmpdir, dst)
            jpegTransform(IMG, fname , op)
            self.assert_(os.path.isfile(fname))
            img = Image(fname)
            #self.assertEqual(img.size, (w, h))
            self.assertEqual(img.mimetype, "image/jpeg")

        self.assertRaises(OperationError, jpegTransform, IMG, fname, op, True)

        fname = os.path.join(self.tmpdir, "nonsense.spam")
        self.assertRaises(OperationError, jpegTransform, fname, fname,
                          FI_JPEG_OPERATION.FIJPEG_OP_ROTATE_90)

        try:
            jpegTransform("/bogus/filename", "/bogus/filename", 0)
        except OperationError:
            err = sys.exc_info()[1]
            expected = ("JPEG Transformation of '/bogus/filename' to "
                        "'/bogus/filename' with op '0' failed.",
                        "Invalid magic number")
            self.assertEqual(err.args, expected)
        else:
            self.fail("OperationError expected")

    @owner("c.heimes")
    def test_histogram(self):
        for channel in (fi.FICC_BLACK, fi.FICC_RED, fi.FICC_GREEN, fi.FICC_BLUE):
            hist = self.img.getHistogram(channel)
            self.assert_(isinstance(hist, list), hist)
            self.assertEqual(len(hist), 256)
            self.assert_(all(isinstance(i, int) for i in hist))

        self.assertRaises(ValueError, self.img.getHistogram, -23)

    @owner("c.heimes")
    def test_adjust(self):
        # TODO: simple test, add more tests
        self.img.adjustColors(10, 10, 2.0, 1)


class TestMetadata(TestImageBase):
    maxDiff = None

    def _check_metadata_img(self, img, **kw):
        meta = img.getMetadata()
        for k, v in kw.items():
            meta.setdefault(k, {}).update(v)
        self.assertEqual(meta, {})

        count = img.getMetadataCount()
        for k, v in kw.items():
            count.setdefault(k, 0) + len(v)
        self.assertEqual(count,
            {'FIMD_EXIF_MAIN': 0,
             'FIMD_EXIF_EXIF': 0,
             'FIMD_EXIF_INTEROP': 0,
             'FIMD_GEOTIFF': 0,
             'FIMD_COMMENTS': 0,
             'FIMD_IPTC': 0,
             'FIMD_XMP': 0,
             'FIMD_NODATA': 0,
             'FIMD_EXIF_MAKERNOTE': 0,
             'FIMD_ANIMATION': 0,
             'FIMD_CUSTOM': 0,
             'FIMD_EXIF_GPS': 0}
            )

    def _check_metadata_tiff(self, tiff, **kw):
        meta = tiff.getMetadata()
        for k, v in kw.items():
            for k2, v2 in v.items():
                if v2 is None:
                    meta[k].pop(k2, None)
                else:
                    meta[k][k2] = v2

        self.assertEqual(meta,
            {'FIMD_EXIF_MAIN':
                {'Software': ('ImageGear Version:  13.05.001', 'Software used'),
                 'InterColorProfile': ('', None),
                 'DateTime': ('2007:07:23 14:19:45', 'File change date and time'),
                 'Artist': ('Zeutschel Omniscan 11', 'Person who created the image'),
                 'BitsPerSample': ('8', 'Number of bits per component'),
                 'Compression': ('LZW (5)', 'Compression scheme'),
                 'FillOrder': ('1', None),
                 'ImageLength': ('1618', 'Image height'),
                 'ImageWidth': ('1136', 'Image width'),
                 'InterColorProfile': ('', None),
                 #'Orientation': ('top, left side', 'Orientation of image'),
                 'PhotometricInterpretation': ('2', 'Pixel composition'),
                 'PlanarConfiguration': ('1', 'Image data arrangement'),
                 'ResolutionUnit': ('inches', 'Unit of X and Y resolution'),
                 'RowsPerStrip': ('2', 'Number of rows per strip'),
                 'SamplesPerPixel': ('3', 'Number of components'),
                 'StripByteCounts': ('6697', 'Bytes per compressed strip'),
                 'StripOffsets': ('8', 'Image data location'),
                 'XResolution': ('300', 'Image resolution in width direction'),
                 'YResolution': ('300', 'Image resolution in height direction'),
                 }
            }
            )

        count = tiff.getMetadataCount()
        for k, v in kw.items():
            for k2, v2 in v.items():
                if v2 is None:
                    count[k] -= 1

        self.assertEqual(count,
            {'FIMD_EXIF_MAIN': 18,
             'FIMD_EXIF_EXIF': 0,
             'FIMD_EXIF_INTEROP': 0,
             'FIMD_GEOTIFF': 0,
             'FIMD_COMMENTS': 0,
             'FIMD_IPTC': 0,
             'FIMD_XMP': 0,
             'FIMD_NODATA': 0,
             'FIMD_EXIF_MAKERNOTE': 0,
             'FIMD_ANIMATION': 0,
             'FIMD_CUSTOM': 0,
             'FIMD_EXIF_GPS': 0 }
            )

    def _check_metadata_tiff2(self, tiff2, **kw):
        meta = tiff2.getMetadata()
        for k, v in kw.items():
            for k2, v2 in v.items():
                if v2 is None:
                    meta[k].pop(k2, None)
                else:
                    meta[k][k2] = v2

        self.assertEqual(meta,
            {'FIMD_EXIF_MAIN':
                {'Artist': ('ULB HALLE - MUB',
                            'Person who created the image'),
                 'BitsPerSample': ('8', 'Number of bits per component'),
                 'Compression': ('dump mode (1)', 'Compression scheme'),
                 'DateTime': ('2007:08:23 07:46:26',
                              'File change date and time'),
                 'DocumentName': ('1-000360E', None),
                 'FillOrder': ('1', None),
                 'ImageLength': ('2501', 'Image height'),
                 'ImageWidth': ('1972', 'Image width'),
                 'InterColorProfile': ('', None),
                 #'Orientation': ('top, left side', 'Orientation of image'),
                 'PageName': ('1-000360E_0003_T_8\\1-000360E_00004_T_14.tif',
                              'Name of the page'),
                 'PhotometricInterpretation': ('2', 'Pixel composition'),
                 'PlanarConfiguration': ('1', 'Image data arrangement'),
                 'ResolutionUnit': ('inches',
                                    'Unit of X and Y resolution'),
                 'RowsPerStrip': ('1', 'Number of rows per strip'),
                 'SamplesPerPixel': ('3', 'Number of components'),
                 'Software': ('MUB - Zeutschel OS 11.8, Scanner 2',
                              'Software used'),
                 'StripByteCounts': ('5916', 'Bytes per compressed strip'),
                 'StripOffsets': ('8', 'Image data location'),
                 'XResolution': ('300',
                                 'Image resolution in width direction'),
                 'YResolution': ('300',
                                 'Image resolution in height direction')
                 }}
            )

        count = tiff2.getMetadataCount()
        for k, v in kw.items():
            for k2, v2 in v.items():
                if v2 is None:
                    count[k] -= 1

        self.assertEqual(count,
            {'FIMD_EXIF_MAIN': 20,
             'FIMD_EXIF_EXIF': 0,
             'FIMD_EXIF_INTEROP': 0,
             'FIMD_GEOTIFF': 0,
             'FIMD_COMMENTS': 0,
             'FIMD_IPTC': 0,
             'FIMD_XMP': 0,
             'FIMD_NODATA': 0,
             'FIMD_EXIF_MAKERNOTE': 0,
             'FIMD_ANIMATION': 0,
             'FIMD_CUSTOM': 0,
             'FIMD_EXIF_GPS': 0}
            )

    @owner("c.heimes")
    def test_metadata(self):
        self._check_metadata_img(self.img)
        self._check_metadata_tiff(self.tiff)
        self._check_metadata_tiff2(self.tiff2)

    @owner("c.heimes")
    def test_metadata_write(self):
        # needs latest FreeImage patch
        self.tmpdir = tempfile.mkdtemp()
        for imgname in ("img", "tiff", "tiff2"):
            img = getattr(self, imgname)
            check = getattr(self, "_check_metadata_%s" % imgname)

            filename = os.path.join(self.tmpdir, os.path.basename(img.filename))
            if imgname == "tiff":
                flags = fi.TIFF_LZW
                update = {'FIMD_EXIF_MAIN':
                               # FreeImage adds an orientation field, ignore it
                              {'Orientation': None,
                               'StripByteCounts': ('6697', 'Bytes per compressed strip')
                          }}
            elif imgname == "tiff2":
                flags = fi.TIFF_NONE
                update = {'FIMD_EXIF_MAIN':
                              {'Orientation': None,
                          }}
            else:
                flags = 0
                update = {}
            img.save(filename, flags=flags)
            with Image(filename) as saved:
                check(saved, **update)

    @owner("c.heimes")
    def test_header(self):
        header = self.tiff.getInfoHeader()
        self.assertEqual(repr(header),
            '<BitmapInfo size=40, width=1136, height=1618, planes=1, bit_count=24, '
            'compression=0, size_image=0, xppm=11811, yppm=11811, colors_used=0, '
            'colors_important=0>')

    @owner("c.heimes")
    def test_icc(self):
        self.assertEqual(self.tiff.has_icc, True)
        icc = self.tiff.getICC()
        self.assert_(isinstance(icc, bytes))
        self.assertEqual(len(icc), 308804)
        self.tiff.removeICC()
        self.assertEqual(self.tiff.has_icc, False)
        icc2 = self.tiff.getICC()
        self.assertEqual(icc2, None)
        #self.tiff.setICC(icc)
        #self.assertEqual(self.tiff.has_icc, True)
        #icc3 = self.tiff.getICC()
        #self.assertEqual(icc3, icc)

    @owner("c.heimes")
    def test_copymetadata(self):
        clone = self.tiff.clone()
        count = clone.getMetadataCount()
        self.assertEqual(sum(count.itervalues()), 18, count)

        clone.clearMetadata()
        count = clone.getMetadataCount()
        self.assertEqual(sum(count.itervalues()), 0, count)

        clone.copyMetadataFrom(self.tiff)
        count = clone.getMetadataCount()
        self.assertEqual(sum(count.itervalues()), 18, count)

        # round trip doesn't work because libtiff can't write all EXIF data yet (as of 3.14.1)
        # check save/load roundtrip       
        #self.tmpdir = tempfile.mkdtemp()
        #fname = os.path.join(self.tmpdir, "clone.tiff")
        #clone.save(fname)

        #loaded = Image(fname)
        #count = loaded.getMetadataCount()
        #self.assertEqual(sum(count.itervalues()), 18)
        #self.assertEqual(self.tiff.getMetadata(), loaded.getMetadata())


def test_main():
    suite = unittest2.TestSuite()
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(TestImage))
    suite.addTest(unittest2.defaultTestLoader.loadTestsFromTestCase(TestMetadata))
    return suite

def test_memory():
    import psutil
    p = psutil.Process(os.getpid())
    print([(mem // 1024 ** 2) for mem in p.get_memory_info()])
    for i in range(50):
        TestMetadata("test_count").debug()
    print([(mem // 1024 ** 2) for mem in p.get_memory_info()])

if __name__ == "__main__": # pragma: no cover
    suite = unittest2.TestSuite()
    #suite.addTest(TestMetadata("test_icc"))
    #suite.addTest(TestImage("test_rotation"))
    #suite.addTest(TestImage("test_toBuffer_PIL"))
    #suite.addTest(TestMetadata("test_metadata"))
    suite = test_main()
    unittest2.TextTestRunner(verbosity=2).run(suite)
