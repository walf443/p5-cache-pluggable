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


