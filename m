Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:64033 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989AbaGNMO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 08:14:59 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so3364291qcq.20
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 05:14:57 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 14 Jul 2014 08:14:55 -0400
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140714081455.69f55224@tlielax.poochiereds.net>
In-Reply-To: <20140714151405.2fa06dd7@notabene.brown>
References: <20140714151405.2fa06dd7@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/MeCzUKgB9BDsSciHf=APoWv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MeCzUKgB9BDsSciHf=APoWv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 Jul 2014 15:14:05 +1000
NeilBrown <neilb@suse.de> wrote:

>=20
> If an 'open' of a file in an NFSv4 filesystem finds that the dentry is
> in cache, but the inode is stale (on the server), the dentry will not
> be re-validated immediately and may cause ESTALE to be returned to
> user-space.
>=20
> For a non-create 'open', do_last() calls lookup_fast() and on success
> will eventually call may_open() which calls into nfs_permission().
> If nfs_permission() makes the ACCESS call to the server it will get
> NFS4ERR_STALE, resulting in ESTALE from may_open() and thence from
> do_last().
> The retry-on-ESTALE in filename_lookup() will repeat exactly the same
> process because nothing in this path will invalidate the dentry due to
> the inode being stale, so the ESTALE will be returned.
>=20
> lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFSv4
> filesystem, that will succeed for regular files:
> 	/* Let f_op->open() actually open (and revalidate) the file */
>=20
> Unfortunately in the case of a STALE inode, f_op->open() never gets
> called.  If we teach nfs4_lookup_revalidate() to report a failure on
> NFS_STALE() inodes, then the dentry will be invalidated and a full
> lookup will be attempted.  The ESTALE errors go away.
>=20
>=20
> While I think this fix is correct, I'm not convinced that it is
> sufficient, particularly if lookupcache=3Dnone.
> The current code will fail an "open" is nfs_permission() fails,
> without having performed a LOOKUP. i.e. it will use the cache.
> nfs_lookup_revalidate will force a lookup before the permission check
> if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will not.
>=20

This patch should make the code fall through to nfs_lookup_revalidate,
which would then force the lookup, right?

Also, I'm a little unclear...

Why would may_open fail with ESTALE after the v4 OPEN succeeds? The
OPEN should be returning a filehandle and attributes for the inode
actually opened. It seems like we ought to be doing any permission
checks vs. that inode, not anything we had in cache. Presumably the
server is then holding it open so it shouldn't be stale.

Are we not properly updating the dcache (and attrcache) after the OPEN
reply?

>=20
> Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 4a3d4ef76127..4f7414afca27 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1563,6 +1563,8 @@ static int nfs4_lookup_revalidate(struct dentry
> *dentry, unsigned int flags) /* We cannot do exclusive creation on a
> positive dentry */ if (flags & LOOKUP_EXCL)
>  		goto no_open_dput;
> +	if (NFS_STALE(inode))
> +		goto no_open_dput;
> =20
>  	/* Let f_op->open() actually open (and revalidate) the file
> */ ret =3D 1;

Looks legit to me too, but it seems like the inode could go stale w/o
us knowing after this point.

Acked-by: Jeff Layton <jlayton@primarydata.com>

--Sig_/MeCzUKgB9BDsSciHf=APoWv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTw8m/AAoJEAAOaEEZVoIVEWYQALpaPwCKjPXlgFoIfTRn/+gi
M+0RKvRiVptX5SFdpmTxDpRkwPeo4+olNC/kXyy5UET5GEkJjZ9FuLcCx1FLUomA
V8xK5hynYzWzSARVwDJH7VK0mlqp/OfWZ7GdxaxC8jrBkM3uZOkX9TukaIl/f0MU
GHhetDDzym3uEVX+Q/G79ou/dzUvQr8jL6doVWp7uzDebRyS8SO1gIJ6YLW9X1Ru
p+44r8gOTnT2GULInC16KeJgv/lxC3V2G9EXSDh+hmwkxjxyj3N6mSRsmaWQEA0e
P9kOokaLjgNAeaWsLpgQJ0VfIrgYlIZ4933FHChtgMCJ9BddbMkbrq9hOrTEbttp
z9U6mzwoBR6VpFzjD8mLwmQb2G9lK5gtgOSZQTGNGDZBqnxVpGYMMRjvprsbhTL9
TigbnyfqX/oUau61WoHWcJj+PjSa8tTp8QutmI2f0IT3W+BIOMv7zTKYffA6slxb
+AxCRoXI7kVNqVpVLDh2EkY/s3qGLc0YUPs29c9qJn8QVeNtCQmmi6pLs9+Tw5cs
O2hgyXnDzMsMeAv21rMZw0iB09ZTy6EzgzRY6RzjJ0YPDkR+0hkCI+OGbCVH6AMH
99iiLIFmCD+sSfD5KnVZpPksf4+DFl3h/VLLnT7LwRP4xlh28kSF6H6apizyi8G0
mLQVlI12fZxHBF7iF/zB
=OmzF
-----END PGP SIGNATURE-----

--Sig_/MeCzUKgB9BDsSciHf=APoWv--
