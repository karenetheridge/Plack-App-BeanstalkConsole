use strict;
use warnings;
package inc::RequireExecutable;

use Moose;
with 'Dist::Zilla::Role::InstallTool';

has executable => (
    is => 'ro', isa => 'Str',
    required => 1,
);

sub setup_installer
{
    my $self = shift;
    my ($mfpl) = grep { $_->name eq 'Makefile.PL' } @{ $self->zilla->files };

    $self->log_fatal('No Makefile.PL was found. [=' . __PACKAGE__ . '] should appear in dist.ini after your installer!')
        unless $mfpl;


    my $content = 'use File::Which;' . "\n"
        . 'do { print "' . $self->executable . ' not found; aborting.\\n"; ' . 'exit 0 } if not which("' . $self->executable . '");' . "\n";
    $mfpl->content( $content . $mfpl->content );
    return;
}

__PACKAGE__->meta->make_immutable;
__END__
=pod

=head1 SYNOPSIS

    [=inc::RequireExecutable]
    executable = foo

=head1 DESCRIPTION

Edits your Makefile.PL to add a line that bails out if the specified
executable does not exist on your system.

=head1 TODO

ship this as its own dist!

=cut
