#!/bin/bash
## Bundle set up the USB drive and copy contents

function installme {
  echo "Installing to USB Drive..."
  diskutil quiet rename /Volumes/NO\ NAME Tropo
  cp -R /tmp/tropo/* /Volumes/Tropo
  diskutil eject /Volumes/Tropo
  read -p "Do you have another drive inserted you would like to install to? (y/n):"
  [ "$REPLY" != "y" ] || installme 
}

echo "Checking for updates..."
./bundle.sh quiet
mkdir /tmp/tropo
tar -zxf ../tropo-usb.tar.gz -C /tmp/tropo
installme
rm -rf /tmp/tropo