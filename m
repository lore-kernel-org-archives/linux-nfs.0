From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  1/17] svcrdma: Simplify receive buffer posting
Date: Mon, 5 May 2008 15:31:40 -0400
Message-ID: <20080505193140.GC12814@fieldses.org>
References: <1209745721600-git-send-email-tom@opengridcomputing.com> <12097457211326-git-send-email-tom@opengridcomputing.com> <1209745721248-git-send-email-tom@opengridcomputing.com> <12097457213375-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbYEETbl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 15:31:41 -0400
In-Reply-To: <12097457213375-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:28:27AM -0500, Tom Tucker wrote:
> The svcrdma transport provider currently allocates receive buffers
> to the RQ through the xpo_release_rqst method. This approach is overly
> complicated since it means that the rqstp rq_xprt_ctxt has to be
> selectively set based on whether the RPC is going to be processed
> immediately or deferred. Instead, just post the receive buffer when
> we are certain that we are replying in the send_reply function.

Makes sense to me.  But, by the way:

> index af408fc..1e0af2f 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -910,27 +910,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  	return NULL;
>  }
>  
> -/*
> - * Post an RQ WQE to the RQ when the rqst is being released. This
> - * effectively returns an RQ credit to the client. The rq_xprt_ctxt
> - * will be null if the request is deferred due to an RDMA_READ or the
> - * transport had no data ready (EAGAIN). Note that an RPC deferred in
> - * svc_process will still return the credit, this is because the data
> - * is copied and no longer consume a WQE/WC.
> - */
>  static void svc_rdma_release_rqst(struct svc_rqst *rqstp)
>  {
> -	int err;
> -	struct svcxprt_rdma *rdma =
> -		container_of(rqstp->rq_xprt, struct svcxprt_rdma, sc_xprt);
> -	if (rqstp->rq_xprt_ctxt) {
> -		BUG_ON(rqstp->rq_xprt_ctxt != rdma);
> -		err = svc_rdma_post_recv(rdma);
> -		if (err)
> -			dprintk("svcrdma: failed to post an RQ WQE error=%d\n",
> -				err);
> -	}
> -	rqstp->rq_xprt_ctxt = NULL;
>  }

Why is it that the svcsock equivalent (svc_release_skb) frees
rqstp->rq_deferred, but this doesn't?  Don't we need to free that in the
rdma case too?

--b.
