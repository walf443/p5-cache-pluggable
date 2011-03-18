package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::Duplicate);

package main;
use strict;
use warnings;
use Test::More;
use Cache::Pluggable;
use Cache::Memcached::Fast;
use Cache::Memcached;
use Test::Cache::Pluggable;

my ($guard1, $port1) = Test::Cache::Pluggable->guard_memcached;
my ($guard2, $port2) = Test::Cache::Pluggable->guard_memcached;

my $memcache1 = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port1" }],
});

my $memcache2 = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port2" }],
});
my $memcache3 = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port2" }],
});


my $cache = t::Cache->new(
    cache => $memcache1,
    duplicate => [$memcache2, $memcache3],
);

my $t = Test::Cache::Pluggable->new(cache => $cache);

$t->run({ key => "hoge", value => "fuga" });
is($memcache1->get("hoge"), "fuga", "memcache1 get OK");
is($memcache2->get("hoge"), "fuga", "memcache2 get OK");
is($memcache3->get("hoge"), "fuga", "memcache3 get OK");

done_testing();

