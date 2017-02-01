Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47206 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752845AbdBAS36 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 13:29:58 -0500
Date: Wed, 1 Feb 2017 10:29:57 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 4/7] svcrdma: Clean up backchannel send header encoding
Message-ID: <20170201182957.GC32532@infradead.org>
References: <20170131184623.14185.35480.stgit@klimt.1015granger.net>
 <20170131185318.14185.90053.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170131185318.14185.90053.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 31, 2017 at 01:53:18PM -0500, Chuck Lever wrote:
> Replace C structure-based XDR decoding with pointer arithmetic.
> Pointer arithmetic is considered more portable.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 288e35c..abfce04 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -200,19 +200,20 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  {
>  	struct rpc_xprt *xprt = rqst->rq_xprt;
>  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
> -	struct rpcrdma_msg *headerp = (struct rpcrdma_msg *)rqst->rq_buffer;
> +	__be32 *p;
>  	int rc;
>  
>  	/* Space in the send buffer for an RPC/RDMA header is reserved
>  	 * via xprt->tsh_size.
>  	 */
> +	p = (__be32 *)rqst->rq_buffer;

Why not move the assignment onto the same line as the declaration
of p?  Also rq_buffer is a void pointer, so the case shouldn't be
needed.

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
