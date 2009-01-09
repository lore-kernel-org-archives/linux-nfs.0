From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
	client
Date: Fri, 9 Jan 2009 16:57:57 -0500
Message-ID: <20090109215757.GF5466@fieldses.org>
References: <200812240537.mBO5blpr005502@acsinet13.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52515 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757815AbZAIV56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 16:57:58 -0500
In-Reply-To: <200812240537.mBO5blpr005502-eiegoW5zEh26xOVM2wN62FaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 24, 2008 at 01:36:16PM +0800, wengang wang wrote:
> sometimes HPUX nfs client sends a create request to linux nfs server(v2/v3).
> the dump of the request is like:
>     obj_attributes
>         mode: value follows
>             set_it: value follows (1)
>             mode: 00
>         uid: no value
>             set_it: no value (0)
>         gid: value follows
>             set_it: value follows (1)
>             gid: 8030
>         size: value follows
>             set_it: value follows (1)
>             size: 0
>         atime: don't change
>             set_it: don't change (0)
>         mtime: don't change
>             set_it: don't change (0)
> 
> note that mode is 00(havs no rwx privilege even for the owner) and it requires
> to set size to 0.
> 
> as current nfsd(v2/v3) implementation, the server does mainly 2 steps:
> 1) creates the file in mode specified by calling vfs_create().
> 2) sets attributes for the file by calling nfsd_setattr().
> 
> at step 2), it finally calls file system specific setattr() function which may
> fails when checking permission because changing size needs WRITE privilege but
> it has no since mode is 000.

Thanks for the report.

> for this case, a new file created, we may simply ignore the request of setting
> size to 0. so that the WRITE privilege is not needed and finally success.
> 
> the patch is based on 2.6.27.10.

It is a bit of a weird special case, but I can't see why not to do it.

Could you find some way to avoid adding those sane 10 lines twice?  How
about just doing this inside nfsd_create_setattr(), which is called from
both functions?

--b.

> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> --
>  vfs.c |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> diff -up ./fs/nfsd/vfs.c.orig ./fs/nfsd/vfs.c
> --- ./fs/nfsd/vfs.c.orig	2008-12-23 14:11:14.000000000 +0800
> +++ ./fs/nfsd/vfs.c	2008-12-23 14:54:16.000000000 +0800
> @@ -1268,6 +1268,16 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  	switch (type) {
>  	case S_IFREG:
>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
> +		/* HPUX client sometimes creates a file in mode 000, and set
> +		 * size to 0. setting size to 0 may fail for some spcific 
> +		 * file systems by the permission checking which requires
> +		 * WRITE privilege but the mode is 000.
> +		 * we ignore setting size to 0 for the creation, since it's
> +		 * just 0 after created.
> +		 * */
> +		if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
> +			iap->ia_valid &= ~ATTR_SIZE;
> +
>  		break;
>  	case S_IFDIR:
>  		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
> @@ -1421,6 +1431,16 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  		/* setattr will sync the child (or not) */
>  	}
>  
> +	/* HPUX client sometimes creates a file in mode 000, and set size to 0.
> +	 * setting size to 0 may fail for some spcific file systems by the
> +	 * permission checking which requires WRITE privilege but the mode is
> +	 * 000.
> +	 * we ignore setting size to 0 for the creation, since it's just 0
> +	 * after created.
> +	 * */
> +	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
> +		iap->ia_valid &= ~ATTR_SIZE;
> +
>  	if (createmode == NFS3_CREATE_EXCLUSIVE) {
>  		/* Cram the verifier into atime/mtime */
>  		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
