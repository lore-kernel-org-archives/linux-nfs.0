From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: Fill in WCC data for REMOVE, RMDIR, MKNOD, and
 MKDIR
Date: Wed, 7 Jul 2010 17:10:37 -0400
Message-ID: <20100707211037.GF2957@fieldses.org>
References: <20100706204750.2918.92546.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55011 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab0GGVKm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 17:10:42 -0400
In-Reply-To: <20100706204750.2918.92546.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 06, 2010 at 04:53:34PM -0400, Chuck Lever wrote:
> Some well-known NFSv3 clients drop their directory entry caches when
> they receive replies with no WCC data.

Can we include any more details?  (And/or a simple test case that
demonstrates the difference?)

> Without this data, they
> employ extra READ, LOOKUP, and GETATTR requests to ensure their
> directory entry caches are up to date, causing performance to suffer
> needlessly.
> 
> In order to return WCC data, our server has to have both the pre-op
> and the post-op attribute data on hand when a reply is XDR encoded.
> The pre-op data is filled in when the incoming fh is locked, and the
> post-op data is filled in when the fh is unlocked.
> 
> Unfortunately, for REMOVE, RMDIR, MKNOD, and MKDIR, the directory fh
> is not unlocked until well after the reply has been XDR encoded.

So it wasn't happening until an fh_put() was done in .pc_release()?

> This
> means that encode_wcc_data() does not have wcc_data for the parent
> directory, so none is returned to the client after these operations
> complete.
> 
> By unlocking the parent directory fh immediately after the internal
> operations for each NFS procedure is complete, the post-op data is
> filled in before XDR encoding starts, so it can be returned to the
> client properly.

Looks good to me, thanks, applying for 2.6.36.

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Bruce-
> 
> This patch seems to go a long way towards fixing the pre-wcc data
> problem and related performance issues.  Perhaps this patch is also
> appropriate for stable releases, though I haven't tested it with any.

If it's a longstanding problem, I'm inclined to leave it be on the
grounds that people sticking with a stable release are resigned to the
performance they've always had....

--b.

> 
> 
>  fs/nfsd/nfs3proc.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 3d68f45..9ae9331 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -271,7 +271,7 @@ nfsd3_proc_mkdir(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
>  	fh_init(&resp->fh, NFS3_FHSIZE);
>  	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
>  				    &argp->attrs, S_IFDIR, 0, &resp->fh);
> -
> +	fh_unlock(&resp->dirfh);
>  	RETURN_STATUS(nfserr);
>  }
>  
> @@ -327,7 +327,7 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp, struct nfsd3_mknodargs *argp,
>  	type = nfs3_ftypes[argp->ftype];
>  	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
>  				    &argp->attrs, type, rdev, &resp->fh);
> -
> +	fh_unlock(&resp->dirfh);
>  	RETURN_STATUS(nfserr);
>  }
>  
> @@ -348,6 +348,7 @@ nfsd3_proc_remove(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
>  	/* Unlink. -S_IFDIR means file must not be a directory */
>  	fh_copy(&resp->fh, &argp->fh);
>  	nfserr = nfsd_unlink(rqstp, &resp->fh, -S_IFDIR, argp->name, argp->len);
> +	fh_unlock(&resp->fh);
>  	RETURN_STATUS(nfserr);
>  }
>  
> @@ -367,6 +368,7 @@ nfsd3_proc_rmdir(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
>  
>  	fh_copy(&resp->fh, &argp->fh);
>  	nfserr = nfsd_unlink(rqstp, &resp->fh, S_IFDIR, argp->name, argp->len);
> +	fh_unlock(&resp->fh);
>  	RETURN_STATUS(nfserr);
>  }
>  
> 
