package t::Cache;
use Mouse;
extends 'Cache::Pluggable';

with qw(Cache::Pluggable::Plugin::Serialize);

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
use JSON::XS;

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

subtest 'key_filter interface' => sub {
    subtest 'default key_filter' => sub {
        my $val = $cache->key_filter("foo");
        is($val, "foo", "should be same as argument");
    };
};

{
    my $value = {
        key => "value",
    };
    my $encoded_value = $serialize_methods->[0]->($value);
    $memcache->set('hoge', $encoded_value);
}

subtest 'get interface' => sub {
    subtest 'hashref interface' => sub {
        lives_ok(sub {
            my $val = $cache->get({ key => 'hoge' });
            is_deeply($val, { key => "value" }, 'fetching value ok');
        }, 'lives ok')
            or diag($@);
    };

    subtest 'key interface' => sub {
        lives_ok(sub {
            my $val = $cache->get('hoge');
            is_deeply($val, { key => "value" }, 'fetching value ok');
        }, 'lives ok')
            or diag($@);
    };
};

subtest 'set interface' => sub {
    subtest 'hashref interface' => sub {
        $cache->set({ key => "hoge", value => { key => "value" } });
        lives_ok(sub {
        }, 'lives ok')
            or diag($@);
        my $value = $cache->get('hoge');
        is_deeply($value, { key => "value" }, "should be same");
    };

    subtest 'key interface' => sub {
        lives_ok(sub {
            my $val = $cache->set('hoge' => { key => "value" });
        }, 'lives ok')
            or diag($@);
        my $value = $cache->get('hoge');
        is_deeply($value, { key => "value" }, "should be same");
    };
};

done_testing();

