use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Warnings;

if (not -d 't/app')
{
    my $sharedir = eval { File::ShareDir::dist_dir('Plack-App-BeanstalkConsole') };

    if (-d $sharedir and glob("$sharedir/*"))
    {
        diag "symlinking $sharedir <- t/app for override tests";
        symlink($sharedir, 't/app');
    }
    else
    {
        # if we hit this case, we must be running a copy directly out of git
        # rather than an uploaded version, *and* do not have a copy of the app
        # in t/app/ that the primary developer has
        plan skip_all => 'copy the app from github to t/app/ for these tests';
    }
}

use Plack::Test;
use HTTP::Request::Common;
use Plack::App::BeanstalkConsole;

my $app = Plack::App::BeanstalkConsole->new(
    root => 't/app',
)->to_app;

foreach my $url (
    '/',
    '/public/',
)
{
    my $http_request = GET $url;

    my $response = test_psgi($app, sub { shift->($http_request) });

    is($response->code, '200', 'can successfully contact the app');
}

done_testing;
