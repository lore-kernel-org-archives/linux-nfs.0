From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
	client --revised
Date: Wed, 4 Feb 2009 18:49:24 -0500
Message-ID: <20090204234924.GE20917@fieldses.org>
References: <200901121216.n0CCGYMx001106@acsinet13.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48117 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514AbZBDXtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 18:49:20 -0500
In-Reply-To: <200901121216.n0CCGYMx001106-eiegoW5zEh26xOVM2wN62FaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 08:14:46PM +0800, wengang wang wrote:
> for descriptions for the problem and solution please see my former post with
> Subject "nfsd(v2/v3): fix the failure of creation from HPUX client".

Could you just repeat that introduction each time?  I want to commit it
with the patch, and that will save me some work hunting down the old
email.

> comparing with former post, this patch puts the trick to nfsd_create_setattr().
> 
> the patch is based on 2.6.27.10.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> --
>  vfs.c |   20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
> diff -up ./fs/nfsd/vfs.c.orig ./fs/nfsd/vfs.c
> --- ./fs/nfsd/vfs.c.orig	2008-12-23 14:11:14.000000000 +0800
> +++ ./fs/nfsd/vfs.c	2009-01-12 19:35:13.000000000 +0800
> @@ -1155,7 +1155,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
>  
>  static __be32
>  nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
> -			struct iattr *iap)
> +			struct iattr *iap, int newfile)
>  {
>  	/*
>  	 * Mode has already been set earlier in create:
> @@ -1168,6 +1168,16 @@ nfsd_create_setattr(struct svc_rqst *rqs
>  	 */
>  	if (current->fsuid != 0)
>  		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
> +	/*
> +	 * HPUX client sometimes creates a file in mode 000, and set
> +	 * size to 0. setting size to 0 may fail for some spcific
> +	 * file systems by the permission checking which requires
> +	 * WRITE privilege but the mode is 000.
> +	 * we ignore setting size to 0 for the creation, since it's
> +	 * just 0 after created.
> +	 * */
> +	if (newfile && (iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
> +		iap->ia_valid &= ~ATTR_SIZE;

It seems that all newfile does is tell us whether the net thing that was
created is a regular file or not.  Does it even make sense to set size
on other objects?  If not, then why not just make this:

	if (iap->ia_size == 0)
		iap->ia_valid &= ~ATTR_SIZE;

and remove the need for "newfile"?

Also: I'm curious, can you tell where exactly in the code the permission
error is getting set?  From a quick look at nfsd_setattr() it appears
it's doing all permissions checks with NFSD_MAY_OWNER_OVERRIDE, which
should allow the setting of size, even in the case of mode 0, as long as
the caller is the owner of the new file.  Is HPUX also trying to set the
onwer?

--b.

>  	if (iap->ia_valid)
>  		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
>  	return 0;
> @@ -1191,6 +1201,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  	__be32		err;
>  	__be32		err2;
>  	int		host_err;
> +	int		newfile = 0;
>  
>  	err = nfserr_perm;
>  	if (!flen)
> @@ -1268,6 +1279,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  	switch (type) {
>  	case S_IFREG:
>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
> +		newfile = 1;
>  		break;
>  	case S_IFDIR:
>  		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
> @@ -1289,7 +1301,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  		write_inode_now(dchild->d_inode, 1);
>  	}
>  
> -	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
> +	err2 = nfsd_create_setattr(rqstp, resfhp, iap, newfile);
>  	if (err2)
>  		err = err2;
>  	mnt_drop_write(fhp->fh_export->ex_path.mnt);
> @@ -1324,6 +1336,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  	__be32		err2;
>  	int		host_err;
>  	__u32		v_mtime=0, v_atime=0;
> +	int		newfile = 0;
>  
>  	err = nfserr_perm;
>  	if (!flen)
> @@ -1415,6 +1428,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  	}
>  	if (created)
>  		*created = 1;
> +	newfile = 1;
>  
>  	if (EX_ISSYNC(fhp->fh_export)) {
>  		err = nfserrno(nfsd_sync_dir(dentry));
> @@ -1433,7 +1447,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  	}
>  
>   set_attr:
> -	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
> +	err2 = nfsd_create_setattr(rqstp, resfhp, iap, newfile);
>  	if (err2)
>  		err = err2;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
