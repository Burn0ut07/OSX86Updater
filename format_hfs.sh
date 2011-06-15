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


disk=$1

if [[ "$(mount | egrep /Volumes/EFI)" = "" ]]; then
    newfs_hfs -v EFI ${disk}s1
fi

exit 0