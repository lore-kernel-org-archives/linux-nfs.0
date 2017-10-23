Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48768 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751635AbdJWUlf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Oct 2017 16:41:35 -0400
Date: Mon, 23 Oct 2017 16:41:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Preserve CB send buffer across retransmits
Message-ID: <20171023204134.GB21106@fieldses.org>
References: <20171016161133.29152.48259.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171016161133.29152.48259.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the ping, apologies for the delay.

On Mon, Oct 16, 2017 at 12:14:33PM -0400, Chuck Lever wrote:
> During each NFSv4 callback Call, an RDMA Send completion frees the
> page that contains the RPC Call message. If the upper layer
> determines that a retransmit is necessary, this is too soon.
> 
> One possible symptom: after a GARBAGE_ARGS response an NFSv4.1
> callback request, the following BUG fires on the NFS server:
...
> It would be great if this could go into v4.14-rc, but I can live
> with v4.15.

OK, I'll be slightly lazy and queue this up for 4.15....

> Jeff's review suggested adding a comment documenting the requirement
> that rqst->rq_buffer is backed by a single page. However, all of the
> server-side transport mechanics are page-based, so I'm not sure this
> wouldn't be a redundant comment. Suggestions welcome.

If it's always a page then I guess the way to make it ridiculously
obvious would be to keep a pointer to the page instead and use
page_address() as necessary, but.... I'm guessing that's inconvenient
for other users.

So, no suggestions.

--b.

> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index ec37ad8..1854db2 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -132,6 +132,10 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  	if (ret)
>  		goto out_err;
>  
> +	/* Bump page refcnt so Send completion doesn't release
> +	 * the rq_buffer before all retransmits are complete.
> +	 */
> +	get_page(virt_to_page(rqst->rq_buffer));
>  	ret = svc_rdma_post_send_wr(rdma, ctxt, 1, 0);
>  	if (ret)
>  		goto out_unmap;
> @@ -164,7 +168,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  		return -EINVAL;
>  	}
>  
> -	/* svc_rdma_sendto releases this page */
>  	page = alloc_page(RPCRDMA_DEF_GFP);
>  	if (!page)
>  		return -ENOMEM;
> @@ -183,6 +186,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  {
>  	struct rpc_rqst *rqst = task->tk_rqstp;
>  
> +	put_page(virt_to_page(rqst->rq_buffer));
>  	kfree(rqst->rq_rbuffer);
>  }
>  
