Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40122 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753856AbaHLTQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 15:16:43 -0400
Date: Tue, 12 Aug 2014 15:16:43 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/11] SUNRPC: Do not override wspace tests in
 svc_handle_xprt
Message-ID: <20140812191643.GB25914@fieldses.org>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 03, 2014 at 01:03:06PM -0400, Trond Myklebust wrote:
> We already determined that there was enough wspace when we
> called svc_xprt_enqueue.

So xpo_has_wspace may have returned true then, but I don't see what
guarantees it still would now.  Couldn't another server thread have also
run svc_recv() and the atomic_add(rqstp->rq_reserved,
&xprt->xpt_reserved) between the svc_xprt_enqueue call and now?

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/svc_xprt.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 32647b2a6a34..b731077b6a30 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -744,7 +744,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
>  			svc_add_new_temp_xprt(serv, newxpt);
>  		else
>  			module_put(xprt->xpt_class->xcl_owner);
> -	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
> +	} else {
>  		/* XPT_DATA|XPT_DEFERRED case: */
>  		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
>  			rqstp, rqstp->rq_pool->sp_id, xprt,
> -- 
> 1.9.3
> 
