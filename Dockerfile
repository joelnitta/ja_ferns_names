FROM rocker/geospatial:4.1.1

ARG DEBIAN_FRONTEND=noninteractive

############################
# Install APT packages

# gawk for taxon-tools
# libxml2 for roxyglobals
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libxml2-dev \
    gawk \
    unar \
  && apt-get clean

#############################
# Other custom software

ENV APPS_HOME=/apps
RUN mkdir $APPS_HOME
WORKDIR $APPS_HOME

### taxon-tools ###
WORKDIR $APPS_HOME
ENV APP_NAME=taxon-tools
RUN git clone https://github.com/camwebb/$APP_NAME.git && \
	cd $APP_NAME && \
  git checkout 8f8b5e2611b6fdef1998b7878e93e60a9bc7c130 && \
	make check && \
	make install

### gnparser ###
WORKDIR $APPS_HOME
ENV APP_NAME=gnparser
ENV VERSION=1.4.0
ENV DEST=$APPS_HOME/$APP_NAME/$VERSION
RUN wget https://github.com/gnames/gnparser/releases/download/v$VERSION/gnparser-v$VERSION-linux.tar.gz \
  && tar xf $APP_NAME-v$VERSION-linux.tar.gz \
  && rm $APP_NAME-v$VERSION-linux.tar.gz \
  && mv "$APP_NAME" /usr/local/bin/

WORKDIR /home/rstudio/
