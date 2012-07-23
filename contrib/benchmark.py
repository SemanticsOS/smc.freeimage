from smc.freeimage import Image, hasJPEGTurbo, getVersion
from PIL.Image import open as pil_open, VERSION as PIL_VERSION
from smc.freeimage.tests.common import IMG
from time import time
import sys
import os

COUNT = 300

print "Python %i.%i.%i" % sys.version_info[:3]
print "read / write cycles: %i" % COUNT
print repr(Image(IMG))
print ""

if hasJPEGTurbo():
    print "smc.freeimage, FreeImage %s with jpeg turbo" % getVersion()
else:
    print "smc.freeimage, FreeImage %s standard" % getVersion()

start = time()
for i in xrange(COUNT):
    Image(IMG)
end = time() - start
print " - read %0.3f sec" % end

# http://www.libjpeg-turbo.org/About/Performance Restart Markers
Image(IMG).save("pon_rewrite_fi.jpg")
start = time()
for i in xrange(COUNT):
    Image("pon_rewrite_fi.jpg")
end = time() - start
print " - read %0.3f sec (w/o restart markers)" % end

img = Image(IMG)
start = time()
for i in xrange(COUNT):
    img.save("testfi.jpg")
end = time() - start
print " - write %0.3f sec" %  end

print "PIL %s" % PIL_VERSION
start = time()
for i in xrange(COUNT):
    pil_open(IMG).load()
end = time() - start
print " - read %0.3f sec" % end

pil_open(IMG).save("pon_rewrite_pil.jpg")
start = time()
for i in xrange(COUNT):
    pil_open("pon_rewrite_pil.jpg").load()
end = time() - start
print " - read %0.3f sec (resaved)" % end

img = pil_open(IMG)
img.load()
start = time()
for i in xrange(COUNT): 
    img.save("testpil.jpg")
end = time() - start
print " - write %0.3f sec" % end


