package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::Namespace);

package main;
use strict;
use warnings;
use Test::More;
use Cache::Pluggable;
use Test::Cache::Pluggable;
use Cache::Memcached::Fast;

my ($guard, $port) = Test::Cache::Pluggable->guard_memcached();
my $memcache = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port" }],
});

my $cache = t::Cache->new(
    cache => $memcache,
    namespace => 'namespace',
);

my $t = Test::Cache::Pluggable->new(
    cache => $cache,
);

subtest 'key_filter interface' => sub {
    subtest 'default key_filter' => sub {
        my $val = $cache->key_filter("foo");
        is($val, "namespace:foo", "should be same as argument");
    };
};

$t->run({ key => "hoge", value => "fuga" });

done_testing();

