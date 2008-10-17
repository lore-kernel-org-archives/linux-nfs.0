From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] SUNRPC add deferral processing callbacks
Date: Fri, 17 Oct 2008 13:48:03 -0400
Message-ID: <20081017174803.GC11884@fieldses.org>
References: <1224104426-12293-1-git-send-email-andros@netapp.com> <1224104426-12293-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros-HgOvQuBEEgQAvxtiuMwx3w@public.gmane.org>
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41383 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625AbYJQRsF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 13:48:05 -0400
In-Reply-To: <1224104426-12293-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 15, 2008 at 05:00:24PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> For EOS, NFSD compound RPC deferred processing should restart operation which
> caused the deferral.
> 
> Add a callback and a defer_data pointer in svc_rqst to enable svc_defer to
> save partial result state in the deferral request.
> 
> Add page pointer storage to svc_deferred_req to cache the pages holding the
> partially processed request.
> 
> Add callbacks and a defer_data pointer in svc_deferred_request to enable
> svc_deferred_recv to restore and release the partial result state.
> 
> Signed-off-by: Andy Adamson<andros-HgOvQuBEEgQAvxtiuMwx3w@public.gmane.org>

Could you fix the missing space there?

> ---
>  include/linux/sunrpc/svc.h |   10 ++++++++++
>  net/sunrpc/svc_xprt.c      |   20 +++++++++++++++-----
>  2 files changed, 25 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index dc69068..46a4097 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -215,6 +215,9 @@ struct svc_rqst {
>  	struct svc_cred		rq_cred;	/* auth info */
>  	void *			rq_xprt_ctxt;	/* transport specific context ptr */
>  	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
> +	/* callback to save deferred request state */
> +	void (*rq_save_state)(struct svc_rqst *, struct svc_deferred_req *);
> +	void			*rq_defer_data; /* defer state data to save */
>  
>  	size_t			rq_xprt_hlen;	/* xprt header len */
>  	struct xdr_buf		rq_arg;
> @@ -323,6 +326,13 @@ struct svc_deferred_req {
>  	union svc_addr_u	daddr;	/* where reply must come from */
>  	struct cache_deferred_req handle;
>  	size_t			xprt_hlen;
> +	/* callbacks to restore and release deferred request state
> +	 * set in rq_save_state */
> +	void (*restore_state)(struct svc_rqst *, struct svc_deferred_req *);
> +	void (*release_state)(struct svc_deferred_req *);
> +	void			*defer_data; /* defer state data */
> +	struct page		*respages[RPCSVC_MAXPAGES];
> +	short			resused;
>  	int			argslen;
>  	__be32			args[0];
>  };
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index e46c825..531b325 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -876,6 +876,8 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
>  	struct svc_xprt *xprt = dr->xprt;
>  
>  	if (too_many) {
> +		if (dr->release_state)
> +			dr->release_state(dr);
>  		svc_xprt_put(xprt);
>  		kfree(dr);
>  		return;
> @@ -902,10 +904,10 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
>  static struct cache_deferred_req *svc_defer(struct cache_req *req)
>  {
>  	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
> -	struct svc_deferred_req *dr;
> +	struct svc_deferred_req *dr = NULL;
>  
>  	if (rqstp->rq_arg.page_len)
> -		return NULL; /* if more than a page, give up FIXME */
> +		goto out; /* if more than a page, give up FIXME */
>  	if (rqstp->rq_deferred) {
>  		dr = rqstp->rq_deferred;
>  		rqstp->rq_deferred = NULL;
> @@ -914,9 +916,9 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
>  		size_t size;
>  		/* FIXME maybe discard if size too large */
>  		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
> -		dr = kmalloc(size, GFP_KERNEL);
> +		dr = kzalloc(size, GFP_KERNEL);
>  		if (dr == NULL)
> -			return NULL;
> +			goto out;
>  
>  		dr->handle.owner = rqstp->rq_server;
>  		dr->prot = rqstp->rq_prot;
> @@ -935,7 +937,13 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
>  	dr->xprt = rqstp->rq_xprt;
>  
>  	dr->handle.revisit = svc_revisit;
> -	return &dr->handle;
> +	if (rqstp->rq_save_state)
> +		rqstp->rq_save_state(rqstp, dr);
> +out:
> +	rqstp->rq_defer_data = NULL;
> +	rqstp->rq_save_state = NULL;
> +
> +	return dr ? &dr->handle: NULL;

I may not be thinking this through clearly, but: I think the correct
place to initialize rq_defer_data and rq_save_state is not here but at
the very start of request processing (in svc_recv or at the top of
svc_process).  We shouldn't depend on svc_defer()--it may never get
called.

--b.

>  }
>  
>  /*
> @@ -959,6 +967,8 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
>  	rqstp->rq_xprt_hlen   = dr->xprt_hlen;
>  	rqstp->rq_daddr       = dr->daddr;
>  	rqstp->rq_respages    = rqstp->rq_pages;
> +	if (dr->restore_state)
> +		dr->restore_state(rqstp, dr);
>  	return (dr->argslen<<2) - dr->xprt_hlen;
>  }
>  
> -- 
> 1.5.4.3
> 
