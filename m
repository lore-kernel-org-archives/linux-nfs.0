Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42617 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752510AbdDEBKm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Apr 2017 21:10:42 -0400
From: NeilBrown <neilb@suse.com>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Date: Wed, 05 Apr 2017 11:09:57 +1000
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Avoid cross-structure casting
In-Reply-To: <20170405001206.GA58184@beast>
References: <20170405001206.GA58184@beast>
Message-ID: <87efx7irru.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Apr 04 2017, Kees Cook wrote:

> When the call to nfs_devname() fails, the error path attempts to retain
> the error via the mnt variable, but this requires a cast across very
> different types (char * to struct vfsmount), which the upcoming structure
> layout randomization plugin flags as being potentially dangerous in the
> face of randomization. This is a false positive, but what this code
> actually wants to do is retain the error value, so this patch explicitly
> sets it, instead of using what seems to be an unexpected cast.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/nfs/namespace.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
> index 786f17580582..89f50bf12f52 100644
> --- a/fs/nfs/namespace.c
> +++ b/fs/nfs/namespace.c
> @@ -259,9 +259,10 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
>  	if (page == NULL)
>  		goto out;
>  	devname = nfs_devname(dentry, page, PAGE_SIZE);
> -	mnt = (struct vfsmount *)devname;
> -	if (IS_ERR(devname))
> +	if (IS_ERR(devname)) {
> +		mnt = ERR_PTR(PTR_ERR(devname));

Allow me to introduce you to ERR_CAST()
/**
 * ERR_CAST - Explicitly cast an error-valued pointer to another pointer type
 * @ptr: The pointer to cast.
 *
 * Explicitly cast an error-valued pointer to another pointer type in such a
 * way as to make it clear that's what's going on.
 */

So:
 +		mnt = ERR_CAST(devname);

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljkQ+UACgkQOeye3VZi
gbm4fA/7BWLmvhWTv7RMCtbELg15EYNpHERB9Tj7GtI19FMX2mCRh7gjc/EZyfNt
GSPeKkM+bwrlPZGPt1wG8UreMkdfRP6MvMiFTWV+4Dp7lmcJDVULodllUaxyGFlO
Ggok7GRt+CqDDi00acg13dJiwaGw+hS0US/WgX4Cf4YYG0S7xaI2XMAbM2c7v87/
llkGNzpVT4qwHKZU9cl2ah+ASDQU8LN3FdJlJoRnFBtJEMuAyo/ZBi5dhvuDUd8c
0kI7841D2D5mKI25zxOSv08hFDtVVQaWJCKl5dIfrdNHE0TMj4uHdG0BT+1tNNdQ
IuwsL/VYdqUq6b/QpZ9brFlLgaFj6Guf2CIWaLldtrRwEcw468z3/8T7ha9KQbHr
SsitNTX4EqRn6LIj8OU0iGCscXD1D+p3V3UuRW5vcFcNkr3S6kovh/LV7ojVK/CV
nXrraJ5PR+F8B8wnQAHvHDMik3YIZUwL/wAaf2eqFguzp7Ypawcr8KxYoV8eP5xi
Tt4jvAaOZ/O2G9pXW01Xn4DdkrJGgHPQOzbkmqs0bwvKv3h/E6+pXaW3h769wEZ8
BFQSUzv5Ewt1nr2bM5o954dlGPw5ajp2eBT1277noQUVT5zI42aiETcrS3/15mUP
OMVgV6BRi7qvAjxMRUaLkWwMHsh0whQiQxP35K3/43qG9cxF3q8=
=E+mH
-----END PGP SIGNATURE-----
--=-=-=--
