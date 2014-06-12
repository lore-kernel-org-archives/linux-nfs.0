Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37824 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528AbaFLBoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2014 21:44:07 -0400
Date: Thu, 12 Jun 2014 11:43:57 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140612114357.3a50f3ab@notabene.brown>
In-Reply-To: <20140611142102.GB19382@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
	<20140604173926.53918af3@notabene.brown>
	<20140604220531.GA8362@fieldses.org>
	<20140605103423.43e21569@notabene.brown>
	<20140611142102.GB19382@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nMq1J81jRSEAG+Bb7.2XR5J"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nMq1J81jRSEAG+Bb7.2XR5J
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Jun 2014 10:21:02 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Jun 05, 2014 at 10:34:23AM +1000, NeilBrown wrote:
> > On Wed, 4 Jun 2014 18:05:31 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Wed, Jun 04, 2014 at 05:39:26PM +1000, NeilBrown wrote:
> > > > Below is my suggestion.  It seems easy enough.  It even works.
> > >=20
> > > Woah!
> > >=20
> > > Anyway, looks reasonable to me, and it fixes an immediate problem so =
I'm
> > > inclined to just apply.
> ...
> > And if you are going to apply it, you'll want:
> >=20
> >    Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> Oh, gah, then I forgot to actually apply.

The best laid plan of mice ....

>=20
> Anyway, it's a reasonably self-contained fix for an important bug so
> I'll send it as part of a later bugfix pull request.
>=20
> I thought it could also use a more explicit description of the resulting
> problem, so I added:
>=20
> 	... so further delegations should not be handed out.
>=20
> 	The current code fails to do so, and the result is effectively a
> 	live-lock under some workloads: a client attempting a
> 	conflicting operation on a read-delegated file receives
> 	NFS4ERR_DELAY and retries the operation, but by the time it
> 	retries the server may already have given out another
> 	delegation.

Looks good, thanks.

NeilBrown

--Sig_/nMq1J81jRSEAG+Bb7.2XR5J
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU5kF3Tnsnt1WYoG5AQKUJg//d+2CTOlv1lkZ27yhMGvhY0j4wh22FGSC
Vebnv9INee/yyLN5qsh3hkxauoQ/3psIq0F0dzxFS1IgnaXZ7uzY0UTlpuUhFSpZ
Q/vpc45F24m+JgEVBLY21xkAAsv46+zQrzwDmyFO27jXNHJcgMF+pXEZgmMEtpkT
zIe/xNeH9kSE8zPu3VL5GzFrjra5PqAOS/p/Y+akvOQNHjJC+5Cd3LAFEFiRRKQY
nrhXSwgoUZXLCReBWhzKEfixZho+A7ump6s/0PDnPKMfgIWCkH+Nj+fa+ntSv4U5
suxn7gUO3fNbRjM3VrXHiJ7L/l1B5XE3hlo1B/ztNQAyFUUDEDOmPUutrjaj7lB6
ZSghDxRoUN0loAUG0M1wqdXHQ+y217nQmSmjtxidNGQyvOFfglPkgjX0e+0Eaw3M
po24kTh2L0wEgTlWvkha940MDSz/lk5kerus9pfN/IxcPGS0QZaqqymUQQp9xp5R
fXRKwryIoTGhDnFBKNfZiZwkqb4ZgQjwAVFnKSyhPvzAgFJku3IGJa9+9KGpoc4k
/+oBjuR5sGHqzTuMejkBq6+p+zCc3UdXuFfcqrBxt8i320Qwa+3g/5w3pSolxufb
k2JnTXyvMpcV5UvJ8x3S+sshv7c082qJV6NzKj45kFouBVJXDvmxIel+MV//t4RD
RL4RkxA1lJI=
=2hEK
-----END PGP SIGNATURE-----

--Sig_/nMq1J81jRSEAG+Bb7.2XR5J--
