Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35784 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbcDZUVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:21:08 -0400
Subject: Re: [PATCH v2 15/18] xprtrdma: Refactor __fmr_dma_unmap()
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192251.3566.35007.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FCDAF.8090606@grimberg.me>
Date: Tue, 26 Apr 2016 23:21:03 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192251.3566.35007.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 009694b..9d50f3a 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -186,15 +186,10 @@ static void
>   __fmr_dma_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>   {
>   	struct ib_device *device = r_xprt->rx_ia.ri_device;
> -	struct rpcrdma_mw *mw = seg->rl_mw;
>   	int nsegs = seg->mr_nsegs;
>
> -	seg->rl_mw = NULL;
> -
>   	while (nsegs--)
>   		rpcrdma_unmap_one(device, seg++);

When will we get to see this in the form of dma_unmap_sg()? ;)

Looks fine anyways...

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
