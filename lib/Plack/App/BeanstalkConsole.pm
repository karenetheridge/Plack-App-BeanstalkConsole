use strict;
use warnings;
package Plack::App::BeanstalkConsole;
# vim: set ts=8 sts=4 sw=4 tw=115 et :
# ABSTRACT: A web application that provides access to Beanstalk statistics and tools
# KEYWORDS: beanstalk jobs queue web application dashboard console plack psgi

our $VERSION = '0.011';

use parent 'Plack::App::PHPCGIFile';

use File::ShareDir ();
use Scalar::Util ();

sub prepare_app
{
    my $self = shift;
    if (not $self->{root})
    {
        my $class = Scalar::Util::blessed($self);
        (my $dist = $class) =~ s/::/-/g;
        $self->{root} = File::ShareDir::dist_dir($dist);
    }
    $self->SUPER::prepare_app;
}

sub call
{
    my ($self, $env) = @_;

    # / -> /public/
    # CSS is screwed up if we rewrite PATH_INFO directly here.
    return [ '301', [ 'Location' => '/public/' ], [] ]
        if $env->{PATH_INFO} eq '/';

    # */ -> */index.php
    $env->{PATH_INFO} .= 'index.php'
        if substr($env->{PATH_INFO}, -1, 1) eq '/';

    $self->SUPER::call($env);
}

1;
__END__

=pod

=head1 SYNOPSIS

    use Plack::App::BeanstalkConsole;
    # accessible under /...
    my $app = Plack::App::BeanstalkConsole->new->to_app;

    # Or mount on a specific path
    use Plack::Builder;
    builder {
        # accessible under /beanstalk/...
        mount beanstalk => Plack::App::BeanstalkConsole->new;
    };

See L<plackup> for how to quickly and easily mount this application from the
command line.

=head1 DESCRIPTION

=for stopwords Petr Sergey Trofimov

This is a simple L<Plack> wrapper for the excellent
L<Beanstalk Console|https://github.com/ptrofimov/beanstalk_console>
application written in PHP by Петр Трофимов (Petr Trofimov)
and Сергей Лысенко (Sergey Lysenko).

The latest version of the application is downloaded at install time and saved
as a L<File::ShareDir|share dir>, which is used by default if the C<root> is
not overridden (see below).

To use, mount the app on your server and go to the '/' URI,
where you will be prompted to enter the address of your beanstalk server(s).

=head1 METHODS

=head2 C<new>

    Plack::App::BeanstalkConsole->new(<options>)

Options (passed as a hash):

=over 4

=item * C<root> (optional)

If not provided, the PHP code that was downloaded at install time is used.
However, you can override this option to point to any directory you wish, that
contains the PHP code to be mounted. (In this way it functions just like
L<Plack::App::PHPCGIFile>.)

    Plack::App::BeanstalkConsole->new(root => 'path/to/beanstalk_console')

=back

=head1 EXTERNAL REQUIREMENTS

The C<php-cgi> binary must be available in C<$PATH>.  In newer versions of
PHP, this is is normally installed as part of the main PHP installation.

=head1 SEE ALSO

=for stopwords beanstalkd

=for :list
* L<Plack>
* L<Plack::App::PHPCGIFile>
* L<Beanstalk Console|https://github.com/ptrofimov/beanstalk_console>
* L<beanstalkd|http://kr.github.com/beanstalkd>

=cut
