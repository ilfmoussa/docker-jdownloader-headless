#!/bin/bash

# Get latest version of JDownloader.jar
JD="https://installer.jdownloader.org/JDownloader.jar"
NEW="/tmp/JDownloader.jar"
OLD="/opt/JDownloader/JDownloader.jar"

curl --output ${NEW} ${JD}

if [[ $(md5sum ${NEW} ${OLD} | awk '{print $1}' | uniq | wc -l) == 1 ]]
then
    echo "No update on JDownloader.jar"
else
    echo "There is a new JDownloader.jar"
    cp ${NEW} ${OLD}
fi

if [ ! -f ${OLD} ];
then
	echo "No jdownloader by default copy by default"
	cp ${NEW} ${OLD}
fi
# Launching JDownloader
$(which java) -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar /opt/JDownloader/JDownloader.jar -norestart
exit 1
