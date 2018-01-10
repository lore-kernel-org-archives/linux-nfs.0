Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54268 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752264AbeAJCdv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 21:33:51 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 10 Jan 2018 13:33:43 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] Support statx() mask and query flags parameters
In-Reply-To: <20180109162353.10698-1-trond.myklebust@primarydata.com>
References: <20180109162353.10698-1-trond.myklebust@primarydata.com>
Message-ID: <87h8rubfy0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 09 2018, Trond Myklebust wrote:

> Support the query flags AT_STATX_FORCE_SYNC by forcing an attribute
> revalidation, and AT_STATX_DONT_SYNC by returning cached attributes
> only.
>
> Use the mask to optimise away server revalidation for attributes
> that are not being requested by the user.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> v2:
>  - Respect the attribute cache timeout.
>  - Unless AT_STATX_DONT_SYNC is set, we must only return attributes
>    that have been duly revalidated.

This looks good, thanks.
It handles _FORCE_SYNC and _DONT_SYNC and avoids the flush if
CTIME/MTIME aren't requested.

I note that you no longer call nfs_need_revalidate_inode().
Most of the checks in there you have included in a different form,
but I don't see a test for NFS_INO_INVALID_LABEL.  Is there a reason
that we don't need that test any more?  Was it redundant previously?

Thanks,
NeilBrown


>
>  fs/nfs/inode.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 38 insertions(+), 13 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index b112002dbdb2..c2c8bb7755ad 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -735,12 +735,20 @@ int nfs_getattr(const struct path *path, struct kst=
at *stat,
>  		u32 request_mask, unsigned int query_flags)
>  {
>  	struct inode *inode =3D d_inode(path->dentry);
> -	int need_atime =3D NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
> +	struct nfs_server *server =3D NFS_SERVER(inode);
> +	unsigned long cache_validity;
>  	int err =3D 0;
> +	bool force_sync =3D query_flags & AT_STATX_FORCE_SYNC;
> +	bool do_update =3D false;
>=20=20
>  	trace_nfs_getattr_enter(inode);
> +
> +	if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync)
> +		goto out_no_update;
> +
>  	/* Flush out writes to the server in order to update c/mtime.  */
> -	if (S_ISREG(inode->i_mode)) {
> +	if ((request_mask & (STATX_CTIME|STATX_MTIME)) &&
> +			S_ISREG(inode->i_mode)) {
>  		err =3D filemap_write_and_wait(inode->i_mapping);
>  		if (err)
>  			goto out;
> @@ -757,24 +765,41 @@ int nfs_getattr(const struct path *path, struct kst=
at *stat,
>  	 */
>  	if ((path->mnt->mnt_flags & MNT_NOATIME) ||
>  	    ((path->mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
> -		need_atime =3D 0;
> -
> -	if (need_atime || nfs_need_revalidate_inode(inode)) {
> -		struct nfs_server *server =3D NFS_SERVER(inode);
> -
> +		request_mask &=3D ~STATX_ATIME;
> +
> +	/* Is the user requesting attributes that might need revalidation? */
> +	if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX_CTIME|
> +					STATX_MTIME|STATX_UID|STATX_GID|
> +					STATX_SIZE|STATX_BLOCKS)))
> +		goto out_no_revalidate;
> +
> +	/* Check whether the cached attributes are stale */
> +	do_update |=3D force_sync || nfs_attribute_cache_expired(inode);
> +	cache_validity =3D READ_ONCE(NFS_I(inode)->cache_validity);
> +	do_update |=3D cache_validity & NFS_INO_INVALID_ATTR;
> +	if (request_mask & STATX_ATIME)
> +		do_update |=3D cache_validity & NFS_INO_INVALID_ATIME;
> +	if (request_mask & (STATX_CTIME|STATX_MTIME))
> +		do_update |=3D cache_validity & NFS_INO_REVAL_PAGECACHE;
> +	if (do_update) {
> +		/* Update the attribute cache */
>  		if (!(server->flags & NFS_MOUNT_NOAC))
>  			nfs_readdirplus_parent_cache_miss(path->dentry);
>  		else
>  			nfs_readdirplus_parent_cache_hit(path->dentry);
>  		err =3D __nfs_revalidate_inode(server, inode);
> +		if (err)
> +			goto out;
>  	} else
>  		nfs_readdirplus_parent_cache_hit(path->dentry);
> -	if (!err) {
> -		generic_fillattr(inode, stat);
> -		stat->ino =3D nfs_compat_user_ino64(NFS_FILEID(inode));
> -		if (S_ISDIR(inode->i_mode))
> -			stat->blksize =3D NFS_SERVER(inode)->dtsize;
> -	}
> +out_no_revalidate:
> +	/* Only return attributes that were revalidated. */
> +	stat->result_mask &=3D request_mask;
> +out_no_update:
> +	generic_fillattr(inode, stat);
> +	stat->ino =3D nfs_compat_user_ino64(NFS_FILEID(inode));
> +	if (S_ISDIR(inode->i_mode))
> +		stat->blksize =3D NFS_SERVER(inode)->dtsize;
>  out:
>  	trace_nfs_getattr_exit(inode, err);
>  	return err;
> --=20
> 2.14.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpVe4cACgkQOeye3VZi
gbkkdg//balZdMxWNxFGqwoS4n65DvHhepJJaoXZbwwwGMWLtNB7FmZxSWoi/M44
SU8625CmCyPhfosmfo19YeJBuHIH+mOINXnQ6znnSKyV/W1+fYdlZGyekilWaNb2
lKXDJmVddfkaVBp9/dRUWTnJ82r6oB8+IPdHngHDQ4vml2zDZCJS6b8+YPDjQJr5
mybhh69LursXtKE16O6u8nG7q1js8yxrglovIByigntNXBvRX/OcBrgUpTHQwxMi
pXjKmj3tw4kF+0jzmLL9ea+KvHJZ6Dd+koVYqdz0WTFerFmnX38mQryaN/muagpZ
UyunR0gMCJ1VA+EpvdAT3ChXcyfEavlYHqwICg382LJcwpZjT+7+rJFelGI6sVoN
+ETgU+TMalbyNujB+btDx4awuJUM3gXM33VvzLLZlCm85OMPdcQFe8ouuTXm13cs
8gj30ba7BJb46ddcwXXYrd4/VBq1yJfczAGutCriLDbZ8b+hLu+uStOgnyvsasqh
fUnGfdyv97lLJXUKaRTWrDteqb9VpWwNE7ZRpYECcZ4fpHSij70EpCQYCzkc7ZZN
gVnFD0sxVJvBl2eGc/Gu9NC+I83uxlD9mvpliM6eoOuJ9yWhwTg7LhKfO7NEL94L
ymmPMHn78LoZse1unk6O8GVAmhF3MYAKWNnvDnErubgQu4+OKj4=
=BSxf
-----END PGP SIGNATURE-----
--=-=-=--
