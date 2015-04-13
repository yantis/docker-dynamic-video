############################################################
# Copyright (c) 2015 Jonathan Yantis
# Released under the MIT license
############################################################

# FROM yantis/archlinux-tiny
# FROM yantis/archlinux-small
# FROM yantis/archlinux-small-ssh-hpn
# FROM yantis/ssh-hpn-x
# YOU ARE HERE

FROM yantis/ssh-hpn-x
MAINTAINER Jonathan Yantis <yantis@yantis.net>

# Update and force a refresh of all package lists even if they appear up to date.
RUN pacman -Syyu --noconfirm && \

    # Install common packages.
    pacman --noconfirm -S lib32-glibc lib32-zlib lib32-gcc-libs libxdamage libxxf86vm && \

    # Install the X-server and default to mesa both 32 and 64 bit
    pacman --noconfirm -S xorg-server mesa-libgl lib32-mesa-libgl && \

    # Download from the AUR and cache the Nvidiia Beta drivers here
    mkdir -p /root/nvidia/349/ && \
    pacman --noconfirm -S binutils gcc autoconf make fakeroot yaourt && \
    runuser -l docker -c "yaourt --noconfirm \
            -Sw \
            --cachedir /root/nvidia/349 \
            nvidia-libgl-beta \
            nvidia-utils-beta \
            lib32-nvidia-libgl-beta \
            lib32-nvidia-utils-beta" && \
    pacman --noconfirm -Rs binutils gcc autoconf make fakeroot yaourt && \

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

    # Download and cache the Nvidia 346 drivers for run time.
    mkdir -p /root/nvidia/346/ && \
    pacman --noconfirm \
           -Sw \
           --cachedir /root/nvidia/346 \
           nvidia-libgl \
           nvidia-utils \
           lib32-nvidia-utils \
           lib32-nvidia-libgl && \

    ##########################################################################
    # CLEAN UP SECTION - THIS GOES AT THE END                                #
    ##########################################################################
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
CMD /init
