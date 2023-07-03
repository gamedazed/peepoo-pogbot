#! /usr/bin/perl

use strict;
use warnings;
no strict 'refs';
no strict 'subs';

package PeePoo;
#################################################################################################
#####################################   Written by gamedazed   ##################################
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
use Exporter qw{import};
use lib q{/usr/local/share/perl/5.30.0};
our @export = qw{api_call color_code encode_base64 decode_base64 printxl printl log timestamp strip_ws color};
use Term::ANSIColor (qw{:constants});    #(qw{constants}); # apparently not a thing anymore https://perldoc.perl.org/Term::ANSIColor#COMPATIBILITY )

our $verbosity       = q{debug};
our $logLevel        = q{debug};
our $logFile         = q{log.log};
our $timestampFormat = q{iso8601};
$ENV{TEMP}           = q{/tmp};
our $browser         =   q{firefox};
our $localMntPoint   =   q{/nas};
our $home            =   q{/home/gamedazed};
our $useHW_Encoding  =   q{1};
our $localOutPath    =   q{/videos/Captures/};
our $gcsMountPoint   =   q{/gdrive};
our $gcsBucketName   =   q{pub};
our $gcsLogFile      =   qq{$home/gcsfuse.log};
our $authorization   =   qq{$home/revod-364904-c9d09a09225b.json};
our %streams=(
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

my $authKey = q{};
my $apiUrl  = q{};

# general wrapper for restful api calls
sub api_call() {
    my $method  = shift;
    my $webLoc  = shift;
    my $content = shift;
    return qq{Bad Input to api_call subroutine\n} unless $method =~ m/(GET|POST|PUT|PATCH|DELETE)/i;
    $method = uc($method);

    my $apiCall = qq{curl -s --request $method --header "Authorization: Bearer $authKey" };
    foreach my $key (%$content) {
        last if !$key; last if !$$content{$key};
        $apiCall .= qq{ --form "$key=$$content{$key}" };
    }
    $apiCall .= qq{$apiUrl/$webLoc};
}

sub encode_base64() {
    my $input = shift; 
    chomp $input;
    return qx{echo "$input" | base64 | tr -d "\n"};
}

sub decode_base64() {
    my $input = shift;
    chomp $input;
    return qx{echo "$input" | base64 -d | tr -d "\n"};
}

sub stage_env() {
    my $env = shift;
    my $path = shift;
    unless ($path =~ m!/\.env\s*$!) {
        if (-d $path) {
            $path =~ m!/$/!   ?
              $path .= q{/.env} :
              $path .= q{.env}  ;
        }
        else {
            if ($ENV{make_missing_paths}) {
                system(qq{mkdir -pv $path});
                &stage_env($env, $path);
            }
            else {
                die qq{Path $path does not exist}
            }
            
        }
    }
    system(touch $path) unless -f $path;
    open (my $fh, '>', $path);
    print $fh qq{$_=$$env{$_}\n} foreach (keys %$env);
    close $fh;
    return $path;
}

sub get_palette() {
    my %color_palette = (
        debug   =>  [ DARK BLUE ON_BLACK ],
        info    =>  [ BOLD BLUE ON_BLACK ],
        warning =>  [ FAINT YELLOW ON_BLACK ],
        error   =>  [ BLINK RED ON_BLACK ],
        critical=>  [ BOLD YELLOW ON_RED ],
        subname =>  [ FAINT CYAN ON_BLACK ],
        reset   =>  [ RESET ],
        default =>  [ WHITE ON_BLACK ],
        notice  =>  [ DARK GREEN ON_BLACK ],
        ambient =>  [ FAINT WHITE ON_BLACK ],
    );
    return \%color_palette
}

# does the coloring for printl / printxl
sub color_code() {
    my $colorCode = shift;
    my $message   = shift;
    my $color_palette = &get_palette();

    # Input Validation
    ## For some reason message isn't defined (what, then, are we logging)
    if (!defined $message) {
        # If, for instance, message found itself in $colorCode position because $colorCode was unable to be determined
        if (defined $colorCode) {
            my $message_in_color_field=1; # < start off with assumption message ended up in colorCode,
            #  do away with that assumption only if colorCode is not one of the existing palette options
            foreach my $color (keys %$color_palette) {
                $message_in_color_field-- if $color eq $colorCode;
            }
            if ($message_in_color_field) {
                # Set message accordingly
                $message   = $colorCode;
                # If no colorCode was able to be determined, go with default
                $colorCode = q{default}
            }
        }
        else {
            # No arguments were given. No sense breaking on this, but no sense doing anything either
            return;
        }
    }
    elsif (!$message || $message =~ m/^\s*$/) {
        &printl('debug', qq{color_code got:\n\tMessage: $message\n\tColorCode: $colorCode\n});
        # Empty arguments were given. No sense breaking on this, but no sense doing anything either
        return;
    }

    return qq{@{$$color_palette{$colorCode}}} . $message . qq{@{$$color_palette{reset}}};
}

# print and log an execution, get return code, sys/perl error string(s), and command output as return
sub printxl() {
    my $command = shift;
    my $error; my $sysError;
    my $returnCode;
    my $returnOutput;
    my $executionStatus = q{success};
    my $printVerbosity  = q{info};
    #################################
    {
        local $@;
        $returnOutput = eval {
            my $test = qx{$command 2>&1};
        };
        if ($@) {
            $error = $@;
            $printVerbosity = qq{error};
        }
        if ($!) {
            $sysError = $!;
            $printVerbosity = $error;
        }
        $returnCode = $? >> 8;
    }
    if (defined $error || defined $sysError) {
        $executionStatus = q{error};
        $error    = q{} unless defined $error;
        $sysError = q{} unless defined $sysError;
        $returnOutput .= qq{\n$error\n$sysError\n};
    }
    elsif ($returnCode) {
        $executionStatus = q{RCnonzero};
        $printVerbosity  = q{warning}
    }
    chomp $returnOutput;
    &printl($printVerbosity, $returnOutput);
    return ($executionStatus, $returnOutput, $returnCode);
}

# log a string, generally used with printl
sub log() {
    my $message = shift;
    $message .= $_ foreach (@_);
    qx{touch $logFile} unless -e $logFile;
    open (my $log, '>>', $logFile);
    print $log $message;
    close $log;
}

# print and log with formatting and colored verbosity/purpose
sub printl() {
    my $msgType = shift;
    my $message = shift;

    my $callingSub =  (caller(1))[3];
    $callingSub    =  q{-null-} unless $callingSub;
    $callingSub    =~ s/^main::(.)/\U$1/;
    $callingSub    =~ s/^/.::/;
    $callingSub    =~ s/$/::./;

    my $timestamp = &timestamp(qq{$timestampFormat});

    my $printThis = &compare_intensity($msgType, $verbosity);
    my $logThis   = &compare_intensity($msgType, $logLevel);

    my $msg     = qq{\n$timestamp\t$msgType\n$callingSub : $message\n};
    &log($msg) if $logThis;

    $callingSub = &color_code('subname', $callingSub);
    $message    = &color_code($msgType , $message);
    $msgType    = &color_code($msgType , $msgType);
    $msg        = qq{\n$timestamp\t$msgType\n$callingSub : $message\n};
    print qq{$msg\n} if $printThis;
}

# given a contextual importance and a relative threshold, which is stronger?
sub compare_intensity() {
    my $context   = shift;
    my $threshold = shift;

    my %severity = (
        debug   =>  4,
        info    =>  3,
        notice  =>  3,
        warning =>  2,
        error   =>  1,
        critical=>  0,
    );
    my ($nthresh, $ncntxt);
    $nthresh = $severity{$threshold};
    $ncntxt  = $severity{$context};
    
    return 1 if $ncntxt le $nthresh;
    return 0;
}

# makes sure we have our ioctl in place
sub verify_ioctl_module() {
    local $@;
    eval { require 'sys/ioctl.ph' };
    $@ ?
      return 0 :
      return 1 ;
}

# easy mode timestamps, know nothing and do it right every time (usually)
sub timestamp() {
    my $tsf = shift;
    my $converted;
    my %preconfigured = (
        "iso8601"       =>      q{yyyy-mm-dd_hh:mn:ss.mstz},
        "usStdDate"     =>      q{mm-dd-yyyy},
        "euStdDate"     =>      q{yyyy-mm-dd},
        "usStdDateTime" =>      q{mm-dd-yyyy_hh:mm:ss},
        "euStdDateTime" =>      q{yyyy-mm-dd_hh:mm:ss},
    );
    $converted = &get_tsf($preconfigured{$tsf}) if $preconfigured{$tsf};
    $converted = &get_tsf($tsf)             unless $preconfigured{$tsf};
    $converted =~ s/_/T/ if $tsf eq q{iso8601};
    return qx{date $converted | tr -d "\n"};
}

# Given a number of seconds, provide the value in the most reduced version under day/hour/minute/second notation
sub human_time() {
    my $seconds = shift;
    my $human_readable = '';
    my $layers = 1;
    my ($days, $hours, $minutes);
    if ($seconds >= 86400) {
        $days = ($seconds - ($seconds % 86400)) / 86400;
        $human_readable .= "$days Day "  if $days == 1;
        $human_readable .= "$days Days " unless $days == 1;
        $layers++;
        $seconds = $seconds % 86400;
    }
    if ($seconds >= 3600) {
        $hours = ($seconds - ($seconds % 3600)) / 3600;
        $human_readable .= "$hours Hour "  if $hours == 1;
        $human_readable .= "$hours Hours " unless $hours == 1;
        $layers++;
        $seconds = $seconds % 3600;
    }
    if ($seconds >= 60) {
        $minutes = ($seconds - ($seconds % 60)) / 60;
        $human_readable .= "$minutes Minute "  if $minutes == 1;
        $human_readable .= "$minutes Minutes " unless $minutes == 1;
        $layers++;
        $seconds = $seconds % 60;
    }
    if ($seconds > 0) {
        $human_readable .= "$seconds Second"  if $seconds == 1;
        $human_readable .= "$seconds Seconds" unless $seconds == 1;
    }
    $human_readable =~ s/(\d+\s[DHMS]\w+)\s?$/and $1/ if $layers > 1;
    $human_readable =~ s/(([^a][^n][^d]\s)?[DHMS]\w+)\s/$1, /g if $layers > 2;
    return "$human_readable";
}

sub get_video_duration() {
    my $filename = shift;
    my $duration = qx{ffprobe -i $filename 2>&1 | grep -oP 'Duration: (\\d{2}[:\\.]){3}\\d\\d' | sed 's/Duration: //' | tr -d "\\n"};
    return $duration;
}

sub duration_to_seconds() {
    use Math::Round qw(:all);
    my $duration = shift;
    if ($duration =~ m/(\d{2}):(\d{2}):(\d{2})(\.\d+)/) {
        my $hours   = $1;
        my $minutes = $2;
        my $seconds = $3;
        my $msecs   = $4;

        $minutes += ($hours   * 60);
        $seconds += ($minutes * 60);
        $seconds += nearest(1, $msecs);
        return $seconds;
    }
}

sub duration_difference() {
    my $t1 = shift;
    my $t2 = shift;
    if (!defined $t2 || !defined $t1 || $t1 !~ m/^\d+$/ || $t2 !~ m/^\d+$/) {
        &printl('error', qq{Must specify two parameters and both must be integers in seconds\n});
        return undef;
    }

    if ($t1 > $t2) {
        my $diff = $t1 - $t2;
        my $readable = &human_time($diff);
        &printl('debug', qq{Trimming $diff seconds ($readable) from the beginning of the video\n});
        return " -b $diff ";
    }
    elsif ($t2 > $t1) {
        my $diff = $t2 - $t1;
        my $readable = &human_time($diff);
        &printl('debug', qq{Trimming $diff seconds ($readable) from the end of the video\n});
        return " -e $diff ";
    }
}

# Given a human timestamp format, provide that format in a way that the date command can use to format
sub get_tsf() {
    my $append = shift;
    my $tsf = '+';
    my @preFormat;
    # a cheeky if 
    if (@preFormat = $append =~ m/([a-zA-Z]{2}+:?)([\W_]?)([a-zA-Z]{2}+:?)([\W_]?)([a-zA-Z]{2,4}+:?)([-_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?/){
        my @format;
        my $stack = 0;
        foreach my $part (@preFormat) {
            next if !defined $part;
            push @format, $part;
        }
        for (my $x = 0; $x <= $#format; $x++) {

            if ($format[$x] =~ m/dd/i) {
                $tsf .='%d';
            }
            elsif ($format[$x] =~ m/mm/i) {
                $tsf .= '%m' unless $format[$x] =~ m/:/;
                $tsf .= '%M:'    if $format[$x] =~ m/:/;
            }
            elsif ($format[$x] =~ m/mn/i) {
                $tsf .= '%M';
                $tsf .= ':' if $format[$x] =~ m/:/;
            }
            elsif ($format[$x] =~ m/yy/i) {
                if ($format[$x] =~ m/yyyy/i 
                  || (defined $format[$x+2] 
                    && ($format[$x] =~ m/yy/i 
                    && $format[$x+2] =~ m/yy/i) ) 
                  || defined $format[$x+1] 
                  && ($format[$x] =~ m/yy/i 
                  && $format[$x+1] =~ m/yy/i) ) {
                    $tsf .= '%Y';
                    $stack++;
                }
                elsif ($format[$x] =~ m/yy/i && $stack < 1) {
                     $tsf .= '%y';
                }
            }
            elsif ($format[$x] =~ m/hh/i) {
                $tsf .= '%H';
                $tsf .= ':' if $format[$x] =~ m/:/;
            }
            elsif ($format[$x] =~ m/ss/i) {
                $tsf .= '%S';
            }
            elsif ($format[$x] =~ m/ms/i) {
                $tsf .= '%3N';
            }
            elsif ($format[$x] =~ m/ns/i) {
                $tsf .= '%N';
            }
            elsif ($format[$x] =~ m/tz/) {
                $tsf .= '%z';
            }
            elsif ($format[$x] =~ m/TZ/) {
                $tsf .= '%Z';
            }
            else {
                $tsf .= $format[$x];
            }
        }
    }
    else {
        return "ERROR: Failed to format timestamp";
    }
    return $tsf;
}

# Remove trailing whitespace (very beginning, very end, no change in between)
sub strip_ws() {
    my $in = @_;
    my @out_all;
    if (ref($in)) {
        # Not a string, assume array
        # <,< well...just in case
        return undef if ref($in) eq q{HASH};
        foreach my $e (@$in) {
            my $out = &strip_ws($e);
            push @out_all, $out;
        }
        return @out_all;
    }
    else {
        my $out = $in;
        $out =~ s/^\s*//g;
        $out =~ s/\s*$//g;
        return $out;
    }
    return undef;
}

sub rsync_xfer(){
    my $source = shift;
    my $destination = shift;
    my $options = shift;
    my $command = q{rsync };
    $command .= &option_heiphenate(qq{$_}) foreach (@{$$options{bool}});
    $command .= &option_heiphenate(qq{$_}, qq{$$options{paramd}{$_}} ) foreach (keys %{$$options{paramd}});
    $command .= &option_heiphenate(q{vv}) if $PeePoo::verbosity eq q{debug};
    $command .= &option_heiphenate(q{v}) if $PeePoo::verbosity eq q{info};
    $command .= qq{$source $destination};

    &printl(q{debug}, qq{Running $command});
    return $command
    my ($status, $output, $rc) = &printxl($command);

    my %rc_lookup = (
        0    =>  q{success},
        1    =>  q{Syntax / Usage Error},
        2    =>  q{Protocol Incompatibility},
        3    =>  q{Errors selecting input/output files, dirs},
        4    =>  q{Requested action not supported: an attempt was made to manipulate 64-bit files on a platform that cannot support them; or an option was specified that is supported by the client and not by the server.},
        5    =>  q{Error starting client-server protocol},
        6    =>  q{Daemon unable to append to log-file},
        10   =>  q{Error in socket I/O},
        11   =>  q{Error in file I/O},
        12   =>  q{Error in rsync protocol data stream},
        13   =>  q{Errors with program diagnostics},
        14   =>  q{Error in IPC code},
        20   =>  q{Received SIGUSR1 or SIGINT},
        21   =>  q{Some error returned by waitpid()},
        22   =>  q{Error allocating core memory buffers},
        23   =>  q{Partial transfer due to error},
        24   =>  q{Partial transfer due to vanished source files},
        25   =>  q{The --max-delete limit stopped deletions},
        30   =>  q{Timeout in data send/receive},
        35   =>  q{Timeout waiting for daemon connection},
    );
    #$status .= qq{\n$rc_lookup{$rc}};
    #return $rc;
}

sub option_heiphenate() {
    my $paramName  = shift;
    my $paramValue = shift;
    if (length($paramName) == 1) {
        if (defined $paramValue) {
            return qq{ -$paramName $paramValue }
        }
        else {
            return qq{ -$paramName }
        }
    }
    else {
        if (defined $paramValue) {
            return qq{ --$paramName=$paramValue };
        }
        else {
            return qq{ --$paramName };
        }
    }
    return &printl(q{warning}, qq{Didn't determine what kind of heiphenation was appropriate here ($paramName)});
}

sub uri_encode() {
    my $string = shift;
    use URL::Encode;
    return &fuckit(&URL::Encode::url_encode($string));
}

# so fucking stupid I have to do this
sub fuckit() {
    my $f = shift;
    $f =~ s/\+/%20/g;
    $f =~ s/%21/!/g;
    return $f;
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

    &printl(q{debug}, qq{\n\n(watchbot command):\n$cmd $trigger_command\n\n});
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
    . qq{-o $outputDir/'$outputFile' };
    &printl(q{debug}, qq{\n\n(chat download command):\n$cmd\n\n});
    return $cmd . $trigger_command;
}

sub get_chatrender_cmd() {
    my $channel_name  = shift;
    my $outputDir     = shift;
    my $chatIn        = shift;
    my $chatOut       = shift;
    my $height        = shift;
    my $width         = shift;
    my $offset        = shift;
    # my $cmd = qq{docker run --rm -it }
    # . qq{--name "$channel_name-peepootwitchybot" }
    # . qq{-e running_application='twitch-downloader-cli' }
    # . qq{--network 'shitting_and_farting' -v nas_share:/nas/ }
    # . qq{ bxggs/twitch-downloader-cli:latest };
    my $cmd = q{TwitchDownloaderCLI };
    $offset = '' unless defined $offset;

    my $trigger_command = qq{chatrender }
    . qq{-i $outputDir/'$chatIn' $offset }
    . qq{--ffmpeg-path /mnt/c/Users/*/AppData/Local/Microsoft/WindowsApps/ffmpeg.exe }  # Until build option causing chatrender to fail is fixed, see https://github.com/lay295/TwitchDownloader/issues/753
    . qq{--outline --font-size 17 --skip-drive-waiting }
    . qq{-h $height -w $width  }
    . qq{--output $outputDir/'$chatOut'};
    &printl(q{debug}, qq{\n\n(twitchify command):\n$cmd\n\n});

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
    if ($useHW_Encoding){
        my $trigger_command =
        qq{ -y -vsync 2  -hwaccel cuda -i $outputDir/'$video'        \\
        -i $outputDir/'$chat'                                        \\
        -filter_complex hstack                                       \\
        -c:a copy          -c:v h264_nvenc          -rc-lookahead 20 \\
        -tune hq -b:v 5M   -bufsize 5M              -maxrate 10M     \\
        -qmin 0 -bf 3      -b_ref_mode middle       -temporal-aq 1   \\
        $gcsMountPoint/$gcsBucketName/$channel_name/'$vod' };
        &printl(q{debug}, qq{\n\n(pogvodbot command):\n$cmd\n\n});
        return $cmd . $trigger_command;
    }
    else {
        my $trigger_command = qq{ -i $outputDir/'$video'                  \\
        -i $outputDir/'$chat'                                             \\
        -filter_complex hstack -preset veryfast -vsync 2                  \\
        $gcsMountPoint/$gcsBucketName/$channel_name/'$vod' };
        &printl(q{debug}, qq{\n\n(pogvodbot command):\n$cmd\n\n});
        return $cmd . $trigger_command;
    }
}

sub generate_ratio() {
    use POSIX;
    my $fn = shift;
    my $stream = qx{ffprobe -i $fn 2>&1};
    my %chat_ratio = (
        1080 => 422,
        720  => 280,
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

sub trim_chat_by() {
    my $vod  = shift;
    my $chat = shift;
    my $duration1 = &duration_to_seconds(&get_video_duration($vod));
    if ($duration1) {
	    &printl(q{debug}, qq{VOD has duration of $duration1 seconds\n});
    }
    else {
	    &printl(q{warning}, qq{VOD duration was unable to be determined\n});
    }
    my $duration2;
    if ($chat =~ m/json['"]*$/) {
        $duration2 = &get_chat_json_duration($chat);
	if ($duration2) {
		&printl(q{debug}, qq{Chat has duration of $duration2 seconds, derived from the JSON\n});
	}
	else {
		&printl(q{warning}, qq{Chat duration was unable to be determined from the JSON\n});
	}
    }
    elsif($chat =~ m/mp4['"]*$/) {
        $duration2 = &duration_to_seconds(&get_video_duration($chat));
	if ($duration2) {
		&printl(q{debug}, qq{Chat has duration of $duration2 seconds, derived from the rendered video\n});
	}
	else {
		&printl(q{warning}, qq{Chat duration was unable to be determined from the mp4\n});
	}
    }
    &printl(q{debug}, qq{Determining delta between Duration1(vod), $duration1 and Duration2(chat), $duration2\n});
    my $diff = &duration_difference($duration2, $duration1);
    &printl(q{debug}, qq{Got diff $diff\n});
    return $diff;
}

sub get_chat_json_duration() {
    my $chat = shift;
    my $duration = qx{grep -oP '"end":\\d{4,}' $chat | sed 's/"end"://' | tr -d "\\n"};
    if (!$duration) {
        &printl('warning', qq{Searching $chat for "end" did not result in a timestamp\nTrying using Duration...\n});
        $duration = qx{grep -oP '"duration": "((\\d+h)?(\\d+m)?(\\d+s)?)+"' $chat | sed 's/"duration": //' | tr -d "\\n"};
        if ($duration =~ m/(\d*)h(\d*)m(\d*)s/) {
            my $hours = $1;
            my $minutes = $2;
            my $seconds = $3;
            $minutes += ($hours   * 60);
            $seconds += ($minutes * 60);
            return $seconds;
        }
        else {
            return q{};
        }
    }
    else {
        return $duration;
    }
}

############################################################################

sub start_headless_chromium() {
    my $docker;
    -f qq{$home/bin/docker}          ?
      $docker = qq{$home/bin/docker} :
      $docker = q{docker}            ;
    my ($status, $output, $rc) = &printxl(qq{$docker start peepooemu});
    if ($status ne 'success') {
        &printxl(qq{$docker run -d --restart=unless-stopped  --name=peepooemu -p 9229:9222 --cap-add=SYS_ADMIN justinribeiro/chrome-headless});
        sleep 5;
    }
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
        port          => 9229,
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
        elsif ($try > 9000) {
            return undef;
        }
        else {
            &prune_headless_chromium();
            &start_headless_chromium();
            &get_vod_id($channel_name, 40000000);
        }
    }
}

sub matches_timestamp() {
    my $fn = shift;
    # Matches pretty much any timestamp with a date and time
    return 1 if $fn =~ m/^([a-zA-Z]{2}+:?)([\W_]?)([a-zA-Z]{2}+:?)([\W_]?)([a-zA-Z]{2,4}+:?)([-_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?([\W_]?)?([a-zA-Z]{2}+:?)?\./;
    return 0;
}

sub prune_headless_chromium() {
    my $docker;
    -f qq{$home/bin/docker}          ?
      $docker = qq{$home/bin/docker} :
      $docker = q{docker}            ;
    &printxl(qq{$docker container rm -f peepooemu}) if qx{$docker container ls} !~ m/peepooemu/;
}

sub wait_for_finalization() {
    my $channel_name = shift;
    my $cmd = qq{ps aux | grep yt-dlp | grep $channel_name | grep -v grep | tr -d "\n"};
    while (qx{$cmd}) {
        &printl(q{notice}, "finalizing VOD recording...\n");
        sleep 10;
    }
    return 1;
}

################ Google Cloud Storage - Mount, Transfer, Unmount ################

sub transfer() {
    my $channel_name = shift;
    my $localPath    = shift;
    my $localPath_fn = shift;
    my $transfer_dir = qq{$gcsMountPoint/$gcsBucketName/$channel_name/};

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
    if (!-d qq{$gcsMountPoint/$gcsBucketName/$channel_name}) {
        &printl(q{info}, "Mounting GCS Fuse.");

        &printxl(qq{gcsfuse --key-file $authorization --log-file $gcsLogFile --debug_gcs --debug_fuse --debug_http --implicit-dirs $gcsBucketName $gcsMountPoint});
        my $is_mounted = qx{ls -l $gcsMountPoint/ | wc -l | tr -d "\n"};
        if ($is_mounted) {
            &printl(q{info}, qq{Mounting completed.});
            return $is_mounted;
        }
        else {
            &printl(q{info}, qq{Failed to mount.});
            return $is_mounted;
        }
    }
    else {
        &printl(q{info}, qq{Mount already present.});
        return 1;
    }
}

sub teardown_transient_storage() {
    return &printxl(qq{umount $gcsMountPoint})
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
    return &rsync_xfer($source, $destination, $options);
}
##################################################################################

sub post_notification() {
    use WebService::Discord::Webhook;
    my $channel_name = shift;
    my $video = shift;
    my @urls;
    push @urls, $streams{channel}{gamedazed}{discord};
    #my $dev_discord_url = $streams{channel}{$channel_name}{discord};
    #my $personal_discord_url = $streams{channel}{gamedazed}{discord};
    #foreach my $notification ($dev_discord_url, $personal_discord_url) {
    #    # testing for definition and non-null before attempting to operate on it
    #    if (defined $notification) {
    #        if ($notification) {
    #            push @urls, $notification;
    #        }
    #    }
    #}

    # gcp
    #my $storage_bucket_pubDir = qq{https://storage.googleapis.com/$gcsBucketName/$channel_name};

    my $uriTitle = &uri_encode($video);
    my $clean    = qr/^.*?\Q$channel_name\E\s?\-\s?(.*)\s[｜\|].*$/i;
    #my $link = qq{$storage_bucket_pubDir/$uriTitle};
    $video  =~ s/$clean/$1/;
    my $notification = qq{$channel_name: $video is ready\n};
    #my $notification = qq{$video\n$link};

    foreach my $url (@urls) {
        my $hook = WebService::Discord::Webhook->new( $url );
        $hook->get();
        $hook->execute( content => $notification );
    }
}

##################################################################################



$| = 1;
