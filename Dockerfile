FROM ubuntu:18.04

# Installing the latest updates
RUN apt-get update && apt-get -y upgrade

# Installing the necessary packages
RUN apt-get install -y \
      x11-utils xdg-utils xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable dbus-x11 xvfb xsel \
      gtk2-engines-pixbuf imagemagick x11-apps x11-common x11-xserver-utils x11-session-utils x11-xfs-utils x11-xkb-utils \
      libx11-dev libxtst-dev libxmu-dev libkrb5-dev libzmq5 locales libtool pkg-config autoconf automake cmake vim git unzip \
      xdotool firefox

# Installing supervisor app
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY /files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set keyboard layout
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG de_DE.UTF-8  
ENV LANGUAGE de_DE:de  
ENV LC_ALL de_DE.UTF-8

# Display variable
ENV DISPLAY 11

CMD ["/usr/bin/supervisord"]
