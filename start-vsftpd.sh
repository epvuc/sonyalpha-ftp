#! /bin/sh -x
mkdir -p /dstate/sonyftp/srv/ftp
docker run --restart=always --name sonyftp -d \
-e FTP_USER=camera -e FTP_PASSWORD='MyPassword' -e FTP_PASV_ADDRESS='256.256.256.256' \
-v /dstate/sonyftp/vsftpd.crt:/etc/ssl/certs/vsftpd.crt:ro \
-v /dstate/sonyftp/vsftpd.key:/etc/ssl/private/vsftpd.key:ro \
-v /dstate/sonyftp/srv:/srv:rw \
--log-driver=syslog --log-opt syslog-facility=user --log-opt tag="vsftpd" \
-p 21:21 -p 10090-10100:10090-10100 \
	sonyftp-deb10 vsftpd /etc/vsftpd_ssl.conf
