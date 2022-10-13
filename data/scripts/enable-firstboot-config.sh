if [ -e /etc/cloud/cloud.cfg ]; then
        # not useful for cloud
        systemctl mask systemd-firstboot.service

        systemctl enable cloud-init-local
        systemctl enable cloud-init
        systemctl enable cloud-config
        systemctl enable cloud-final
else
        # Enable jeos-firstboot
        mkdir -p /var/lib/YaST2
        touch /var/lib/YaST2/reconfig_system

        systemctl mask systemd-firstboot.service
        systemctl enable jeos-firstboot.service
fi
