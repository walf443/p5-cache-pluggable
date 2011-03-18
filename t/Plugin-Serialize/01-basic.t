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
use JSON::XS;
use Test::Cache::Pluggable;

my ($guard, $port) = Test::Cache::Pluggable->guard_memcached;

my $memcache = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port" }],
    serialize_methods => [sub { shift }, sub { shift }],
});

my $serialize_methods = [
    sub { JSON::XS->new->utf8->encode(shift) },
    sub { JSON::XS->new->utf8->decode(shift) },
];
my $cache = t::Cache->new(
    cache => $memcache,
    serialize_methods => $serialize_methods,
);

my $t = Test::Cache::Pluggable->new(cache => $cache);
$t->run({ key => "foo", value => { foo => "bar" }});
$t->run({ key => "foo", value => { "あいうえお" => "かきくけこ" }});

done_testing();

