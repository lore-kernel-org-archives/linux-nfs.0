Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:35856 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3GCBuG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jul 2013 21:50:06 -0400
Date: Wed, 3 Jul 2013 11:49:56 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: David Howells <dhowells@redhat.com>
Cc: torvalds@linux-foundation.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        milosz@adfin.com
Subject: Re: [GIT PULL] Fix assorted FS-Cache issues
Message-Id: <20130703114956.53b40a7374fe007df84548dd@canb.auug.org.au>
In-Reply-To: <4578.1372810333@warthog.procyon.org.uk>
References: <20130703093815.006437fd5f18210b7729b060@canb.auug.org.au>
	<6302.1372775256@warthog.procyon.org.uk>
	<4578.1372810333@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__3_Jul_2013_11_49_56_+1000_.e7GQ/cuongKgNPS"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Wed__3_Jul_2013_11_49_56_+1000_.e7GQ/cuongKgNPS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 03 Jul 2013 01:12:13 +0100 David Howells <dhowells@redhat.com> wrot=
e:
>
> Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>=20
> > >   git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git=
 tags/fscache-20130702
> >=20
> > /me wonders where this has been hiding for the last month and a half ...
>=20
> I asked you to pull my fscache branch on the 23rd May, and you replied on=
 the
> 27th May saying you'd done so.

And in linux-next, I keep fetching the same branch every day to get
updates.  It is polite (in fact necessary) for you to keep that branch up
to date if you change things.  You did not update that branch until today
which is what confused me.  The *commits* you sent Linus have never been
in linux-next even though the *patches* have.

Not a biggie, just makes it a bit hard to keep track.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__3_Jul_2013_11_49_56_+1000_.e7GQ/cuongKgNPS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR04NJAAoJEECxmPOUX5FERZ0P/2CW2652LfurQvLc+vnNMaEN
3L7yWQ0yJYQeH5xnPZSARgOu17cPEX7q5rd5fUM9004UBuDzsOdUAkjvZhRoIZVK
aLmcKPFRpdc1MQAaabOiuZEZ4b4OBCjsYcCWFVILgBMHJeCM3GJ2l2Who/k5S/a1
liMmY0SRuPbS0dd5d/LXBtjVG81Btl92AA1p3OkxoIngGV8USGlpTd0l/FEhk4AA
+nA0qU/0LqRbVrxlMbvEALRh2c8MtSEvyb5cERP4DUXB07rXdYkhkZKPje5sTtzQ
OUubQW66jKAnyBTBPLPP3PuhENzrrZ+0MAqpOQYmkbaFwOwDaxiwf/cj3VZT9+5F
jt8CXEgSCOziNHpqlPzM/7zRY0ytSkxXXhSBWrdJXL2RJU0vjw1VWj4Tubkc7c1C
0PhCtNwYm2oXZ6ss6bhLRIkRFYPwsGd9f8M++WK8eHYKDLvlMyPdcquutzZfP+kI
fsIxq2MJxlPQLWVgrRV/Ca5jjWeaResPA5nyklzS4fLkDDmmYTDNVcXlGA1jJATl
py7iu6rndczt4Ye0tAmx2na1+DWkGUpU8OSvKdrvuVE+uO8raJ8EXLCpfk3pTFXt
8atOo2Ldo4qZ6DVKJYqxp5cFztBpjZNBuaF5z3kYfb+w6hLN/j+7TJMCBNuxP8DG
7LY9CeCFOGoP/tmAyOg2
=qSIv
-----END PGP SIGNATURE-----

--Signature=_Wed__3_Jul_2013_11_49_56_+1000_.e7GQ/cuongKgNPS--
