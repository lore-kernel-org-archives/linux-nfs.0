Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35046 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529AbbEGKha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:37:30 -0400
Received: by wgyo15 with SMTP id o15so39058786wgy.2
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:37:29 -0700 (PDT)
Message-ID: <554B4074.5010404@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:37:40 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 12/14] xprtrdma: Split rb_lock
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175837.3483.28838.stgit@manet.1015granger.net>
In-Reply-To: <20150504175837.3483.28838.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:58 PM, Chuck Lever wrote:
> /proc/lock_stat showed contention between rpcrdma_buffer_get/put
> and the MR allocation functions during I/O intensive workloads.
>
> Now that MRs are no longer allocated in rpcrdma_buffer_get(),
> there's no reason the rb_mws list has to be managed using the
> same lock as the send/receive buffers. Split that lock. The
> new lock does not need to disable interrupts because buffer
> get/put is never called in an interrupt context.
>
> struct rpcrdma_buffer is re-arranged to ensure rb_mwlock and
> rb_mws is always in a different cacheline than rb_lock and the
> buffer pointers.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/fmr_ops.c   |    1 +
>   net/sunrpc/xprtrdma/frwr_ops.c  |    1 +
>   net/sunrpc/xprtrdma/verbs.c     |   10 ++++------
>   net/sunrpc/xprtrdma/xprt_rdma.h |   16 +++++++++-------
>   4 files changed, 15 insertions(+), 13 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 5dd77da..52f9ad5 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -65,6 +65,7 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
>   	struct rpcrdma_mw *r;
>   	int i, rc;
>
> +	spin_lock_init(&buf->rb_mwlock);
>   	INIT_LIST_HEAD(&buf->rb_mws);
>   	INIT_LIST_HEAD(&buf->rb_all);
>
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 3fb609a..edc10ba 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -266,6 +266,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
>   	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
>   	int i;
>
> +	spin_lock_init(&buf->rb_mwlock);
>   	INIT_LIST_HEAD(&buf->rb_mws);
>   	INIT_LIST_HEAD(&buf->rb_all);
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 1f51547..c5830cd 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1179,15 +1179,14 @@ rpcrdma_get_mw(struct rpcrdma_xprt *r_xprt)
>   {
>   	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>   	struct rpcrdma_mw *mw = NULL;
> -	unsigned long flags;
>
> -	spin_lock_irqsave(&buf->rb_lock, flags);
> +	spin_lock(&buf->rb_mwlock);
>   	if (!list_empty(&buf->rb_mws)) {
>   		mw = list_first_entry(&buf->rb_mws,
>   				      struct rpcrdma_mw, mw_list);
>   		list_del_init(&mw->mw_list);
>   	}
> -	spin_unlock_irqrestore(&buf->rb_lock, flags);
> +	spin_unlock(&buf->rb_mwlock);
>
>   	if (!mw)
>   		pr_err("RPC:       %s: no MWs available\n", __func__);
> @@ -1198,11 +1197,10 @@ void
>   rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
>   {
>   	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
> -	unsigned long flags;
>
> -	spin_lock_irqsave(&buf->rb_lock, flags);
> +	spin_lock(&buf->rb_mwlock);
>   	list_add_tail(&mw->mw_list, &buf->rb_mws);
> -	spin_unlock_irqrestore(&buf->rb_lock, flags);
> +	spin_unlock(&buf->rb_mwlock);
>   }
>
>   static void
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 5650c23..ae31fc7 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -283,15 +283,17 @@ rpcr_to_rdmar(struct rpc_rqst *rqst)
>    * One of these is associated with a transport instance
>    */
>   struct rpcrdma_buffer {
> -	spinlock_t	rb_lock;	/* protects indexes */
> -	u32		rb_max_requests;/* client max requests */
> -	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
> -	struct list_head rb_all;
> -	int		rb_send_index;
> +	spinlock_t		rb_mwlock;	/* protect rb_mws list */
> +	struct list_head	rb_mws;
> +	struct list_head	rb_all;
> +	char			*rb_pool;
> +
> +	spinlock_t		rb_lock;	/* protect buf arrays */
> +	u32			rb_max_requests;
> +	int			rb_send_index;
> +	int			rb_recv_index;
>   	struct rpcrdma_req	**rb_send_bufs;
> -	int		rb_recv_index;
>   	struct rpcrdma_rep	**rb_recv_bufs;
> -	char		*rb_pool;
>   };
>   #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
>

Looks good,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
