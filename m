Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbaGBVea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2014 17:34:30 -0400
Date: Wed, 2 Jul 2014 17:34:28 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Ensure that nfsd_create_setattr commits files to
 stable storage
Message-ID: <20140702213428.GE11510@fieldses.org>
References: <1404253673-12676-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404253673-12676-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 01, 2014 at 06:27:53PM -0400, Trond Myklebust wrote:
> Since nfsd_create_setattr strips the mode from the struct iattr, it
> is quite possible that it will optimise away the call to nfsd_setattr
> altogether.
> If this is the case, then we never call commit_metadata() on the
> newly created file.

Thanks.  Looks like a relatively rare problem that we've lived with for
a while, so I'm inclined to just wait for 3.17, but it could also go to
3.16 and stable if you saw it as more urgent....

--b.

> 
> Also ensure that both nfsd_setattr() and nfsd_create_setattr() fail
> when the call to commit_metadata fails.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/vfs.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 140c496f612c..5fd9095268cb 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -464,7 +464,7 @@ out_put_write_access:
>  	if (size_change)
>  		put_write_access(inode);
>  	if (!err)
> -		commit_metadata(fhp);
> +		err = commit_metadata(fhp);
>  out:
>  	return err;
>  }
> @@ -1121,7 +1121,8 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>  		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
>  	if (iap->ia_valid)
>  		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
> -	return 0;
> +	/* Callers expect file metadata to be committed here */
> +	return commit_metadata(resfhp);
>  }
>  
>  /* HPUX client sometimes creates a file in mode 000, and sets size to 0.
> @@ -1253,9 +1254,10 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	err = nfsd_create_setattr(rqstp, resfhp, iap);
>  
>  	/*
> -	 * nfsd_setattr already committed the child.  Transactional filesystems
> -	 * had a chance to commit changes for both parent and child
> -	 * simultaneously making the following commit_metadata a noop.
> +	 * nfsd_create_setattr already committed the child.  Transactional
> +	 * filesystems had a chance to commit changes for both parent and
> +	 * child * simultaneously making the following commit_metadata a
> +	 * noop.
>  	 */
>  	err2 = nfserrno(commit_metadata(fhp));
>  	if (err2)
> @@ -1426,7 +1428,8 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	err = nfsd_create_setattr(rqstp, resfhp, iap);
>  
>  	/*
> -	 * nfsd_setattr already committed the child (and possibly also the parent).
> +	 * nfsd_create_setattr already committed the child
> +	 * (and possibly also the parent).
>  	 */
>  	if (!err)
>  		err = nfserrno(commit_metadata(fhp));
> -- 
> 1.9.3
> 
