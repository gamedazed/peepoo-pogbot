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
use lib q{/usr/local/lib/perl5/site_perl/5.36.0/x86_64-linux-gnu};
use lib q{/usr/local/lib/perl5/site_perl/5.36.0};
use lib q{/usr/local/lib/perl5/vendor_perl/5.36.0/x86_64-linux-gnu};
use lib q{/usr/local/lib/perl5/vendor_perl/5.36.0};
use lib q{/usr/local/lib/perl5/5.36.0/x86_64-linux-gnu};
use lib q{/usr/local/lib/perl5/5.36.0};
use PeePoo;
use Parallel::ForkManager;
use WWW::Twitch;

<<<<<<< HEAD
my @watch_list = qw{nyanners lordaethelstan projektMelody nightmareNexus};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));

######## Compatability #########
my $browser        = q{firefox};
my $envOS          = q{NT};
my $drive          = q{G};
$PeePoo::verbosity = q{debug};
$PeePoo::logLevel  = q{info};
$PeePoo::logFile   = q{pog.log};
########## testing #############                                                      

=======
my @watch_list = qw{Nyanners lordAethelstan};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));

my $configFile = q{pogbot.ini};
#################################### Compatability ####################################
my $browser         =   q{firefox};
my $impersonateThis =   q{revod-364904@appspot.gserviceaccount.com};
my $authorization   =   q{~/.boto};
$PeePoo::verbosity  =   q{debug};
$PeePoo::logLevel   =   q{info};
$PeePoo::logFile    =   q{pog.log};
####################################### testing #######################################
>>>>>>> e0d50c46cef0c6e7f0b309961553a9e198b36945
my %streams;
my %config;

# main program flow
sub main() {
<<<<<<< HEAD
    print "Here as $streams{pid}{$$}{channel}\n";    
    while (1) { my ($vod_id, $channel_name) = &poll() }
    # if ($vod_id || $channel_name) {
    #     if ($vod_id) {
    #         print "Here with vod id $vod_id as $streams{pid}{$$}{channel}\n";
    #         print "I didn't know my channel was $streams{pid}{$$}{channel}" unless $channel_name;
    #         print "I've also got channel name $channel_name" if $channel_name;
    #         live_trigger($channel_name) if $vod_id;
    #     }
    #     elsif ($channel_name) {
    #         print "Here with channel name as $streams{pid}{$$}{channel}\n";
    #         print "I didn't know my channel was $streams{pid}{$$}{channel}" unless $channel_name;
    #         print "I've also got channel name $channel_name" if $channel_name;
    #     }
    # }
    # else {
    #      print "Here as $streams{pid}{$$}{channel}\nRecycling through main\n";
    # }
=======
    my @ffmpeg_args = @_;
    while (scalar(@watch_list)) {
        my ($vod_id, $channel_name) = &poll();
        &live_trigger($channel_name);
    }
>>>>>>> e0d50c46cef0c6e7f0b309961553a9e198b36945
}

#check each streamer's online state
sub poll() {
    ############################# Callbacks #############################
    $fm_poll->run_on_finish(sub {
        my ($pid, $returnCode, $ident) = @_;
        
        &PeePoo::printl( q{info}, qq{$ident went live!\n} );
    });
    $fm_poll->run_on_wait(sub {
        my $pid = shift; 
<<<<<<< HEAD
        my $channel_name = $streams{pid}{$$}{channel};

        &PeePoo::printl( q{info}, qq{Polling for $channel_name . . .\n} ) unless $channel_name =~ m/Parent/i;
    },15);
=======
        &PeePoo::printl( q{info}, qq{Polling for live streamers . . .\n} );
    });
>>>>>>> e0d50c46cef0c6e7f0b309961553a9e198b36945
    $fm_poll->run_on_start(sub {
        my ($pid, $ident) = @_;
        &PeePoo::printl( q{info}, qq{Started polling for $ident - ($pid)!\n} );
    });
    #####################################################################

    POLL:
    foreach my $channel_name (@watch_list) {
        my $pid = $fm_poll->start($channel_name) and next POLL;
        $streams{channel}{$channel_name}{pid} = $pid;
        $streams{pid}{$pid}{channel} = $channel_name;
        my $vod_id  = &get_live_status($channel_name);
        #print "Got $vod_id\n";
        $fm_poll->finish;
        #print "Returning Vod ID $vod_id and channel name $channel_name\n";
        #return($vod_id, $channel_name);
    }
}

# Check if they're online
sub get_live_status() {
    my $channel_name = shift;
    my $twitch = WWW::Twitch->new();
    my $is_live;
    until($is_live->{id}) {
        $is_live = $twitch->live_stream($channel_name);
        $streams{pid}{$$}{vod_id} = $is_live->{id};
        $streams{channel}{$channel_name}{vod_id} = $is_live->{id};
    }
<<<<<<< HEAD
    &PeePoo::printl(q{info}, qq{$is_live->{id}});
    my $vod_id = $is_live->{id};
    live_trigger($channel_name);
    return $vod_id;
=======
    return $is_live->{id} if $is_live;
>>>>>>> e0d50c46cef0c6e7f0b309961553a9e198b36945
}

# Not a longterm solution, command will be dynamically generated around the passed parameters once config and args are able to read.
# That said, this is the command I have found myself enjoying the most
sub live_trigger() {
    my $channel_name = shift;
    return undef unless defined $channel_name;
    chomp $channel_name;
    print "Peparing to record stream for $channel_name";

    my $cmd = q{yt-dlp};
    my $outputDir = qq{/downloads/$channel_name};
<<<<<<< HEAD
    print qx{mkdir -v $outputDir} unless -d $outputDir;
    my $ua  = q{Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0};
    my $jar = qq{/home/gamedazed/cookies.sqlite};
    my $o = qq{-o "$outputDir/subtitle:%(uploader)s-%(title)s.%(ext)s" -o "$outputDir/%(uploader)s-%(title)s.%(ext)s" BaW_j+enozKc};
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
    --wait-for-video 10 } . $o        ;
    &PeePoo::printl(q{debug}, qq{$cmd $trigger_command});
    my ($executionStatus, $returnOutput, $returnCode) = &PeePoo::printxl(qq{$cmd $trigger_command});
    &PeePoo::printl(q{info}, qq{Stream download exited with returncode $returnCode and status $executionStatus\n});
}

sub setup() {
    &PeePoo::printl(q{info}, "Mounting GCS Fuse.");
    &PeePoo::printxl(q{gcsfuse --key-file /home/gamedazed/revod-364904-c9d09a09225b.json --log-file /home/gamedazed/gcsfuse.log --debug_gcs --debug_fuse --debug_http --implicit-dirs transient-peepoo /downloads});
    &PeePoo::printl(q{info}, qq{Mounting completed.}) unless qx{ls -l /downloads/ | wc -l | tr -d "\n"} == 0; 
}

#&setup();
my $pid = $$;
$streams{pid}{$pid}{channel} = q{Parent};
&main(@ARGV);
=======
    my $ua  = q{Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0};
    my $jar = qq{/home/gamedazed/cookies.sqlite};
    my $o = qq{-o "$outputDir/subtitle:%(uploader)s-%(title)s.%(ext)s" -o "$outputDir/%(uploader)s-%(title)s.%(ext)s" BaW_j+enozKc --write-subs};
    my $trigger_command = qq{$cmd --sub-langs live_chat --hls-prefer-native --allow-dynamic-mpd --hls-split-discontinuity --concurrent-fragments 5 --write-subs -vvv  --user-agent '$ua' --cookies '$jar' https://twitch.tv/$channel_name --wait-for-video 10  $o};
    &PeePoo::printl($trigger_command);
    &PeePoo::printxl($trigger_command);
}


sub setup() {
    &PeePoo::printl(q{info}, "Mounting GCS Fuse.");
    &PeePoo::printxl(q{gcsfuse --key-file /home/gamedazed/revod-364904-c9d09a09225b.json --log-file /home/gamedazed/gcsfuse.log --debug_gcs --debug_fuse --implicit-dirs transient-peepoo /downloads});
    &PeePoo::printl(q{info}, qq{Mounting completed.}) unless qx{ls -l /downloads/ | wc -l | tr -d "\n"} == 0; 
}

&setup();
&main(@ARGV);
>>>>>>> e0d50c46cef0c6e7f0b309961553a9e198b36945
