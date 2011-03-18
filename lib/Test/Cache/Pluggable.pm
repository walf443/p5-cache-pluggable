package Test::Cache::Pluggable;
use Mouse;
use Test::More;
use Test::Differences qw/eq_or_diff/;
use Data::Dumper;
use Proc::Guard qw();
use Test::TCP qw();
use File::Which qw();
use Try::Tiny;

has 'cache' => (
    is => 'ro',
);

no Mouse;

sub lives_ok {
    my ($cb, $msg) = @_;

    my $error;
    try { $cb->() } catch {
        $error = $_;
    };
    ok(! defined $error, $msg)
        or diag($error);
}

sub guard_memcached {
    my ($class, $cb) = @_;

    my $program = File::Which::which('memcached')
        or plan skip_all => q{This test require 'memcached'};

    my $port = Test::TCP::empty_port();
    my $proc = Proc::Guard::proc_guard($program, '-p', $port, '-l', '127.0.0.1');
    Test::TCP::wait_port($port);

    if ( defined $cb ) {
        $cb->($port);
    }
    return ($proc, $port);
}

sub run {
    my ($self, $hashref, $test_name) = @_;

    $test_name ||= "Test::Cache::Pluggable#run";

    subtest $test_name => sub {
        subtest 'set/get testing' => sub {
            subtest 'hashref interface' => sub {
                lives_ok(sub {
                    $self->cache->set($hashref);
                }, 'set ok');

                my $value;
                lives_ok(sub {
                    $value = $self->cache->get($hashref);
                }, 'get ok');

                eq_or_diff($value, $hashref->{value}, "get/set ok")
                    or Dumper($value);

            };

            subtest 'key interface' => sub {
                lives_ok(sub {
                    my $val = $self->cache->set($hashref->{key} => $hashref->{value});
                }, 'set ok');

                my $value;
                lives_ok(sub {
                    $value = $self->cache->get($hashref->{key});
                }, 'get ok');

                eq_or_diff($value, $hashref->{value}, "get/set ok")
                    or Dumper($value);

            };
        };
    };

}

1;
__END__

=head1 NAME

Test::Cache::Pluggable - test for your plugin

=head1 SYNOPSIS

    package t::Cache;
    use Mouse;
    extends 'Cache::Pluggable';
    with qw(YourPlugin);

    package main;
    use Test::Cache::Pluggable;

    my ($guard, $port) = Test::Cache::Pluggable->guard_memcached();

    my $cache = t::Cache->new(
        cache => $cache
    );
    my $c = Test::Cache::Pluggable->new($cache);
    $c->run({ key => "foo", value => "bar", extends => 10 });

=head1 DESCRIPTION

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<CLI>

+<Cache::Cache>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

