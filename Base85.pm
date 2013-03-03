package MIME::Base85;

require 5.005_62;

use vars qw( $VERSION );
$VERSION = '1.1';

use Inline Python => <<'END';

import struct
from struct import unpack, pack

_b85chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"
_b85dec = {}

def _mkb85dec():
    for i in range(len(_b85chars)):
        _b85dec[_b85chars[i]] = i

def b85_encode(text, pad=False):
    l = len(text)
    r = l % 4
    if r:
        text += '\0' * (4 - r)
    longs = len(text) >> 2
    out = []
    words = unpack('>' + 'L' * longs, text[0:longs*4])
    for word in words:
        rems = [0, 0, 0, 0, 0]
        for i in range(4, -1, -1):
            rems[i] = _b85chars[word % 85]
            word /= 85
        out.extend(rems)

    out = ''.join(out)
    if pad:
        return out

    olen = l % 4
    if olen:
        olen += 1
    olen += l / 4 * 5
    return out[0:olen]

def b85_decode(text):
    if not _b85dec:
        _mkb85dec()

    l = len(text)
    out = []
    for i in range(0, len(text), 5):
        chunk = text[i:i+5]
        acc = 0
        for j in range(len(chunk)):
            try:
                acc = acc * 85 + _b85dec[chunk[j]]
            except KeyError:
                raise TypeError('Bad base85 character at byte %d' % (i + j))
        if acc > 4294967295:
            raise OverflowError('Base85 overflow in hunk starting at byte %d' % i)
        out.append(acc)

    cl = l % 5
    if cl:
        acc *= 85 ** (5 - cl)
        if cl > 1:
            acc += 0xffffff >> (cl - 2) * 8
        out[-1] = acc

    out = pack('>' + 'L' * ((l + 4) / 5), *out)
    if cl:
        out = out[:-(5 - cl)]

    return out

END

sub import {
	*encode = \&b85_encode;
	*decode = \&b85_decode;
}


1;
__END__

=head1 NAME

MIME::Base85 - Base85 encoder / decoder

=head1 SYNOPSIS

      use MIME::Base85; 

      $encoded = MIME::Base85::encode($data);
      $decoded = MIME::Base85::decode($encoded);

=head1 DESCRIPTION

Encode data similar way like MIME::Base64 does.

=head1 EXPORT

NOTHING

=head1 AUTHOR

-

=head1 SEE ALSO

perl(1), MIME::Base64(3pm).

=cut
