package Cache::Pluggable::Plugin::Duplicate;
use Mouse::Role;

has 'duplicate' => (
    is => 'ro',
    isa => "ArrayRef",
    default => sub {
        [],
    },
);

around '_set' => sub {
    my $orig = shift;
    my $self = shift;

    my @args = @_;
    $orig->($self, @args);
    for my $cache ( @{ $self->duplicate } ) {
        $cache->set(@args);
    }
};

no Mouse::Role;

1;

__END__
=head1 NAME

Cache::Pluggable::Plugin::Duplicate - duplicate data

=head1 SYNOPSIS

  package Proj::Cache;
  use Mouse;
  extends 'Cache::Pluggable';

  with qw(Cache::Pluggable::Plugin::Duplicate);

  __PACKAGE__->meta->make_immutable();

  package main;
  use strict;
  use warnings;
  use Cache::Memcached::Fast;

  my $migrate_memcache = Cache::Memcached::Fast->new(
        servers => [{ address => 'host2:11211', weight => 1 }],
  );
  my $cache = Proj::Cache->new(
    cache => Cache::Memcached::Fast->new(
        servers => [{ address => 'host1:11211', weight => 1 }],
    ),
    duplicate => [
        $migrate_memcache,
    ],
  );
  $cache->set("hoge", "fuga"); # set hoge to host1 and host2.

=head1 DESCRIPTION

This plugin duplicate set data. It's useful to migrate cache storage.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<Cache::Pluggable>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

