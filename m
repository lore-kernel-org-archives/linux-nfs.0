Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:56597 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168Ab2JMVlB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Oct 2012 17:41:01 -0400
Message-ID: <5079DDC5.6020407@fifthhorseman.net>
Date: Sat, 13 Oct 2012 17:31:49 -0400
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Jim Rees <rees@umich.edu>, Larry McVoy <lm@bitmover.com>,
        Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com> <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com> <20121013013613.GA11272@umich.edu> <CA+55aFzQWw-rv76VX2=2MpFf3-ZMFtzVcps-PQsXO6cOG+4tBg@mail.gmail.com>
In-Reply-To: <CA+55aFzQWw-rv76VX2=2MpFf3-ZMFtzVcps-PQsXO6cOG+4tBg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig9527B90B9FCC809C5FB4E279"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9527B90B9FCC809C5FB4E279
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/12/2012 09:45 PM, Linus Torvalds wrote:
> On Sat, Oct 13, 2012 at 10:36 AM, Jim Rees <rees@umich.edu> wrote:
>>
>> I install kernels on Ubuntu every day of the week and twice on Sundays=
, and
>> never jump through their silly hoops.  The only magic is making the
>> initramfs, if you use one.
>>
>> make install modules_install
>> update-initramfs -c -k 3.6.1 (or whatever)
>> update-grub
>=20
> This magic is what the distro "/usr/sbin/installkernel" script is
> supposed to do, which the kernel Makefile does for the "install"
> target.
>=20
> So the "make install" *should* have done the grub and initramfs
> update. Ubuntu screwed up (probably because Debian did).
>=20
> I wish they'd just fix it.=20

fwiw, this was fixed in debian as of debianutils package 3.4.3.  So it
should be functional in testing (wheezy) but, alas, not in the current
stable release (squeeze).

For ubuntu, i think the fixed packages should be available from "nattie
narwhal" forward, but i haven't tested them directly.

For reference, the bug report in debian is at:

   http://bugs.debian.org/607411

Regards,

	--dkg


--------------enig9527B90B9FCC809C5FB4E279
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQJ8BAEBCgBmBQJQed3FXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznpoJYP/iArPZY1mU3vEaDhBAJyv26x
3owQmgExpINuqFjYs3wcwoZ5pdt6FhkgeDwUe5MfcKFGB7EhDzU7fUVWn8Tz2Pw/
8GhyMQqmTdR7dj6uiAfSuvLTZgOS20Q//3Rl8rf8dVGiqanMkcHBPnLOiF9Ng1VY
jA634MswhhIRMpB1RRVuD9jN9IDR1enIgK3bjZoCWyEGWcO80UYVPyR/A0MG31PZ
aSAuEAPt6cnvJtNhdYxkwJXAsMf1XO81eVbKcCeHU5pTwPFqoG5C7dncXtK4cwcN
jRAOVBQ/k4oYSGa5x8mZzJXcQyJT9TIXv/Ew8f4oQzIJmDip+6fzq1TGfrQKSzfH
VzI/NtflqLYAXQwwjjK4QwvF2NftVIWAjEdPCMZEoz7VKgSKZQRwJBWRiU27YjhS
hq7SovqUF4slpdDIvM7tVnFbaJhV43iVaYLJucLyMxCWMUY70pAxaMo8DS4CGEyj
7krc+7VIf7rPkzIEWtT2Fins4B4FpZULSpiclvU7z4vZEH4jpk8ZEf0D657dvKyH
kK2OT6u5t2iU+Fmtb0c0FsCHx+p8RAi4dmJzSGm8qxIaC9E985n58BrF94Oqqi4e
jOpyJDXvH9+G3pl2mD3vXUWn51oT2ssmhcnJZ4JhzUto7NwavQ1wBPY58tKfAxpy
klLXPjgBt+zcJJ3UY0b0
=94eS
-----END PGP SIGNATURE-----

--------------enig9527B90B9FCC809C5FB4E279--
