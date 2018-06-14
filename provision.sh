#####################################################################
# This will install all packages in the file package-list
# TODO: This does not install efficiently (dependencies are re-installed)
# TODO: Should we include a window manager?
#####################################################################
if ! id | grep 'uid=0(root)'; then
    echo "##############################################################"
    echo ""
    echo "  You must run this as a super user"
    echo ""
    echo "##############################################################"
else
    for package in "$(cat package-list)"; do
        pacman -S --noconfirm "$package"
    done
fi
