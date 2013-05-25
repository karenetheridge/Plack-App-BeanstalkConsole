use strict;
use warnings;
package Plack::App::BeanstalkConsole;
# ABSTRACT: ...

use parent 'Plack::App::PHPCGIFile';

use File::ShareDir;
use Scalar::Util 'blessed';

sub prepare_app
{
    my $self = shift;
    if (not $self->{root})
    {
        my $class = blessed $self;
        (my $dist = $class) =~ s/::/-/g;
        $self->{root} = File::ShareDir::dist_dir($dist);
    }
    $self->SUPER::prepare_app;
}

sub call
{
    my ($self, $env) = @_;

    $env->{PATH_INFO} .= 'index.php'
        if substr($env->{PATH_INFO}, -1, 1) eq '/';

    $self->SUPER::call($env);
}

1;
__END__

=pod

=head1 SYNOPSIS

...

=head1 DESCRIPTION


=head1 FUNCTIONS/METHODS

=begin :list

* C<foo>

=end :list

...

=head1 EXTERNAL REQUIREMENTS

The C<php-cgi> binary must be available in C<$PATH>.

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Plack-App-BeanstalkConsole>
(or L<bug-Plack-App-BeanstalkConsole@rt.cpan.org|mailto:bug-Plack-App-BeanstalkConsole@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

...

=head1 SEE ALSO

...

=cut
