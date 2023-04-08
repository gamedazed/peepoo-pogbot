#(1)  #* Preparing the Poller
FROM docker:latest as docker

#(2)  *  Bare Necessities
RUN apk update && \
  apk add --no-cache openssl openssl-dev dos2unix util-linux keyutils libnfsidmap libtirpc nfs-utils libnfs rpcbind wget vim git coreutils bash grep yasm fuse iptables pkgconf make cmake gcc libgcc libc-dev
#(3)  #* Compile and install ffmpeg from source
## Take some time to get some Gamer Supps
RUN git clone https://github.com/FFmpeg/FFmpeg /root/ffmpeg
RUN cd /root/ffmpeg && \
  ./configure --enable-openssl --enable-nonfree --disable-shared --extra-cflags=-I/usr/local/include && \
  make -j8 && make install -j8;
ARG CACHEBREAK=1
##* Mount the Google Storage Bucket *#############
#(4) #* Download gcsfuse to mount the Google Cloud Storage Bucket
#RUN curl -L -O https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v0.41.7/gcsfuse_0.41.7_amd64.deb
#(5) #* Install gcsfuse using dpkg
#RUN dpkg --install gcsfuse_0.41.7_amd64.deb 

## Install yt-dlp
ENV BUILD_VERSION 2022.10.04

# mount fuse bucket
RUN gcloud auth login

#(6) #* Install release version $BUILD_VERSION of yt-dlp
RUN apk add --update ca-certificates curl python3 perl perl-utils perl-app-cpanminus apkbuild-cpan perl-cpanel-json-xs perl-test-cpan-meta perl-cpan-meta-check perl-inc-latest perl-template-toolkit perl-module-build perl-test-leaktrace && \
  rm -rf /var/cache/apk/*                           && \
  curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/yt-dlp && \
  chmod a+rx /usr/local/bin/yt-dlp                      && \ 
  mkdir /nas                                            && \
  chmod a+rw /nas                                       && \
  mkdir /downloads                                      && \
  chmod a+rw /downloads                                 && \
  mkdir /.cache                                         && \
  chmod 777 /.cache                                     && \
  rpcbind -s                                            && \
  mkdir ~root/modules

ENV SKIP_IPTABLES 1
RUN cpanm WWW::Twitch Parallel::ForkManager

#(9) #* Login to Twitch from Firefox, stage the cookies in your build directory, skip ads
COPY cookies.sqlite                       /root/cookies.sqlite
COPY Dockerfile.stream                    /root/Dockerfile.stream
#(10) #* This is going to be your Service Account Credential File for the Google Cloud Project 
# that Storage is managed under. # NOTE: If this is ever considered for wider distribution
# I should consider changing this to an environment variable since it won't be the same twice
COPY revod-364904-c9d09a09225b.json       /root/revod-364904-c9d09a09225b.json

#(11) #* This is our script. It runs the show.
COPY pogbot.pl                            /root/pogbot.pl

#(12) #* This is our utility module. The script won't run without it. Mostly there for logging and output.
COPY modules/PeePoo.pm                    /root/modules/PeePoo.pm

WORKDIR                                   /root/
########################################################################################################
RUN chmod +x pogbot.pl
CMD  [ "./pogbot.pl" ]
