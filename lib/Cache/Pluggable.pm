package Cache::Pluggable;
use strict;
use warnings;
our $VERSION = '0.01';
use Class::Load qw();
use Class::Accessor::Lite (
    new => 1,
    rw => [qw(
        cache
    )],
);

sub get {
    my $self = shift;
    if ( ref $_[0] eq 'HASH' ) {
        return $self->_get_hashref(@_);
    } else {
        return $self->_get(@_);
    }
}

sub _get_hashref {
    my ($self, $hash_ref) = @_;
    my %hash = %$hash_ref; # copy
    return $self->_get($hash{key});
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
        return $self->_set(@_);
    }
}

sub _set_hashref {
    my ($self, $hash_ref) = @_;
    my %hash = %$hash_ref; # copy
    return $self->_set($hash{key}, $hash{value}, $hash{expires_in} || undef);
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
  use parent 'Cache::Pluggable';
  __PACKAGE__->load_plugins(qw/ SafeKey +Proj::Cache::Plugin::GetCallback /);

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
  my $value = $cache->get($key);
  $cache->set(foo => $value, $expire);

=head1 DESCRIPTION

You would like to wrap CPAN's Cache::XXX libraries a bit.
This library help you to write some modules and reuse it.

=head1 METHODS

=over

=item Cache::Pluggable->load_plugins(@plugins);

Load plugins and modify methods in order of @plugins.
Order may be important for some plugin.

=item my $cache = Proj::Cache->new(%args);

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

=item expires_in ( optional )

expires_in in N seconds.

=back

=item $cache->set($key, $value, $expire);

many Cache:: library has this intercace.
But, It's hard to extend. So, $hash_ref is recommend.

=back

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<CLI>

+<Cache::Cache>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
