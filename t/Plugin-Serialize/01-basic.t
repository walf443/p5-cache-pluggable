package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::Serialize);

package main;
use strict;
use warnings;
use utf8;
use Test::More;
use Cache::Pluggable;
use Cache::Memcached::Fast;
use Cache::Memcached;
use JSON::XS;
use Test::Cache::Pluggable;
use Test::Differences qw/eq_or_diff/;

my ($guard, $port) = Test::Cache::Pluggable->guard_memcached;

my $memcache_of = {
    'Cache::Memcached::Fast' => Cache::Memcached::Fast->new({
        servers => [{ address => "localhost:$port" }],
        namespace => 'Cache::Memcached::Fast',
    }),
    'Cache::Memcached' => Cache::Memcached->new({
        servers => ["localhost:$port"],
        namespace => 'Cache::Memcached',
    }),
};

for my $module ( keys %{ $memcache_of } ) {
    subtest $module => sub {
        my $memcache = $memcache_of->{$module};

        my $cache = t::Cache->new(
            cache => $memcache,
        );

        my $t = Test::Cache::Pluggable->new(cache => $cache);

        subtest 'ascii' => sub {
            $t->run({ key => "foo", value => { foo => "bar" }});
            my $value = $memcache->get("foo");
            eq_or_diff($t->cache->serialize_methods->[1]->($value), { foo => "bar" }, "serialize ok");
        };

        subtest 'flagged utf8' => sub {
            $t->run({ key => "foo", value => { "あいうえお" => "かきくけこ" }});
            my $value = $memcache->get("foo");
            eq_or_diff($t->cache->serialize_methods->[1]->($value), { "あいうえお" => "かきくけこ" }, "serialize ok");
        };

    };
}

done_testing();

