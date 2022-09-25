#! /usr/bin/perl

use strict;
use warnings;
no strict 'refs';

use Parallel::ForkManager;
use WWW::Twitch;

my $quiet_flag = 0;

my $configFile = q{pogpoll.ini};
my @watch_list = qw{nyanners lordaethelstan};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));
my $fm_record  = new Parallel::ForkManager(scalar(@watch_list));

my %streams;
my %config;

sub main() {
    my ($vod_id, $chan_name) = &poll();
    my $fileName             = &record($chan_name, $vod_id);
    my $merged_file          = &two_as_one($fileName, qq{${$vod_id}-${$chan_name}_chat.mp4}, qq{final_$fileName});
}

sub poll() {
    ##################### Callbacks #####################
    $fm_poll->run_on_finish(sub {
        my ($pid, $returnCode, $ident) = @_;
        print qq{$ident went live!\n};
    });
    $fm_poll->run_on_wait(sub {
        my ($pid, $ident) = @_; 
        print qq{Actively polling for streamers..\n};
    }, 5);
    $fm_poll->run_on_start(sub {
        my ($pid, $ident) = @_;
        print qq{Started polling for $ident - ($pid)!\n};
    });
    #####################################################

    POLL:
    foreach my $chan_name (@watch_list) {
        $fm_poll->start($chan_name) and next POLL;
        my $vod_id  = &get_live_status($chan_name);
        $streams{$vod_id}{channel}   = $chan_name;
        $streams{$chan_name}{vod_id} = $vod_id;
        $fm_poll->finish;
        return($vod_id, $chan_name);
    }
}

sub record() {
    my $chan_name = shift;
    my $vod_id    = shift;
    ##################### Callbacks #####################
    $fm_record->run_on_finish(sub {
        my ($pid, $returnCode, $ident) = @_;
        print qq{$ident recorded successfully - "$streams{$ident}{filename}"!\n} 
            unless $returnCode;
    });
    $fm_record->run_on_wait(sub {
        print qq{Actively recording a stream - ($$)\n};
    }, 60);
    $fm_record->run_on_start(sub {
        my ($pid, $ident) = @_;
        &get_chat($vod_id, qq{$vod_id-$chan_name});
        print qq{Started recording $streams{$ident}{channel} [$ident] - ($pid)\n};
    });
    #####################################################
    RECORD:
    foreach my $chan_name (@watch_list) {
        $fm_record->start($vod_id) and next RECORD;
        my $filename = &live_trigger($chan_name, $vod_id);
        $fm_record->finish;
        return $filename;
    }
}

sub two_as_one {
    my $vod  = shift;
    my $chat = shift;
    $config{'vod-n-chat_filename'} = qq{final_$vod} unless defined $config{'vod-n-chat_filename'};
    $config{'vod-n-chat_filename'} = $config{'vod-n-chat_path'} . $config{'vod-n-chat_filename'};
    print qx{ffmpeg -i "$vod" -i "$chat" -filter_complex hstack -preset veryfast "$config{'vod-n-chat_filename'}"};
}


sub get_live_status {
    my $channel_name = shift;
    my $twitch = WWW::Twitch->new();
    my $is_live;
    until($is_live) {
        $is_live = $twitch->live_stream($channel_name);
    }
    return $is_live->{id} if ($is_live);
}

sub live_trigger {
    my $channel_name = shift; 
    my $vod_id = shift;
    my $filename = "$vod_id - $channel_name.mp4";
    $streams{$channel_name}{filename} = $filename;
    $quiet_flag ? 
        print qx{youtube-dl -q -o "$filename" https://twitch.tv/$channel_name} :
        print qx{youtube-dl    -o "$filename" https://twitch.tv/$channel_name} ;
    $fm_record->finish;
    return $filename;
}

sub get_chat() {
    my $vod_id   = shift;
    my $vod_file = shift;
    my $out = $vod_file; $out =~ s/\.mp4$/_chat.mp4/;
    print qx{/usr/local/bin/TwitchDownloaderCLI -m ChatDownload --embed-emotes --id $vod_id -o ${vod_file}_chat.json};
    print qx{/usr/local/bin/TwitchDownloaderCLI -m ChatRender -i "${vod_file}_chat.json" -h 1080 -w 422 --framerate 60 --update-rate 0 --font-size 18 -o ${vod_file}_chat.mp4};
    return qq{${vod_file}_chat.mp4};
}


sub parse_config() {
    open (my $fh, '<', $configFile);
    my @config = <$fh>;
    close $configFile;

    my @properties = qw(transcoding_path vod-n-chat_path vod-n-chat_filename);

    for (my $line = 0; defined $config[$line]; $line++) {
        $config[$line] =~ s/#.*//;
        next if $config[$line] =~ m/^\s*$/;
        foreach my $prop (@properties) {
            if ($config[$line] =~ m/$prop?\s*[=\:]\s*(.*)$/) {
                my $value = $1;
                if ($prop =~ m/path/) {
                    -e $value ?
                      $config{$prop} = $value :
                      $config{$prop} = './';
                    if ($config{$prop} !~ m~/$~) {
                        $config{$prop} .= '/';
                    }
                }
                else {
                     $config{$prop} = $config[$line]
                }
            }
        }
    }
}

&parse_config();

while (1) {
    &main;
}