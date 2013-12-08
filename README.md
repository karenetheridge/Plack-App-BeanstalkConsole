# NAME

Plack::App::BeanstalkConsole - a web application that provides access to Beanstalk statistics and tools

# VERSION

version 0.006

# SYNOPSIS

    use Plack::App::BeanstalkConsole;
    # accessible under /...
    my $app = Plack::App::BeanstalkConsole->new->to_app;

    # Or mount on a specific path
    use Plack::Builder;
    builder {
        # accessible under /beanstalk/...
        mount beanstalk => Plack::App::BeanstalkConsole->new;
    };

See [plackup](https://metacpan.org/pod/plackup) for how to quickly and easily mount this application from the
command line.

# DESCRIPTION

This is a simple [Plack](https://metacpan.org/pod/Plack) wrapper for the excellent
[Beanstalk Console](https://github.com/ptrofimov/beanstalk_console)
application written in PHP by Петр Трофимов (Petr Trofimov)
and Сергей Лысенко (Sergey Lysenko).

The latest version of the application is downloaded at install time and saved
as a [File::ShareDir](#share-dir), which is used by default if the `root` is
not overridden (see below).

To use, mount the app on your server and go to the '/' URI,
where you will be prompted to enter the address of your beanstalk server(s).

# METHODS

## `new`

    Plack::App::BeanstalkConsole->new(<options>)

Options (passed as a hash):

- `root` (optional)

    If not provided, the PHP code that was downloaded at install time is used.
    However, you can override this option to point to any directory you wish, that
    contains the PHP code to be mounted. (In this way it functions just like
    [Plack::App::PHPCGIFile](https://metacpan.org/pod/Plack::App::PHPCGIFile).)

        Plack::App::BeanstalkConsole->new(root => 'path/to/beanstalk_console')

# EXTERNAL REQUIREMENTS

The `php-cgi` binary must be available in `$PATH`.  In newer versions of
PHP, this is is normally installed as part of the main PHP installation.

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Plack-App-BeanstalkConsole)
(or [bug-Plack-App-BeanstalkConsole@rt.cpan.org](mailto:bug-Plack-App-BeanstalkConsole@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# SEE ALSO

- [Plack](https://metacpan.org/pod/Plack)
- [Plack::App::PHPCGIFile](https://metacpan.org/pod/Plack::App::PHPCGIFile)
- [Beanstalk Console](https://github.com/ptrofimov/beanstalk_console)
- [beanstalkd](http://kr.github.com/beanstalkd)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
