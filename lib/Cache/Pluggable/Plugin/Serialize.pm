package  Cache::Pluggable::Plugin::Serialize;
use Mouse::Role;

has 'serialize_methods' => (
    is => 'ro',
    isa => 'ArrayRef[CodeRef]',
);

around '_get' => sub {
    my $orig = shift;
    my $self = shift;
    my $ret = $orig->($self, @_);
    return $self->serialize_methods->[1]->($ret);
};

around '_set_hashref' => sub {
    my $orig = shift;
    my $self = shift;
    my $hashref = shift;
    my %hash = %$hashref; # copy for privending side effect.
    $hash{value} = $self->serialize_methods->[0]->($hash{value});
    $orig->($self, \%hash, @_);
};

no Mouse::Role;

1;

=head1 NAME

Cache::Pluggable::Role::Namespace - added namespace to key.

=head1 SYNOPSIS

  package Proj::Cache;
  use Mouse;
  extends 'Cache::Pluggable';

  with qw(Cache::Pluggable::Plugin::Serialize);

  __PACKAGE__->meta->make_immutable();

  package main;
  use strict;
  use warnings;
  use Cache::Memcached::Fast;

  my $cache = Proj::Cache->new(
    cache => Cache::Memcached::Fast->new(
        servers => [{ address => 'localhost:11211', weight => 1 }],
        namespace => 'proj:',
    ),
    serialize_methods => [ sub { JSON::XS->new->utf8->encode(shift) }, sub { JSON::XS->new->utf8->decode(shift) } ],
  );
  my $value = $cache->get($key); # "GET proj:$key"
  $cache->set(foo => $value, $expire); # "SET proj:$key $value"

=head1 DESCRIPTION

This plugin always append namespace to key.

It's useful to share cache storages between many projects.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<Cache::Pluggable>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

