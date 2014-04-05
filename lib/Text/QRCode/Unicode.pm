use strict;
use warnings;

package Text::QRCode::Unicode;

use Text::QRCode ();

sub new
{
    my $class = shift;
    my $text_qrcode = Text::QRCode->new(@_);
    bless \$text_qrcode, $class
}

my @CHARS = (
    ' ',
    "\x{2598}",  # QUADRANT UPPER LEFT
    "\x{259D}",  # QUADRANT UPPER RIGHT
    "\x{2580}",  # UPPER HALF BLOCK
    "\x{2596}",  # QUADRANT LOWER LEFT
    "\x{258C}",  # LEFT HALF BLOCK
    "\x{259E}",  # QUADRANT UPPER RIGHT AND LOWER LEFT
    "\x{259B}",  # QUADRANT UPPER LEFT AND UPPER RIGHT AND LOWER LEFT
    "\x{2597}",  # QUADRANT LOWER RIGHT
    "\x{259A}",  # QUADRANT UPPER LEFT AND LOWER RIGHT
    "\x{2590}",  # RIGHT HALF BLOCK
    "\x{259C}",  # QUADRANT UPPER LEFT AND UPPER RIGHT AND LOWER RIGHT
    "\x{2584}",  # LOWER HALF BLOCK
    "\x{2599}",  # QUADRANT UPPER LEFT AND LOWER LEFT AND LOWER RIGHT
    "\x{259F}",  # QUADRANT UPPER RIGHT AND LOWER LEFT AND LOWER RIGHT
    "\x{2588}",  # FULL BLOCK
);

use constant {
    FULL_BLOCK          => "\x{2588}",
    LEFT_HALF_BLOCK     => "\x{258C}",
    UPPER_HALF_BLOCK    => "\x{2580}",
    QUADRANT_UPPER_LEFT => "\x{2598}",
};

#my @colors = ("1;33;42", "1;31;44");
#printf "%x \e[%sm%s\e[m\n", $_, $colors[$_ & 1], $CHARS[$_] for 0..$#CHARS;

sub lines
{
    my $text_qrcode = ${ shift() };
    my $text = shift;
    my $res = $text_qrcode->plot($text);
    my $h = scalar @$res;
    my $w = scalar @{$res->[0]};

    # If with is odd, should the last bit be filled or empty?
    my $filler = 0;

    my $filler_right = FULL_BLOCK
		     . ($filler || !($w & 1) ? FULL_BLOCK : LEFT_HALF_BLOCK);

    my @a;
    my $tmp;
    for(my $j = ($h-1) & ~1; $j >= 0; $j -= 2) {
	my $s = FULL_BLOCK x 2;

	# As we may go one line too far, we will access
	# cells outside the matrix at $j+1
	no warnings 'uninitialized';

	for(my $i = 0; $i < $w-1; $i += 2) {
	    $tmp = ($res->[$j]->[$i]     eq '*' ? 0 : 1)
		 | ($res->[$j]->[$i+1]   eq '*' ? 0 : 2)
		 | ($res->[$j+1]->[$i]   eq '*' ? 0 : 4)
		 | ($res->[$j+1]->[$i+1] eq '*' ? 0 : 8);
	    $s .= $CHARS[$tmp];
	}
	$s .= $CHARS[
		  ($res->[$j]->[$w-1]   eq '*' ? 2 :  3)
		| ($res->[$j+1]->[$w-1] eq '*' ? 8 : 12)
	    ] if $w & 1;
	$s .= $filler_right;
	unshift @a, $s;
    }
    # Top margin
    my $top_margin = FULL_BLOCK x (3+($w>>1)) . $filler_right;
    unshift @a, $top_margin;
    # Bottom margin
    push @a,
	  ($filler || !($h & 1))
	? $top_margin
	: (UPPER_HALF_BLOCK x (4+($w>>1)) . ($filler ? FULL_BLOCK : QUADRANT_UPPER_LEFT));

    \@a
}

1;

=head1 NAME

Text::QRCode::Unicode

=head1 SYNOPSIS

Print a QR code for L<http://slashdot.org>:

    use Text::QRCode::Unicode;

    use open ':locale', ':std':
    use feature 'say';

    say for @{ Text::QRCode::Unicode->new->lines("http://slashdot.org") };

=head1 AUTHOR

Olivier MenguE<eacute>, L<mailto:dolmen@cpan.org>.

=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2014 Olivier MenguE<eacute>.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl 5 itself.

=cut

