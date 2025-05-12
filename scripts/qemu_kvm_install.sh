pacman -S edk2-ovmf qemu-full qemu-block-gluster qemu-block-iscsi samba qemu-user-static qemu-guest-agent libvirt dnsmasq openbsd-netcat virt-manager bridge-utils swtpm --needed

sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

