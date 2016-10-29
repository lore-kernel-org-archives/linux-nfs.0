Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:33173 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbcJ2PpR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2016 11:45:17 -0400
Received: by mail-qt0-f176.google.com with SMTP id p16so52549680qta.0
        for <linux-nfs@vger.kernel.org>; Sat, 29 Oct 2016 08:45:17 -0700 (PDT)
Message-ID: <1477755914.13215.6.camel@redhat.com>
Subject: Re: [PATCH] svcrdma: backchannel cannot share a page for send and
 rcv buffers
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Sat, 29 Oct 2016 11:45:14 -0400
In-Reply-To: <20161029021531.2673.6849.stgit@klimt.1015granger.net>
References: <20161029021531.2673.6849.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-28 at 22:22 -0400, Chuck Lever wrote:
> The underlying transport releases the page pointed to by rq_buffer
> during xprt_rdma_bc_send_request. When the backchannel reply arrives,
> rq_rbuffer then points to freed memory.
> 
> Fixes: 68778945e46f ('SUNRPC: Separate buffer pointers for RPC ...')
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> Hi Bruce-
> 
> This applies on top of Jeff's recent patch in the same area. It's
> an obvious quick fix rather than a deep review of that code path.
> 
> I've tested with iozone, git "make test", and some xfstests with
> NFSv4.1 / RDMA; I ran into another crasher that is preventing more
> extensive testing. The prepare_creds crash has not re-appeared so
> far.
> 
> I enabled RPC client debugging on the server during these tests to
> confirm that the CB_RECALL operations were successful.
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index fc4535e..20027f8 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -177,19 +177,26 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  		return -EINVAL;
>  	}
>  
> +	/* svc_rdma_sendto releases this page */
>  	page = alloc_page(RPCRDMA_DEF_GFP);
>  	if (!page)
>  		return -ENOMEM;
> -
>  	rqst->rq_buffer = page_address(page);
> -	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
> +
> +	rqst->rq_rbuffer = kmalloc(rqst->rq_rcvsize, RPCRDMA_DEF_GFP);
> +	if (!rqst->rq_rbuffer) {
> +		put_page(page);
> +		return -ENOMEM;
> +	}
>  	return 0;
>  }
>  
>  static void
>  xprt_rdma_bc_free(struct rpc_task *task)
>  {
> -	/* No-op: ctxt and page have already been freed. */
> +	struct rpc_rqst *rqst = task->tk_rqstp;
> +
> +	kfree(rqst->rq_rbuffer);
>  }
>  
>  static int
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Obviously, mine was not based on any deep reading of this code either,
so I'll take your word for it on this:

Acked-by: Jeff Layton <jlayton@redhat.com>
