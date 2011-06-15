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
# Copyright © 2011 Joel Jauregui and Wei-Chen Ling.
#

type=$1
disk=$2

rdisk="${disk:0:5}r${disk:5}"


if [[ $type = "trunk" ]]; then
    if [ -f ~/DL_Chameleon/trunk/sym/i386/boot0hfs ]; then
        # use boot0hfs
        fdisk -f ~/DL_Chameleon/trunk/sym/i386/boot0hfs -u -y ${rdisk}
    else
        # use boot0
        fdisk -f ~/DL_Chameleon/trunk/sym/i386/boot0 -u -y ${rdisk}
    fi
    dd if=~/DL_Chameleon/trunk/sym/i386/boot1h of=${rdisk}s1
else
    if [ -f ~/DL_Chameleon/meklort/sym/i386/boot0hfs ]; then
        # use boot0hfs
        fdisk -f ~/DL_Chameleon/meklort/sym/i386/boot0hfs -u -y ${rdisk}
    else
        # use boot0
        fdisk -f ~/DL_Chameleon/meklort/sym/i386/boot0 -u -y ${rdisk}
    fi
    dd if=~/DL_Chameleon/meklort/sym/i386/boot1h of=${rdisk}s1
fi


if [[ "$(mount | egrep /Volumes/EFI)" = "" ]]; then
    mkdir /Volumes/EFI
    mount_hfs ${disk}s1 /Volumes/EFI

    if [ -d /Volumes/EFI/Extra ]; then
        chmod -R 777 /Volumes/EFI/Extra/Extensions
        chmod -R 777 /Volumes/EFI/Extra/
    else
        mkdir /Volumes/EFI/Extra
        chmod -R 777 /Volumes/EFI/Extra/
    fi
    
    if [[ $type = "trunk" ]]; then
        cp -f ~/DL_Chameleon/trunk/sym/i386/boot /Volumes/EFI
        rm -rf /Volumes/EFI/Extra/modules/
        cp -Rf ~/DL_Chameleon/trunk/sym/i386/modules /Volumes/EFI/Extra
    else
        cp -f ~/DL_Chameleon/meklort/sym/i386/boot /Volumes/EFI
        rm -rf /Volumes/EFI/Extra/modules/
        cp -Rf ~/DL_Chameleon/meklort/sym/i386/modules /Volumes/EFI/Extra
    fi

    chmod -R 777 /Volumes/EFI/Extra
    open /Volumes/EFI
fi

exit 0