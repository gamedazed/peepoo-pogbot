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

my @watch_list = qw{lordaethelstan aethelworld nyanners pinkcatbad rubberross};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));

#################################### Compatability ####################################
$PeePoo::browser         =   q{firefox};
$PeePoo::localMntPoint   =   q{/nas};
$PeePoo::home            =   q{/home/gamedazed};
$PeePoo::useHW_Encoding  =   q{1};
$PeePoo::localOutPath    =   q{/videos/Captures/};
$PeePoo::gcsMountPoint   =   q{/gdrive};
$PeePoo::gcsBucketName   =   q{pub};
$PeePoo::gcsLogFile      =   qq{$PeePoo::home/gcsfuse.log};
$PeePoo::authorization   =   qq{$PeePoo::home/revod-364904-c9d09a09225b.json};
$PeePoo::verbosity       =   q{debug};
$PeePoo::logLevel        =   q{debug};
$PeePoo::logFile         =   qq{$PeePoo::home/pog.log};
####################################### testing #######################################

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
            $error .= qq{$PeePoo::streams{pid}{$$}{channel} process exited with code $returnCode};
        }
        return $returnCode if $PeePoo::streams{pid}{$$}{channel} eq q{Parent};
        &PeePoo::printl( q{info}, qq{$PeePoo::streams{pid}{$$}{channel}\'s stream ended\n} );
    });
    $fm_poll->run_on_wait(sub {
        foreach my $pid (keys %{$PeePoo::streams{pid}}) {
            my $channel_name = $PeePoo::streams{pid}{$pid}{channel};
            next if $channel_name eq 'Parent';
            &PeePoo::printl(q{info}, qq{$channel_name ($pid)});
        }
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
        # Restart based on the non-running pid's channel name, not array index
        my $running = qx{ps aux | grep $channel_name | grep -v grep | wc -l | tr -d "\n"};
        next if $running;

        my $pid = $fm_poll->start($channel_name) and next POLL;
        $PeePoo::streams{channel}{$channel_name}{pid} = $pid;
        $PeePoo::streams{pid}{$pid}{channel} = $channel_name;
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

sub live_trigger() {
    my $channel_name = shift;
    return undef unless defined $channel_name;
    chomp $channel_name;

    my $outputDir = $PeePoo::localMntPoint . $PeePoo::localOutPath . $channel_name; # i.e. /nas/videos/Captures/lordaethelstan
    foreach my $dir ($outputDir, qq{$PeePoo::gcsMountPoint/$PeePoo::gcsBucketName/$channel_name}) {
        print qx{mkdir -vp $dir} unless -d $dir;
    }
    my $timestamp = &PeePoo::timestamp(q{yyyy_mm_dd-hh.mm.ss});     # i.e. 2023_05_30-16:22:30

    my $live_record = &PeePoo::get_watchbot_cmd($channel_name, $outputDir);
    &PeePoo::printl(q{notice}, qq{executing $live_record});
    my ($liveRecord_executionStatus, $liveRecored_returnOutput, $liveRecord_returnCode) = &PeePoo::printxl($live_record);
    &PeePoo::printl(q{notice}, qq{\n - The recording completed as a $liveRecord_executionStatus with exit code $liveRecord_returnCode.\n});
    &PeePoo::wait_for_finalization($channel_name); # While yt-dlp is writing for the channel in question, wait 10 seconds and check again;
    if ($liveRecord_executionStatus eq q{error}) {
        &PeePoo::printl(q{error}, qq{Exiting out early - YT-DLP returned an error\n\--- $liveRecord_returnCode ---\n$liveRecord_executionStatus});
        return qq{Failed with code $liveRecord_returnCode\n}
    }

    my $video = &PeePoo::get_fn($outputDir, q{.mp4});
    $video =~ s/_chat\.mp4$/\.mp4/; # if a chat file was the most recently written
    &PeePoo::printl(q{notice}, qq{    * Filename: $video});
    $video =~ s/\.temp//;           # .temp is used when finalizing   (Could be latest file if still finalizing)
    $video =~ s/\.part//;           # .part is used when downloading  (Could be latest file if stream crashed)
    my $default = $video;
    $video =~ s/[\p{Sc}!'"]//g;       # Santizing unicode characters and exclamations
    &PeePoo::printl(q{notice}, qq{    * Santized Filename: $video});
    if (-f qq{$outputDir/$default}) {
        &PeePoo::printxl(qq{mv -v $outputDir/'$default' $outputDir/'$video'}) unless -f qq{$outputDir/'$video'};
    }
    unless (&PeePoo::matches_timestamp($video)){
        &PeePoo::printxl(qq{mv -v $outputDir/'$video' $outputDir/'$timestamp.$video'});
        $video = qq{$timestamp.$video} if -f qq{$outputDir/$timestamp.$video};
        &PeePoo::printl(q{notice}, qq{    * Timestamped Filename: $video});
    }
    (my $chat = $video) =~ s/\.(\w{3})$/_chat/;
    (my $vod = $video)  =~ s/\.(\w{3})$/_fullvod.$1/;

    &PeePoo::printl(q{notice}, q{    * Getting VOD ID});
    my $vod_id = &PeePoo::get_vod_id($channel_name);
    if ($vod_id =~ m/\d+/) {
        &PeePoo::printl(q{notice}, qq{ - Got VOD ID $vod_id\n});
    }
    else {
        defined $vod_id ?
          &PeePoo::printl(q{critical}, qq{ VOD ID returned $vod_id - I'm going to try to download chat with this but I don't think it looks right\n}) :
          &PeePoo::printl(q{critical}, qq{ VOD ID returned undefined! Cannot download chat!\n});
        # If you don't have a VOD ID, as can happen when vods aren't saved on a channel, just move the vod recording to the cloud storage
        &PeePoo::printxl(qq{mv -v $video $PeePoo::gcsMountPoint/$PeePoo::gcsBucketName/$channel_name/$video});
        #&post_notification($channel_name, $video);
        return 154;
    }

    my $chatDownloadCmd = &PeePoo::get_chatdownload_cmd($channel_name, $outputDir, qq{$chat.json}, $vod_id);
    &PeePoo::printl(q{notice}, qq{\n(chat Download) executing $chatDownloadCmd\n});
    my ($chatDownload_executionStatus, $chatDownload_returnOutput, $chatDownload_returnCode) = &PeePoo::printxl($chatDownloadCmd);
    if ($chatDownload_executionStatus eq q{success}) {
        &PeePoo::printl(q{notice}, qq{ - Chat has finished downloading\n});

        my $offset = &PeePoo::trim_chat_by(qq{$outputDir/'$video'}, qq{$outputDir/'$chat'});
        my ($height, $width) = &PeePoo::generate_ratio(qq{$outputDir/$video});
        my $twitchifyCmd = &PeePoo::get_chatrender_cmd($channel_name, $outputDir, qq{$chat.json}, qq{$chat.mp4}, $height, $width, $offset);
        &PeePoo::printl(q{notice}, qq{\n(chat render) executing $twitchifyCmd\n});
        my ($chatRender_executionStatus, $chatRender_returnOutput, $chatRender_returnCode) = &PeePoo::printxl($twitchifyCmd);
        if ($chatRender_executionStatus eq q{success}) {
            &PeePoo::printl(q{notice}, qq{ - Chat has finished rendering\n});
            &PeePoo::printxl(qq{rm -v $outputDir/'$chat.json'});

            my $vodCmd = &PeePoo::get_vod_cmd($channel_name, $outputDir, qq{$chat.mp4}, $video, $vod);
            &PeePoo::printl(q{notice}, qq{\n(Concat Chat & VOD) executing $vodCmd\n});
            my ($fullVOD_executionStatus, $fullVOD_returnOutput, $fullVOD_returnCode) = &PeePoo::printxl($vodCmd);
            &PeePoo::printl(q{notice}, qq{ - Video & Chat Concat Completed - FullVOD finalized\n});
            system(qq{rm -v $outputDir/'$chat.mp4' $outputDir/'$video'*}) if $fullVOD_executionStatus eq q{success};
        }
        else{
            &PeePoo::printl (q{warning}, qq{The render of Chat failed, the fullVOD will not be able to be generated without intervention\n}
            . qq{\n$chatDownload_returnOutput\n}
            . qq{\tReturn Code $chatDownload_returnCode\n}
            . qq{\n\nMoving the VOD to the destination folder and exiting out early\n});
            &PeePoo::printxl(qq{mv -v $outputDir/'$video' $PeePoo::gcsMountPoint/$PeePoo::gcsBucketName/$channel_name/'$video'});
            return 1;
        }
    }
    else {
        &PeePoo::printl (q{warning}, qq{The download of Chat failed, the fullVOD will not be able to be generated without intervention\n}
        . qq{\n$chatDownload_returnOutput\n}
        . qq{\tReturn Code $chatDownload_returnCode\n}
        . qq{\n\nMoving the VOD to the destination folder and exiting out early\n});
        &PeePoo::printxl(qq{mv -v $outputDir/'$video' $PeePoo::gcsMountPoint/$PeePoo::gcsBucketName/$channel_name/'$video'});
        return 154;
    }

    if (-f qq{$PeePoo::gcsMountPoint/$PeePoo::gcsBucketName/$channel_name/'$video'}) {
        &PeePoo::post_notification($channel_name, $vod);
    }
    return 1;
}

##################################################################################

$PeePoo::streams{pid}{$$}{channel} = q{Parent};
&main(@ARGV);