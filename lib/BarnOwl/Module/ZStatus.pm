use warnings;
use strict;

=head1 NAME

BarnOwl::Module::ZStatus

=head1 DESCRIPTION

I didn't write this.

=cut

package BarnOwl::Module::ZStatus;

my $next = undef;

sub cmd_zstatus {
    my $cmd = shift;
    my $args = join(" ", @_);
    BarnOwl::start_question('Sleep-dep [0-10]? ', sub {got_sleep($args, @_)});
}

sub got_sleep {
    my @pass = @_;
    $next = sub {
        BarnOwl::start_question('Angst [0-10]? ', sub {got_angst(@pass, @_)});
    };
}

sub got_angst {
    my @pass = @_;
    $next = sub {
        BarnOwl::start_question('Stress [0-10]? ', sub {got_stress(@pass, @_)});
    }
}

sub got_stress {
    my @pass = @_;
    $next  = sub {
        BarnOwl::start_question('Hosage [0-10]? ', sub {got_hosage(@pass, @_)});
    }
}

sub got_hosage {
    my ($args, $sleep, $angst, $stress, $hosage) = @_;
    my $message = "[Zephyr status dashboard]\n";
    $message .= format_bar("sleepdep ", $sleep);
    $message .= format_bar("angst    ", $angst);
    $message .= format_bar("stress   ", $stress);
    $message .= format_bar("hosage   ", $hosage);
    BarnOwl::zephyr_zwrite($args, $message);
}

sub format_bar {
    my $header = shift;
    my $num    = shift;
    my $bar = "";
    $bar .= "$header [";
    $bar .= colorize(("="x$num) . (" " x (10 - $num)), $num) . "]";
    $bar .= colorize(" ($num/10)", $num);
    $bar .= "\n";
    return $bar;
}

sub colorize {
    my $text = shift;
    my $num = shift;
    my $color;
    if($num <= 3) { $color = "green" }
    elsif($num <= 6) {$color = "yellow"}
    else {$color = "red";}

    return '@<@color(' . $color . ")$text>";
}

BarnOwl::new_command(zstatus => \&cmd_zstatus, {
    summary => "Zephyr a personal status dashboard",
    usage   => "zstatus [zephyr command-line]",
    description => "Asks you questions about your status, and zephyrs the \n" .
    "result as a colored set of ASCII statusbars to the specified destination\n\n" .
    "Use with a zephyr command line, e.g. :zstatus -c nelhage -i status"
   });

sub main_loop {
    if($next) {
        $next->();
        undef $next;
    }
}

$BarnOwl::Hooks::mainLoop->add(\&main_loop);

=head1 SEE ALSO

Foo, Bar, Baz

=cut

1;
