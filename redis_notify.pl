use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use Redis;
$VERSION = '0.0.1';
%IRSSI = (
    authors     => 'Ilya Averyanov',
    contact     => 'ilya@averyanov.org',
    name        => 'redis_notify',
    description => 'Write a notification to Redis that shows who is talking to you in which channel.',
    url         => 'https://github.com/savonarola/irssi-remote-notifications',
    license     => 'GNU General Public License',
    changed     => '2012-02-05'
);


use constant REDIS => 'averyanov.org:6379';
use constant REDIS_DB => 1;
use constant REDIS_KEY => 'irssi:notifications';
use constant REDIS_PASSWORD => 'XXX';

#--------------------------------------------------------------------
# In parts based on fnotify.pl 0.0.3 by Thorsten Leemhuis'
# http://www.leemhuis.info/files/fnotify/
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# Create redis client
#--------------------------------------------------------------------
sub redis_client {
    my $redis = Redis->new(server => REDIS, encoding => undef);
    $redis->auth(REDIS_PASSWORD) if REDIS_PASSWORD;
    $redis->select(REDIS_DB);
    return $redis;
}

#--------------------------------------------------------------------
# Write message to Redis
#--------------------------------------------------------------------
sub push_notification {
    my ($msg) = @_;
    eval {
        my $redis = redis_client();
        $redis->lpush(REDIS_KEY, $msg);
    };
}

#--------------------------------------------------------------------
# Private message parsing
#--------------------------------------------------------------------

sub priv_msg {
    my ($server,$msg,$nick,$address,$target) = @_;
    push_notification($nick." " .$msg );
}

#--------------------------------------------------------------------
# Printing hilight's
#--------------------------------------------------------------------

sub hilight {
    my ($dest, $text, $stripped) = @_;
    if ($dest->{level} & MSGLEVEL_HILIGHT) {
        push_notification($dest->{target}. " " .$stripped );
    }
}

#--------------------------------------------------------------------
# Irssi::signal_add_last / Irssi::command_bind
#--------------------------------------------------------------------

Irssi::signal_add_last("message private", "priv_msg");
Irssi::signal_add_last("print text", "hilight");

#- end
