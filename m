Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976Ab1EDATz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 20:19:55 -0400
Date: Tue, 3 May 2011 20:20:23 -0400
From: Jeff Layton <jlayton@redhat.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110503202023.699435f4@corrin.poochiereds.net>
In-Reply-To: <1304386808-2733-2-git-send-email-andros@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon,  2 May 2011 21:40:08 -0400
andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Hookup TCP congestion feedback into rpc_slot allocation so that the RPC layer
> can fully utilize the negotiated TCP window.
> 
> Use a slab cache for rpc_slots. Statically allocate an rpc_xprt rpc_slot slab
> cache using GFP_KERNEL to the RPC_DEF_SLOT_TABLE number of slots at
> rpc_xprt allocation.
> 
> Add a dynamic rpc slot allocator to rpc_xprt_ops which is set only for TCP.
> For TCP, trigger a dyamic slot allocation in response to a write_space
> callback which is in turn called when the TCP layer is waiting for buffer space.
> 
> Dynamically add a slot at the beginning of the RPC call_transmit state. The slot
> allocator uses GFP_NOWAIT and will return without allocating a slot if
> GFP_NOWAIT allocation fails. This is OK because the write_space callback will
> be called again, and the dynamic slot allocator can retry.
> 
> Signed-off-by: Andy Adamson <andros@netap.com>
> ---
>  include/linux/sunrpc/sched.h |    2 +
>  include/linux/sunrpc/xprt.h  |    6 +++-
>  net/sunrpc/clnt.c            |    4 ++
>  net/sunrpc/sched.c           |   39 ++++++++++++++++++++++
>  net/sunrpc/xprt.c            |   75 +++++++++++++++++++++++++++++++++++++-----
>  net/sunrpc/xprtsock.c        |    1 +
>  6 files changed, 117 insertions(+), 10 deletions(-)
> 

Nice work, comments inline below...


[...]

> +
> +/*
> + * Static transport rpc_slot allocation called only at rpc_xprt allocation.
> + * No need to take the xprt->reserve_lock.
> + */
> +int
> +xprt_alloc_slot_entries(struct rpc_xprt *xprt, int num_req)
> +{
> +	struct rpc_rqst *req;
> +	int i;
> +
> +	for (i = 0; i < num_req; i++) {
> +		req = rpc_alloc_slot(GFP_KERNEL);
> +		if (!req)
> +			return -ENOMEM;
> +		memset(req, 0, sizeof(*req));
> +		list_add(&req->rq_list, &xprt->free);
> +	}
> +	dprintk("<-- %s mempool_alloc %d reqs\n", __func__,
> +		xprt->max_reqs);
> +	return 0;
> +}
> +

So, I don't quite get this...

You declare a global mempool early on, and then allocate from that
mempool for a list of static entries. Doesn't that sort of rob you of
any benefit of using a mempool here? IOW, won't the static allocations
potentially rob the mempool of "guaranteed" entries such that the
dynamic ones eventually all turn into slab allocations anyway?

What I think would make more sense would be to have multiple mempools
-- one per xprt and simply set the mempool size to the number of
"static" entries that you want for the mempool. Then you could get rid
of the free list, and just do allocations out of the mempool directly.
You'll be guaranteed to be able to allocate up to the number in the
mempool and everything above that would just becomes a slab allocation.

-- 
Jeff Layton <jlayton@redhat.com>
