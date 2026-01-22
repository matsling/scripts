#!/bin/bash

#    This script updates the Duo Auth proxy (https://duo.com/docs/authproxy-reference)
#    to the latest version on debian distros.
#    Copyright (C) <2026>  <matsling>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Variables
workingdir="/root/"

# Print commands as they execute
set -x

# Change working directory to /root/ if not already
cd $workingdir

# Remove any old versions of duoauthproxy in the home root directory to avoid conflicts
rm -rf *duoauthproxy*

# Get the current version number
currentversion=$(/opt/duoauthproxy/bin/authproxyctl version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sed 's/\.//g')

# Get the latest version of DUOproxy, this is assumed to be run as root from the /root/ directory
wget "https://dl.duosecurity.com/duoauthproxy-latest-src.tgz"

# Extract the latest version
tar xvf "$workingdir/duoauthproxy-latest-src.tgz"

# Store the extracted directory name
newversiondir=$(ls | grep duoauthproxy*src)

# Get the version number from the directory name
newversion=$(echo $newversiondir | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sed 's/\.//g')

# Check if the new version is higher than the current version
if [[ $newversion -eq $currentversion || $newversion -lt $currentversion ]]; then
    # if the update is equal or below the current version, exit
    echo "No update available"
    exit 1
else
    # If the new version is higher than the current version, upgrade

    # Shutdown the running duoauthproxy
    systemctl stop duoauthproxy.service

    # Install dependencies
    apt install build-essential libssl-dev libffi-dev -y

    # Change the working directory to the extracted directory
    cd $workingdir/$newversiondir

    # Build files from source
    make

    # Change the working directory to the build directory
    cd $workingdir/$newversiondir/duoauthproxy-build

    # Install with silent switches
    sudo ./install --install-dir /opt/duoauthproxy --service-user duo_authproxy_svc --log-group duo_authproxy_grp --create-init-script yes

    # Reload Daemons
    systemctl daemon-reload

    # Start the new version
    systemctl start duoauthproxy.service

    echo "Upgrade Complete!"
    exit 0
fi