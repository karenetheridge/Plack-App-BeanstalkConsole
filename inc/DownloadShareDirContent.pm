use strict;
use warnings;
package inc::DownloadShareDirContent;

use Moose;
extends 'Dist::Zilla::Plugin::MakeMaker::Awesome' => { -version => 0.14 };

use File::Basename;

has url => (
    is => 'ro', isa => 'Str',
    required => 1,
);

around register_prereqs => sub
{
    my $orig = shift;
    my $self = shift;

    $self->$orig(@_);

    $self->zilla->register_prereqs(
        { phase => 'configure' },
        'File::Spec' => 0,
        'File::Temp' => 0,
        'HTTP::Tiny' => 0,
        'Archive::Extract' => 0,
        'File::ShareDir::Install' => 0.03,
    );
};

around _build_share_dir_block => sub
{
    my $orig = shift;
    my $self = shift;

    my $url = $self->url;
    my $filename = basename($url);

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

    $share_dir_code->[0] =
        $share_dir_code->[0]
        ? $pre_preamble . $share_dir_code->[0]
        : qq{use File::ShareDir::Install;\n} . $pre_preamble;

    $share_dir_code->[1] =
        qq{\{\npackage\nMY;\nuse File::ShareDir::Install qw(postamble);\n\}\n}
        if not $share_dir_code->[1];

    return $share_dir_code;
};

__PACKAGE__->meta->make_immutable;
__END__
=pod

=head1 SYNOPSIS

    # remove [MakeMaker], and add:

    [DownloadShareDirContent]
    url = http://foo.com/bar.baz.gz

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
