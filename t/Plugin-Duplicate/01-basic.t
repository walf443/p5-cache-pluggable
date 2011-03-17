package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::Duplicate);

package main;
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

my $port1 = empty_port();
my $proc1 = proc_guard(scalar(which('memcached')), '-p', $port1);
wait_port($port1);
my $port2 = empty_port();
my $proc2 = proc_guard(scalar(which('memcached')), '-p', $port2);
wait_port($port2);

my $memcache1 = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port1" }],
});

my $memcache2 = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port2" }],
});

my $cache = t::Cache->new(
    cache => $memcache1,
    duplicate => [$memcache2],
);

subtest 'set interface' => sub {
    subtest 'hashref interface' => sub {
        lives_ok(sub {
            $cache->set({ key => 'hoge', value => 'fuga'});
        }, 'lives ok');
        is($memcache1->get("hoge"), "fuga", "memcache1 get OK");
        is($memcache2->get("hoge"), "fuga", "memcache2 get OK");
    };

    subtest 'key interface' => sub {
        lives_ok(sub {
            my $val = $cache->set('hoge' => 'fuga');
        }, 'lives ok');
        is($memcache1->get("hoge"), "fuga", "memcache1 get OK");
        is($memcache2->get("hoge"), "fuga", "memcache2 get OK");
    };
};

done_testing();

