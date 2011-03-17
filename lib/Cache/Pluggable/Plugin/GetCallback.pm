package Cache::Pluggable::Plugin::GetCallback;
use Mouse::Role;
no Mouse::Role;

sub get_callback {
    my ($self, $hash_ref, $code_ref) = @_;
    my $value = $self->_get_hashref($hash_ref);
    return $value if defined $value;
    return if $hash_ref->{not_callback};
    $value = $code_ref->($hash_ref->{key});
    $self->set({ 
        %$hash_ref,
        value => $value || undef,
    });
    return $value;
}

1;

__END__
=head1 NAME

Cache::Pluggable::Plugin::GetCallback - add get_callback interface

=head1 SYNOPSIS

  package Proj::Cache;
  use Mouse;
  extends 'Cache::Pluggable';

  with qw(Cache::Pluggable::Plugin::GetCallback);

  __PACKAGE__->meta->make_immutable();

  package main;
  use strict;
  use warnings;
  use Cache::Memcached::Fast;

  my $cache = Proj::Cache->new(
    cache => Cache::Memcached::Fast->new(
        servers => [{ address => 'localhost:11211', weight => 1 }],
    ),
  );
  my $value = $cache->get_callback({
     key => $key,
     expire_in => 10, # sec
  } => sub {
      # do heavy task.
      my $value = $key x 3;
      return $value;
  });

=head1 DESCRIPTION

This plugin add get_callback method.

=over

=item my $value = $self->get_callback($hash_ref => $code_ref);

$hash_ref is followings:

=over 4

=item key: Str

key to get and set.

=item expire_in: Int ( optional )

expire in N sec.

=item not_callback: Bool ( optional )

If it was set, don't run $code_ref.
It may be useful in situation when you want to call $code_ref from CLI
and you does not want to call $code_ref from Web.

=back

$code_ref is CodeRef. It should return set value.

=back

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<Cache::Pluggable>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

