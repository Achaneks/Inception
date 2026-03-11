FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Create the directory vsftpd requires for its secure chroot jail
# Without this vsftpd crashes immediately with "500 OOPS"
RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup_ftp.sh /setup_ftp.sh
RUN chmod +x /setup_ftp.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/setup_ftp.sh"]