#!/usr/bin/perl
use strict;
use Redis;
use Encode;

use constant REDIS => 'averyanov.org:6379';
use constant REDIS_DB => 1;
use constant REDIS_KEY => 'irssi:notifications';
use constant REDIS_PASSWORD => 'XXX';

sub redis_client {
    my $redis = Redis->new(server => REDIS, encoding => undef);
    $redis->auth(REDIS_PASSWORD) if REDIS_PASSWORD;
    $redis->select(REDIS_DB);
    return $redis;
}

sub notify {
    my ($msg) = @_;
    my ($from, $message) = split(/\s+/, $msg, 2);
    system '/usr/local/bin/growlnotify', '-n', $from, '-t', "irssi: $from", '-a', 'XChat Azure', '-m', $message;
}

my $redis = redis_client();
while(1) {
    while(my $msg = $redis->rpop(REDIS_KEY)) {
        notify($msg);
    }
    select undef, undef, undef, 0.1;
}

