Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58428 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbbAMCOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 21:14:51 -0500
Date: Tue, 13 Jan 2015 15:14:40 +1300
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        "L. A. Walsh" <suse@tlinx.org>, Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v2 05/17] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20150113151440.372733ed@notabene.brown>
In-Reply-To: <20150112182500.33bebf6c@tlielax.poochiereds.net>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-6-git-send-email-jlayton@primarydata.com>
	<20150113120343.02e0b977@notabene.brown>
	<20150112182500.33bebf6c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/WaR=38e+HyQDZN4pKHrZyXq"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/WaR=38e+HyQDZN4pKHrZyXq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 12 Jan 2015 18:25:00 -0500 Jeff Layton <jeff.layton@primarydata.com>
wrote:

> On Tue, 13 Jan 2015 12:03:43 +1300
> NeilBrown <neilb@suse.de> wrote:
>=20
> > On Thu,  4 Sep 2014 08:38:31 -0400 Jeff Layton <jlayton@primarydata.com>
> > wrote:
> >=20
> > > Ensure that it's OK to pass in a NULL file_lock double pointer on
> > > a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
> > > do just that.
> > >=20
> > > Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
> > > with an error return. That's a problem we can handle without
> > > crashing the box if it occurs.
> > >=20
> > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > > ---
> > >  fs/locks.c                      | 34 ++++++++++++++-----------------=
---
> > >  fs/nfsd/nfs4state.c             |  2 +-
> > >  include/trace/events/filelock.h | 14 +++++++-------
> > >  3 files changed, 22 insertions(+), 28 deletions(-)
> > >=20
> > > diff --git a/fs/locks.c b/fs/locks.c
> > > index 4031324e6cca..1289b74fffbf 100644
> > > --- a/fs/locks.c
> > > +++ b/fs/locks.c
> > > @@ -1637,22 +1637,23 @@ out:
> > >  	return error;
> > >  }
> > > =20
> > > -static int generic_delete_lease(struct file *filp, struct file_lock =
**flp)
> > > +static int generic_delete_lease(struct file *filp)
> > >  {
> > > +	int error =3D -EAGAIN;
> > >  	struct file_lock *fl, **before;
> > >  	struct dentry *dentry =3D filp->f_path.dentry;
> > >  	struct inode *inode =3D dentry->d_inode;
> > > =20
> > > -	trace_generic_delete_lease(inode, *flp);
> > > -
> > >  	for (before =3D &inode->i_flock;
> > >  			((fl =3D *before) !=3D NULL) && IS_LEASE(fl);
> > >  			before =3D &fl->fl_next) {
> > > -		if (fl->fl_file !=3D filp)
> > > -			continue;
> > > -		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
> > > +		if (fl->fl_file =3D=3D filp)
> > > +			break;
> > >  	}
> > > -	return -EAGAIN;
> > > +	trace_generic_delete_lease(inode, fl);
> > > +	if (fl)
> > > +		error =3D fl->fl_lmops->lm_change(before, F_UNLCK);
> > > +	return error;
> > >  }
> >=20
> > Hi Jeff,
> >  I have a report of a crash in 3.18 because fl->fl_lmops is NULL in the=
 above.
> >    https://bugzilla.suse.com/show_bug.cgi?id=3D912569
> >=20
> > I assume this happens because a file_lock is found which is not IS_LEAS=
E.
> > When that happens, the loop will abort, but fl will not be NULL.
> > As non-LEASE locks have  a NULL fl_lmops, we crash.
> >=20
> > I would be inclined to put the code back the way it was, and just move =
the
> > trace_generic_delete_lease call.
> >=20
> > Alternately we could make it
> >=20
> >   if (fl && IS_LEASE(fl))
> >           error =3D fl->fl_lmops-> .....
> >=20
> > What do you think?
> >=20
> > NeilBrown
>=20
> Doh! Well spotted...
>=20
> Either fix sounds fine as long as we don't make generic_delete_lease
> require a "flp" arg again. IOW, if you do make the code work similarly
> to how it did before, then we should do:
>=20
>     return fl->fl_lmops->lm_change(before, F_UNLCK);
>=20
> ...rather than trying to use the ops from a completely different struct
> file_lock argument that's passed in.
>=20
> FWIW, I have an overhaul of the locking code that is queued for v3.20
> that will also fix this (as we'll be moving all of the different locks
> to separate lists), but we'll obviously need to queue up a patch for
> stable for this in the interim.
>=20
> Thanks!


As you are going to re-write it all I won't try to make it elegant, just a
simple fix.  I'll post shortly.

Thanks,
NeilBrown

--Sig_/WaR=38e+HyQDZN4pKHrZyXq
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVLR/kDnsnt1WYoG5AQIWHA/+L6Pyd4tnKvn3NenbgGhTPCPDUtDzeCJU
Tiyb1SpweAEu78SFMRva5J3X1eOKwfGyG/WKGc50OeG5pR3IHQ0Lqghh8XKxEkov
LhL6Am263+/1qGkrn6ZAcJ0AJasA5SIP/h5r03nkAx0SUc01ONpbMKxmlvfjV7UX
0j64hNMu0TK4b312Th8hi8KH9Xg5TfkQbGfDJC6tgtlVWRmFi8giF2i9YGawJOyG
7s1gQTvsnuKFc/hibjtxUMOki/Z8HhQhrn/rTRNvonGSL+I4XTDjEiMpX9j/iIgw
gz3+yLu4o0q/MuVeW8R8HADFbkj/bOBVwRxUotEJ2GXulNR6ItAXmG8jXV9Ub6qQ
q87o2G7dBsiGxMdjqai4SzKgkcTp1Mo4y/vfCkCAV9oXOoi3wVcakcsHSKbuwN0M
2KWDV6YB/ChZlpXF2E/Antbue6qjYxfyfbv2oSZ+oDk9fXN7pgVxLhEYgy4kIJ68
dkxgwakPaat1xjiQPlJU9oXw0rwGAwuRIQckLsyRYT+6n/gHgeK6TI57hFue0cL4
CNoEAVM2oBH7n2SgUTG/Y2iTZDbfzUPpK2cWOUdL+yh8QxjMLqamsDYJksvvMNT+
gBjS1xKBmh+as8dHoRk4xik9gUjktElP4JXoPtN4oq5vwvBQmD4hBmV9/LOt+3fe
+VyvVwWxcu0=
=BRWs
-----END PGP SIGNATURE-----

--Sig_/WaR=38e+HyQDZN4pKHrZyXq--
