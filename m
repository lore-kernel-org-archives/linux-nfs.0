Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52479 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab1LSVxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 16:53:00 -0500
Date: Mon, 19 Dec 2011 16:52:59 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        fedfs-utils-devel@oss.oracle.com, jlayton@redhat.com
Subject: Re: [PATCH] NFSD: Change name of extended attribute containing
 junction
Message-ID: <20111219215259.GA15613@fieldses.org>
References: <20111219193843.30843.56764.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111219193843.30843.56764.stgit@degas.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2011 at 02:38:43PM -0500, Chuck Lever wrote:
> As of fedfs-utils-0.8.0, user space stores all NFS junction
> information in a single extended attribute: "trusted.junction.nfs".

I suspect the break of backwards-compatibility is fine, but we should
add a note explaining it; would something like this be right?:

	This breaks compatibility with fedfs-utils versions before
	0.8.0.  As fedfs-utils has not been widely distributed, we don't
	believe this will affect anyone.

(Cc'ing jlayton: does this cause a problem for whatever just went into
Fedora?)

--b.

> 
> Both FedFS and NFS basic junctions are stored in this one attribute,
> and the intention is that all future forms of NFS junction metadata
> will be stored in this attribute.  Other protocols may use a different
> extended attribute.
> 
> Thus NFSD needs to look only for that one extended attribute.  The
> "trusted.junction.type" xattr is deprecated.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/vfs.c |   17 ++++++++++++++---
>  1 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index d1d4d5e..b494f86 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -594,8 +594,19 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
>  	return error;
>  }
>  
> -#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
> -#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
> +/*
> + * NFS junction information is stored in an extended attribute.
> + */
> +#define NFSD_JUNCTION_XATTR_NAME	XATTR_TRUSTED_PREFIX "junction.nfs"
> +
> +/**
> + * nfsd4_is_junction - Test if an object could be an NFS junction
> + *
> + * @dentry: object to test
> + *
> + * Returns 1 if "dentry" appears to contain NFS junction information.
> + * Otherwise 0 is returned.
> + */
>  int nfsd4_is_junction(struct dentry *dentry)
>  {
>  	struct inode *inode = dentry->d_inode;
> @@ -606,7 +617,7 @@ int nfsd4_is_junction(struct dentry *dentry)
>  		return 0;
>  	if (!(inode->i_mode & S_ISVTX))
>  		return 0;
> -	if (vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0) <= 0)
> +	if (vfs_getxattr(dentry, NFSD_JUNCTION_XATTR_NAME, NULL, 0) <= 0)
>  		return 0;
>  	return 1;
>  }
> 
