use strict;
use warnings;
use lib 'inc';
use ExtUtils::MakeMaker::Dist::Zilla::Develop;

WriteMakefile(
    NAME => 'Plack::App::BeanstalkConsole',
    VERSION_FROM => 'lib/Plack/App/BeanstalkConsole.pm',
    INSTALLMAN1DIR => 'none',
    INSTALLMAN3DIR => 'none',
    NORECURS => 1,
);

if (not -d 't/app') {
    my $filename = 'beanstalk_console.zip';
    require File::Spec;
    my $archive_file = $filename;
    my $url = 'https://github.com/ptrofimov/beanstalk_console/archive/master.zip';
    my $extract_dir = 't';

    print "downloading $url into $archive_file...\n";
    require HTTP::Tiny;
    my $response = HTTP::Tiny->new->mirror($url, $archive_file);
    $response->{success} or die "failed to download $url into $archive_file";

    print "extracting into '$extract_dir'...\n";
    require Archive::Extract;
    my $ae = Archive::Extract->new(archive => $archive_file);
    $ae->extract(to => $extract_dir) or die "failed to extract $archive_file to $extract_dir";

    my $appdir = 'beanstalk_console-master';

    rename("$extract_dir/$appdir", 't/app')
    or warn "Cannot rename('$extract_dir/$appdir' to 't/app'): $!";

    -d 't/app' and -d 't/app/lib' and -d 't/app/public'
        or die 'something went wrong extracting the application';

    print "done.\n";
}
