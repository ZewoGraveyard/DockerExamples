FROM ubuntu:14.04

ENV SWIFT_VERSION 2.2-SNAPSHOT-2015-12-31-a
ENV SWIFT_PLATFORM ubuntu14.04

# Install related packages
RUN apt-get update && \
    apt-get install -y build-essential wget libssl-dev clang libedit-dev python2.7 python2.7-dev libicu52 rsync git libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install Swift Ubuntu 14.04 Snapshot
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget $SWIFT_URL && \
    wget $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*

    # Set Swift Path
    ENV PATH /usr/bin:$PATH

WORKDIR /tmp

RUN git clone https://github.com/Zewo/libvenice.git && cd libvenice && \
    make && \
    make package && \
    dpkg -i libvenice.deb

RUN git clone https://github.com/Zewo/http_parser.git && cd http_parser && \
    make && \
    make package && \
    dpkg -i http_parser.deb

RUN git clone https://github.com/Zewo/uri_parser.git && cd uri_parser && \
    make && \
    make package && \
    dpkg -i uri_parser.deb

RUN mkdir -p /var/app
WORKDIR /var/app/

RUN git clone https://github.com/Zewo/Examples.git

WORKDIR /var/app/Examples

RUN swift build

EXPOSE 8080

CMD .build/debug/Todo
