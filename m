Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53420 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965118AbeEIVDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 May 2018 17:03:10 -0400
Date: Wed, 9 May 2018 17:03:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 09/19] svcrdma: Preserve Receive buffer until
 svc_rdma_sendto
Message-ID: <20180509210309.GC31959@fieldses.org>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
 <20180507192737.4608.29315.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180507192737.4608.29315.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 07, 2018 at 03:27:37PM -0400, Chuck Lever wrote:
> Rather than releasing the incoming svc_rdma_recv_ctxt at the end of
> svc_rdma_recvfrom, hold onto it until svc_rdma_sendto.
> 
> This permits the contents of the Receive buffer to be preserved
> through svc_process and then referenced directly in sendto as it
> constructs Write and Reply chunks to return to the client.
> 
> The real changes will come in subsequent patches.
> 
> Note: I cannot use ->xpo_release_rqst for this purpose because that
> is called _before_ ->xpo_sendto. svc_rdma_sendto uses information in
> the received Call transport header to construct the Reply transport
> header, which is preserved in the RPC's Receive buffer.
> 
> The historical comment in svc_send() isn't helpful: it is already
> obvious that ->xpo_release_rqst is being called before ->xpo_sendto,
> but there is no explanation for this ordering going back to the
> beginning of the git era.

Yeah.  I'm fine with deleting that comment at least.  (Or maybe moving
the call if it makes sense, I haven't thought about it.)

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   14 +++++++++++---
>  2 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index ecfe7c9..d9fef52 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -789,7 +789,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>  		goto out_readchunk;
>  
>  complete:
> -	svc_rdma_recv_ctxt_put(rdma_xprt, ctxt);
> +	rqstp->rq_xprt_ctxt = ctxt;
>  	rqstp->rq_prot = IPPROTO_MAX;
>  	svc_xprt_copy_addrs(rqstp, xprt);
>  	return rqstp->rq_arg.len;
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index a397d9a..cbbde70 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -623,6 +623,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>  	struct svc_xprt *xprt = rqstp->rq_xprt;
>  	struct svcxprt_rdma *rdma =
>  		container_of(xprt, struct svcxprt_rdma, sc_xprt);
> +	struct svc_rdma_recv_ctxt *rctxt = rqstp->rq_xprt_ctxt;
>  	__be32 *p, *rdma_argp, *rdma_resp, *wr_lst, *rp_ch;
>  	struct xdr_buf *xdr = &rqstp->rq_res;
>  	struct page *res_page;
> @@ -675,7 +676,12 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>  				      wr_lst, rp_ch);
>  	if (ret < 0)
>  		goto err0;
> -	return 0;
> +	ret = 0;
> +
> +out:
> +	rqstp->rq_xprt_ctxt = NULL;
> +	svc_rdma_recv_ctxt_put(rdma, rctxt);
> +	return ret;
>  
>   err2:
>  	if (ret != -E2BIG && ret != -EINVAL)
> @@ -684,12 +690,14 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>  	ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
>  	if (ret < 0)
>  		goto err0;
> -	return 0;
> +	ret = 0;
> +	goto out;
>  
>   err1:
>  	put_page(res_page);
>   err0:
>  	trace_svcrdma_send_failed(rqstp, ret);
>  	set_bit(XPT_CLOSE, &xprt->xpt_flags);
> -	return -ENOTCONN;
> +	ret = -ENOTCONN;
> +	goto out;
>  }
