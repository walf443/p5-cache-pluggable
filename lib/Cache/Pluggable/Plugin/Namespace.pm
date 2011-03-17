package Cache::Pluggable::Plugin::Namespace;
use Mouse::Role;

has 'namespace' => (
    is  => 'rw',
    isa => 'Str',
);

around 'key_filter' => sub {
    my $orig = shift;
    my $self = shift;
    my $result = $orig->($self, @_);
    $self->namespace . ':' . $result;
};

no Mouse::Role;

1;

__END__

=head1 NAME

Cache::Pluggable::Plugin::Namespace - added namespace to key.

=head1 SYNOPSIS

  package Proj::Cache;
  use Mouse;
  extends 'Cache::Pluggable';

  with qw(Cache::Pluggable::Plugin::Namespace);

  __PACKAGE__->meta->make_immutable();

  package main;
  use strict;
  use warnings;
  use Cache::Memcached::Fast;

  my $cache = Proj::Cache->new(
    namespace => "proj",
    cache => Cache::Memcached::Fast->new(
        servers => [{ address => 'localhost:11211', weight => 1 }],
    ),
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

