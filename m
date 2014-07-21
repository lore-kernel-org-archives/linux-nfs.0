Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60413 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaGUWup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2014 18:50:45 -0400
Date: Tue, 22 Jul 2014 08:50:25 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140722085025.00ca48cb@notabene.brown>
In-Reply-To: <20140721211757.GL8438@fieldses.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-11-git-send-email-jlayton@primarydata.com>
	<20140721170254.0289ab9f@notabene.brown>
	<20140721074412.4d9be086@tlielax.poochiereds.net>
	<20140722064049.6478e74d@notabene.brown>
	<20140721211757.GL8438@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/CmzoP3E/TCEYC=9jwHcViun"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/CmzoP3E/TCEYC=9jwHcViun
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Jul 2014 17:17:57 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Jul 22, 2014 at 06:40:49AM +1000, NeilBrown wrote:
> > On Mon, 21 Jul 2014 07:44:12 -0400 Jeff Layton <jeff.layton@primarydata=
.com>
> > wrote:
> >=20
> > > On Mon, 21 Jul 2014 17:02:54 +1000
> > > NeilBrown <neilb@suse.de> wrote:
> >=20
> > > > >  	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > > > > =20
> > > > >  	__set_bit(hash&255, bd->set[bd->new]);
> > > > >  	__set_bit((hash>>8)&255, bd->set[bd->new]);
> > > > >  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> > > > > +	spin_lock(&blocked_delegations_lock);
> > > >=20
> > > > __set_bit isn't atomic.  The spin_lock should be taken *before* the=
se
> > > > __set_bit() calls.
> > > >=20
> > > > Otherwise, looks fine.
> > > >=20
> > > > Thanks,
> > > > NeilBrown
> > > >=20
> > > >=20
> > >=20
> > > Ok. I guess the worry is that we could end up setting bits in the
> > > middle of swapping the two fields? Makes sense -- fixed in my repo.
> >=20
> > It is more subtle than that.
> > __set_bit() will:
> >   read a value from memory to a register
> >   set a bit in the register
> >   write the register back out to memory
> >=20
> > If two threads both run __set_bit on the same word of memory at the same
> > time, one of the updates can get lost.
> > set_bit() (no underscore) performs an atomic RMW to avoid this, but is =
more
> > expensive.
> > spin_lock() obviously ensures the required exclusion and as we are goin=
g to
> > take the lock anyway we may as well take it before setting bits so we c=
an use
> > the non-atomic (cheaper) __set_bit function.
> >=20
> > > I'll send out the updated set later today (it also includes a few nits
> > > that HCH pointed out last week).
> > >=20
> > > As a side note...I wonder how much we'll get in the way of false
> > > positives with this scheme?
> >=20
> > If a future version of NFSv4 could allow delegations to be granted whil=
e a
> > file is open (oh, it seems you are the only client using this file at t=
he
> > moment, you can treat this "open" as a delegation if you like) a few fa=
lse
> > positives would be a complete non-issue.
>=20
> For what it's worth, I think 4.1 provides what you're asking for here;
> see
>=20
> 	http://tools.ietf.org/html/rfc5661#section-20.7
>=20
> and the discussion of the various WANT_ flags in
>=20
> 	http://tools.ietf.org/html/rfc5661#section-18.16.3
>=20
> As far as I know none of that is implemented yet.
>=20
> --b.

I guess I should really read the 4.1 (and 4.2) spec some day....
Though the 20.7 section seems to be about saying "resources in general are
available" rather than "this  specific file that you wanted a delegation for
but didn't get one is how up for delegation"....
But I only had a quick read so I might have missed something.

Thanks,
NeilBrown


--Sig_/CmzoP3E/TCEYC=9jwHcViun
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU82ZMTnsnt1WYoG5AQJ2ihAAo7KiFi1TqlxpeWw/GdGXLsvgz4hDfU8z
CtQGC9SZ7ykm3jIums1nsA56NxNvERq3mCnx1d2++4qRGPZHgUTj/peZpy+yRhup
lG2y1UUpXyJWAWN04lIaPG6i7P84TkvAu0f7qqOZVmVCiRze5p1pgp437KCOGkoV
rZdAWiH/Cxipt/XhRHiL9y72DpJ3UnH7REBV7aDIMOnwAG5wclEEhC/xD5S9HLjH
VsviWZEcQTtHroeZ5+j+7va83LsBsYWhIACEnkH3ne7bJgXwpgSe7z32LgyhBnP3
igZR/xeLOfLag2MikNDBSqR8sXSZhc6pVl9DJxcZCSEXhEQZfjA9t6yfe4BSI5+0
WR0Ol+KreWYNRFzQzM1XqNVMuiLkq1UJcoIryThl4qMp2lbwwQ28Q6K5vB55+nW8
ysMZRg4Q+smY717ay4aBFoVP+rdGYtZwq3xaDU3K3V4a47vlB2j4fIe+nvKrANF6
hQHRO0un7Xl5eEfws8+isZwCn+8VDN4MrUCwbA7mC1vYMTKf0pBQmsAbGcym/fJ1
L7CTEDIuFLYV4wyN5FA5pst6s58wydWhtQOsmGeOr/P+BsEpUHMggZAWLwRkd0OK
O77wLytVlSxe4mDgwGE7QOzKRjACr1WQk5FJ14vWpyW3DKaH6ZdOFuLE4hd4WS8J
VAHwD+dUNV8=
=DxvF
-----END PGP SIGNATURE-----

--Sig_/CmzoP3E/TCEYC=9jwHcViun--
