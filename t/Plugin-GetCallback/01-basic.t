package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::GetCallback);

package main;
use strict;
use warnings;
use Test::More;
use Cache::Pluggable;
use Test::Cache::Pluggable;
use Cache::Memcached::Fast;

my ($guard, $port) = Test::Cache::Pluggable->guard_memcached;

my $memcache = Cache::Memcached::Fast->new({
    servers => [{ address => "localhost:$port" }],
});

my $cache = t::Cache->new(
    cache => $memcache,
    namespace => 'namespace',
);

my $counter = 0;
my $code = sub {
    my $key = shift;
    $counter++;
    return $key x 3;
};
{
    my $value = $cache->get_callback({
        key => "hoge",
        expires_in => 10,
    } => $code);
    is($value, "hogehogehoge", "get_callback should return callback result");
    is($counter, 1, "callback should be called");
    my $got_value = $cache->get({ key => "hoge"});
    is($value, "hogehogehoge", "get_callback should set value");
}

{
    my $value = $cache->get_callback({
        key => "hoge",
        expires_in => 10,
    } => $code);
    is($value, "hogehogehoge", "get_callback should return callback result");
    is($counter, 1, "callback should not be called because value can get");
}

done_testing();

