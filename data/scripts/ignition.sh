#======================================
# Add default kernel boot options
#--------------------------------------
serialconsole='console=ttyS0,115200'
[[ "$kiwi_profiles" == *"RaspberryPi2" ]] && serialconsole='console=ttyAMA0,115200'
[[ "$kiwi_profiles" == *"Rock64" ]] && serialconsole='console=ttyS2,1500000'
[[ "$kiwi_profiles" == *"MS-HyperV"* ]] && serialconsole="rootdelay=300 $serialconsole earlyprintk=ttyS0,115200"
[[ "${kiwi_btrfs_root_is_readonly_snapshot-false}" != 'true' ]] && mount_root_rw='rw'

grub_cmdline=("${mount_root_rw}" 'quiet' 'systemd.show_status=yes' "${serialconsole}" 'console=tty0')
rpm -q wicked && grub_cmdline+=('net.ifnames=0')

# setup ignition if installed
if rpm -q ignition >/dev/null; then
  ignition_platform='metal'
  case "${kiwi_profiles}" in
    *kvm*) ignition_platform='qemu' ;;
    *DigitalOcean*) ignition_platform='digitalocean' ;;
    *VMware*) ignition_platform='vmware' ;;
    *OpenStack*) ignition_platform='openstack' ;;
    *VirtualBox*) ignition_platform='virtualbox' ;;
    *HyperV*) ignition_platform='metal'
              grub_cmdline+=('rootdelay=300') ;;
    *Pine64*|*RaspberryPi*|*Rock64*|*Vagrant*|*onie*|*SelfInstall*) ignition_platform='metal' ;;
    *) echo "Unhandled profile?"
       exit 1
       ;;
  esac

  # One '\' for sed, one '\' for grub2-mkconfig
  grub_cmdline+=('\\$ignition_firstboot' "ignition.platform.id=${ignition_platform}")
fi

sed -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.*\$#GRUB_CMDLINE_LINUX_DEFAULT=\"${grub_cmdline[*]}\"#" /etc/default/grub
