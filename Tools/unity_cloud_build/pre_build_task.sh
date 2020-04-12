#!/bin/bash

sponge () (
    append=false

    while getopts 'a' opt; do
        case $opt in
            a) append=true ;;
            *) echo error; exit 1
        esac
    done
    shift "$(( OPTIND - 1 ))"

    outfile=$1

    tmpfile=$(mktemp "$(dirname "$outfile")/tmp-sponge.XXXXXXXX") &&
    cat >"$tmpfile" &&
    if "$append"; then
        cat "$tmpfile" >>"$outfile"
    else
        if [ -f "$outfile" ]; then
            chmod --reference="$outfile" "$tmpfile"
        fi
        if [ -f "$outfile" ]; then
            mv "$tmpfile" "$outfile"
        elif [ -n "$outfile" ] && [ ! -e "$outfile" ]; then
            cat "$tmpfile" >"$outfile"
        else
            cat "$tmpfile"
        fi
    fi &&
    rm -f "$tmpfile"
)

CDNVER=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest.txt?r=$RANDOM")

CDNWINHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standalonewindows64.txt?r=$RANDOM")
CDNOSXHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standaloneosxuniversal.txt?r=$RANDOM")
CDNLINHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standalonelinux64.txt?r=$RANDOM")

NEWHASH=$(git rev-parse --short HEAD)

# If another build with this hash completed and uploaded before this one, then it already updated latest.txt and we should not increment it.
if [ "$CDNWINHASH" = "$NEWHASH" ] || [ "$CDNOSXHASH" = "$NEWHASH" ] || [ "$CDNLINHASH" = "$NEWHASH" ]; then
    NEWVER=$CDNVER
else
    NEWVER=$(($CDNVER + 1))
fi

BUILDINFO_PATH="Assets/StreamingAssets/buildinfo.json"
CONFIG_PATH="Assets/StreamingAssets/config/config.json"

CDN_PATH_WIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneWindows64/%s.zip" $NEWVER)
CDN_PATH_LIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneLinux64/%s.zip" $NEWVER)
CDN_PATH_OSX=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneOSX/%s.zip" $NEWVER)

# Ensure the config and buildversion are properly set.
curl "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" --output jq

./jq --arg v "$NEWVER" '.BuildNumber = $v' $BUILDINFO_PATH | sponge $BUILDINFO_PATH
./jq --arg v "SentinelStationDev" '.ForkName = $v' $BUILDINFO_PATH | sponge $BUILDINFO_PATH
./jq --arg v "$CDN_PATH_WIN" '.WinDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH
./jq --arg v "$CDN_PATH_OSX" '.OSXDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH
./jq --arg v "$CDN_PATH_LIN" '.LinuxDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH

