Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58784 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbaGUUlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 16:41:03 -0400
Date: Tue, 22 Jul 2014 06:40:49 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140722064049.6478e74d@notabene.brown>
In-Reply-To: <20140721074412.4d9be086@tlielax.poochiereds.net>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-11-git-send-email-jlayton@primarydata.com>
	<20140721170254.0289ab9f@notabene.brown>
	<20140721074412.4d9be086@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/HDOUhrIc=0ckY=u.nzUps.0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/HDOUhrIc=0ckY=u.nzUps.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Jul 2014 07:44:12 -0400 Jeff Layton <jeff.layton@primarydata.com>
wrote:

> On Mon, 21 Jul 2014 17:02:54 +1000
> NeilBrown <neilb@suse.de> wrote:

> > >  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > > =20
> > >  	__set_bit(hash&255, bd->set[bd->new]);
> > >  	__set_bit((hash>>8)&255, bd->set[bd->new]);
> > >  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> > > +	spin_lock(&blocked_delegations_lock);
> >=20
> > __set_bit isn't atomic.  The spin_lock should be taken *before* these
> > __set_bit() calls.
> >=20
> > Otherwise, looks fine.
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
>=20
> Ok. I guess the worry is that we could end up setting bits in the
> middle of swapping the two fields? Makes sense -- fixed in my repo.

It is more subtle than that.
__set_bit() will:
  read a value from memory to a register
  set a bit in the register
  write the register back out to memory

If two threads both run __set_bit on the same word of memory at the same
time, one of the updates can get lost.
set_bit() (no underscore) performs an atomic RMW to avoid this, but is more
expensive.
spin_lock() obviously ensures the required exclusion and as we are going to
take the lock anyway we may as well take it before setting bits so we can u=
se
the non-atomic (cheaper) __set_bit function.

> I'll send out the updated set later today (it also includes a few nits
> that HCH pointed out last week).
>=20
> As a side note...I wonder how much we'll get in the way of false
> positives with this scheme?

If a future version of NFSv4 could allow delegations to be granted while a
file is open (oh, it seems you are the only client using this file at the
moment, you can treat this "open" as a delegation if you like) a few false
positives would be a complete non-issue.  As it is, I think we just have to
hope.

Thanks,
NeilBrown


--Sig_/HDOUhrIc=0ckY=u.nzUps.0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8160Tnsnt1WYoG5AQLJ+BAAkcBf7yv9QhOI/ct0YV8KSFPwP8iogQbt
Cv9wbmFVWj9XXJoxyl/r+bO1rNlZRVwqnjH4+U2xfE1g5a5Qf0v0VisGlZnvrCnI
dTmeRI3igOn3nt2Qc+A2X4d09yzETY2W8ACZPorJtMjzFUotsFz/o4LpzIFKylt2
3G68jyNE1hq9lT97Eysor/2hUEpIHjVV4SLxK3hFlGN1TBDrb35e+XJBTQuUY7Jc
2GqmDdBBtycfV4ZIY3xWsUatdzyCykQf7Bklz1TX1EXR45djCaQWv858nqw6LMq0
D3CfZG7uuSzCr9gsuuiky806d6OeDI9qCGrf5DsI/MhD+VeZ6HxPufWARvXxi0G6
9eldZ4Z+LJVm7HkPcMHVN+mxg4g4Z9jKqmUzxHxQ7XX+Derk3x71mOKN1HbonqwK
WQCRVZJrfAnozEvrMSPS0nRb0iik0bfpM5FwSSHv7vvdpVFVA9Sf6bsEb/tY6XFr
uyWUuto76qh/PfzNk5KOD/x6/uehXR7LsNwJEV7zRDd7LQs0kAdGSGnO510S4TQo
tU8k1nHAq5rbYsPeiyXht/LBqNegN+pgbTsU7d6ELg/soBBAVcOv+XfsszyWdK9A
gjJUx4gEEs06+XTazMVV8F2qIvk78We1WZn6z2zR/gDJ8C5Z+Q7f2cg4g050PLzJ
IPuVpBJ/dfA=
=f9LG
-----END PGP SIGNATURE-----

--Sig_/HDOUhrIc=0ckY=u.nzUps.0--
