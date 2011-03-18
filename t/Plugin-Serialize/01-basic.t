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
use Test::Differences qw/eq_or_diff/;

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

subtest 'ascii' => sub {
    $t->run({ key => "foo", value => { foo => "bar" }});
    my $value = $memcache->get("foo");
    eq_or_diff($serialize_methods->[1]->($value), { foo => "bar" }, "serialize ok");
};

subtest 'flagged utf8' => sub {
    $t->run({ key => "foo", value => { "あいうえお" => "かきくけこ" }});
    my $value = $memcache->get("foo");
    eq_or_diff($serialize_methods->[1]->($value), { "あいうえお" => "かきくけこ" }, "serialize ok");
};

done_testing();

