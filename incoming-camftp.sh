#! /bin/bash
#
# This is just an example of something you can do with a directory-watcher to take
# images the camera sends and upload them to a webdav server. 
# 
exit 0
#
USER=MyWebdavUsername
PW=MyWebdavPassword
NOW=`/bin/date +%Y-%m-%d`
NAME=$1
PATH=/dstate/sonyftp/srv

echo upload.sh $*
if [ \! -r "$PATH/$NAME" ]; then
  echo "$PATH/$NAME" does not exist
  exit 1
fi

if [ ${NAME: -4} == ".ARW" ]; then
    /usr/bin/curl -s -u "$USER":"$PW" -T "$PATH/$NAME" "https://MyNextcloudServer/remote.php/dav/files/$USER/import/$NAME"
    echo "`/bin/date +"%Y-%m-%d %H:%M:%S"` $PATH/$NAME -> https://MyNextcloudServer/remote.php/dav/files/$USER/import/$NAME" >> /var/log/sonyupload.log
fi

if [ ${NAME: -4} == ".JPG" ]; then
# mkdir sure the directory exists
#    /usr/bin/curl -s -u "$USER":"$PW" -X MKCOL "https://MyNextcloudServer/remote.php/dav/files/$USER/import/$NOW"  2>&1 > /dev/null 
# upload the file to nextcloud
#     /usr/bin/curl -s -u "$USER":"$PW" -T "$PATH/$NAME" "https://MyNextcloudServer/remote.php/dav/files/$USER/import/$NOW/$NAME"
    /usr/bin/curl -s -u "$USER":"$PW" -T "$PATH/$NAME" "https://MyNextcloudServer/remote.php/dav/files/$USER/export/camftp/$NAME"
    echo "`/bin/date +"%Y-%m-%d %H:%M:%S"` $PATH/$NAME -> https://MyNextcloudServer/remote.php/dav/files/$USER/export/camftp/$NAME" >> /var/log/sonyupload.log
fi
