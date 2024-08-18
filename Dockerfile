FROM alpine:3.20

# Install Samba and necessary utilities
RUN apk add --no-cache samba samba-common-tools

# Define build-time arguments
ARG SAMBA_USER
ARG SAMBA_PASSWORD

# Create and configure Samba user
RUN adduser -D -H -s /sbin/nologin ${SAMBA_USER} && \
    echo "${SAMBA_USER}:${SAMBA_PASSWORD}" | chpasswd && \
    (echo "${SAMBA_PASSWORD}"; echo "${SAMBA_PASSWORD}") | smbpasswd -s -a ${SAMBA_USER}

# Copy Samba configuration file
COPY smb.conf /etc/samba/smb.conf

# Set up the media directory and permissions
RUN mkdir -p /mnt/mydisk/media && \
    chown -R ${SAMBA_USER}:${SAMBA_USER} /mnt/mydisk/media

# Expose Samba ports
EXPOSE 139 445

# Start Samba service in the foreground
CMD ["smbd", "--foreground", "--no-process-group"]