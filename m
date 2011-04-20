Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50460 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab1DTPXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 11:23:25 -0400
Date: Wed, 20 Apr 2011 11:23:24 -0400
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Open with O_CREAT flag set fails to open existing files on non
 writable directories
Message-ID: <20110420152324.GB15919@fieldses.org>
References: <1303301376.21523.7.camel@dhcp-1-119.fab.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1303301376.21523.7.camel@dhcp-1-119.fab.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 20, 2011 at 01:09:35PM +0100, Sachin Prabhu wrote:
> An open on a NFS4 share using the O_CREAT flag on an existing file for
> which we have permissions to open but contained in a directory with no
> write permissions will fail with EACCES.
> 
> A tcpdump shows that the client had set the open mode to UNCHECKED which
> indicates that the file should be created if it doesn't exist and
> encountering an existing flag is not an error. Since in this case the
> file exists and can be opened by the user, the NFS server is wrong in
> attempting to check create permissions on the parent directory.
> 
> The patch adds a conditional statement to check for create permissions
> only if the file doesn't exist.

That looks correct to me, thanks.

It's a bad bug, but appears to be one we've lived with a long time, so
I'm a bit up in the air whether to submit now for 2.6.39 or to queue up
for 2.6.40.

--b.

> 
> Signed-off-by: Sachin S. Prabhu <sprabhu@redhat.com>
> 
> diff -up linux-2.6/fs/nfsd/vfs.c.bz683372 linux-2.6/fs/nfsd/vfs.c
> --- linux-2.6/fs/nfsd/vfs.c.bz683372	2011-04-20 13:03:54.021040329 +0100
> +++ linux-2.6/fs/nfsd/vfs.c	2011-04-20 13:05:21.551858218 +0100
> @@ -1363,7 +1363,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  		goto out;
>  	if (!(iap->ia_valid & ATTR_MODE))
>  		iap->ia_mode = 0;
> -	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
>  	if (err)
>  		goto out;
>  
> @@ -1385,6 +1385,13 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
>  	if (IS_ERR(dchild))
>  		goto out_nfserr;
>  
> +	/* If file doesn't exist, check for permissions to create one */
> +	if (!dchild->d_inode) {
> +		err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> +		if (err)
> +			goto out;
> +	}
> +
>  	err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
>  	if (err)
>  		goto out;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
