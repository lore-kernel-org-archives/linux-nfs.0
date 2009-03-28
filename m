From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/47] nfsd: don't use the deferral service, return
	NFS4ERR_DELAY
Date: Fri, 27 Mar 2009 20:04:46 -0400
Message-ID: <20090328000446.GI18222@fieldses.org>
References: <49CC40E5.2080506@panasas.com> <1238122897-6938-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54982 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbZC1AEs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 20:04:48 -0400
In-Reply-To: <1238122897-6938-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2009 at 06:01:37AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> On an NFSv4.1 server cache miss that causes an upcall, NFS4ERR_DELAY will be
> returned. It is up to the NFSv4.1 client to resend only the operations that
> have not been processed.
> 
> Initialize rq_usedeferral to 1 in svc_process(). rq_usedeferral was initialized
> to 0, which means that the first NFSv4.0 or NFSv4.1 rpc would be dropped due
> to the logic in svc_defer().

Nit: is this a comment about a change from a previous version of the
patch?  It doesn't make much sense to a reader who hasn't seen that
previous version.

> Will be turned off in nfsd4_proc_compound() only
> when NFSv4 Sessions are used.
> 
> Note: this isn't an adequate solution on its own. It's acceptable as a way
> to get some minimal 4.1 up and working, but we're going to have to find a
> way to avoid returning DELAY in all common cases before 4.1 can really be
> considered ready.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: reverse rq_nodeferral negative logic]
>     use positive rq_usedeferral logic instead.
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [sunrpc: initialize rq_usedeferral]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

I'd be inclined to just collapse that into the two signed-off-by's, and
drop the patch-history information.

--b.

> ---
>  fs/nfsd/nfs4proc.c         |    8 ++++++++
>  include/linux/sunrpc/svc.h |    1 +
>  net/sunrpc/svc.c           |    2 ++
>  net/sunrpc/svc_xprt.c      |    2 +-
>  4 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index f156b85..7839654 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -873,6 +873,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	resp->tag = args->tag;
>  	resp->opcnt = 0;
>  	resp->rqstp = rqstp;
> +	/* Use the deferral mechanism only for NFSv4.0 compounds */
> +	rqstp->rq_usedeferral = (args->minorversion == 0);
>  
>  	/*
>  	 * According to RFC3010, this takes precedence over all other errors.
> @@ -957,10 +959,16 @@ encode_op:
>  
>  		nfsd4_increment_op_stats(op->opnum);
>  	}
> +	if (!rqstp->rq_usedeferral && status == nfserr_dropit) {
> +		dprintk("%s Dropit - send NFS4ERR_DELAY\n", __func__);
> +		status = nfserr_jukebox;
> +	}
>  
>  	cstate_free(cstate);
>  out:
>  	nfsd4_release_compoundargs(args);
> +	/* Reset deferral mechanism for RPC deferrals */
> +	rqstp->rq_usedeferral = 1;
>  	dprintk("nfsv4 compound returned %d\n", ntohl(status));
>  	return status;
>  }
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 9f9f699..815dd58 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -230,6 +230,7 @@ struct svc_rqst {
>  	struct svc_cred		rq_cred;	/* auth info */
>  	void *			rq_xprt_ctxt;	/* transport specific context ptr */
>  	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
> +	int			rq_usedeferral;	/* use deferral */
>  
>  	size_t			rq_xprt_hlen;	/* xprt header len */
>  	struct xdr_buf		rq_arg;
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index c51fed4..6334858 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1023,6 +1023,8 @@ svc_process(struct svc_rqst *rqstp)
>  	rqstp->rq_res.tail[0].iov_len = 0;
>  	/* Will be turned off only in gss privacy case: */
>  	rqstp->rq_splice_ok = 1;
> +	/* Will be turned off only when NFSv4 Sessions are used */
> +	rqstp->rq_usedeferral = 1;
>  
>  	/* Setup reply header */
>  	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 1e66f24..600d091 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -974,7 +974,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
>  	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
>  	struct svc_deferred_req *dr;
>  
> -	if (rqstp->rq_arg.page_len)
> +	if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
>  		return NULL; /* if more than a page, give up FIXME */
>  	if (rqstp->rq_deferred) {
>  		dr = rqstp->rq_deferred;
> -- 
> 1.6.2.1
> 
