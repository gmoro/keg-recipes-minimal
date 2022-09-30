#!/bin/bash

# keg: included from common-sysconfig
baseUpdateSysConfig /etc/sysconfig/keyboard COMPOSETABLE "clear latin1.add"
baseUpdateSysConfig /etc/sysconfig/language INSTALLED_LANGUAGES ""
baseUpdateSysConfig /etc/sysconfig/language RC_LANG "C.UTF-8"
baseUpdateSysConfig /etc/sysconfig/security POLKIT_DEFAULT_PRIVS "restrictive"
baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM ""
baseUpdateSysConfig /etc/sysconfig/windowmanager INSTALL_DESKTOP_EXTENSIONS "no"

# keg: included from common-files
cat >> "/etc/profile" <<EOF
# yast in Public Cloud images fix
NCURSES_NO_UTF8_ACS=1
export NCURSES_NO_UTF8_ACS
EOF
cat >> "/etc/sysconfig/console" <<EOF
CONSOLE_ENCODING="UTF-8"
CONSOLE_FONT="lat9w-16.psfu"
CONSOLE_SCREENMAP="trivial"
EOF
cat >> "/etc/zypp/locks" <<EOF
type: package
match_type: glob
case_sensitive: on
solvable_name: plymouth*
EOF

# keg: included from common-config
# Start generate /etc/motd
#
source /etc/os-release

OS_PRETTY_NAME="$PRETTY_NAME"
OS_VERSION_MAJOR="${VERSION_ID%.*}"
ARCH="`uname -m`"

for suma_prod in /etc/products.d/SUSE-Manager-Server.prod /etc/products.d/SUSE-Manager-Proxy.prod
do
  if [[ -f $suma_prod ]]; then
     SUMA_VERSION=`sed -n -r -e '/<version>/s/( *<version>)([^<]*)(.*)/\2/p' $suma_prod`
     break
  fi
done

test -f etc/products.d/SLES_SAP.prod && OS_PRETTY_NAME="$OS_PRETTY_NAME for SAP Applications"

get_motd_includes()
{
    if [ -d /etc/motd.d ]; then
        for inc in `ls /etc/motd.d` ; do
            echo "r /etc/motd.d/${inc}"
        done
    fi
}

test -f /etc/motd-caption && cap_replace="r /etc/motd-caption"

motd_func="\
s/{OS_PRETTY_NAME}/$OS_PRETTY_NAME/g
s/{OS_VERSION_MAJOR}/$OS_VERSION_MAJOR/g
s/{ARCH}/$ARCH/g
s/{SUMA_VERSION}/$SUMA_VERSION/g
/{CAPTION}/{
$cap_replace
d
}
/{INCLUDES}/{
`get_motd_includes`
d
}"

for motd in /etc/motd* ; do
    test -f $motd || continue
    sed -i -e "$motd_func" $motd
done

test -d /etc/motd.d && rm -r /etc/motd.d
test -f /etc/motd-caption && rm /etc/motd-caption
#
# End generate /etc/motd

[ -x /sbin/set_polkit_default_privs ] && /sbin/set_polkit_default_privs

# Generation of the iscsi config file moved to %post of the package
# This implies that all instances have the same iscsi initiator name as the
# file is generated during image build. We do not want this (bsc#1202540)
rm -rf /etc/iscsi/initiatorname.iscsi

sed -i -e 's/^root:[^:]*:/root:*:/' /etc/shadow

prodfiles=(`grep -l '<codestream>' /etc/products.d/*prod`)
for p in $prodfiles ; do
  grep -q '<flavor>extension</flavor>' $p || prodfile="$prodfile $p"
done
if [[ ${#prodfile[*]} -ne 1 ]]; then
    echo "No base product package installed or base product ambiguous." >&2
    false
else
    ln -sf `basename "${prodfile[0]}"` /etc/products.d/baseproduct
fi

sed -i -e 's/# download.use_deltarpm = true/download.use_deltarpm = false/' \
    /etc/zypp/zypp.conf

sed -i -e 's/latest,latest-1,running/latest,running/' /etc/zypp/zypp.conf

# keg: included from common-services
baseInsertService boot.device-mapper
baseInsertService haveged
baseInsertService sshd
baseRemoveService boot.efivars
baseRemoveService boot.lvm
baseRemoveService boot.md
baseRemoveService boot.multipath
baseRemoveService display-manager
baseRemoveService kbd
