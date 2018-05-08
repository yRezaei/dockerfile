FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y upgrade
RUN apt-get install -y \
      x11-utils xdg-utils xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable dbus-x11 \
      xvfb xsel gtk2-engines-pixbuf imagemagick x11-apps x11-common x11-xserver-utils x11-session-utils x11-xfs-utils x11-xkb-utils \
      libx11-dev libxtst-dev locales supervisor firefox \
      && mkdir -p /var/log/supervisor
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
### Installing configuration packages ###
RUN apt-get install -yq libtool pkg-config autoconf automake \
    ### Installing programming packages ###
    cmake vim git unzip libkrb5-dev
    ### Installing ZMQ library (Networking) ref: https://github.com/zeromq/libzmq/blob/master/Dockerfile ###
RUN cd /tmp && git clone git://github.com/jedisct1/libsodium.git && cd libsodium && git checkout e2a30a && ./autogen.sh && ./configure && make check && make install && ldconfig
RUN cd /tmp && git clone --depth 1 git://github.com/zeromq/libzmq.git && cd libzmq && ./autogen.sh && ./configure && make
RUN cd /tmp/libzmq && make install && ldconfig

# locales to UTF-8
RUN locale-gen de_DE.UTF-8 && /usr/sbin/update-locale LANG=de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8

# Display variable
ENV DISPLAY 1

CMD ["/usr/bin/supervisord"]
