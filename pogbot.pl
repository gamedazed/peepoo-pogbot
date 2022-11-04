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
my %streams;
my %config;

# main program flow
sub main() {
    my @ffmpeg_args = @_;
    while (scalar(@watch_list)) {
        my ($vod_id, $channel_name) = &poll();
        &live_trigger($channel_name);
    }
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
        &PeePoo::printl( q{info}, qq{Polling for live streamers . . .\n} );
    });
    $fm_poll->run_on_start(sub {
        my ($pid, $ident) = @_;
        &PeePoo::printl( q{info}, qq{Started polling for $ident - ($pid)!\n} );
    });
    #####################################################################

    POLL:
    foreach my $channel_name (@watch_list) {
        $fm_poll->start($channel_name) and next POLL;
        my $vod_id  = &get_live_status($channel_name);
        $fm_poll->finish;
        return($vod_id, $channel_name);
    }
}

# Check if they're online
sub get_live_status() {
    my $channel_name = shift;
    my $twitch = WWW::Twitch->new();
    my $is_live;
    until($is_live) {
        $is_live = $twitch->live_stream($channel_name);
    }
    return $is_live->{id} if $is_live;
}

# Not a longterm solution, command will be dynamically generated around the passed parameters once config and args are able to read.
# That said, this is the command I have found myself enjoying the most
sub live_trigger() {
    my $channel_name = shift;
    return undef unless defined $channel_name;
    my $args = join(' ', @_);

    my $cmd = q{yt-dlp};
    my $outputDir = qq{/downloads/$channel_name};
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
