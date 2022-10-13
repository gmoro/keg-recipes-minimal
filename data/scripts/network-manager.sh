# Enable NetworkManager if installed
if rpm -q --whatprovides NetworkManager >/dev/null; then
        systemctl enable NetworkManager.service
fi
