use strict;
use warnings;

package Text::QRCode::Unicode;

use Text::QRCode ();

use constant {
    TEXT_QRCODE => 0,
    OPTIONS     => 1,

    FLG_FILLER  => 1,
    FLG_NARROW  => 2,
    FLG_REVERSE => 4,
};

sub new
{
    my $class = shift;
    my %opt = (filler => 0, narrow => 1, reverse => 0, @_);

    my $flags =
	  (0 + delete $opt{filler})
	| (0 + delete $opt{narrow}) << 1
	| (0 + delete $opt{reverse}) << 2;

    bless [
	Text::QRCode->new(%opt),
	$flags,
    ], $class
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
    my $self = shift;
    my $text = shift;
    my $res = $self->[TEXT_QRCODE]->plot($text);
    my $h = scalar @$res;
    my $w = scalar @{$res->[0]};

    my $options = $self->[OPTIONS];
    # If width is odd, should the last bit be filled or empty?
    my $filler = $options & FLG_FILLER;
    # Use half (1) or full (2) character width for a QR code block
    my $narrow = $options & FLG_NARROW;
    die "Option 'reverse' not supported... yet!" if $options & FLG_REVERSE;

    my $full_right_char = !$narrow || $filler || !($w & 1);
    my $right_char = $full_right_char ? FULL_BLOCK : LEFT_HALF_BLOCK;
    # QR codes have a margin of 4 blocks
    my $filler_left = FULL_BLOCK x ($narrow ? 2 : 4);
    my $filler_right =
	  $narrow
	? FULL_BLOCK . $right_char
	: $filler_left;

    my @a;
    my $tmp;
    for(my $j = ($h-1) & ~1; $j >= 0; $j -= 2) {
	my $s = $filler_left;

	# As we may go one line too far, we will access
	# cells outside the matrix at $j+1
	no warnings 'uninitialized';

	if ($narrow) {
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
	} else {
	    for(my $i = 0; $i < $w; $i++) {
		$s .= $CHARS[
			($res->[$j  ]->[$i] eq '*' ? 0 :  3)
		      | ($res->[$j+1]->[$i] eq '*' ? 0 : 12)
		    ];
	    }
	}
	$s .= $filler_right;
	unshift @a, $s;
    }
    my $count = (2 + ($w >> 1) + 2) * ($narrow ? 1 : 2) + ($w & 1) - 1;
    # Top margin
    my $std_margin = (FULL_BLOCK x $count) . $right_char;
    unshift @a, $std_margin, $std_margin;
    # Bottom margin
    push @a, $std_margin,
	  ($filler || !($h & 1))
	? $std_margin
	: (UPPER_HALF_BLOCK x $count) . ($full_right_char ? UPPER_HALF_BLOCK : QUADRANT_UPPER_LEFT);

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

