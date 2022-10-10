#======================================
# If SELinux is installed, configure it like transactional-update setup-selinux
#--------------------------------------
if [[ -e /etc/selinux/config ]]; then
    # Check if we don't have selinux already enabled.
    grep ^GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub | grep -q security=selinux || \
        sed -i -e 's|\(^GRUB_CMDLINE_LINUX_DEFAULT=.*\)"|\1 security=selinux selinux=1"|g' "/etc/default/grub"

    # Adjust selinux config
# FIXME temporary set ALP on permissive mode
#   sed -i -e 's|^SELINUX=.*|SELINUX=enforcing|g' \
#       -e 's|^SELINUXTYPE=.*|SELINUXTYPE=targeted|g' \
#       "/etc/selinux/config"
    sed -i -e 's|^SELINUX=.*|SELINUX=permissive|g' \
        -e 's|^SELINUXTYPE=.*|SELINUXTYPE=targeted|g' \
        "/etc/selinux/config"

    # Move an /.autorelabel file from initial installation to writeable location
    test -f /.autorelabel && mv /.autorelabel /etc/selinux/.autorelabel
fi
