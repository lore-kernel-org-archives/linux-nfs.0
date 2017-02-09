Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36197 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdBIP4E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 10:56:04 -0500
Received: by mail-it0-f67.google.com with SMTP id f200so2631780itf.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Feb 2017 07:56:04 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfsd: restore owner override for truncate
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20170209142238.5322-1-hch@lst.de>
Date: Thu, 9 Feb 2017 10:56:01 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4EE105F6-4749-4408-A190-AE0A7EBE2E67@gmail.com>
References: <20170209142238.5322-1-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 9, 2017, at 9:22 AM, Christoph Hellwig <hch@lst.de> wrote:
>=20
> The switch to vfs_truncate in nfsd_setattr dropped the owner override
> used for NFS permissions.  Add a copy of vfs_truncate with it restored
> to the nfsd code for now as it's very late in the cycle, but there
> should be a way to consolidate it back in the future.
>=20
> Fixes: 41f53350 ("nfsd: special case truncates some more")
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Chuck Lever <chucklever@gmail.com>
> ---
> fs/nfsd/vfs.c | 81 =
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 80 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index a974368026a1..fd4a32e0b0b4 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -332,6 +332,85 @@ nfsd_sanitize_attrs(struct inode *inode, struct =
iattr *iap)
> 	}
> }
>=20
> +/* copy of vfs_truncate with NFS owner override hacked in, sigh.. */
> +static long nfsd_truncate(const struct path *path, loff_t length)
> +{
> +	struct inode *inode;
> +	struct dentry *upperdentry;
> +	long error;
> +
> +	inode =3D path->dentry->d_inode;
> +
> +	/* For directories it's -EISDIR, for other non-regulars - =
-EINVAL */
> +	if (S_ISDIR(inode->i_mode))
> +		return -EISDIR;
> +	if (!S_ISREG(inode->i_mode))
> +		return -EINVAL;
> +
> +	error =3D mnt_want_write(path->mnt);
> +	if (error)
> +		goto out;
> +
> +	/*
> +	 * The file owner always gets access permission for accesses =
that
> +	 * would normally be checked at open time. This is to make
> +	 * file access work even when the client has done a fchmod(fd, =
0).
> +	 *
> +	 * However, `cp foo bar' should fail nevertheless when bar is
> +	 * readonly. A sensible way to do this might be to reject all
> +	 * attempts to truncate a read-only file, because a creat() call
> +	 * always implies file truncation.
> +	 * ... but this isn't really fair.  A process may reasonably =
call
> +	 * ftruncate on an open file descriptor on a file with perm 000.
> +	 * We must trust the client to do permission checking - using =
"ACCESS"
> +	 * with NFSv3.
> +	 */
> +	if (!uid_eq(inode->i_uid, current_fsuid())) {
> +		error =3D inode_permission(inode, MAY_WRITE);
> +		if (error)
> +			goto mnt_drop_write_and_out;
> +	}
> +
> +	error =3D -EPERM;
> +	if (IS_APPEND(inode))
> +		goto mnt_drop_write_and_out;
> +
> +	/*
> +	 * If this is an overlayfs then do as if opening the file so we =
get
> +	 * write access on the upper inode, not on the overlay inode.  =
For
> +	 * non-overlay filesystems d_real() is an identity function.
> +	 */
> +	upperdentry =3D d_real(path->dentry, NULL, O_WRONLY);
> +	error =3D PTR_ERR(upperdentry);
> +	if (IS_ERR(upperdentry))
> +		goto mnt_drop_write_and_out;
> +
> +	error =3D get_write_access(upperdentry->d_inode);
> +	if (error)
> +		goto mnt_drop_write_and_out;
> +
> +	/*
> +	 * Make sure that there are no leases.  get_write_access() =
protects
> +	 * against the truncate racing with a lease-granting setlease().
> +	 */
> +	error =3D break_lease(inode, O_WRONLY);
> +	if (error)
> +		goto put_write_and_out;
> +
> +	error =3D locks_verify_truncate(inode, NULL, length);
> +	if (!error)
> +		error =3D security_path_truncate(path);
> +	if (!error)
> +		error =3D do_truncate(path->dentry, length, 0, NULL);

do_truncate does not seem to be available in the EXPORT_SYMBOL pool.


> +
> +put_write_and_out:
> +	put_write_access(upperdentry->d_inode);
> +mnt_drop_write_and_out:
> +	mnt_drop_write(path->mnt);
> +out:
> +	return error;
> +}
> +
> /*
>  * Set various file attributes.  After this call fhp needs an fh_put.
>  */
> @@ -398,7 +477,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh =
*fhp, struct iattr *iap,
> 		    ((iap->ia_valid & ~(ATTR_SIZE | ATTR_MTIME)) =3D=3D =
0))
> 			implicit_mtime =3D true;
>=20
> -		host_err =3D vfs_truncate(&path, iap->ia_size);
> +		host_err =3D nfsd_truncate(&path, iap->ia_size);
> 		if (host_err)
> 			goto out_host_err;
>=20
> --=20
> 2.11.0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



