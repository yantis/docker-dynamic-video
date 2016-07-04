############################################################
# Copyright (c) 2015 Jonathan Yantis
# Released under the MIT license
############################################################

# ├─yantis/archlinux-tiny
#    ├─yantis/archlinux-small
#       ├─yantis/archlinux-small-ssh-hpn
#          ├─yantis/ssh-hpn-x
#             ├─yantis/dynamic-video

FROM yantis/ssh-hpn-x
MAINTAINER Jonathan Yantis <yantis@yantis.net>

# Don't update
RUN pacman -Syy --noconfirm && \

    # Install common packages.
    pacman --noconfirm -S lib32-glibc lib32-zlib lib32-gcc-libs libxdamage libxxf86vm && \

    # Install the X-server and default to mesa both 32 and 64 bit
    pacman --noconfirm -S xorg-server mesa-libgl lib32-mesa-libgl && \

    # # Download from the AUR and cache the Nvidiia Beta drivers here
    # Nvidia beta drivers and Nvidia drivers are the same at this time

    # mkdir -p /root/nvidia/367/ && \
    # pacman --noconfirm -S binutils gcc autoconf make fakeroot && \

    # # Get the beta drivers from the AUR. We can not use yaourt since the ones in the repos are older.
    # # And yaourt defaults to the repos before using the AUR.

    # # nvidia-utils-beta && nvidia-libgl-beta
    # wget -P /tmp https://aur.archlinux.org/cgit/aur.git/snapshot/nvidia-utils-beta.tar.gz && \
    # tar -xvf /tmp/nvidia-utils-beta.tar.gz -C /tmp && \
    # chown -R docker:docker /tmp/nvidia-utils-beta && \
    # runuser -l docker -c "(cd /tmp/nvidia-utils-beta && makepkg -sc --noconfirm --pkg nvidia-utils-beta --pkg nvidia-libgl-beta)" && \
    # mv /tmp/nvidia-utils-beta/*.xz /root/nvidia/367/ && \

    # # lib32-nvidia-utils-beta && lib32-nvidia-libgl-beta
    # wget -P /tmp https://aur.archlinux.org/cgit/aur.git/snapshot/lib32-nvidia-utils-beta.tar.gz && \
    # tar -xvf /tmp/lib32-nvidia-utils-beta.tar.gz -C /tmp && \
    # chown -R docker:docker /tmp/lib32-nvidia-utils-beta && \
    # runuser -l docker -c "(cd /tmp/lib32-nvidia-utils-beta && makepkg -sc --noconfirm --pkg lib32-nvidia-utils-beta --pkg lib32-nvidia-libgl-beta)" && \
    # mv /tmp/lib32-nvidia-utils-beta/*.xz /root/nvidia/367/ && \

    # # Remove build dependencies.
    # pacman --noconfirm -Rs binutils gcc autoconf make fakeroot && \

    # Download and cache the Nvidia 304 drivers for run time.
    mkdir -p /root/nvidia/304/ && \
    pacman --noconfirm \
           -Sw \
           --cachedir /root/nvidia/304 \
           nvidia-304xx-libgl \
           nvidia-304xx-utils \
           lib32-nvidia-304xx-libgl \
           lib32-nvidia-304xx-utils && \

    # Download and cache the Nvidia 340 drivers for run time.
    mkdir -p /root/nvidia/340/ && \
    pacman --noconfirm \
           -Sw \
           --cachedir /root/nvidia/340 \
            nvidia-340xx-libgl \
            nvidia-340xx-utils \
            lib32-nvidia-340xx-libgl \
            lib32-nvidia-340xx-utils && \

    # Download and cache the Nvidia 367 drivers for run time.
    mkdir -p /root/nvidia/367/ && \
    pacman --noconfirm \
           -Sw \
           --cachedir /root/nvidia/367 \
           nvidia-libgl \
           nvidia-utils \
           lib32-nvidia-utils \
           lib32-nvidia-libgl && \

    #########################################################################
    # CLEAN UP SECTION - THIS GOES AT THE END                                #
    ##########################################################################

    # Clean up all the nvidia downloads and installs directories
    # rm -r /tmp/* && \

    localepurge && \

    # Remove man and docs
    rm -r /usr/share/man/* && \
    rm -r /usr/share/doc/* && \

    # Delete any backup files like /etc/pacman.d/gnupg/pubring.gpg~
    find /. -name "*~" -type f -delete && \

    bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    rm -r /var/lib/pacman/sync/*
    #########################################################################

ADD X /service/X
ADD initialize-graphics /usr/bin/initialize-graphics
CMD /init
