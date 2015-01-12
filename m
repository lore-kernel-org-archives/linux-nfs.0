Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56657 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbbALXEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 18:04:11 -0500
Date: Tue, 13 Jan 2015 12:03:43 +1300
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        "L. A. Walsh" <suse@tlinx.org>, Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH v2 05/17] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20150113120343.02e0b977@notabene.brown>
In-Reply-To: <1409834323-7171-6-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/B0dade/Go=U/Q/eY3u0LKe8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/B0dade/Go=U/Q/eY3u0LKe8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu,  4 Sep 2014 08:38:31 -0400 Jeff Layton <jlayton@primarydata.com>
wrote:

> Ensure that it's OK to pass in a NULL file_lock double pointer on
> a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
> do just that.
>=20
> Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
> with an error return. That's a problem we can handle without
> crashing the box if it occurs.
>=20
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/locks.c                      | 34 ++++++++++++++--------------------
>  fs/nfsd/nfs4state.c             |  2 +-
>  include/trace/events/filelock.h | 14 +++++++-------
>  3 files changed, 22 insertions(+), 28 deletions(-)
>=20
> diff --git a/fs/locks.c b/fs/locks.c
> index 4031324e6cca..1289b74fffbf 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1637,22 +1637,23 @@ out:
>  	return error;
>  }
> =20
> -static int generic_delete_lease(struct file *filp, struct file_lock **fl=
p)
> +static int generic_delete_lease(struct file *filp)
>  {
> +	int error =3D -EAGAIN;
>  	struct file_lock *fl, **before;
>  	struct dentry *dentry =3D filp->f_path.dentry;
>  	struct inode *inode =3D dentry->d_inode;
> =20
> -	trace_generic_delete_lease(inode, *flp);
> -
>  	for (before =3D &inode->i_flock;
>  			((fl =3D *before) !=3D NULL) && IS_LEASE(fl);
>  			before =3D &fl->fl_next) {
> -		if (fl->fl_file !=3D filp)
> -			continue;
> -		return (*flp)->fl_lmops->lm_change(before, F_UNLCK);
> +		if (fl->fl_file =3D=3D filp)
> +			break;
>  	}
> -	return -EAGAIN;
> +	trace_generic_delete_lease(inode, fl);
> +	if (fl)
> +		error =3D fl->fl_lmops->lm_change(before, F_UNLCK);
> +	return error;
>  }

Hi Jeff,
 I have a report of a crash in 3.18 because fl->fl_lmops is NULL in the abo=
ve.
   https://bugzilla.suse.com/show_bug.cgi?id=3D912569

I assume this happens because a file_lock is found which is not IS_LEASE.
When that happens, the loop will abort, but fl will not be NULL.
As non-LEASE locks have  a NULL fl_lmops, we crash.

I would be inclined to put the code back the way it was, and just move the
trace_generic_delete_lease call.

Alternately we could make it

  if (fl && IS_LEASE(fl))
          error =3D fl->fl_lmops-> .....

What do you think?

NeilBrown

--Sig_/B0dade/Go=U/Q/eY3u0LKe8
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVLRSzznsnt1WYoG5AQI4Zw/+NRjisaUY9EayEKIyn8xuqshuADgGlkOf
hFRt+1K4TVA5WnLNSncJtSk86ju99Kpfn13SamIygMiT9MNeZWVi/JNxSXkjy+Qn
o6de+1Z9YAPYYdTwkNWBBpu9SwmOTiFlMUHUxemime02VHz2JixQktBRvcs4C+6a
Uh6Bd9Oy9i5PFfi6iL/Qxo130lF/5mxxHLjc35a/JDkt+7GIAV1n1v3ceEXkNI7W
1isw9yV6j77l362gcZ/3Y1xQq3wEL2LYQ1JSXXKaI93rqjZTTlXoFWxa9ab85XMM
w3+f5mRFz9NHHJIk5RKyicUyTLzxzrGd5lppmxX8ys1zugT97j/1b1gqt3D598aH
R5AN0wvXUw7Brx28nMWJvMiprlowe/sHhAPLQS+tMSRjg//8QOaLtZCMKjeOwTkn
+eyNrd0O4JuPKgXNuMDaZcbtsmffOvQRQpm1hQ+96QIERPETSppOLtRUrGl/P9Kn
sTznpsIxwQZ0UaftsSGWYIFkLjzBZZ9t3dCGgnKJ4oV+Q0cNhS7h8hgTzonTKZ/e
KckupPevhBRjbt1JkHh97EQ7wzI/78EYVyOrzqYoM+5JDZivmmkvpP1lLXQklp5G
ATdR/LwT8DnUsUSP4NVHY71Eydxqky7R8wWf3gcuBB33W9M4Zn/89rm8SQCkCES/
vKJ9mJyra6Y=
=x9mW
-----END PGP SIGNATURE-----

--Sig_/B0dade/Go=U/Q/eY3u0LKe8--
