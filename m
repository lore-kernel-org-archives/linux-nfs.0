From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2.6.30] svcrdma: clean up error paths.
Date: Sun, 3 May 2009 14:42:23 -0400
Message-ID: <20090503184223.GB20762@fieldses.org>
References: <20090429191400.29365.36715.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, linux-nfs@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52281 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055AbZECSmX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:42:23 -0400
In-Reply-To: <20090429191400.29365.36715.stgit-T4OLL4TyM9aNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2009 at 02:14:00PM -0500, Steve Wise wrote:
> These fixes resolved crashes due to resource leak BUG_ON checks. The
> resource leaks were detected by introducing asynchronous transport errors.

Thanks, applied for 2.6.30.  (And also appropriate for stable (2.6.29),
I assume?)

But, could someone take a closer look at the error paths here?  Questions:

	- svc_rdma_post_recv() does a svc_rdma_put_context() on error--
	  are you sure its caller needs to as well?
	- In send_reply, some of the cleanout is shared between the
	  first return -ENOTCONN and the final err: cleanup.  Could we
	  add another err: label and share some of that cleanup?

--b.

> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 ++-
>  2 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 6c26a67..8b510c5 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -183,6 +183,7 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
>  
>   fatal_err:
>  	printk("svcrdma: Error fast registering memory for xprt %p\n", xprt);
> +	vec->frmr = NULL;
>  	svc_rdma_put_frmr(xprt, frmr);
>  	return -EIO;
>  }
> @@ -516,6 +517,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  		       "svcrdma: could not post a receive buffer, err=%d."
>  		       "Closing transport %p.\n", ret, rdma);
>  		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
> +		svc_rdma_put_frmr(rdma, vec->frmr);
>  		svc_rdma_put_context(ctxt, 0);
>  		return -ENOTCONN;
>  	}
> @@ -606,6 +608,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  	return 0;
>  
>   err:
> +	svc_rdma_unmap_dma(ctxt);
>  	svc_rdma_put_frmr(rdma, vec->frmr);
>  	svc_rdma_put_context(ctxt, 1);
>  	return -EIO;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 3d810e7..4b0c2fa 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -520,8 +520,9 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
>  	svc_xprt_get(&xprt->sc_xprt);
>  	ret = ib_post_recv(xprt->sc_qp, &recv_wr, &bad_recv_wr);
>  	if (ret) {
> -		svc_xprt_put(&xprt->sc_xprt);
> +		svc_rdma_unmap_dma(ctxt);
>  		svc_rdma_put_context(ctxt, 1);
> +		svc_xprt_put(&xprt->sc_xprt);
>  	}
>  	return ret;
>  
> 
