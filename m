Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758398AbcHCUvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 16:51:31 -0400
Date: Wed, 3 Aug 2016 16:50:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: remove some dead code in nfsd_create_locked()
Message-ID: <20160803205042.GC5901@fieldses.org>
References: <20160803190500.GE775@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160803190500.GE775@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 03, 2016 at 10:05:00PM +0300, Dan Carpenter wrote:
> We changed this around in f13058a93484 ('nfsd: reorganize nfsd_create')
> so "dchild" can't be an error pointer any more.  Also we don't need to
> test if dchild is NULL because dput has a check built-in.

Thanks!

> Can it even be NULL?

It was returned from a caller's lookup_one_len, which can only return
pointers or errors, I believe.  (And looks like callers also do
fh_verify and would already oops if it was null.)

Anyway, added a brief comment to that effect, fixed up the referenced
commitid (I rewrote some history there, apologies) and committed, will
push out after a few tests....

--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index c844fd6..cd628ce 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1141,7 +1141,7 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		char *fname, int flen, struct iattr *iap,
>  		int type, dev_t rdev, struct svc_fh *resfhp)
>  {
> -	struct dentry	*dentry, *dchild = NULL;
> +	struct dentry	*dentry, *dchild;
>  	struct inode	*dirp;
>  	__be32		err;
>  	__be32		err2;
> @@ -1208,8 +1208,7 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (!err)
>  		err = fh_update(resfhp);
>  out:
> -	if (dchild && !IS_ERR(dchild))
> -		dput(dchild);
> +	dput(dchild);
>  	return err;
>  
>  out_nfserr:
