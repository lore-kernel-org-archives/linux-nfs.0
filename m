Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbaGCOiT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2014 10:38:19 -0400
Date: Thu, 3 Jul 2014 10:38:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfsd: properly convert return from commit_metadata to
 __be32
Message-ID: <20140703143818.GA24322@fieldses.org>
References: <1404388459-32288-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404388459-32288-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 03, 2014 at 07:54:19AM -0400, Jeff Layton wrote:
> Commit 2a7420c03e504 (nfsd: Ensure that nfsd_create_setattr commits
> files to stable storage), added a couple of calls to commit_metadata,
> but doesn't convert their return codes to __be32 in the appropriate
> places.

Thanks, applying.--b.

> 
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/vfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index e1b792ada45b..f501a9b5c9df 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -463,7 +463,7 @@ out_put_write_access:
>  	if (size_change)
>  		put_write_access(inode);
>  	if (!err)
> -		err = commit_metadata(fhp);
> +		err = nfserrno(commit_metadata(fhp));
>  out:
>  	return err;
>  }
> @@ -1122,7 +1122,7 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>  	if (iap->ia_valid)
>  		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
>  	/* Callers expect file metadata to be committed here */
> -	return commit_metadata(resfhp);
> +	return nfserrno(commit_metadata(resfhp));
>  }
>  
>  /* HPUX client sometimes creates a file in mode 000, and sets size to 0.
> -- 
> 1.9.3
> 
