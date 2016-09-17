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

if (not -d 't/app/public') {
    my $filename = 'beanstalk_console.zip';
    require File::Spec;
    my $archive_file = File::Spec->catfile('t', 'app', $filename);
    my $url = 'http://github.com/downloads/ptrofimov/beanstalk_console/beanstalk_console.zip';
    my $extract_dir = 't/app';
    mkdir $extract_dir;

    print "downloading $url into $archive_file...\n";
    require HTTP::Tiny;
    my $response = HTTP::Tiny->new->mirror($url, $archive_file);
    $response->{success} or die "failed to download $url into $archive_file";

    print "extracting into $extract_dir...\n";
    require Archive::Extract;
    my $ae = Archive::Extract->new(archive => $archive_file);
    $ae->extract(to => $extract_dir) or die "failed to extract $archive_file to $extract_dir";
    print "done.\n";
}
