# interlock-dev 2017-01-25 21:09:31 -0500
FROM phusion/baseimage:0.9.18
MAINTAINER Unknown

# Exposed Ports
EXPOSE 4430

# Copy files into the image

# SHA256: 954275920718877adcbfa737dd1a3b88ba6ff06570a58aa161d085003d21e7e9
COPY entry.sh entry.sh

# Set working directory
WORKDIR /home/interlock

# Run commands
RUN `# Creating user / Adjusting user permissions`               &&            \
     (groupadd -g 1000 interlock || true)                        &&            \
     ((useradd -u 1000 -g 1000 -p interlock -m interlock) ||                   \
      (usermod -u 1000 interlock && groupmod -g 1000 interlock)) &&            \
     mkdir -p /home/interlock                                    &&            \
     chown -R interlock:interlock /home/interlock /opt           &&            \
                                                                               \
    `# Updating Package List`                                    &&            \
     DEBIAN_FRONTEND=noninteractive apt-get update               &&            \
                                                                               \
    `# Installing packages`                                      &&            \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     bc                                                                        \
     build-essential                                                           \
     ca-certificates                                                           \
     cpio                                                                      \
     cryptsetup                                                                \
     file                                                                      \
     git                                                                       \
     golang                                                                    \
     less                                                                      \
     lvm2                                                                      \
     python                                                                    \
     rsync                                                                     \
     sudo                                                                      \
     unzip                                                                     \
     vim                                                                       \
     wget                                                                      \
                                                                               \
    `# Cleaning up after installation`                           &&            \
     DEBIAN_FRONTEND=noninteractive apt-get clean                &&            \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*               &&            \
                                                                               \
    `# Fixing permission errors for volume`                      &&            \
     mkdir -p /interlock                                         &&            \
     chown -R interlock:interlock /interlock                     &&            \
     chmod -R 700 /interlock                                     &&            \
                                                                               \
    `# Fixing permission errors for volume`                      &&            \
     mkdir -p /usbarmory                                         &&            \
     chown -R interlock:interlock /usbarmory                     &&            \
     chmod -R 700 /usbarmory                                     &&            \
                                                                               \
    `# Fixing permission errors for volume`                      &&            \
     mkdir -p /buildroot                                         &&            \
     chown -R interlock:interlock /buildroot                     &&            \
     chmod -R 700 /buildroot                                     &&            \
                                                                               \
    `# Fixing permission errors for volume`                      &&            \
     mkdir -p /luks                                              &&            \
     chown -R interlock:interlock /luks                          &&            \
     chmod -R 700 /luks

# Set up external volumes
VOLUME interlock
VOLUME usbarmory
VOLUME buildroot
VOLUME luks

# Copy source dockerfiles into the image
COPY Dockerfile.yml /Dockerfile.yml
COPY Dockerfile     /Dockerfile

# Enter the container
CMD ["/sbin/my_init", "--quiet", "--", "setuser", "interlock", "/entry.sh"]
