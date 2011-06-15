#!/bin/bash

#
# This file is part of OSX86Updater.
#
# OSX86Updater is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OSX86Updater is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OSX86Updater.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright © 2010 Joel Jauregui
#

type=$1
disk=$2

if [[ $type = "EFI" ]]; then
	if [[ "$(mount | egrep /Volumes/EFI)" = "" ]]; then
		mkdir /Volumes/EFI
		mount_hfs ${disk}s1 /Volumes/EFI
        chmod -R 777 /Volumes/EFI/Extra/Extensions
        chmod -R 777 /Volumes/EFI/Extra/
	fi

	chmod -R 755 /Volumes/EFI/Extra/Extensions
	chown -R root:wheel /Volumes/EFI/Extra/Extensions
	rm /Volumes/EFI/Extra/Extensions.mkext
	kextcache -m /Volumes/EFI/Extra/Extensions.mkext /Volumes/EFI/Extra/Extensions
	chmod -R 755 /Volumes/EFI/Extra
	chown -R root:wheel /Volumes/EFI/Extra
	umount -f /Volumes/EFI
	rm -rf /Volumes/EFI
elif [[ $type = "Extra" ]]; then
    chmod -R 755 /Extra/Extensions
    chown -R root:wheel /Extra/Extensions

    rm /Extra/Extensions.mkext
    kextcache -m /Extra/Extensions.mkext /Extra/Extensions
    chmod -R 755 /Extra
    chown -R root:wheel /Extra
else
	kextcache -system-mkext
fi

exit 0