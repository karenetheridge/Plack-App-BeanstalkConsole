use strict;
use warnings;
package inc::DownloadShareDirContent;

use Moose;
with qw(
    Dist::Zilla::Role::PrereqSource
    Dist::Zilla::Role::InstallTool
    Dist::Zilla::Role::AfterBuild
);

use Dist::Zilla::Plugin::MakeMaker ();
use File::Basename;

has url => (
    is => 'ro', isa => 'Str',
    required => 1,
);

sub register_prereqs {
    my ($self) = @_;

    $self->zilla->register_prereqs(
        { phase => 'configure' },
        'File::Spec' => 0,
        'File::Temp' => 0,
        'HTTP::Tiny' => 0,
        'Archive::Extract' => 0,
        'File::ShareDir::Install' => 0.03,
    );
}

sub setup_installer
{
    my $self = shift;

    $self->log_fatal('A Makefile.PL has already been created. [DownloadShareDirContent] should appear in dist.ini before [MakeMaker]!')
        if grep { $_->name eq 'Makefile.PL' } @{ $self->zilla->files };

    my $url = $self->url;
    my $filename = basename($url);

    # unfortunately there is no better way currently of modifying what
    # MakeMaker does, other than subclassing MakeMaker and replacing it
    # entirely
    my $meta = Class::MOP::class_of('Dist::Zilla::Plugin::MakeMaker');
    $meta->make_mutable;
    Moose::Util::add_method_modifier(
        $meta,
        around => [ share_dir_code => sub {
            my $orig = shift;
            my $self = shift;

            my $share_dir_code = $self->$orig(@_);

            my $pre_preamble = <<"NEWCODE";
# begin inc::DownloadShareDirContent
use File::Spec;
use File::Temp 'tempdir';
use HTTP::Tiny;
use Archive::Extract;

my \$archive_file = File::Spec->catfile(tempdir(CLEANUP => 1), "$filename");
print "downloading $url to \$archive_file...\n";
my \$response = HTTP::Tiny->new->mirror('$url', \$archive_file);
\$response->{success} or die "failed to download $url into \$archive_file";

my \$extract_dir = tempdir;
my \$ae = Archive::Extract->new(archive => \$archive_file);
\$ae->extract(to => \$extract_dir) or die "failed to extract \$archive_file to \$extract_dir ";

install_share dist => \$extract_dir;
# end inc::DownloadShareDirContent
NEWCODE

            $share_dir_code->{preamble} =
                $share_dir_code->{preamble}
                ? $pre_preamble . $share_dir_code->{preamble}
                : qq{use File::ShareDir::Install;\n} . $pre_preamble;

            $share_dir_code->{postamble} =
                qq{\{\npackage\nMY;\nuse File::ShareDir::Install qw(postamble);\n\}\n}
                if not $share_dir_code->{postamble};

            return $share_dir_code;
        } ],
    );
    $meta->make_immutable;
}

sub after_build
{
    my $self = shift;

    $self->log_fatal('No Makefile.PL was found. [DownloadShareDirContent] should appear in dist.ini before [MakeMaker]!')
        unless grep { $_->name eq 'Makefile.PL' } @{ $self->zilla->files };
}

1;
__END__
=pod

=head1 SYNOPSIS

    [DownloadShareDirContent]
    url = http://foo.com/bar.baz.gz
    skip_automated_tests = 1

=head1 DESCRIPTION

At build time, the content at the indicated URL is downloaded, extracted, and
included as sharedir content, which can be accessed normally via
L<File::ShareDir>.

Please consider also using [NoAutomatedTesting], so the entire cpantesters
network doesn't hammer your server to download your content!

=head1 LIMITATIONS

Only distributions built via L<ExtUtils::MakeMaker> (that use
L<Dist::Zilla::Plugin::MakeMaker>) are currently supported.  This plugin must
be included in C<dist.ini> B<before> C<[MakeMaker]>.

=head1 TODO

ship this as its own dist!

=head1 SEE ALSO

L<Dist::Zilla::Plugin::MakeMaker>

L<Dist::Zilla::Plugin::ShareDir>

=cut
