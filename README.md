# sonyalpha-ftp
setup for serving ftp for sony alpha digital camera uploads

I make no claims to authorship of any of these pieces, I just made a dockerfile and
startup script to get vsftpd running with the correct parameters.

**Be aware that this is insecure due to being forced to use obsolete SSL configuration. It's probably safest to only use it on an internal network.**

This is all to allow sony mirrorless cameras to upload images via
ftp directly from the camera. The camera firmware has an outdated
ftp and ssl implementation neither of which can be fixed, so we have
to cope with it. 

The camera can only speak TLS 1.1, which is insecure and is disabled
in modern linux distros, so we install debian 10 but then replace
/etc/openssl/openssl.cnf with one in which TLS 1.1 is permitted. 
Then the vsftpd config file will be able to forbid TSLv1.2 and force
1.1. 

To build: 

`docker build -t sonyftp-deb10 .`

It needs a working directory for uploads to end up in and for ssl certs, etc.
I'm using `/dstate/sonyftp` in the `start-vsftpd.sh` script here. 

The working directory needs to contain a directory `srv` which needs to 
contain a subdir named "ftp" or else 
logins from the camera fail with no errors logged. The directory 
never gets used, but it has to be there. Also note that while you can put
SSL certs in there are have vsftpd use them, as far as I can tell the camera
will never actually accept them and you'll have to click through the
warning about that when you first enable ftp mode on the camera. So they may
as well be self-signed, and even if you upload self-signed certs' CA cert
to the camera, it won't use it and you'll still have to click through the warning.

The camera wants to use passive ftp mode and for that the ftp server
needs to know the IP address clients will connect back to it on,
which is hidden from it in docker; so you have to tell it 
explicitly with `FTP_PASV_ADDRESS='my.public.ip.address'`. 

For the same reason, you need to allow inbound tcp connections on the
full range of inbound pasv ftp ports, which is just awesome.  Note that
these rules need to be on the FORWARD chain, because the packets are
traversing NAT, being inbound on a real world IP and ending up on
docker on 172.17.whatever. 

```
iptables -A block -p tcp -o docker0  --dport 21 -j ACCEPT  # sony ftp
iptables -A block -p tcp -o docker0 --destination-port 10090:10100 -j ACCEPT
```

vsftp is gross and can only log to a file, which defaults to 
/var/log/vsftpd.log.  If you try to tell it to write to /dev/stdout instead 
it fails, either because it's stupid or because it's chrooting to some 
random empty directory that doesn't have dev/stdout in it? But you can do
this awful thing in the Dockerfile and then it does work:

`ln -sf /proc/1/fd/1 /var/log/vsftpd.log`

To do stuff automatically with the uploaded files, you can install `inoticoming` and run this:

```
inoticoming --logfile /var/log/inoticoming.log /dstate/sonyftp/srv \
    --stdout-to-log /dstate/sonyftp/incoming-camftp.sh {} \;
```

which will watch the incoming ftp dir for new files, and call 
incoming-camftp.sh on them, which can do whatever you want.

Once you have the working directory, certs, and iptables rules in place,
you can edit `start-vsftpd.sh` to configure the pathnames, FTP password, etc,
and run it to launch the container, after which hopefully the camera will be
willing to upload to it. 
