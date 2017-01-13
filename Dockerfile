FROM debian:jessie

# Set up a development image
RUN echo deb http://httpredir.debian.org/debian testing main contrib non-free > /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends build-essential ca-certificates

# Buildroot Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends wget cpio python unzip rsync bc locales-all file

# Interlock Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends git golang

# Test Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends lvm2 cryptsetup sudo

# User Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends less vim

COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]

