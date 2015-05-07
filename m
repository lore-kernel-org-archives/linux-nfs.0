Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36053 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025AbbEGKAk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:00:40 -0400
Received: by lbbqq2 with SMTP id qq2so27067919lbb.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:00:38 -0700 (PDT)
Message-ID: <554B37CF.2070206@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:00:47 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 04/14] xprtrdma: Use ib_device pointer safely
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175720.3483.80356.stgit@manet.1015granger.net>
In-Reply-To: <20150504175720.3483.80356.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:57 PM, Chuck Lever wrote:
> The connect worker can replace ri_id, but prevents ri_id->device
> from changing during the lifetime of a transport instance.
>
> Cache a copy of ri_id->device in rpcrdma_ia and in rpcrdma_rep.
> The cached copy can be used safely in code that does not serialize
> with the connect worker.
>
> Other code can use it to save an extra address generation (one
> pointer dereference instead of two).
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/fmr_ops.c      |    8 +----
>   net/sunrpc/xprtrdma/frwr_ops.c     |   12 +++----
>   net/sunrpc/xprtrdma/physical_ops.c |    8 +----
>   net/sunrpc/xprtrdma/verbs.c        |   61 +++++++++++++++++++-----------------
>   net/sunrpc/xprtrdma/xprt_rdma.h    |    2 +
>   5 files changed, 43 insertions(+), 48 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 302d4eb..0a96155 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -85,7 +85,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>   	   int nsegs, bool writing)
>   {
>   	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
> -	struct ib_device *device = ia->ri_id->device;
> +	struct ib_device *device = ia->ri_device;
>   	enum dma_data_direction direction = rpcrdma_data_dir(writing);
>   	struct rpcrdma_mr_seg *seg1 = seg;
>   	struct rpcrdma_mw *mw = seg1->rl_mw;
> @@ -137,17 +137,13 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>   {
>   	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>   	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_device *device;
>   	int rc, nsegs = seg->mr_nsegs;
>   	LIST_HEAD(l);
>
>   	list_add(&seg1->rl_mw->r.fmr->list, &l);
>   	rc = ib_unmap_fmr(&l);
> -	read_lock(&ia->ri_qplock);
> -	device = ia->ri_id->device;
>   	while (seg1->mr_nsegs--)
> -		rpcrdma_unmap_one(device, seg++);
> -	read_unlock(&ia->ri_qplock);
> +		rpcrdma_unmap_one(ia->ri_device, seg++);

Umm, I'm wandering if this is guaranteed to be the same device as
ri_id->device?

Imagine you are working on a bond device where each slave belongs to
a different adapter. When the active port toggles, you will see a
ADDR_CHANGED event (that the current code does not handle...), what
you'd want to do is just reconnect and rdma_cm will resolve the new
address for you (via the backup slave). I suspect that in case this
flow is concurrent with the reconnects you may end up with a stale
device handle.
