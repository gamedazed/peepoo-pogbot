#! /usr/bin/perl

use strict;
use warnings;

###################################################################################################
#####################################  Written by gamedazed   #####################################
#                                   ...^~77?JJ?7?YYYYYJYYJJ?~^::..                                    
#                          .::~7J5PBB###&&&&&&&&&&&&&&&&&&&&&#####BGPY?!^:.                           
#                  ..^~7YPB##&&######BBBBBBBGBBBBBBBBBBB###BBB####&&&&&&&&#BPY?!^.                    
#             :~?5B#&&&&&&#####BBBBGGPP5PPPPP5PPPGGGGGGGGGPPGGGGGGGGBBB##&&&&&&&&#BP?~.               
#         .~YG#&&&&&&##BBGGBBBBBGP55YY5555YYYYYY55PPP555P55PPPPPPPPPPGGGGBBB###&&&&&&&&#GJ~.          
#      .:7PB#&&####BBBBBBBBBBGY7~^^:^~7JYYYYYY55YY5555555555555JJJY5GBBBBGGGGGBBBBBB##&&&&&#GJ^       
#    :?PBB###BBBGGGGGGGP5YYJ!.       .~YPPGGGGGGPPGGGGGPP5Y7!^.    ..^?PB#BBBBGGGGGGBBBBGGBB###5!.    
#  :?GBB###BG5YYJJJJJJJJJJJJJ?7!~~!?YPB#&#################BPJ~..   ....^7Y5PPGGGGGGBBGGP5555GB#&#5^   
# 5BBBBB#BG5J7~^:^!?Y55PGGGGGGGGGB#&&&#BGPYYJJJJY55PBB###&###BGPYJ??JY5PGGGGPPPPPPPGGGGGP5J?JYPB#&B7  
# BBGGBBBGPY?~::^?PGBBBB########&&#BPJ~:.        ...:!YPGBB###BBBBBBBBBB####BBBBBBBBBGGP5YJ??JY5PB&#5:
# BBGGGPGBPJ!^::7PB##########&&&#BGPY^               .!JYPGB#####BBBB################BGPY?~~~!7?YPB#&G
# #BBG5PBB57~::^JPBB#######&&&&#BGP5Y?^            .:!JY5PGBBB##############&&&&&&&##BG5J!^:^^~!7J5B&#
# GGGGPGBBP?~:.~YPGGBBBBBGGB&&#BBGP5Y?!:.        ..:~7JY5PGGBBB##&&&&#################BGPY7^^^~~!7JP#B
# 75BBGBBBP?^:^7Y555PPGBGPYJJ5PGBGGPY?~^:.       .:^!?YPPGBB###&&##BP5PGB##&&&#######BBGGP5J~~~~!!7YGG
# .7PGBBBPY!^:^!??JJYPGBGG5Y7~:.....^:...           ..:^!!?JYYJ!^:...~?5B###########BBBGGPP5!~!!7?JY5P
#  :75PPYJ77!!777?JY5PGGGGPPPY?^.   .^:^:....     ...^^~~:!7:.   .:!YPGB######BBBBBBBBBBBGGPJ!!!7?Y5GG
#   ..:~J5P55YJJJJYY5555PPPPP55Y?~.. ^7~^::::. ...::^!??^:.  .:~JPGB######BBBBBBBGBBBB####BBP!..:~7Y5P
#     .~YGBBGP55YY55555555555555P57:^7!~^^^^^:.:::^^~7Y7 ..^7YPBBB######BBBBBBBBBBBBB######5!.     .. 
#      .^?5GBBGGPPPP55555555555YYPP77!~~^^^^^::^^^^~~7J~.~YPBBBB########BBBBBBGGGBBB#####BY^          
#      .~?PBBBBGGGGPPP55555555YY5PGGJ!~~^^^~^^^^^^~~!7Y55GBBBBB#####BBBBBBGGGGGGGBBB####5^.           
#      .^JG###BBBBBGGGPPPP555YYYY55GGPJ7!~~~^^^^~~!?YPBBBBBBBGBBBBGGGGGGGGGPPPGGBB#####BY^            
#    .^JG######BBBGGGGPP55YYYYYY55GBB#BP5YYYYY555PGGGGGGBBBBGGGPPPPPPPGGGGGGGGGBBB###&&&BJ^           
# ^!JG#&&&#########BBGGPPP5555PPGGGGGPPPPGGBBBBBBBGGGGPPGPPGGGPPPPPGGGBBBBBBBBBB#####&&&&P!.          
# G#&&&&###BBBBBBBBBBGGGGGGGGPPPP55PPPGGGBBBBGPGGBGGGP5555PGGGGGGGGGGGBBBBB##########&&&&&BY^.        
###################################################################################################

use lib q{/home/gamedazed/modules};
use lib q{/usr/local/share/perl/5.30.0};
use PeePoo;
use Parallel::ForkManager;
use WWW::Twitch;

my @watch_list = qw{lordaethelstan aethelworld};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));

#################################### Compatability ####################################
my $browser         =   q{firefox};
my $localMntPoint   =   q{/nas};
my $home            =   q{/home/gamedazed};
my $localOutPath    =   q{/videos/Captures/};
my $gcsMountPoint   =   q{/gdrive};
my $gcsBucketName   =   q{pub};
my $gcsLogFile      =   qq{$home/gcsfuse.log};
my $authorization   =   qq{$home/revod-364904-c9d09a09225b.json};
$PeePoo::verbosity  =   q{debug};
$PeePoo::logLevel   =   q{debug};
$PeePoo::logFile    =   qq{$home/pog.log};
####################################### testing #######################################
my %streams=(
    channel =>  {
        lordaethelstan  =>  {
            userid      =>  q{1665175701},
            discord     =>  qx{cat $home/.webhook | tr -d "\n"},
        },
        aethelworld     =>  {
            discord     =>  qx{cat $home/.webhook | tr -d "\n"},
        },
        gamedazed       =>  {
            discord     =>  qx{cat $home/personal_server.webhook | tr -d "\n"},
        },
        nyanners        =>  {
            userid      =>  q{82350088}
        },
        tobs            =>  {
            userid      =>  q{598826002}
        },
        coqui           =>  {
            userid      =>  q{633385488}
        }
    }
);
# main loop
sub main() {
    while (1) {
        &poll(@watch_list);
    }
}

#check each streamer's online state and provide status on files being generated
sub poll() {
    my @watching = @_;
    ############################# Callbacks #############################
    $fm_poll->run_on_finish(sub {
        my ($pid, $returnCode, $ident) = @_;
        my $status = "info";
        if ($returnCode != 0) {
            $status = q{warning};
            my $error = q{};
            $error .= qq{$!\n} if (defined $! && $!);   # System Errors
            $error .= qq{$@\n} if (defined $@ && $@);   # Perl Errors
            $error .= qq{$streams{pid}{$$}{channel} process exited with code $returnCode};
        }
        return $returnCode if $streams{pid}{$$}{channel} eq q{Parent};
        &PeePoo::printl( q{info}, qq{$streams{pid}{$$}{channel}\'s stream ended\n} );
    });
    $fm_poll->run_on_wait(sub {
        my $channel_name = $streams{pid}{$$}{channel};
        &PeePoo::printl(q{info}, qq{$channel_name ($$)});
        
        # Print files modified over the past 1800 minutes
        &PeePoo::printxl(q{echo && find /nas/videos/Captures/ -type f -mmin -1800 -exec ls -l {} \;}) if qx{ps aux | grep yt-dlp | grep -v grep | wc -l | tr -d "\n"};
        # Show actively running yt-dlp processes
        &PeePoo::printxl(q{echo && ps aux | grep yt-dlp | grep -v grep }) if qx{ps aux | grep yt-dlp | grep -v grep | wc -l | tr -d "\n"};
    },180);
    $fm_poll->run_on_start(sub {
        my ($pid, $ident) = @_;
        &PeePoo::printl( q{info}, qq{Started polling for $ident - ($pid)!\n} );
    });
    #####################################################################
    POLL:
    foreach my $channel_name (@watching) {
        my $pid = $fm_poll->start($channel_name) and next POLL;
        $streams{channel}{$channel_name}{pid} = $pid;
        $streams{pid}{$pid}{channel} = $channel_name;
        my $vod_id  = &get_live_status($channel_name);
        $fm_poll->finish;
    }
}

# Check if they're online
sub get_live_status {
    my $channel_name = shift;
    my $twitch = WWW::Twitch->new();
    my $is_live;
    until($is_live->{id}) {
        $is_live = $twitch->live_stream($channel_name);
    }
    my $post_processing_cmd = &live_trigger($channel_name);
    return $post_processing_cmd;
}

sub get_watchbot_cmd() {
    my $channel_name = shift;
    my $outputDir = shift;

    my $ua  = q{Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0};
    my $jar = qq{$home/cookies.sqlite};
    my $o   = qq{ -o "$outputDir/%(uploader)s-%(description)s.%(ext)s"};

    # my $cmd = qq{docker run --rm --name=${channel_name}-peepoowatchbot } .
    #   q{-e running_application='yt-dlp' --network 'shitting_and_farting' } .
    #   q{jauderho/yt-dlp:latest};
    my $cmd = q{yt-dlp};
    my $trigger_command = qq{                \\
    --sub-langs live_chat                    \\
    --hls-prefer-native                      \\
    --allow-dynamic-mpd                      \\
    --hls-split-discontinuity                \\
    --concurrent-fragments 5                 \\
    --write-subs   -vvv                      \\
    --user-agent '$ua'                       \\
    --cookies $jar                           \\
    https://twitch.tv/$channel_name          \\
    --wait-for-video 1 $o    };

    &PeePoo::printl(q{debug}, qq{\n\n(watchbot command):\n$cmd $trigger_command\n\n});
    return qq{$cmd $trigger_command}
}

sub get_chatdownload_cmd() {
    my $channel_name = shift;
    my $outputDir    = shift;
    my $outputFile   = shift;
    my $vod_id       = shift;
    # my $cmd = qq{docker run --rm -it }            
    # . qq{--name "$channel_name-peepootwitchybot" }
    # . qq{-e running_application='twitch-downloader-cli' }
    # . qq{--network 'shitting_and_farting' -v nas_share:/nas/ }
    # . qq{ bxggs/twitch-downloader-cli:latest };
    my $cmd = q{TwitchDownloaderCLI};
    my $trigger_command = qq{ chatdownload }
    . qq{-u $vod_id }
    . qq{--embed-images }
    . qq{-o "$outputDir/$outputFile" };
    &PeePoo::printl(q{debug}, qq{\n\n(chat download command):\n$cmd\n\n});
    return $cmd . $trigger_command;
}

sub get_chatrender_cmd() {
    my $channel_name  = shift;
    my $outputDir     = shift;
    my $chatIn        = shift;
    my $chatOut       = shift;
    my $height        = shift;
    my $width         = shift;
    # my $cmd = qq{docker run --rm -it }
    # . qq{--name "$channel_name-peepootwitchybot" }
    # . qq{-e running_application='twitch-downloader-cli' }
    # . qq{--network 'shitting_and_farting' -v nas_share:/nas/ }
    # . qq{ bxggs/twitch-downloader-cli:latest };
    my $cmd = q{TwitchDownloaderCLI };
    
    my $trigger_command = qq{chatrender }
    . qq{-i "$outputDir/$chatIn" }
    . qq{--outline --font-size 17 --skip-drive-waiting }
    . qq{-h $height -w $width  }
    . qq{--output "$outputDir/$chatOut"};
    &PeePoo::printl(q{debug}, qq{\n\n(twitchify command):\n$cmd\n\n});

    return $cmd . $trigger_command;
}

sub get_vod_cmd() {
    my $channel_name = shift;
    my $outputDir    = shift;
    my $chat         = shift;
    my $video        = shift;
    my $vod          = shift;
    #my $cmd = qq{docker run --rm -it                                \\
    #--name $channel_name-pogvodbot                                  \\
    #-e running_application='ffmpeg'                                 \\
    #--network 'shitting_and_farting' -v nas_share:/nas/             \\
    # xychelsea/ffmpeg-nvidia:latest                                 \\
    my $cmd = q{ffmpeg};
    my $trigger_command = qq{ -i $outputDir/'$video'                  \\
    -i $outputDir/'$chat'                                             \\
    -filter_complex hstack -preset veryfast -vsync 2                  \\
    $gcsMountPoint/$channel_name/'$vod' };
    &PeePoo::printl(q{debug}, qq{\n\n(pogvodbot command):\n$cmd\n\n});
    return $cmd . $trigger_command;
}

sub live_trigger() {
    my $channel_name = shift;
    return undef unless defined $channel_name;
    chomp $channel_name;

    my $outputDir = $localMntPoint . $localOutPath . $channel_name; # i.e. /nas/videos/Captures/lordaethelstan
    print qx{mkdir -vp $outputDir} unless -d $outputDir;            # create the subdirectory for the channel if it doesn't exist
    print qx{mkdir -vp $gcsMountPoint/$channel_name} unless -d qq{$gcsMountPoint/$channel_name}; # i.e. /downloads/lordaethelstan
    my $timestamp = &PeePoo::timestamp(q{yyyy_mm_dd-hh:mm:ss});     # i.e. 2023_05_30-16:22:30

    my $live_record = &get_watchbot_cmd($channel_name, $outputDir);
    &PeePoo::printl(q{notice}, qq{executing $live_record});
    my ($liveRecord_executionStatus, $liveRecored_returnOutput, $liveRecord_returnCode) = &PeePoo::printxl($live_record);
    &PeePoo::printl(q{notice}, qq{\n - The recording completed as a $liveRecord_executionStatus with exit code $liveRecord_returnCode.\n});
    &wait_for_finalization($channel_name); # While yt-dlp is writing for the channel in question, wait 10 seconds and check again;

    my $video = &get_fn($outputDir, q{.mp4});
    $video =~ s/_chat\.mp4$/\.mp4/; # if a chat file was the most recently written
    &PeePoo::printl(q{notice}, qq{    * Filename: $video});
    $video =~ s/\.temp//;     # .temp is used when finalizing   (Could be latest file if still finalizing)
    $video =~ s/\.part//;     # .part is used when downloading  (Could be latest file if stream crashed)
    $video =~ s/[\p{Sc}!]//g; # Santizing unicode characters and exclamations from the video name for fewer unexpected errors and easier remediation
    &PeePoo::printl(q{notice}, qq{    * Santized Filename: $video});
    &PeePoo::printxl(qq{mv -v $outputDir/'$video' $outputDir/'$timestamp.$video'}) unless $video =~ m/^\Q$timestamp\E/;
    $video = qq{$timestamp.$video} if -f qq{$outputDir/$timestamp.$video};
    &PeePoo::printl(q{notice}, qq{    * Timestamped Filename: $video});
    (my $chat = $video) =~ s/\.(\w{3})$/_chat/;
    (my $vod = $video)  =~ s/\.(\w{3})$/_fullvod.$1/;

    &PeePoo::printl(q{notice}, q{    * Getting VOD ID});
    my $vod_id = &get_vod_id($channel_name);
    if ($vod_id =~ m/\d+/) {
        &PeePoo::printl(q{notice}, qq{ - Got VOD ID $vod_id\n});
    }
    else {
        defined $vod_id ?
          &PeePoo::printl(q{critical}, qq{ VOD ID returned $vod_id - I'm going to try to download chat with this but I don't think it looks right\n}) :
          &PeePoo::printl(q{critical}, qq{ VOD ID returned undefined! Cannot download chat!\n});
        # If you don't have a VOD ID, as can happen when vods aren't saved on a channel, just move the vod recording to the cloud storage
        &PeePoo::printxl(qq{mv -v $video $gcsMountPoint/$channel_name/$video});
        #&post_notification($channel_name, $video);
        return 1;
    }
    
    my $chatDownloadCmd = &get_chatdownload_cmd($channel_name, $outputDir, qq{$chat.json}, $vod_id);
    &PeePoo::printl(q{notice}, qq{\n(chat Download) executing $chatDownloadCmd\n});
    my ($chatDownload_executionStatus, $chatDownload_returnOutput, $chatDownload_returnCode) = &PeePoo::printxl($chatDownloadCmd);
    &PeePoo::printl(q{notice}, qq{ - Chat has finished downloading\n});

    my ($height, $width) = &generate_ratio(qq{$outputDir/$video});
    my $twitchifyCmd = &get_chatrender_cmd($channel_name, $outputDir, qq{$chat.json}, qq{$chat.mp4}, $height, $width);
    &PeePoo::printl(q{notice}, qq{\n(chat render) executing $twitchifyCmd\n});
    my ($chatRender_executionStatus, $chatRender_returnOutput, $chatRender_returnCode) = &PeePoo::printxl($twitchifyCmd);
    &PeePoo::printl(q{notice}, qq{ - Chat has finished rendering\n});
    &PeePoo::printxl(qq{rm -v $outputDir/'$chat.json'}) if $chatRender_executionStatus =~ m/success/i;

    my $vodCmd = &get_vod_cmd($channel_name, $outputDir, qq{$chat.mp4}, $video, $vod);
    &PeePoo::printl(q{notice}, qq{\n(Concat Chat & VOD) executing $vodCmd\n});
    my ($fullVOD_executionStatus, $fullVOD_returnOutput, $fullVOD_returnCode) = &PeePoo::printxl($vodCmd);
    &PeePoo::printl(q{notice}, qq{ - Video & Chat Concat Completed - FullVOD finalized\n});
    system(qq{rm -v $outputDir/'$chat.mp4' $outputDir/'$video'*}) if $fullVOD_executionStatus =~ m/success/i;
    # Let's hold off on deleting these until we get a few wins behind our belt

    if (-f qq{/downloads/$channel_name/$vod}) {
        #&post_notification($channel_name, $vod);
    }
    return 1;
}

sub generate_ratio() {
    use POSIX;
    my $fn = shift;
    my $stream = qx{ffprobe -i $fn 2>&1};
    my %chat_ratio = (
        1080 => 422,
        720  => 281,
    );
    if ($stream =~ m/Video\:.*?\s\d{3,4}x(\d{3,4})/) { 
        my $height = $1;
        if (defined $chat_ratio{$height}) {
            return ($height, $chat_ratio{$height});
        }
        else {
            my $ratio = floor($height / 2.55);
            return ($height, $ratio);
        }
    }
    else {
        #assume 1080 but log what went wrong
        print "DOH\n\n$stream\n\n" and return (1080, 422);
    }
}

############################################################################

sub start_headless_chromium() {
    my $docker;
    -f qq{$home/bin/docker}          ?
      $docker = qq{$home/bin/docker} :
      $docker = q{docker}            ;
    &PeePoo::printxl(qq{$docker run -d --restart=unless-stopped  --name=peepooemu -p 9222:9222 --cap-add=SYS_ADMIN justinribeiro/chrome-headless});
    sleep 5;
}

sub get_vod_id() {
    my $channel_name = shift;
    my $try = shift;
    $try = 0 if !defined $try;
    use Log::Log4perl qw(:easy);
    use WWW::Mechanize::Chrome;
    Log::Log4perl->easy_init($ERROR);
    my $url = qq{https://twitch.tv/$channel_name/videos?filter=archives&sort=time};
    my $js  = q{document.getElementsByClassName("ScTransformWrapper-sc-1wvuch4-1 gMwbGx")[0].firstChild.href.match(/\d{10,}/)[0]};
    
    Log::Log4perl->easy_init($ERROR);
    my $mech = WWW::Mechanize::Chrome->new(
        launch_exe    => q{chromium},
        headless      => 1,
        autodie       => 0,
        host          => q{localhost},
        port          => 9222,
    );
    $mech->allow( javascript => 1 );
    $mech->get($url);
    sleep 5;

    my ($vod_id, $type) = $mech->eval($js);
    print "Got Vod ID $vod_id and Type $type\n";
    if ($type eq "string") {
        return $vod_id;
    }
    else {
        if ($try < 10) {
            print "\nGot $type $vod_id\nTrying again ($try)\n";
            $try++;
            &get_vod_id($channel_name, $try);
        }
        else {
            &prune_headless_chromium();
            &start_headless_chromium();
            &get_vod_id($channel_name);
        }
    }
}

sub prune_headless_chromium() {
    my $docker;
    -f qq{$home/bin/docker}          ?
      $docker = qq{$home/bin/docker} :
      $docker = q{docker}            ;
    &PeePoo::printxl(qq{$docker container rm -f peepooemu}) if qx{$docker container ls} !~ m/peepooemu/;
}

sub wait_for_finalization() {
    my $channel_name = shift;
    my $cmd = qq{ps aux | grep yt-dlp | grep $channel_name | grep -v grep | tr -d "\n"};
    while (qx{$cmd}) {
        &PeePoo::printl(q{notice}, "finalizing VOD recording...\n");
        sleep 10;
    }
    return 1;
}

################ Google Cloud Storage - Mount, Transfer, Unmount ################

sub transfer() {
    my $channel_name = shift;
    my $localPath    = shift;
    my $localPath_fn = shift;
    my $transfer_dir = qq{$gcsMountPoint/$channel_name/};

    my $is_mounted = &setup_transient_storage($channel_name);
    if ($is_mounted) {
        system(qq{cp $localPath/$localPath_fn $transfer_dir});
        #&copy_to_gcs(qq{$localPath/$localPath_fn}, $transfer_dir);
        #&teardown_transient_storage();
    }
}

sub get_fn() {
    my $path = shift;
    my $filter = shift;
    if ($filter) {
        return qx{ls -tr $path | grep $filter | tail -1 | tr -d "\n"};
    }
    else {
        return qx{ls -tr $path | tail -1| tr -d "\n"}
    }
}

sub setup_transient_storage() {
    my $channel_name = shift;
    if (!-d qq{$gcsMountPoint/$channel_name}) {
        &PeePoo::printl(q{info}, "Mounting GCS Fuse.");

        &PeePoo::printxl(qq{gcsfuse --key-file $authorization --log-file $gcsLogFile --debug_gcs --debug_fuse --debug_http --implicit-dirs $gcsBucketName $gcsMountPoint});
        my $is_mounted = qx{ls -l $gcsMountPoint/ | wc -l | tr -d "\n"};
        if ($is_mounted) {
            &PeePoo::printl(q{info}, qq{Mounting completed.}); 
            return $is_mounted;
        }
        else {
            &PeePoo::printl(q{info}, qq{Failed to mount.});
            return $is_mounted;
        }
    }
    else {
        &PeePoo::printl(q{info}, qq{Mount already present.});
        return 1;
    }
}

sub teardown_transient_storage() {
    return &PeePoo::printxl(qq{umount $gcsMountPoint})
}

sub copy_to_gcs() {
    my $source = shift;
    my $destination = shift;
    my $options = shift;
    $destination = $gcsMountPoint unless defined $destination;
    unless (defined $options && ref($options) eq q{HASH}) {
        my %o = (
            bool    =>  qw[ progress preallocate whole-file checksum times ignore-existing],
            paramd  =>  {
                q{min-size}         =>  q{100m},
                q{itemize-changes}  =>  q{%<*c %fSD},
                q{compress-level}   =>  9,
            }
        );
        $options = \%o;
    }
    return &PeePoo::rsync_xfer($source, $destination, $options);
}
##################################################################################

sub post_notification() {
    use WebService::Discord::Webhook;
    my $channel_name = shift;
    my $video = shift;
    my @urls;

    my $dev_discord_url = $streams{channel}{$channel_name}{discord};
    my $personal_discord_url = $streams{channel}{gamedazed}{discord};
    foreach my $notification ($dev_discord_url, $personal_discord_url) {
        # testing for definition and non-null before attempting to operate on it
        if (defined $notification) {
            if ($notification) {
                push @urls, $notification;
            }
        }
    }

    # gcp
    #my $storage_bucket_pubDir = qq{https://storage.googleapis.com/$gcsBucketName/$channel_name};

    my $uriTitle = &PeePoo::uri_encode($video);
    my $clean    = qr/^.*?\Q$channel_name\E\s?\-\s?(.*)\s[｜\|].*$/i;
    #my $link = qq{$storage_bucket_pubDir/$uriTitle};
    $video  =~ s/$clean/$1/;
    my $notification = qq{$video\n$link};

    foreach my $url (@urls) {
        my $hook = WebService::Discord::Webhook->new( $url );
        $hook->get();
        $hook->execute( content => $notification );
    }
}

##################################################################################

$streams{pid}{$$}{channel} = q{Parent};
&prune_headless_chromium();
&start_headless_chromium();
&main(@ARGV);