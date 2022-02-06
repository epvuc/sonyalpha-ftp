# sonyalpha-ftp
setup for serving ftp for sony alpha digital camera uploads

I make no claims to authorship of any of these pieces, I just made a dockerfile and
startup script to get vsftpd running with the correct parameters.

This is all to allow sony mirrorless cameras to upload images via
ftp directly from the camera. The camera firmware has an outdated
ftp and ssl implementation neither of which can be fixed, so we have
to cope with it. 

The camera can only speak TLS 1.1, which is insecure and is disabled
in modern linux distros, so we install debian 10 but then replace
/etc/openssl/openssl.cnf with one in which TLS 1.1 is permitted. 
Then the vsftpd config file will be able to forbid TSLv1.2 and force
1.1. 

To build and run: 

cd build; docker build -t sonyftp-deb10 .
cd ..; sh start-sonyftp.sh

the "srv" directory needs to contain a subdir named "ftp" or else 
logins from the camera fail with no errors logged. The directory 
never gets used, but it has to be there. 

The camera wants to use passive ftp mode and for that the ftp server
needs to know the IP address clients will connect back to it on,
which is hidden from it in docker; so you have to tell it 
explicitly with FTP_PASV_ADDRESS='65.50.203.9'. 

For the same reason, you need to allow inbound tcp connections on the
full range of inbound pasv ftp ports, which is awesome.  Note that
these rules need to be on the FORWARD chain, because the packets are
traversing NAT, being inbound on a real world IP and ending up on
docker on 172.17.whatever. 

iptables -A block -p tcp -o docker0  --dport 21 -j ACCEPT  # sony ftp
iptables -A block -p tcp -o docker0 --destination-port 10090:10100 -j ACCEPT

vsftp is gross and can only log to a file, which defaults to 
/var/log/vsftpd.log.  If you try to tell it to write to /dev/stdout instead 
it fails, either because it's stupid or because it's chrooting to some 
random empty directory that doesn't have dev/stdout in it? But you can do
this awful thing in the Dockerfile and then it does work:

ln -sf /proc/1/fd/1 /var/log/vsftpd.log

the compose file doesn't work, not sure why, so start it manually with 
start-vsftpd.sh

To do stuff automatically with the uploaded files, you can run this:

inoticoming --logfile /var/log/inoticoming.log /dstate/sonyftp/srv \
    --stdout-to-log /dstate/sonyftp/incoming-camftp.sh {} \;

which will watch the incoming ftp dir for new files, and call 
incoming-camftp.sh on them, which will then upload them to nextcloud 
in an organized way. 

