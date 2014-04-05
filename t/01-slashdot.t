use utf8;
use strict;
use warnings;

use Test::More tests => 1;

use Text::QRCode::Unicode ();

my $ref = <<'EOF';
████████████████▌
██▗▄▄▐▜▐▞▞▐▗▄▄▐█▌
██▐ ▐▐▀▜▝▜▟▐ ▐▐█▌
██▐▄▟▐▘▛▀▀▟▐▄▟▐█▌
██▄▄▄▟▞▝▟▐▐▄▄▄▟█▌
██▗▖▐▄▄▚▀█▙▌▙▌██▌
██▘▚▝▄▐▟▘▖▀▝▚▙▐█▌
██▐▚▗▟▙▟▟▄ ▞▞▖▟█▌
██▐▚▖▞▐▖▟▚▝▄▖▙▐█▌
██▟▟▄▄▗▙▀▀▗▄▝▐██▌
██▗▄▄▐▞▜▘▟▐▟ ▖▟█▌
██▐ ▐▐▝▜▟▖▖ ▗▝▐█▌
██▐▄▟▐ ▘▟▀▜▌▀▟▐█▌
██▄▄▄▟▟▄███▄▄▄▟█▌
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▘
EOF

is(
    join("\n", @{ Text::QRCode::Unicode->new->lines('http://slashdot.org') })."\n",
    $ref,
    'http://slashdot.org'
);
