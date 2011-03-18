package Cache::Pluggable;
use Mouse;
use Class::Load qw();
our $VERSION = '0.01';

has 'cache' => (
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Mouse;

sub get {
    my $self = shift;
    if ( ref $_[0] eq 'HASH' ) {
        return $self->_get_hashref(@_);
    } else {
        my $key = shift;
        return $self->_get_hashref({ key => $key }, @_);
    }
}

sub key_filter {
    my (undef, $key) = @_;
    return $key;
}

sub _get_hashref {
    my $self = shift;
    my $hash_ref = shift;
    my %hash = %$hash_ref; # copy
    return $self->_get($self->key_filter($hash{key}), @_);
}

sub _get {
    my $self = shift;
    $self->cache->get(@_);
}

sub set {
    my $self = shift;
    if ( ref $_[0] eq 'HASH' ) {
        return $self->_set_hashref(@_);
    } else {
        my $key = shift;
        my $value = shift;
        my $expires_in = shift;
        return $self->_set_hashref({
            key => $key || undef,
            value => $value || undef,
            expires_in => $expires_in || undef,
        }, @_);
    }
}

sub _set_hashref {
    my $self = shift;
    my $hash_ref = shift;
    my %hash = %$hash_ref; # copy
    return $self->_set($self->key_filter($hash{key}), $hash{value}, $hash{expires_in} || undef, @_);
}

sub _set {
    my $self = shift;
    $self->cache->set(@_);
}

1;
__END__

=head1 NAME

Cache::Pluggable - pluggable cache interface

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
    cache => Cache::Memcached::Fast->new(
        servers => [{ address => 'localhost:11211', weight => 1 }],
        namespace => 'proj:',
    ),
  );
  my $value = $cache->get({ key => $key });
  $cache->set(key => $key, value => $value, expires_in => 60);

=head1 DESCRIPTION

You would like to wrap CPAN's Cache::XXX libraries a bit.
This library help you to write some modules and reuse it.

=head1 METHODS

=over

=item my $cache = Proj::Cache->new(%args);

%args is followings:

=over 4

=item cache: Object ( required )

Cache::xxx object like Cache::Memcached::Fast.

=back

=item my $value = $cache->get($hash_ref);

yet anothor get interface for extend get interface. (recommend)

$hash_ref are followings:

=over 4

=item key: Str ( required )

    key name to get.

=back

=item my $value = $cache->get($key);

many Cache:: library has this interface. 
But, It's hard to extend. So, $hash_ref is recommend.

=item $cache->set($hash_ref);

$hash_ref is followings:

=over 4

=item key: Str ( required )

=item value: Str ( required )

=item expires_in: Int ( optional )

expires_in in N seconds.

=back

=item $cache->set($key, $value, $expire);

many Cache:: library has this intercace.
But, It's hard to extend. So, $hash_ref is recommend.

=back

=head1 TESTED cache module.

Cahce::Pluggable work with followings:
+<Cahce::Memcached::Fast>

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<CLI>

+<Cache::Cache>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
