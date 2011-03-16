use strict;
use warnings;
use Test::More;
use Cache::Pluggable;
use Proc::Guard;
use Test::TCP qw/empty_port wait_port/;
use File::Which qw/which/;
use Cache::Memcached::Fast;
use Try::Tiny;

sub lives_ok {
    my ($cb, $msg) = @_;

    my $error;
    try { $cb->() } catch {
        $error = $_;
    };
    ok(! defined $error, $msg);
}

my $port = empty_port();
my $proc = proc_guard(scalar(which('memcached')), '-p', $port);
wait_port($port);

my $memcache = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port" }],
});

my $cache = Cache::Pluggable->new(
    cache => $memcache,
);

$memcache->set('hoge', 'fuga');

subtest 'get interface' => sub {
    subtest 'hashref interface' => sub {
        lives_ok(sub {
            my $val = $cache->get({ key => 'hoge' });
            is($val, 'fuga', 'fetching value ok');
        }, 'lives ok');
    };

    subtest 'key interface' => sub {
        lives_ok(sub {
            my $val = $cache->get('hoge');
            is($val, 'fuga', 'fetching value ok');
        }, 'lives ok');
    };
};

subtest 'set interface' => sub {
    subtest 'hashref interface' => sub {
        lives_ok(sub {
            $cache->set({ key => 'hoge', value => 'fuga'});
        }, 'lives ok');
    };

    subtest 'key interface' => sub {
        lives_ok(sub {
            my $val = $cache->set('hoge' => 'fuga');
        }, 'lives ok');
    };
};

done_testing();
