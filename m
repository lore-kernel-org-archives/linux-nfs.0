Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56359 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933862Ab1KCTQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 15:16:24 -0400
Message-ID: <4EB2E87F.3060202@panasas.com>
Date: Thu, 3 Nov 2011 12:16:15 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] RDMA: RPCRDMA_MAX_DATA_SEGS cause i686 stack to blow.
References: <1320346359-1515-1-git-send-email-steved@redhat.com>
In-Reply-To: <1320346359-1515-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/03/2011 11:52 AM, Steve Dickson wrote:
> Commit 2773395b3 increased RPCRDMA_MAX_DATA_SEGS from 8
> to 64 which significantly increases throughput with the
> RDMA transport.
> 
> Unfortunately making RPCRDMA_MAX_DATA_SEGS that large blows
> the stack on i686 builds during compilation. So the
> RPCRDMA_MAX_PHYSREG_DATA_SEGS is used to allocated data on
> the stack.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c     |    6 +++---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 28236ba..68ba0fb 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1729,11 +1729,11 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf ipb[RPCRDMA_MAX_PHYSREG_DATA_SEGS];

Can't you just allocate this buffer on heap? Any size of a big array
on the stack is a bad idea. And it does help performance as reported
by original commit

Boaz
>  	int len, i, rc = 0;
>  
> -	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
> -		*nsegs = RPCRDMA_MAX_DATA_SEGS;
> +	if (*nsegs > RPCRDMA_MAX_PHYSREG_DATA_SEGS)
> +		*nsegs = RPCRDMA_MAX_PHYSREG_DATA_SEGS;
>  	for (len = 0, i = 0; i < *nsegs;) {
>  		rpcrdma_map_one(ia, seg, writing);
>  		ipb[i].addr = seg->mr_dma;
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 08c5d5a..8d588f2 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -110,6 +110,7 @@ struct rpcrdma_ep {
>  
>  /* temporary static scatter/gather max */
>  #define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
> +#define RPCRDMA_MAX_PHYSREG_DATA_SEGS	(16)
>  #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>  #define MAX_RPCRDMAHDR	(\
>  	/* max supported RPC/RDMA header */ \

