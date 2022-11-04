#(1)  * Preparing the Poller
FROM perl:latest AS perl

#(2)  *  Bare Necessities
RUN apt-get  -y update && apt-get install --no-install-recommends -y wget nano git build-essential yasm fuse pkg-config && rm -rf /var/lib/apt/lists/*
#(3)  * Compile and install ffmpeg from source
## * Take some time to get some Gamer Supps
RUN git clone https://github.com/FFmpeg/FFmpeg /root/ffmpeg                           && \
    cd /root/ffmpeg                                                                   && \
    ./configure --enable-nonfree --disable-shared --extra-cflags=-I/usr/local/include && \
    make -j8 && make install -j8;
ARG CACHEBREAK=1
##* Mount the Google Storage Bucket *#############
#(4) * Download gcsfuse to mount the Storage Bucket #
RUN curl -L -O https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v0.41.7/gcsfuse_0.41.7_amd64.deb
#(5) * Install gcsfuse using dpkg
RUN dpkg --install gcsfuse_0.41.7_amd64.deb 
##* Install yt-dlp
ENV BUILD_VERSION 2022.10.04
#(6) * Install release version $BUILD_VERSION of yt-dlp
RUN apt-get install -y --no-install-recommends ca-certificates curl python3 && \ 
  rm -rf /var/lib/apt/lists/*                       && \
  curl -Lo /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/download/${BUILD_VERSION}/yt-dlp && \
  chmod a+rx /usr/local/bin/yt-dlp                  && \ 
  ln -s /usr/bin/python3 /usr/bin/python            && \
  mkdir /downloads                                  && \
  chmod a+rw /downloads                             && \
  mkdir /.cache                                     && \
  chmod 777 /.cache                                 && \
  mkdir modules;
#(7) * Root tasks complete, make new user and grant it ownership of perl modules
RUN  useradd -m gamedazed && perl -e 'print qx{chown -R gamedazed: $_/} foreach (@INC)'
USER gamedazed
#(8) * Get WWW::Twitch and Parallel::ForkManager and dependencies, try hard, try really hard
# we have ownership of Perl Modules dirs, but not system libraries, so local and self-contained
# makes sense here - the flip to notest over cpan is basically lazy redundancy =w=;
RUN  cpanm -f -n    --self-contained      WWW::Twitch Parallel::ForkManager && \
    cpan notest install                   WWW::Twitch Parallel::ForkManager
#(9) * Login to Twitch from Firefox, stage the cookies in your build directory, skip ads
COPY cookies.sqlite                       /home/gamedazed/cookies.sqlite
#(10)* This is going to be your Service Account Credential File for the Google Cloud Project 
# that Storage is managed under. # NOTE: If this is ever considered for wider distribution
# I should consider changing this to an environment variable since it won't be the same twice
COPY revod-364904-c9d09a09225b.json       /home/gamedazed/revod-364904-c9d09a09225b.json
#(11)* This is our script. It runs the show.
COPY pogbot.pl                            /home/gamedazed/pogbot.pl
#(12)* This is our utility module. The script won't run without it, but it could. Mostly 
# there for logging and output.
COPY modules/PeePoo.pm                    /home/gamedazed/modules/PeePoo.pm

#(13)* Start off in user home, starting off on shell for sanity checks
WORKDIR                                   /home/gamedazed/
ENTRYPOINT [ "/bin/bash"]
#CMD  [ "perl", "/home/gamedazed/pogbot.pl" ]

