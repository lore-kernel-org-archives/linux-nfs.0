From: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v4] nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Fri, 29 Jan 2010 18:53:54 -0500
Message-ID: <20100129235354.GA30852@fieldses.org>
References: <1264796353.3644.4.camel@localhost> <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost> <1264799906.3644.21.camel@localhost> <20100129212706.GA28361@infradead.org> <1264801465.3644.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab0A2Xxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jan 2010 18:53:54 -0500
In-Reply-To: <1264801465.3644.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 29, 2010 at 04:44:25PM -0500, Trond Myklebust wrote:
> nfsd: Use vfs_fsync_range() in nfsd_commit
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The NFS COMMIT operation allows the client to specify the exact byte range
> that it wishes to sync to disk in order to optimise server performance.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Applied, thanks!

--b.

> ---
> 
>  fs/nfsd/vfs.c |   30 ++++++++++++++++++++----------
>  1 files changed, 20 insertions(+), 10 deletions(-)
> 
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 79d216f..ed024d3 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1141,8 +1141,9 @@ out:
>  #ifdef CONFIG_NFSD_V3
>  /*
>   * Commit all pending writes to stable storage.
> - * Strictly speaking, we could sync just the indicated file region here,
> - * but there's currently no way we can ask the VFS to do so.
> + *
> + * Note: we only guarantee that data that lies within the range specified
> + * by the 'offset' and 'count' parameters will be synced.
>   *
>   * Unfortunately we cannot lock the file to make sure we return full WCC
>   * data to the client, as locking happens lower down in the filesystem.
> @@ -1152,23 +1153,32 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
>                 loff_t offset, unsigned long count)
>  {
>  	struct file	*file;
> -	__be32		err;
> +	loff_t		end = LLONG_MAX;
> +	__be32		err = nfserr_inval;
>  
> -	if ((u64)count > ~(u64)offset)
> -		return nfserr_inval;
> +	if (offset < 0)
> +		goto out;
> +	if (count != 0) {
> +		end = offset + (loff_t)count - 1;
> +		if (end < offset)
> +			goto out;
> +	}
>  
>  	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
>  	if (err)
> -		return err;
> +		goto out;
>  	if (EX_ISSYNC(fhp->fh_export)) {
> -		if (file->f_op && file->f_op->fsync) {
> -			err = nfserrno(vfs_fsync(file, file->f_path.dentry, 0));
> -		} else {
> +		int err2 = vfs_fsync_range(file, file->f_path.dentry,
> +				offset, end, 0);
> +
> +		if (err2 != -EINVAL)
> +			err = nfserrno(err2);
> +		else
>  			err = nfserr_notsupp;
> -		}
>  	}
>  
>  	nfsd_close(file);
> +out:
>  	return err;
>  }
>  #endif /* CONFIG_NFSD_V3 */
> 
