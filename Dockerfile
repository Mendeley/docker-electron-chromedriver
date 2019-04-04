FROM node:8

ARG ELECTRON_CHROMEDRIVER_VERSION
ENV CHROMEDRIVER_PORT 9515
ENV CHROMEDRIVER_WHITELISTED_IPS ""
ENV SCREEN_WIDTH 1920
ENV SCREEN_HEIGHT 1080
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

USER root

RUN apt-get update -qqy

#=====
# VNC
#=====
RUN apt-get -qqy install \
  x11vnc

#=======
# Fonts
#=======
RUN apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable

#=========
# fluxbox
# A fast, lightweight and responsive window manager
#=========
RUN apt-get -qqy install \
    xvfb fluxbox

#=====
# Chromedriver dependencies
#=====
RUN apt-get -qqy install \
  libnss3-dev libgconf-2-4 fuse libgtk2.0-0 libgtk-3-0 libasound2

#=====
# Electron app's using node-keytar need libsecret installed.
# Note this won't make node-keytar actually work as don't have
# gnome-keyring installed, but it does allow the app to start
# successfully. The application has a fallback to keep secrets
# in memory if keytar not working.
#
# NOTE this does not effect real built apps! The app has a
# dependency that user's have gnome-keyring or similar installed.
#
# TODO figure out how to have gnome-keyring in test container,
# see https://github.com/atom/node-keytar/issues/132#issuecomment-444159414
# for inspiration, and node-keytars own build/test setup. The main
# problem encountered is that this image is based on a debian
# that doesn't have python-gnomekeyring in it's repos.
#=====
RUN apt-get -qqy install \
  libsecret-1-dev


RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

RUN npm install electron-chromedriver@$ELECTRON_CHROMEDRIVER_VERSION

#==============================
# Generating the VNC password as node
# So the service can be started with node
#==============================

RUN mkdir -p ~/.vnc \
  && x11vnc -storepasswd secret ~/.vnc/passwd

CMD ["/bin/bash", "/entrypoint.sh"]

EXPOSE 5900
EXPOSE 9515
