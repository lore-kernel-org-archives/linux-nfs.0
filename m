Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51032 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756101Ab3LFPgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Dec 2013 10:36:19 -0500
Date: Fri, 6 Dec 2013 10:36:17 -0500
To: Rui Xiang <rui.xiang@huawei.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs/nfsd: return err directly while malloc failing
Message-ID: <20131206153617.GA9020@fieldses.org>
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 06, 2013 at 05:30:16PM +0800, Rui Xiang wrote:
> while nthreads malloc fails, return err value directory
> without kfree.
> 
> And the same issue arises in nfs_lookup, so return res
> directly without freeing fh and fattr.
> 
> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
> ---
>  fs/nfs/dir.c     | 4 ++--
>  fs/nfsd/nfsctl.c | 7 ++++---
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 812154a..2518865 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1278,7 +1278,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
>  
>  	res = ERR_PTR(-ENAMETOOLONG);
>  	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
> -		goto out;
> +		return res;
>  
>  	/*
>  	 * If we're doing an exclusive create, optimize away the lookup
> @@ -1287,7 +1287,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
>  	if (nfs_is_exclusive_create(dir, flags)) {
>  		d_instantiate(dentry, NULL);
>  		res = NULL;
> -		goto out;
> +		return res;
>  	}
>  
>  	res = ERR_PTR(-ENOMEM);
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..3c5e748 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -491,9 +491,10 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
>  	}
>  
>  	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
> -	rv = -ENOMEM;
> -	if (nthreads == NULL)
> -		goto out_free;
> +	if (nthreads == NULL) {
> +		mutex_unlock(&nfsd_mutex);
> +		return -ENOENT;
> +	}
>  
>  	if (size > 0) {
>  		for (i = 0; i < npools; i++) {
> -- 

Looks fine.  Could you send this last chunk to me as a separate patch?

--b.

> 1.8.2.2
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
