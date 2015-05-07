Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37968 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbbEGKQF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:16:05 -0400
Received: by wiun10 with SMTP id n10so53816689wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:16:04 -0700 (PDT)
Message-ID: <554B3B6E.5030306@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:16:14 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 05/14] xprtrdma: Introduce helpers for allocating MWs
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175730.3483.51996.stgit@manet.1015granger.net>
In-Reply-To: <20150504175730.3483.51996.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:57 PM, Chuck Lever wrote:
> We eventually want to handle allocating MWs one at a time, as
> needed, instead of grabbing 64 and throwing them at each RPC in the
> pipeline.
>
> Add a helper for grabbing an MW off rb_mws, and a helper for
> returning an MW to rb_mws. These will be used in a subsequent patch.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/verbs.c     |   31 +++++++++++++++++++++++++++++++
>   net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
>   2 files changed, 33 insertions(+)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index ebcb0e2..c21329e 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1179,6 +1179,37 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
>   	kfree(buf->rb_pool);
>   }
>
> +struct rpcrdma_mw *
> +rpcrdma_get_mw(struct rpcrdma_xprt *r_xprt)
> +{
> +	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
> +	struct rpcrdma_mw *mw = NULL;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&buf->rb_lock, flags);
> +	if (!list_empty(&buf->rb_mws)) {
> +		mw = list_first_entry(&buf->rb_mws,
> +				      struct rpcrdma_mw, mw_list);
> +		list_del_init(&mw->mw_list);
> +	}
> +	spin_unlock_irqrestore(&buf->rb_lock, flags);
> +
> +	if (!mw)
> +		pr_err("RPC:       %s: no MWs available\n", __func__);
> +	return mw;
> +}
> +
> +void
> +rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
> +{
> +	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&buf->rb_lock, flags);
> +	list_add_tail(&mw->mw_list, &buf->rb_mws);
> +	spin_unlock_irqrestore(&buf->rb_lock, flags);
> +}
> +
>   /* "*mw" can be NULL when rpcrdma_buffer_get_mrs() fails, leaving
>    * some req segments uninitialized.
>    */
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 531ad33..7de424e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -415,6 +415,8 @@ int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_ep *,
>   int rpcrdma_buffer_create(struct rpcrdma_xprt *);
>   void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
>
> +struct rpcrdma_mw *rpcrdma_get_mw(struct rpcrdma_xprt *);
> +void rpcrdma_put_mw(struct rpcrdma_xprt *, struct rpcrdma_mw *);
>   struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);
>   void rpcrdma_buffer_put(struct rpcrdma_req *);
>   void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
>

Looks good,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
