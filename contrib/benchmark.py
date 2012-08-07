from smc.freeimage import Image, hasJPEGTurbo, getVersion
from smc.freeimage.enums import FI_FILTER
from PIL.Image import open as pil_open, VERSION as PIL_VERSION, ANTIALIAS, BICUBIC, BILINEAR, NEAREST
from smc.freeimage.tests.common import IMG, BITON, TIFF

from time import time
import sys

try:
    from scipy.misc.pilutil import fromimage, imread, bytescale
    from numpy import asarray
except ImportError:
    print("No numpy and scipy")

RW_COUNT = 300
RESIZE_COUNT = 50

print "Python %i.%i.%i" % sys.version_info[:3]
print "read / write cycles: %i" % RW_COUNT
print "resize cycles: %i" % RESIZE_COUNT
print "JPEG: %r" % Image(IMG)
print "TIFF LZW: %r" % Image(TIFF)
print "TIFF bitonal G4: %r" % Image(BITON)
print ""

if hasJPEGTurbo():
    print "smc.freeimage, FreeImage %s with jpeg turbo" % getVersion()
else:
    print "smc.freeimage, FreeImage %s standard" % getVersion()


#--- FreeImage load
start = time()
for i in xrange(RW_COUNT):
    Image(IMG)
end = time() - start
print " - read JPEG %0.3f sec" % end

# load resaved
# http://www.libjpeg-turbo.org/About/Performance Restart Markers
Image(IMG).save("pon_rewrite_fi.jpg")
start = time()
for i in xrange(RW_COUNT):
    Image("pon_rewrite_fi.jpg")
end = time() - start
print " - read JPEG %0.3f sec (resaved)" % end

# save
img = Image(IMG)
start = time()
for i in xrange(RW_COUNT):
    img.save("testfi.jpg")
end = time() - start
print " - write JPEG %0.3f sec" % end

# TIFF read
start = time()
for i in xrange(RW_COUNT):
    Image(TIFF)
end = time() - start
print " - read LZW TIFF %0.3f sec" % end

start = time()
for i in xrange(RW_COUNT):
    Image(BITON)
end = time() - start
print " - read biton G4 TIFF %0.3f sec" % end

# resize
width = img.width // 2
height = img.height // 2
filters = (("box", FI_FILTER.FILTER_BOX),
           ("bilinear", FI_FILTER.FILTER_BILINEAR),
           ("bspline", FI_FILTER.FILTER_BSPLINE),
           ("bicubic", FI_FILTER.FILTER_BICUBIC),
           ("catmull rom spline", FI_FILTER.FILTER_CATMULLROM),
           ("lanczos3", FI_FILTER.FILTER_LANCZOS3))
for name, flt in filters:
    start = time()
    for i in xrange(RESIZE_COUNT):
        img.resize(width, height, flt)
    end = time() - start
    print " - resize %0.3f sec (%s)" % (end, name)

# numpy
tiff = Image(TIFF)
start = time()
for i in xrange(RW_COUNT):
    arr = asarray(tiff)
    # change last BGR -> RGB
    arr = arr[..., ::-1]
    bytescale(arr, 64, 192)
end = time() - start
print " - tiff numpy.asarray() with bytescale() %0.3f sec" % end

start = time()
for i in xrange(RW_COUNT):
    tiff = Image(TIFF)
    arr = asarray(tiff)
    arr = arr[..., ::-1]
    bytescale(arr, 64, 192)
end = time() - start
print " - tiff load + numpy.asarray() with bytescale() %0.3f sec" % end

# -------------------------------------------------------------------
# PIL load
print "PIL %s" % PIL_VERSION
start = time()
for i in xrange(RW_COUNT):
    pil_open(IMG).load()
end = time() - start
print " - read JPEG %0.3f sec" % end

# load resaved
pil_open(IMG).save("pon_rewrite_pil.jpg")
start = time()
for i in xrange(RW_COUNT):
    pil_open("pon_rewrite_pil.jpg").load()
end = time() - start
print " - read JPEG %0.3f sec (resaved)" % end

# write
img = pil_open(IMG)
img.load()
start = time()
for i in xrange(RW_COUNT):
    img.save("testpil.jpg")
end = time() - start
print " - write JPEG %0.3f sec" % end

# TIFF read
start = time()
for i in xrange(RW_COUNT):
    pil_open(TIFF).load()
end = time() - start
print " - read LZW TIFF %0.3f sec" % end

print " - read biton G4 TIFF: decoder group4 not available"

# resize
filters = (("nearest", NEAREST), ("bilinear", BILINEAR),
           ("bicubic", BICUBIC), ("antialias", ANTIALIAS))
for name, flt in filters:
    start = time()
    for i in xrange(RESIZE_COUNT):
        img.resize((width, height), flt)
    end = time() - start
    print " - resize %0.3f sec (%s)" % (end, name)

# scipy
tiff = pil_open(TIFF)
tiff.load()
start = time()
for i in xrange(RW_COUNT):
    arr = asarray(tiff)
    bytescale(arr, 64, 192)
end = time() - start
print " - tiff numpy.asarray() with bytescale() %0.3f sec" % end

start = time()
for i in xrange(RW_COUNT):
    arr = imread(TIFF)
    bytescale(arr, 64, 192)
end = time() - start
print " - tiff scipy imread() with bytescale() %0.3f sec" % end
