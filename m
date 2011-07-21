Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59005 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab1GUVlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 17:41:07 -0400
Date: Thu, 21 Jul 2011 17:41:06 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>, tom@ogc.us,
        tmtalpey@gmail.com
Subject: Re: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
Message-ID: <20110721214106.GB3341@fieldses.org>
References: <1311270542-2021-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311270542-2021-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 21, 2011 at 01:49:02PM -0400, Steve Dickson wrote:
> Our performance team has noticed that increasing
> RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
> increases throughput when using the RDMA transport.

The main risk that I can see being that we have on the stack in two
places:

	rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg, ...
	{
		...
		u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];

	rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg, ...
	{
		...
		struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS]; 

Where ip_phys_buf is 16 bytes.

So that's 512 bytes in the first case, 1024 in the second.  This is
called from rpciod--what are our rules about allocating memory from
rpciod?

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index cae761a..5d1cfe5 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -109,7 +109,7 @@ struct rpcrdma_ep {
>   */
>  
>  /* temporary static scatter/gather max */
> -#define RPCRDMA_MAX_DATA_SEGS	(8)	/* max scatter/gather */
> +#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
>  #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>  #define MAX_RPCRDMAHDR	(\
>  	/* max supported RPC/RDMA header */ \
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
