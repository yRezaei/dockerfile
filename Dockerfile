FROM ubuntu:18.04
LABEL authors="Yashar A. Rezaei <yashar.a.rezaei@tarja.de>"
LABEL authors="Tarja GmbH"

#=============================================
# Disabling interactive keyboard configuration
#=============================================
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

#========================
# Miscellaneous packages
# Includes minimal runtime used for executing non GUI Java programs
#========================
RUN apt-get update \
    && apt-get -qqy upgrade \
    && apt-get -qqy --no-install-recommends install \
        apt-utils \
        gnupg \
        bzip2 \
        ca-certificates \
        tzdata \
        sudo \
        unzip \
        wget \
        curl \
        python3 python3-setuptools python3-pip \
        # Font family
        libfontconfig libfreetype6 xfonts-cyrillic xfonts-scalable fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei fonts-tlwg-loma-otf ttf-ubuntu-font-family \
        locales \
        # OpenGL packages
        mesa-utils mesa-utils-extra \
        # Daemon and utilities
        dbus dbus-x11 \
        # Clipboard & input utilities
        xsel xdotool \
        # X11 development libraries
        x11-common x11-xserver-utils x11-session-utils x11-xfs-utils x11-xkb-utils libx11-dev libxtst-dev libxmu-dev \
        # Supervisor app
        supervisor \
        # Java8 - OpenJDK JRE headless
        openjdk-8-jre-headless \
        # fluxbox A fast, lightweight and responsive window manager
        fluxbox \
        xfce4-notifyd \
        # Brpwsers
        firefox \
        # Xvfb X virtual framebuffer
        xvfb \
        xorg \
        # Browser video libraries
        gstreamer1.0-libav \
        # ffmpeg/libav/avconv video codecs & dependencies
        ffmpeg \
        libx264-dev \
        libvorbis-dev \
        libx11-dev \
        gpac \
        libgconf2-4 \
    && pip3 install wheel \
    && pip3 install selenium \
    && pip3 install pyvirtualdisplay \
    && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security


#=====================
#  Google chrome
#=====================
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get -y install google-chrome-stable \
    && ln -s /usr/bin/google-chrome /usr/bin/chrome

#==================
# Chrome webdriver
#==================
RUN wget -N http://chromedriver.storage.googleapis.com/2.40/chromedriver_linux64.zip -P ~/ \
    && unzip ~/chromedriver_linux64.zip -d ~/ \
    && rm ~/chromedriver_linux64.zip \
    && mv -f ~/chromedriver /usr/local/bin/chromedriver \
    && chown root:root /usr/local/bin/chromedriver \
    && chmod 0755 /usr/local/bin/chromedriver


#COPY /files/chrome-linux /tmp/chrome-linux
#RUN chown root /tmp/chrome-linux/chrome-sandbox \
#    && chmod 4755 /tmp/chrome-linux/chrome-sandbox \
#    && ln -s /tmp/chrome-linux/chrome-wrapper /usr/bin/chrome

#=========
# Firefox
#=========
#ARG FIREFOX_VERSION=latest
#RUN FIREFOX_DOWNLOAD_URL=$(if [ $FIREFOX_VERSION = "latest" ] || [ $FIREFOX_VERSION = "nightly-latest" ] || [ $FIREFOX_VERSION = "devedition-latest" ]; then echo "https://download.mozilla.org/?product=firefox-$FIREFOX_VERSION-ssl&os=linux64&lang=en-US"; else echo "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2"; fi) \
#    && apt-get update -qqy \
#    && apt-get -qqy --no-install-recommends install firefox \
#    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
#    && wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
#    && apt-get -y purge firefox \
#    && rm -rf /opt/firefox \
#    && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
 #   && rm /tmp/firefox.tar.bz2 \
 #   && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
 #   && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#============
# GeckoDriver
#============
#ARG GECKODRIVER_VERSION=latest
#RUN GK_VERSION=$(if [ ${GECKODRIVER_VERSION:-latest} = "latest" ]; then echo $(wget -qO- "https://api.github.com/repos/mozilla/geckodriver/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([0-9.]+)".*/\1/'); else echo $GECKODRIVER_VERSION; fi) \
#  && echo "Using GeckoDriver version: "$GK_VERSION \
#  && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
#  && rm -rf /opt/geckodriver \
#  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
#  && rm /tmp/geckodriver.tar.gz \
#  && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
#  && chmod 755 /opt/geckodriver-$GK_VERSION \
#  && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver

#======================================
#  Cleanup temporary and leftover files
#======================================
RUN apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==================
# Supervisor configuration
#==================
RUN mkdir -p /var/log/supervisor
COPY /files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Display variable
ENV DISPLAY :11

#========================================
# Add normal user with passwordless sudo
#========================================
#RUN useradd admin \
#         --shell /bin/bash  \
#         --create-home \
#    && usermod -a -G sudo admin \
#    && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
#    && echo 'admin:secret' | chpasswd

#==============================
# Locale and encoding settings
#==============================
#RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
#    locale-gen
#ENV LANG de_DE.UTF-8  
#ENV LANGUAGE de_DE:de  
#ENV LC_ALL de_DE.UTF-8

CMD ["/usr/bin/supervisord"]
