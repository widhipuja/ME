#!/bin/sh

if [ -d "/Library/DesktopCentral_Agent/" ]; then
    echo "DC Directory"
    pkgpath="/Library/DesktopCentral_Agent"
else
    echo "UEMS Directory"
    pkgpath="/Library/UEMS_Agent"
fi

echo "pkgpath: "$pkgpath

updateNewDetailsTo() {
    echo "Updating New values to $1 $2 $3"
    
    defaults write "$1" "$2" "$3"
}

fetchvalueFor() {
    defaults read "$dupServerInfo" $1
}

checkandUpdateRoAuthKey() {
    
    updateNewDetailsTo $serverInfo REMOTEOFFICEAUTHKEY $value2
    updateNewDetailsTo $dupServerInfo REMOTEOFFICEAUTHKEY $value2

    echo "Remote office Details updated successfully."

    # Set file permissions
    chmod 777 /Library/DesktopCentral_Agent/data/dupserverinfo.plist
    chmod 777 /Library/DesktopCentral_Agent/data/serverinfo.plist
}

serverInfo="$pkgpath/data/serverinfo.plist"
dupServerInfo="$pkgpath/data/dupserverinfo.plist"
echo "Existing server info : $serverInfo"
echo "Existing dup server info : $dupServerInfo"

value2=$(fetchvalueFor VALUE2)
RoAuthKey=$(fetchvalueFor REMOTEOFFICEAUTHKEY)

if [[ $value2 == $RoAuthKey ]]; then
    echo "Auth is proper, success. Exiting. "
    exit 0
else
    echo "mismatch in Auth key found. Fixing it"
fi
# check for dcconfig process to end and then proceed to update plist

killall kill dcconfig
killall kill dcondemand

checkandUpdateRoAuthKey

# invoke install status
cd "$pkgpath/bin"
./dcconfig ser statusupdate

exit 0
