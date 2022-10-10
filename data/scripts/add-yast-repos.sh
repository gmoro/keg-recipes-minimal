#======================================
# Add repos from control.xml
#--------------------------------------
if [ -x /usr/sbin/add-yast-repos ]; then
    add-yast-repos
    zypper --non-interactive rm -u live-add-yast-repos
fi
