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

# does the coloring for printl / printxl
sub color_code() {
    my $colorCode = shift;
    my $message   = shift;
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

    &printl(q{warning}, qq{The log identifier $colorCode is not valid\n!})
      and return qq{@{$color_palette{default}}} . $message . qq{@{$color_palette{reset}}}
      unless defined $color_palette{$colorCode};

    return qq{@{$color_palette{$colorCode}}} . $message . qq{@{$color_palette{reset}}};
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
        $executionStatus = q{failed};
        $error    = q{} unless defined $error;
        $sysError = q{} unless defined $sysError;
        $returnOutput .= qq{\n$error\n$sysError\n};
    }
    elsif ($returnCode) {
        $executionStatus = q{failed};
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

# Given two epochs, provide the difference in the most reduced version under day/hour/minute/second notation
sub human_time() {
    my $seconds = shift;
    my $human_readable = '';
    my ($days, $hours, $minutes);
    if ($seconds >= 86400) {
        $days = ($seconds - ($seconds % 86400)) / 86400;
        $seconds = $seconds % 86400;
    }
    if ($seconds >= 3600) {
        $hours = ($seconds - ($seconds % 3600)) / 3600;
        $seconds = $seconds % 3600;
    }
    if ($seconds >= 60) {
        $minutes = ($seconds - ($seconds % 60)) / 60;
        $seconds = $seconds % 60;
    }
    my $layers = 1;
    $human_readable .= "$days Days " and ++$layers if defined $days;
    $human_readable .= "$hours Hours " and ++$layers if defined $hours;
    $human_readable .= "$minutes Minutes " and ++$layers if defined $minutes;
    $human_readable .= "$seconds Seconds" if $seconds > 0;
    $human_readable =~ s/(\d+\s[DHMS]\w+)$/and $1/ if $layers > 1;
    return "$human_readable\n";
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
    $command .= &option_heiphenate(qq{--$_ }) foreach (@{$$options{bool}});
    $command .= &option_heiphenate(qq{--$_=$$options{paramd}{$_}} ) foreach (keys %{$$options{paramd}});
    $command .= &option_heiphenate(q{vv }) if $PeePoo::verbosity eq q{debug};
    $command .= &option_heiphenate(q{v }) if $PeePoo::verbosity eq q{info};
    $command .= qq{$source $destination};

    &PeePoo::printxl(q{debug}, qq{Running $command});

    my ($status, $output, $rc) = &PeePoo::printxl($command);

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
    $status .= qq{\n$rc_lookup{$rc}};
    return $rc;
}

sub option_heiphenate() {
    my $paramName  = shift;
    my $paramValue = shift;
    if (length($paramName) == 1) {
        if (defined $paramValue) {
            return qq{-$paramName $paramValue}
        }
        else {
            return qq{-$paramName}
        }
    }
    else {
        if (defined $paramValue) {
            return qq{--$paramName=$paramValue};
        }
        else {
            return qq{--$paramName};
        }
    }
    return &PeePoo::printl(q{warning}, qq{Didn't determine what kind of heiphenation was appropriate here ($paramName)});
}

$| = 1;
