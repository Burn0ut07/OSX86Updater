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

if [[ $type = "trunk" ]]; then
    rm -rf ~/DL_Chameleon/
    mkdir ~/DL_Chameleon
    cd ~/DL_Chameleon
    svn co http://forge.voodooprojects.org/svn/chameleon/trunk/ >> DL_Log.txt
else
    rm -rf ~/DL_Chameleon/
    mkdir ~/DL_Chameleon
    cd ~/DL_Chameleon
    svn co http://forge.voodooprojects.org/svn/chameleon/branches/meklort/ >> DL_Log.txt
fi

exit 0