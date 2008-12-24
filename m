From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
 client
Date: Wed, 24 Dec 2008 12:44:49 +0530
Message-ID: <4951E169.40809@suse.de>
References: <200812240537.mBO5blpr005502@acsinet13.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:39711 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbYLXHPB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2008 02:15:01 -0500
In-Reply-To: <200812240537.mBO5blpr005502-eiegoW5zEh26xOVM2wN62FaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

wengang wang wrote:
> 
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


What's the Create Mode in this case? EXCLUSIVE or UNCHECKED?
What's the error the server is returning without this patch - ERR_NOTSUPP?

I tested this on 2.6.27.7 with a small program which does this:
        fd = open("file", O_CREAT, 0000);

The file creation succeeded with file size set to 0 and the subsequent
chmod too.

May be this could break EXCLUSIVE create mode semantics?


> the patch is based on 2.6.27.10.
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

-- 
Suresh Jayaraman
