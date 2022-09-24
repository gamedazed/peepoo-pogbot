#! /usr/bin/perl

use strict;
use warnings;
no strict 'refs';

use Parallel::ForkManager;
use WWW::Twitch;

my $quiet_flag = 0;
my $test_flag = 1;

my @watch_list = qw{nyanners lordaethelstan nemu};
my $fm_poll    = new Parallel::ForkManager(scalar(@watch_list));
my $fm_record  = new Parallel::ForkManager(scalar(@watch_list));
my %streams;

sub main() {
    &poll;
}

sub get_chat() {
    my $vod_id   = shift;
    my $vod_file = shift;
    print qx{/usr/local/bin/TwitchDownloaderCLI -m ChatDownload --embed-emotes --id $vod_id -o ${vod_file}_chat.json};
    print qx{/usr/local/bin/TwitchDownloaderCLI -m ChatRender -i "${vod_file}_chat.json" -h 1080 -w 422 --framerate 60 --update-rate 0 --font-size 18 -o ${vod_file}_chat.mp4};
    return qq{${vod_file}_chat.mp4};
}

sub two_as_one {
    my $vod  = shift;
    my $chat = shift;
    my $out  = shift;
    foreach($vod, $chat) {
        die "Unable to locate $_" unless -e $_;
    }
    print qx{ffmpeg -i "$vod" -i "$chat" -filter_complex hstack -preset veryfast "$out"};
}

my $chat_file = &get_chat("41307826459", q{41307826459 - nemu.mp4});
my $merged_file = &two_as_one(q{41307826459 - nemu.mp4}, $chat_file, q{final_41307826459 - nemu.mp4});
die "TESTING COMPLETE!";

sub poll() {
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
    POLL:
    foreach my $chan_name (@watch_list) {
        $fm_poll->start($chan_name) and next POLL;
        my $vod_id  = &get_live_status($chan_name);
        $streams{$vod_id}{channel}   = $chan_name;
        $streams{$chan_name}{vod_id} = $vod_id;
        &record($chan_name, $vod_id);
        $fm_poll->finish;
    }
}
sub record() {
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
        print qq{Started recording $streams{$ident}{channel} [$ident] - ($pid)\n};
    });
    RECORD:
    foreach my $chan_name (@watch_list) {
        next unless $streams{$chan_name}{vod_id};
        my $vod_id = $streams{$chan_name}{vod_id}; 
        $fm_record->start($vod_id) and next RECORD;
        my $filename = &live_trigger($streams{$vod_id}{channel}, $vod_id);
        my $chat_file = &get_chat($vod_id, $filename);
        my $merged_file = &two_as_one($filename, $chat_file, qq{final_{$filename}});
        $fm_record->finish;
    }
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

while (1) {
    &main;
}