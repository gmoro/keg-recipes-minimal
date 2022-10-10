#=====================================
# Configure /etc overlay if needed
#-------------------------------------

if [ -x /usr/sbin/setup-fstab-for-overlayfs ]; then 
    # The %post script can't edit /etc/fstab sys due to https://github.com/OSInside/kiwi/issues/945
    # so use the kiwi custom hack
    cat >/etc/fstab.script <<"EOF"
#!/bin/sh
set -eux

/usr/sbin/setup-fstab-for-overlayfs
# If /var is on a different partition than /...
if [ "$(findmnt -snT / -o SOURCE)" != "$(findmnt -snT /var -o SOURCE)" ]; then
    # ... set options for autoexpanding /var
    gawk -i inplace '$2 == "/var" { $4 = $4",x-growpart.grow,x-systemd.growfs" } { print $0 }' /etc/fstab
fi
EOF
    # ONIE additions
    if [[ "$kiwi_profiles" == *"onie"* ]]; then
        systemctl enable onie-adjust-boottype
        # For testing:
        echo root:linux | chpasswd
        systemctl enable salt-minion

    cat >>/etc/fstab.script <<"EOF"
# Grow the root filesystem. / is mounted read-only, so use /var instead.
gawk -i inplace '$2 == "/var" { $4 = $4",x-growpart.grow,x-systemd.growfs" } { print $0 }' /etc/fstab
# Remove the entry for the EFI partition
gawk -i inplace '$2 != "/boot/efi"' /etc/fstab
EOF
    fi

    chmod a+x /etc/fstab.script

    # To make x-systemd.growfs work from inside the initrd
    cat >/etc/dracut.conf.d/50-microos-growfs.conf <<"EOF"
install_items+=" /usr/lib/systemd/systemd-growfs "
force_drivers+=" xts dm-crypt "
EOF

    # Use the btrfs storage driver. This is usually detected in %post, but with kiwi
    # that happens outside of the final FS.
    if [ -e /etc/containers/storage.conf ]; then
        sed -i 's/driver = "overlay"/driver = "btrfs"/g' /etc/containers/storage.conf
    fi

    # Adjust zypp conf (no needed on transactional system)
    sed -i 's/^multiversion =.*/multiversion =/g' /etc/zypp/zypp.conf
fi

# Enable firewalld if installed
if [ -x /usr/sbin/firewalld ]; then
        systemctl enable firewalld.service
    # punch firewall to allow cockpit ws access
    firewall-offline-cmd --add-service cockpit
fi
