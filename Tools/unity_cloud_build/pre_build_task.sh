#!/bin/bash

CDNVER=$(wget -qO- "https://SentinelStationFiles.b-cdn.net/latest.txt?r=$RANDOM")
NEWVER=$(($CDNVER + 1))

BUILDINFO_PATH="Assets/StreamingAssets/buildinfo.json"
CONFIG_PATH="Assets/StreamingAssets/config/config.json"

CDN_PATH_WIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneWindows64/%s.zip" $NEWVER)
CDN_PATH_LIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneLinux64/%s.zip" $NEWVER)
CDN_PATH_OSX=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneOSX/%s.zip" $NEWVER)

# Ensure the config and buildversion are properly set.
sudo apt-get install moreutils
jq --arg v "$NEWVER" '.BuildNumber = $v' $BUILDINFO_PATH | sponge $BUILDINFO_PATH
jq --arg v "SentinelStationDev" '.ForkName = $v' $BUILDINFO_PATH | sponge $BUILDINFO_PATH
jq --arg v "$CDN_PATH_WIN" '.WinDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH
jq --arg v "$CDN_PATH_OSX" '.OSXDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH
jq --arg v "$CDN_PATH_LIN" '.LinuxDownload = $v' $CONFIG_PATH | sponge $CONFIG_PATH

