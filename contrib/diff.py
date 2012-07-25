# calculate difference of PIL and FreeImage images with numpy
# PIL's and FreeImage's JPEG decoder yield slightly different values

from smc.freeimage import Image
from PIL.Image import open as pil_open
from smc.freeimage.tests.common import IMG, TIFF

import numpy
from scipy.misc.pilutil import toimage

def difference(img, dest):
    fiarr = numpy.asarray(Image(img))
    fiarr = fiarr[..., ::-1]

    pilarr = numpy.asarray(pil_open(img))

    fiarr = fiarr.astype(numpy.int16)
    pilarr = pilarr.astype(numpy.int16)
    diff = numpy.absolute(fiarr - pilarr)

    toimage(diff).convert("L").save(dest)

difference(IMG, "diff_jpeg.png")
difference(TIFF, "diff_tiff.png")
