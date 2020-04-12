#!/bin/bash

# Preping deploy logic
CDNVER=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest.txt?r=$RANDOM")
CDNHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash.txt?r=$RANDOM")
CDNTARGETHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_$TARGET.txt?r=$RANDOM")

NEWHASH=$(git rev-parse --short HEAD)

CDNWINHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standalonewindows64.txt?r=$RANDOM")
CDNOSXHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standaloneosxuniversal.txt?r=$RANDOM")
CDNLINHASH=$(curl -s "https://SentinelStationFiles.b-cdn.net/latest_hash_standalonelinux64.txt?r=$RANDOM")

# If another build with this hash completed and uploaded before this one, then it already updated latest.txt and we should not increment it.
if [ "$CDNWINHASH" = "$NEWHASH" ] || [ "$CDNOSXHASH" = "$NEWHASH" ] || [ "$CDNLINHASH" = "$NEWHASH" ]; then
    NEWVER=$CDNVER
else
    NEWVER=$(($CDNVER + 1))
fi

CDN_PATH_WIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneWindows64/%s.zip" $NEWVER)
CDN_PATH_LIN=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneLinux64/%s.zip" $NEWVER)
CDN_PATH_OSX=$(printf "https://SentinelStationFiles.b-cdn.net/SentinelStationDev/StandaloneOSX/%s.zip" $NEWVER)

if [ "$CDNTARGETHASH" = "$NEWHASH" ]; then
    echo "$NEWHASH - $TARGET already in CDN. No need to upload."
    exit 0
fi

if [ $TARGET = "standalonewindows64" ]; then
    UPLOAD_FOLDER="SentinelStationDev/StandaloneWindows64"
    BUILD_FOLDER="$WORKSPACE/.build/last/windows-64-bit/"
elif [ $TARGET = "standaloneosxuniversal" ]; then
    UPLOAD_FOLDER="SentinelStationDev/StandaloneOSX"
    BUILD_FOLDER="$WORKSPACE/.build/last/mac-universal/"
elif [ $TARGET = "standalonelinux64" ]; then
    UPLOAD_FOLDER="SentinelStationDev/StandaloneLinux64/"
    BUILD_FOLDER="$WORKSPACE/.build/last/linux-64-bit/"
else
    echo "TARGET invalid. Exiting."
    exit 1
fi

cd $BUILD_FOLDER
echo "$(ls)"

echo "$NEWVER" > ./latest.txt
echo "$NEWHASH" > ./latest_hash_${TARGET}.txt
echo "$NEWHASH" > ./latest_hash.txt

#ftp -invp <<EOF
#open $CDN_HOST
#user $CDN_USERNAME $CDN_PASSWORD
#binary
#put "./Sentinelstation.zip" "${UPLOAD_FOLDER}/${NEWVER}.zip"
#rm "latest_hash_${TARGET}.txt"
#put "./latest_hash_${TARGET}.txt" "latest_hash_${TARGET}.txt"
#rm "latest_hash.txt" "latest_hash.txt"
#put "./latest_hash.txt" "latest_hash.txt"
#rm "latest.txt"
#put "./latest.txt" "latest.txt"
#bye
#EOF

zip -qq -r Build.zip .

curl -s -T ./Build.zip -u "$CDN_USERNAME:$CDN_PASSWORD" "ftp://$CDN_HOST:21/${UPLOAD_FOLDER}/${NEWVER}.zip"
curl -s "ftp://$CDN_HOST:21/latest_hash_${TARGET}.txt" -u "$CDN_USERNAME:$CDN_PASSWORD" -Q "rm /latest_hash_${TARGET}.txt"
curl -s -T ./latest_hash_${TARGET}.txt -u "$CDN_USERNAME:$CDN_PASSWORD" "ftp://$CDN_HOST:21/latest_hash_${TARGET}.txt"
curl -s "ftp://$CDN_HOST:21/latest_hash.txt" -u "$CDN_USERNAME:$CDN_PASSWORD" -Q "rm /latest_hash.txt"
curl -s -T ./latest_hash.txt -u "$CDN_USERNAME:$CDN_PASSWORD" "ftp://$CDN_HOST:21/latest_hash.txt" 
curl -s "ftp://$CDN_HOST:21/latest.txt" -u "$CDN_USERNAME:$CDN_PASSWORD" -Q "rm /latest.txt"
curl -s -T ./latest.txt -u "$CDN_USERNAME:$CDN_PASSWORD" "ftp://$CDN_HOST:21/latest.txt"

rm ./Build.zip