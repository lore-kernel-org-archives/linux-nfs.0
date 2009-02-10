From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
	client --3rd
Date: Tue, 10 Feb 2009 11:06:20 -0500
Message-ID: <20090210160620.GE29075@fieldses.org>
References: <200902100328.n1A3SrFg006410@acsinet13.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41255 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbZBJQGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2009 11:06:13 -0500
In-Reply-To: <200902100328.n1A3SrFg006410-eiegoW5zEh26xOVM2wN62FaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good, thanks for your persistance--applied to

	git://linux-nfs.org/~bfields/linux.git for-2.6.30

--b.

On Tue, Feb 10, 2009 at 11:27:51AM +0800, wengang wang wrote:
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
> 
> for this case, a new file created, we may simply ignore the request of setting
> size to 0. so that the WRITE privilege is not needed and finally success.
> 
> the patch is based on 2.6.27.10.
> this is the 3rd edition of the patch. comparing with the 1st edition, it moves
> common code and comment to function nfsd_check_ignore_resizing().
> nfsd_create() and nfsd_create_v3() calls this function instead of embedding the
> code and comment directly.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> --
>  vfs.c |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> diff -up ./fs/nfsd/vfs.c.orig ./fs/nfsd/vfs.c
> --- ./fs/nfsd/vfs.c.orig	2009-02-10 09:59:07.000000000 +0800
> +++ ./fs/nfsd/vfs.c	2009-02-10 10:07:31.000000000 +0800
> @@ -1173,6 +1173,21 @@ nfsd_create_setattr(struct svc_rqst *rqs
>  	return 0;
>  }
>  
> +/* HPUX client sometimes creates a file in mode 000, and sets size to 0.
> + * setting size to 0 may fail for some specific file systems by the permission
> + * checking which requires WRITE permission but the mode is 000.
> + * we ignore the resizing(to 0) on the just new created file, since the size is
> + * 0 after file created.
> + *
> + * call this only after vfs_create() is called.
> + * */
> +static void
> +nfsd_check_ignore_resizing(struct iattr *iap)
> +{
> +	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
> +		iap->ia_valid &= ~ATTR_SIZE;
> +}
> +
>  /*
>   * Create a file (regular, directory, device, fifo); UNIX sockets 
>   * not yet implemented.
> @@ -1268,6 +1283,8 @@ nfsd_create(struct svc_rqst *rqstp, stru
>  	switch (type) {
>  	case S_IFREG:
>  		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);
> +		if (!host_err)
> +			nfsd_check_ignore_resizing(iap);
>  		break;
>  	case S_IFDIR:
>  		host_err = vfs_mkdir(dirp, dchild, iap->ia_mode);
> @@ -1421,6 +1438,8 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  		/* setattr will sync the child (or not) */
>  	}
>  
> +	nfsd_check_ignore_resizing(iap);
> +
>  	if (createmode == NFS3_CREATE_EXCLUSIVE) {
>  		/* Cram the verifier into atime/mtime */
>  		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
