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

use lib q{./modules};
use lib q{/usr/local/share/perl/5.30.0};
use PeePoo;
use Parallel::ForkManager;
use WWW::Twitch;

my @watch_list = qw{nyanners lordaethelstan tobs coqui};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));

#my $configFile = q{pogbot.ini};
#################################### Compatability ####################################
my $browser         =   q{firefox};
my $localMntPoint   =   q{/nas};
my $localOutPath    =   q{/videos/Captures/};
my $gcsMountPoint   =   q{/downloads};
my $gcsBucketName   =   q{transient-peepoo};
my $gcsLogFile      =   q{/root/gcsfuse.log};
my $authorization   =   q{/root/revod-364904-c9d09a09225b.json};
$PeePoo::verbosity  =   q{debug};
$PeePoo::logLevel   =   q{debug};
$PeePoo::logFile    =   q{/root/pog.log};
####################################### testing #######################################                                                 

my %streams=(
    channel =>  {
        lordaethelstan  =>  {
            userid      =>  q{1665175701}
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
my %config;

# main program flow
sub main() {
    while (1) { 
    my ($vod_id, $channel_name) = &poll();
    my $post_processing_cmd = &live_trigger($channel_name) if ($vod_id && $channel_name) }
    my ($executionStatus, $returnOutput, $returnCode) = &PeePoo::printxl($post_processing_cmd);
    # spin up a container as non-root, share volume, mount gcs, transfer vod, do cleanup
    # mix in lots more tests throughout
}

#check each streamer's online state
sub poll() {
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
        &PeePoo::printl( q{$status}, qq{$streams{pid}{$$}{channel}\'s stream ended\n} );
    });
    $fm_poll->run_on_wait(sub {
        my $pid = shift; 
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
    my $channel = shift;
    my @channels;
    if (defined $channel) {
        push @channels, $_ foreach (split(/,/, $channel));
    }
    else {
        @channels = @watch_list;
    }
    POLL:
    foreach my $channel_name (@channels) {
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
        $streams{pid}{$$}{vod_id} = $is_live->{id};
        $streams{channel}{$channel_name}{vod_id} = $is_live->{id};
    }
    &PeePoo::printl(q{info}, qq{$is_live->{id}});
    my $vod_id = $is_live->{id};
    my $post_processing_cmd = &live_trigger($channel_name);
    return $post_processing_cmd;
}

sub get_watchbot_cmd() {
    my $channel_name = shift;
    my $outputDir = shift;

    my $ua  = q{Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0};
    my $jar = qq{/root/cookies.sqlite};
    my $o = qq{ -o "$outputDir/%(uploader)s-%(description)s.%(ext)s"};

    my $cmd = qq{docker run --rm --name=${channel_name}-peepoowatchbot } .
      q{-e running_application='yt-dlp' --network 'shitting_and_farting' } .
      q{-v nas_share:/nas jauderho/yt-dlp};

    my $trigger_command = q{                 \
    --sub-langs live_chat                    \
    --hls-prefer-native                      \
    --allow-dynamic-mpd                      \
    --hls-split-discontinuity                \
    --concurrent-fragments 5                 \
    --write-subs   -vvv                      \
    --user-agent '} . $ua  . q{'             \
    --cookies '}    . $jar . q{'             \
    https://twitch.tv/} . $channel_name . q{ \
    --wait-for-video 10 } . $o               ;

    return qq{$cmd $trigger_command}
}

sub get_chatbot_cmd() {
    my $channel_name = shift;
    my $outputDir    = shift;
    return qq{docker run --rm }            
    .  qq{--name=$channel_name-peepoochatbot } 
    .  qq{-e running_application='twitch-chat-dumper' }
    .  qq{-v nas_share:/nas }
    .  qq{--network 'shitting_and_farting' peepoochatbot }
    .  qq{--channel $channel_name }
    .  qq{--userid $streams{channel}{$channel_name}{userid} }
    .  qq{--output $outputDir/chat.json };
}

sub get_chatrender_cmd() {
    my $channel_name  = shift;
    my $outputDir     = shift;
    my $chatFile_name = shift;
    return qq{docker run --rm -it }
	. qq{--name '$channel_name-peepootwitchybot' }
    . qq{-e running_application='twitch-downloader-cli' }
	. qq{--network 'shitting_and_farting' -v nas_share:/nas/ }
    . qq{ bxggs/twitch-downloader-cli:latest }
	. qq{-m ChatRender }
	. qq{-i '$outputDir/chat.json' }
	. qq{--outline }
	. qq{--timestamp }
	. qq{--embed-emotes }
	. qq{-h 1080 -w 422  }
	. qq{--output '$outputDir/$chatFile_name'}
}

sub get_vod_cmd() {
    my $channel_name = shift;
    my $outputDir    = shift;
    my $chat         = shift;
    my $video        = shift;
    my $vod          = shift;

    my $dockerCmd = qq{docker run --rm -it              \
    --name $channel_name-pogvodbot                      \
    -e running_application='ffmpeg'                     \
    --network 'shitting_and_farting' -v nas_share:/nas/ \
    truecharts/ffmpeg-nvidia:latest                     \
    };
    my $argStr = 
    qq{-y -vsync 0 -hwaccel cuda                                     \
    -i "$outputDir/$video"                                           \
    -i "$outputDir/$chat"                                            \
    -filter_complex hstack                                           \
        -c:a copy          -c:v h264_nvenc          -crf 20          \
        -tune hq -b:v 5M   -bufsize 5M              -maxrate 10M     \
        -qmin 0 -bf 3      -b_ref_mode middle       -temporal-aq 1   \
    -rc-lookahead 20       "$outputDir/$vod" };
    return qq{$dockerCmd $argStr};
}

sub live_trigger() {
    my $channel_name = shift;
    return undef unless defined $channel_name;
    chomp $channel_name;

    my $outputDir = qq{/nas/videos/Captures/$channel_name};
    print qx{mkdir -vp $outputDir} unless -d $outputDir;

    my $fm_exec    = new Parallel::ForkManager(2);
    my %live_record = (
        stream  =>  {
            container   =>  qq{$channel_name-peepoowatchbot},
        },
        chat    =>  {
            container   =>  qq{$channel_name-peepoochatbot},
        },
        twitch_chat =>  {
            container   =>  qq{$channel_name-peepootwitchybot},
        },
        vod     =>  {
            container   =>  qq{$channel_name-pogvodbot},
        }
    );

    # Launch stream and chat recording simultaneously
    $live_record{stream}{command}= &get_watchbot_cmd($channel_name, $outputDir);
    $live_record{chat}{command}  = &get_chatbot_cmd($channel_name, $outputDir);

    $fm_exec->run_on_start(sub {
        my ($pid, $ident) = @_;
        &PeePoo::printl(q{info}, qq{$ident($pid) started\n});
    });
    $fm_exec->run_on_finish(sub {
        my ($pid, $returnCode, $ident) = @_;
        # Even if it's cut short, chat should end when stream does, re-concat in any other context is incrementally more work
        if ($ident eq 'stream') {
            print qx{docker stop $live_record{chat}{container}};
        }
    });

    RECORDING:
    foreach my $r (keys %live_record) {
       $fm_exec->start($r) and next RECORDING;
       &PeePoo::printl(q{warning}, qq{executing $live_record{$r}{command}});
       my ($executionStatus, $returnOutput, $returnCode) = &PeePoo::printxl($live_record{$r}{command});
       print qq{$channel_name($r) exited with $returnCode - $executionStatus\n\n$returnOutput\n\n};
       qx{docker cp graceful_halt.sh $live_record{$r}{container}:/root};
    }
    
    my $video = &get_fn($outputDir, q{.mp4});
    (my $chat = $video) =~ s/\.(\w{3})$/_chat.$1/;
    (my $vod = $video)  =~ s/\.(\w{3})$/_vod.$1/;

    my $twitchifyCmd = &get_chatrender_cmd($channel_name, $outputDir, $chat);
    my $vodCmd = &get_vod_cmd($channel_name, $outputDir, $chat, $video, $vod);
    return (qq{$twitchifyCmd && $vodCmd});

    # &poll($channel_name);

}

# sub transfer() {
#     my $channel_name = shift;
#     my $localPath    = shift;
#     my $localPath_fn = shift;
#     my $transfer_dir = qq{$gcsMountPoint/$channel_name/};

#     &setup_transient_storage($channel_name);
#     &copy_to_gcs(qq{$localPath/$localPath_fn}, $transfer_dir);
#     &teardown_transient_storage()
# }

sub get_fn() {
    my $path = shift;
    my $filter = shift;
    if ($filter) {
        return qx{ls -tr | grep $filter | tail -1 | tr -d "\n"};
    }
    else {
        return qx{ls -tr | tail -1| tr -d "\n"}
    }
}

# sub setup_transient_storage() {
    #     my $channel_name = shift;
    #     unless (-d qq{$gcsMountPoint/$channel_name}) {
    #         &PeePoo::printl(q{info}, "Mounting GCS Fuse.");
    #         &PeePoo::printxl(qq{gcsfuse --key-file $authorization --log-file $gcsLogFile --debug_gcs --debug_fuse --debug_http --implicit-dirs $gcsBucketName $gcsMountPoint});
    #         &PeePoo::printl(q{info}, qq{Mounting completed.}) unless qx{ls -l /$localOutPath/ | wc -l | tr -d "\n"} == 0; 
    #     }
# }

# sub teardown_transient_storage() {
    #     return &PeePoo::printxl(qq{umount $gcsMountPoint})
# }

# sub copy_to_gcs() {
    #     my $source = shift;
    #     my $destination = shift;
    #     my $options = shift;
    #     $destination = $gcsMountPoint unless defined $destination;
    #     unless (defined $options && ref($options) eq q{HASH}) {
    #         my %o = (
    #             bool    =>  qw[ progress preallocate whole-file checksum times ignore-existing],
    #             paramd  =>  {
    #                 q{min-size}         =>  q{100m},
    #                 q{itemize-changes}  =>  q{%<*c %fSD},
    #                 q{compress-level}   =>  9
    #             }
    #         );
    #         $options = \%o;
    #     }
    #     return &PeePoo::rsync_xfer($source, $destination, $options)
# }

$streams{pid}{$$}{channel} = q{Parent};
&main(@ARGV);
