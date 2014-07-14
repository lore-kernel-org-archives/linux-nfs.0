Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53714 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbaGNCZk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 22:25:40 -0400
Date: Mon, 14 Jul 2014 12:25:31 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Add RCU-walk support to NFS.
Message-ID: <20140714122531.13a69cc8@notabene.brown>
In-Reply-To: <CAHQdGtS2XW=GeyxHddKKAb9a2tucO9kzxatPJ78qpMiDiOagiQ@mail.gmail.com>
References: <20140714011630.12562.1940.stgit@notabene.brown>
	<CAHQdGtS2XW=GeyxHddKKAb9a2tucO9kzxatPJ78qpMiDiOagiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_jUkbxM5Gg5iqMb2SD.0Cm+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_jUkbxM5Gg5iqMb2SD.0Cm+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 13 Jul 2014 22:00:12 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Sun, Jul 13, 2014 at 9:28 PM, NeilBrown <neilb@suse.de> wrote:
> > NFS current abort and attempt at filename lookup in RCU mode.
> > This can have serious performance impact on a highly parallel load.
> >
> > The "Makefile" below generates just such a load.  On a 40-core
> > machine "make -j 40" is about 6 times as fast at "make -j 5"
> > when a local filesystem is used (e.g. XFS), but as much as half
> > as fast when NFS is used.
> > With this patch set, "make -j 40" is about 3 times as fast as
> > "make -j 5" on NFS, and "perf" data doesn't show spinlocks to be a big
> > problem any more.
> >
> > This is a re-submission with a few small improvements of a patch set
> > posted in March.  Since then I have recieved confirmation that it
> > definitely fixes the problem, when combined with a patch set which
> > enhances autofs4 in a similar way.  So it has had quite a bit of
> > testing.
>=20
> Hi Neil,
>=20
> What kind of tests have you personally (or SuSE if relevant) performed?
> Have you run this under NFSometer in order to check for regressions,
> and if so on what workloads?
>=20
> The above are not requirements in order to get the patches into
> mainline, I'm just curious.

I hadn't come across NFSometer before, looks useful!

The only testing is that Makefile, and that was done mostly by the customer.

Further, that testing was a version of the patchset for Linux 3.0.
This particular patchset I've only tested lightly on my little 2-core test
machine.
I'm certainly happy to try beating on it a bit hard, and can see if I can g=
et
access to an 80-core machine that I had a brief play with a while back and =
do
some more testing there.

NeilBrown

--Sig_/_jUkbxM5Gg5iqMb2SD.0Cm+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8M/mznsnt1WYoG5AQJEWg/8D48LdaezGaS7OMje/ZXIOwU4fpQeVkmE
hJwW+EvZu+LkDgzOKkOGl4cmN8Do0oHrVchWdjYnwhcUtWp3vTPfq1aMbZwv/L47
TCnYQDA7KK1XzPxmVBmJxASLqEoJokp01bPXRbp5CJYBOmZWiYxRjF4ovuuLbFp3
q1CKArn4wUPhwbnw9xIHFnyvn7jToFLRWzPZDMueo09hUANNCvLyCvJsa9EXNx4S
9XbBVlfAY/ElH1x212C3qt1kZ7maOc5FWvLVOqX4ktqQHi3ME5qe0F4DCH5+DZnw
jaRRFiVsn1cFDzKNc1H3S/4VmteairrwNJyS/pnBJGC2NHgbDWEplQ9yghaqzS6q
yKQztTTC6rYN5/BcK5wHde/p0iD/YDZN5zTof61Ovi56dK4qoQ7kRsuQgRQtdfqm
NpQ1E+z15eLa4q6qm60gn9nQSYdioROJPxRH85mwp/QizP2DU7Pwjyuh5HIqvWyg
vXIlvHewVyGnBRNaEZ9TIRhs/B5AW5zt8LqmVCbE2LpdoriAKtsltcI1wFG7N+zT
9Cl47Lz2zs0patbvsz3bww9i0it406fDsfwlhJRepySl/CCS5SkpHX1w3Hz/7kQm
98KM/CSlbqJc8+x0gtxb/1GFwm6dNTOFh3Wfnn0tsbXNRuqUKcfwZ7XFv528DBgb
pJQoVLp9X60=
=wyPT
-----END PGP SIGNATURE-----

--Sig_/_jUkbxM5Gg5iqMb2SD.0Cm+--
