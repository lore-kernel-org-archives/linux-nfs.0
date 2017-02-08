Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35646 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdBHXN0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 18:13:26 -0500
Received: by mail-io0-f193.google.com with SMTP id m98so520035iod.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 15:13:16 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: NFS server regression in v4.10-rc7
From: Chuck Lever <chucklever@gmail.com>
Date: Wed, 8 Feb 2017 16:27:30 -0500
Cc: Christoph Hellwig <hch@infradead.org>
Message-Id: <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com>
References: <1485246161-20874-1-git-send-email-hch@lst.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Begin forwarded message:
>=20
> From: Christoph Hellwig <hch@lst.de>
> Subject: [PATCH v2] nfsd: special case truncates some more
> Date: January 24, 2017 at 3:22:41 AM EST
> To: bfields@fieldses.org, jlayton@poochiereds.net
> Cc: trondmy@primarydata.com, linux-nfs@vger.kernel.org
>=20
> Both the NFS protocols and the Linux VFS use a setattr operation with =
a
> bitmap of attributs to set to set various file attributes including =
the
> file size and the uid/gid.
>=20
> The Linux syscalls never mixe size updates with unrelated updates like
> the uid/gid, and some file systems like XFS and GFS2 rely on the fact
> that truncates might not update random other attributes, and many
> other file systems handle the case but do not update the different
> attributes in the same transaction.  NFSD on the other hand passes
> the attributes it gets on the wire more or less directly through to
> the VFS, leading to updates the file systems don't expect.  XFS at
> least has an assert on the allowed attributes, which cought an NFS
> client sets the size and group at the same time.
>=20
> To handles this issue properly this switches nfsd to call vfs_truncate
> for size changes, and then handling all other attributes through
> notify_change.  As a side effect this also means less boilerplace
> code around the size change as we can now reuse the VFS code.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>=20
> Changes since V1:
> - avoid an extra setattr just for a MTIME attribute on the wire
>=20
> fs/nfsd/vfs.c | 97 =
+++++++++++++++++++++++------------------------------------
> 1 file changed, 37 insertions(+), 60 deletions(-)
>=20
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 26c6fdb..e91107a 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -332,37 +332,6 @@ nfsd_sanitize_attrs(struct inode *inode, struct =
iattr *iap)
> 	}
> }
>=20
> -static __be32
> -nfsd_get_write_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
> -		struct iattr *iap)
> -{
> -	struct inode *inode =3D d_inode(fhp->fh_dentry);
> -	int host_err;
> -
> -	if (iap->ia_size < inode->i_size) {
> -		__be32 err;
> -
> -		err =3D nfsd_permission(rqstp, fhp->fh_export, =
fhp->fh_dentry,
> -				NFSD_MAY_TRUNC | =
NFSD_MAY_OWNER_OVERRIDE);
> -		if (err)
> -			return err;
> -	}
> -
> -	host_err =3D get_write_access(inode);
> -	if (host_err)
> -		goto out_nfserrno;
> -
> -	host_err =3D locks_verify_truncate(inode, NULL, iap->ia_size);
> -	if (host_err)
> -		goto out_put_write_access;
> -	return 0;
> -
> -out_put_write_access:
> -	put_write_access(inode);
> -out_nfserrno:
> -	return nfserrno(host_err);
> -}
> -
> /*
>  * Set various file attributes.  After this call fhp needs an fh_put.
>  */
> @@ -377,7 +346,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh =
*fhp, struct iattr *iap,
> 	__be32		err;
> 	int		host_err;
> 	bool		get_write_count;
> -	int		size_change =3D 0;
>=20
> 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> 		accmode |=3D NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> @@ -390,11 +358,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct =
svc_fh *fhp, struct iattr *iap,
> 	/* Get inode */
> 	err =3D fh_verify(rqstp, fhp, ftype, accmode);
> 	if (err)
> -		goto out;
> +		return err;
> 	if (get_write_count) {
> 		host_err =3D fh_want_write(fhp);
> 		if (host_err)
> -			return nfserrno(host_err);
> +			goto out_host_err;
> 	}
>=20
> 	dentry =3D fhp->fh_dentry;
> @@ -405,50 +373,59 @@ nfsd_setattr(struct svc_rqst *rqstp, struct =
svc_fh *fhp, struct iattr *iap,
> 		iap->ia_valid &=3D ~ATTR_MODE;
>=20
> 	if (!iap->ia_valid)
> -		goto out;
> +		return 0;
>=20
> 	nfsd_sanitize_attrs(inode, iap);
>=20
> +	if (check_guard && guardtime !=3D inode->i_ctime.tv_sec)
> +		return nfserr_notsync;
> +
> 	/*
> 	 * The size case is special, it changes the file in addition to =
the
> -	 * attributes.
> +	 * attributes, and file systems don't expect it to be mixed with
> +	 * "random" attribute changes.  We thus split out the size =
change
> +	 * into a separate calo for vfs_truncate, and do the rest as a
> +	 * a separate setattr call.
> 	 */
> 	if (iap->ia_valid & ATTR_SIZE) {
> -		err =3D nfsd_get_write_access(rqstp, fhp, iap);
> -		if (err)
> -			goto out;
> -		size_change =3D 1;
> +		struct path path =3D {
> +			.mnt	=3D fhp->fh_export->ex_path.mnt,
> +			.dentry	=3D dentry,
> +		};
> +		bool implicit_mtime =3D false;
>=20
> 		/*
> -		 * RFC5661, Section 18.30.4:
> -		 *   Changing the size of a file with SETATTR indirectly
> -		 *   changes the time_modify and change attributes.
> -		 *
> -		 * (and similar for the older RFCs)
> +		 * vfs_truncate implicity updates the mtime IFF the file =
size
> +		 * actually changes.  Avoid the additional seattr call =
below if
> +		 * the only other attribute that the client sends is the =
mtime.
> 		 */
> -		if (iap->ia_size !=3D i_size_read(inode))
> -			iap->ia_valid |=3D ATTR_MTIME;
> -	}
> +		if (iap->ia_size !=3D i_size_read(inode) &&
> +		    ((iap->ia_valid & ~(ATTR_SIZE | ATTR_MTIME)) =3D=3D =
0))
> +			implicit_mtime =3D true;
>=20
> -	iap->ia_valid |=3D ATTR_CTIME;
> +		host_err =3D vfs_truncate(&path, iap->ia_size);
> +		if (host_err)
> +			goto out_host_err;
>=20
> -	if (check_guard && guardtime !=3D inode->i_ctime.tv_sec) {
> -		err =3D nfserr_notsync;
> -		goto out_put_write_access;
> +		iap->ia_valid &=3D ~ATTR_SIZE;
> +		if (implicit_mtime)
> +			iap->ia_valid &=3D ~ATTR_MTIME;
> +		if (!iap->ia_valid)
> +			goto done;
> 	}
>=20
> +	iap->ia_valid |=3D ATTR_CTIME;
> +
> 	fh_lock(fhp);
> 	host_err =3D notify_change(dentry, iap, NULL);
> 	fh_unlock(fhp);
> -	err =3D nfserrno(host_err);
> +	if (host_err)
> +		goto out_host_err;
>=20
> -out_put_write_access:
> -	if (size_change)
> -		put_write_access(inode);
> -	if (!err)
> -		err =3D nfserrno(commit_metadata(fhp));
> -out:
> -	return err;
> +done:
> +	host_err =3D commit_metadata(fhp);
> +out_host_err:
> +	return nfserrno(host_err);
> }
>=20
> #if defined(CONFIG_NFSD_V4)
> --=20
> 2.1.4

After installing v4.10-rc7 on my test NFS server, I'm seeing a failure
with the git regression test suite.

*** t1050-large.sh ***
ok 1 - setup
ok 2 - add a large file or two
ok 3 - checkout a large file
not ok 4 - packsize limit
#    =20
#          test_create_repo mid &&
#          (
#               cd mid &&
#               git config core.bigfilethreshold 64k &&
#               git config pack.packsizelimit 256k &&
#    =20
#               # mid1 and mid2 will fit within 256k limit but
#               # appending mid3 will bust the limit and will
#               # result in a separate packfile.
#               test-genrandom "a" $(( 66 * 1024 )) >mid1 &&
#               test-genrandom "b" $(( 80 * 1024 )) >mid2 &&
#               test-genrandom "c" $(( 128 * 1024 )) >mid3 &&
#               git add mid1 mid2 mid3 &&
#    =20
#               count=3D0
#               for pi in .git/objects/pack/pack-*.idx
#               do
#                    test -f "$pi" && count=3D$(( $count + 1 ))
#               done &&
#               test $count =3D 2 &&
#    =20
#               (
#                    git hash-object --stdin <mid1
#                    git hash-object --stdin <mid2
#                    git hash-object --stdin <mid3
#               ) |
#               sort >expect &&
#    =20
#               for pi in .git/objects/pack/pack-*.idx
#               do
#                    git show-index <"$pi"
#               done |
#               sed -e "s/^[0-9]* \([0-9a-f]*\) .*/\1/" |
#               sort >actual &&
#    =20
#               test_cmp expect actual
#          )
#    =20
ok 5 - diff --raw
ok 6 - diff --stat
ok 7 - diff

Confirmed with NFSv3 / TCP and NFSv4.0 / TCP. Failure is 100%
reproducible.

If I revert the above commit on the server, the git regression test
suite passes.

The test is run like this: "cd /mnt/server/git; make clean; make; make =
test"

Can anyone else reproduce this failure?


--
Chuck Lever
chucklever@gmail.com



