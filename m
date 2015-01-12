Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:42814 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbALXZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2015 18:25:05 -0500
Received: by mail-qg0-f45.google.com with SMTP id z107so20155832qgd.4
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jan 2015 15:25:03 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 12 Jan 2015 18:25:00 -0500
To: NeilBrown <neilb@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        "L. A. Walsh" <suse@tlinx.org>, Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v2 05/17] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20150112182500.33bebf6c@tlielax.poochiereds.net>
In-Reply-To: <20150113120343.02e0b977@notabene.brown>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-6-git-send-email-jlayton@primarydata.com>
	<20150113120343.02e0b977@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/PpsVTiTFfQrFLRtFuF7iLsB"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/PpsVTiTFfQrFLRtFuF7iLsB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 13 Jan 2015 12:03:43 +1300
NeilBrown <neilb@suse.de> wrote:

> On Thu,  4 Sep 2014 08:38:31 -0400 Jeff Layton <jlayton@primarydata.com>
> wrote:
>=20
> > Ensure that it's OK to pass in a NULL file_lock double pointer on
> > a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
> > do just that.
> >=20
> > Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
> > with an error return. That's a problem we can handle without
> > crashing the box if it occurs.
> >=20
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/locks.c                      | 34 ++++++++++++++--------------------
> >  fs/nfsd/nfs4state.c             |  2 +-
> >  include/trace/events/filelock.h | 14 +++++++-------
> >  3 files changed, 22 insertions(+), 28 deletions(-)
> >=20
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 4031324e6cca..1289b74fffbf 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -1637,22 +1637,23 @@ out:
> >  	return error;
> >  }
> > =20
> > -static int generic_delete_lease(struct file *filp, struct file_lock **=
flp)
> > +static int generic_delete_lease(struct file *filp)
> >  {
> > +	int error =3D -EAGAIN;
> >  	struct file_lock *fl, **before;
> >  	struct dentry *dentry =3D filp->f_path.dentry;
> >  	struct inode *inode =3D dentry->d_inode;
> > =20
> > -	trace_generic_delete_lease(inode, *flp);
> > -
> >  	for (before =3D &inode->i_flock;
> >  			((fl =3D *before) !=3D NULL) && IS_LEASE(fl);
> >  			before =3D &fl->fl_next) {
> > -		if (fl->fl_file !=3D filp)
> > -			continue;
> > -		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
> > +		if (fl->fl_file =3D=3D filp)
> > +			break;
> >  	}
> > -	return -EAGAIN;
> > +	trace_generic_delete_lease(inode, fl);
> > +	if (fl)
> > +		error =3D fl->fl_lmops->lm_change(before, F_UNLCK);
> > +	return error;
> >  }
>=20
> Hi Jeff,
>  I have a report of a crash in 3.18 because fl->fl_lmops is NULL in the a=
bove.
>    https://bugzilla.suse.com/show_bug.cgi?id=3D912569
>=20
> I assume this happens because a file_lock is found which is not IS_LEASE.
> When that happens, the loop will abort, but fl will not be NULL.
> As non-LEASE locks have  a NULL fl_lmops, we crash.
>=20
> I would be inclined to put the code back the way it was, and just move the
> trace_generic_delete_lease call.
>=20
> Alternately we could make it
>=20
>   if (fl && IS_LEASE(fl))
>           error =3D fl->fl_lmops-> .....
>=20
> What do you think?
>=20
> NeilBrown

Doh! Well spotted...

Either fix sounds fine as long as we don't make generic_delete_lease
require a "flp" arg again. IOW, if you do make the code work similarly
to how it did before, then we should do:

    return fl->fl_lmops->lm_change(before, F_UNLCK);

...rather than trying to use the ops from a completely different struct
file_lock argument that's passed in.

FWIW, I have an overhaul of the locking code that is queued for v3.20
that will also fix this (as we'll be moving all of the different locks
to separate lists), but we'll obviously need to queue up a patch for
stable for this in the interim.

Thanks!
--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/PpsVTiTFfQrFLRtFuF7iLsB
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUtFfMAAoJEAAOaEEZVoIV3IMP/0nPOPK81BMtXbbUjVhJq33a
13Mea3fJlsSk/v0om9zuoQ87HrmKKm6q0eGNDC3kfiDsq98Y2Uu3ZCUb+7kKcaQM
lXRfWjp9YyRyy4bOx+6/Tm7GvxXQI32gVo9Sxb8j1tIyMPYFtRqg3v7/a3LQLSUy
rs7AZtWbpEx7PpCa9K0eRfTc/w/LiTSUP+K+hj3k3UA+u6XwWUo720t54Ijt0bfF
XsjEg+O2iayBamS7j4QK60khl7B+SF389ymAug1OstCnCUj89OK+LAkZ1DhzveKd
zzRjfclPQjJuwXm1ftiDQ5JoNSnTi6kHOYuHSxO3s4sKGdy6qFblyyQX0YHvbNpg
5xEHqHE55YddreDhsEZR2F0FLYzAK6HjMwMnxJzdTaAPNBA+vO0fp9jc/U+Va8mU
vqinxtidUPtCVXSPJSEcJC2w7wWcH2Wcd1h3osiCNVRuJKg9RfYdQTI+MqEYgHyC
ZtTT1tMKX77atZhiN8zNK26BbKg1Z82B+Z8gEbsdFdKg2NXraA8M6lmqed8fE2Eu
mPs4fb57CQXnmntDPmIIJ/xp1X9kanBjpTa5mFST8fe5Xpw27WOWx+LvigDdnM7p
qtZ06B8Nx5e/SSVq9go/kaBxx85utp4emPPtc9k2vvwFvS85JXYm1GTM8Bi7LgqC
n+7aYfwkCdR7G5ZRw+QW
=7ceP
-----END PGP SIGNATURE-----

--Sig_/PpsVTiTFfQrFLRtFuF7iLsB--
