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

	rm -rf /.EFI
	cp -r /Volumes/EFI /.EFI

	open /Volumes/EFI
else
	chmod -R 777 /Extra/Extensions
	chmod -R 777 /Extra/

	rm -rf /.Extra
	cp -r /Extra /.Extra

	open /Extra
fi

exit 0