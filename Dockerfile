FROM debian:10
RUN apt-get update && apt-get -y install vsftpd whois db5.3-util && mkdir -p /etc/vsftpd/user_conf && mkdir -p /var/run/vsftpd/empty && ln -sf /proc/1/fd/1 /var/log/vsftpd.log
COPY add-virtual-user.sh /
COPY entry.sh /
COPY vsftpd.conf /etc
COPY vsftpd_ssl.conf /etc
COPY vsftpd_virtual /etc/pam.d
COPY openssl.cnf /etc/openssl/openssl.cnf
VOLUME /srv
EXPOSE 20 21 10090-10100
ENTRYPOINT ["/entry.sh"]
