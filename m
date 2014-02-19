Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46434 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaBSBeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 20:34:16 -0500
Date: Wed, 19 Feb 2014 12:34:05 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/12] NFS fix error return in nfs4_select_rw_stateid
Message-ID: <20140219123405.5a792436@notabene.brown>
In-Reply-To: <1392741222.4923.4.camel@leira.trondhjem.org>
References: <1392737765-41942-1-git-send-email-andros@netapp.com>
	<1392741222.4923.4.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UfaDIvueoevr8rkjfS1uB6U"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/UfaDIvueoevr8rkjfS1uB6U
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Feb 2014 11:33:42 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Tue, 2014-02-18 at 10:36 -0500, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> >=20
> > Do not return an error when nfs4_copy_delegation_stateid succeeds.
> >=20
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfs/nfs4state.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index ba18958..1cfde97 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -1120,8 +1120,11 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, st=
ruct nfs4_state *state,
> >  	if (ret =3D=3D -EIO)
> >  		/* A lost lock - don't even consider delegations */
> >  		goto out;
> > -	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
> > +	/* returns true if delegation stateid found and copied */
> > +	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode)) {
> > +		ret =3D 0;
> >  		goto out;
> > +	}
> >  	if (ret !=3D -ENOENT)
> >  		/* nfs4_copy_delegation_stateid() didn't over-write
> >  		 * dst, so it still has the lock stateid which we now
>=20
> Ouch! That looks like it would trigger looping in both the read and
> write code when we're holding a delegation. Is that what you end up
> seeing?
>=20
> It looks like it was introduced by commit ef1820f9be27b...
>=20

Oops- that was a little careless.  Thanks for the heads-up!

NeilBrown

--Sig_/UfaDIvueoevr8rkjfS1uB6U
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwQKDTnsnt1WYoG5AQKwGw/9FWr62RwzJpzFT3X4vdVnYbsTXNyM0khW
jcW4GqdnhjY0CqNTpfqQNzwSxj1cX1TTXok5Vd9A/HkNO4Q1Td/MH+nSil3Wp5t4
hAOLdBjGCkOqcVp9DCrnO5JCIaheeK700iUCR5aH5XLOJTUdhMyTcOIHyyLYBJMz
WoksMtK2LvfjAWxQkX9aUI8KWPLOF28Lz/9RHQkLJX0ExvER64wtUttBHYiBXJTz
Ham0StxYEIvpJTSxUN2LX1wwVaTxA4DWIxRVVsZonyRPbRqGmsz+6R74nLbjzC21
rWOjzvUojHIsohqN0HqCncLnhlNtLelU/jdx7rChoA2sK8XxWshVFAYJk1/dAIcK
lOBil66uZ4JLFwCBkmk0/JQD50tIcZRp84ofYBPMStHZUVQaR80c8ht+NHu9gPjL
MGPTP9291C3Ld7bxoCZpfYrniicfm6LRQ7yRfNoXrr0SRK+JjDRxp4lVQIcU/AQf
uUFGDeJtva53I8MRPXMaPQZmQnrZc8EQjPIQoRUWsBtaQ48Tqbq1TJs3BDPBTd4g
G9k4KvCgoeroMl6UUqCvNv3ES2UL2Rk4vQ9BiVL4y+G0THIX9o1t8Hy609viDLcO
NPFOwVYYL3He1RAZJ8ntmu//BR9kWh6je/pIc7JDGCRF+QUN65K5QdEBRm+7S2OL
zqxxCq0Wi4U=
=G/cl
-----END PGP SIGNATURE-----

--Sig_/UfaDIvueoevr8rkjfS1uB6U--
