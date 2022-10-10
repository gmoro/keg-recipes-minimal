#======================================
# This is a workaround - someone,
# somewhere needs to load the xts crypto
# module, otherwise luksOpen will fail while
# creating the image.
#--------------------------------------
modprobe xts || true
