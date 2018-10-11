#!/usr/bin/env bash

# KVM INSTALLATION SCRIPT FOR Debian, Ubuntu, LinuxMint

distributor=`lsb_release -i -s`
version=`lsb_release -r -s`
codename=`lsb_release -c -s`
user=$SUDO_USER

echo "------------------------"
echo "Distributor ID: "$distributor
echo "Version: "$version
echo "Codename: "$codename
echo "USER: "$user
echo -e "------------------------\n"

if [ `egrep -c '(vmx|svm)' /proc/cpuinfo` -eq 0 ]; then
  echo -e "CPU doesn't support hardware virtualization.\n"
  exit 1
else
  echo -e "Please make sure that virtualization is enabled in the BIOS.\n"
fi

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if [ $distributor = "Debian" ]; then
  case "$codename" in
  "stretch")
    echo "Installing KVM for $codename"
    apt install -y -f qemu-kvm libvirt-clients libvirt-daemon-system
    adduser $user libvirt
    adduser $user libvirt-qemu
    ;;
  "jessie")
    echo "Installing KVM for $codename"
    apt-get -y -f install qemu-kvm libvirt-bin
    adduser $user kvm
    adduser $user libvirt
    ;;
  *)
    echo "Bad or unsupported codename: $codename";
    exit 1
    ;;
  esac
elif [ $distributor = "Ubuntu" ]; then
  KARMIC=9.10
  LUCID=10.04
  # After this, you need to relogin so that your user becomes an effective member of the libvirtd group.

  if version_gt $version $LUCID; then
    echo "Installing KVM for later version of Ubuntu "$LUCID
    apt-get install -y -f qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
     # Add users to group
    adduser $user libvirtd
  elif version_gt $KARMIC $version; then
    echo "Installing KVM for ealier version of Ubuntu "$KARMIC
    aptitude install -y -f kvm libvirt-bin ubuntu-vm-builder bridge-utils
    adduser $user kvm
    adduser $user libvirtd
  fi

  # You can test if your install has been successful with the following command:
  virsh list --all
elif [ $distributor = "LinuxMint" ]; then
  apt-get install -y -f qemu-kvm libvirt-bin bridge-utils

  # Log out and log back in as the user to make the group membership change effective.
  adduser $user libvirt
fi

