Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460Ab1EDO7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2011 10:59:41 -0400
Date: Wed, 4 May 2011 10:59:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110504105918.422f7609@tlielax.poochiereds.net>
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

[...]

> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 9494c37..1b0aa55 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -498,6 +498,7 @@ void xprt_write_space(struct rpc_xprt *xprt)
>  		dprintk("RPC:       write space: waking waiting task on "
>  				"xprt %p\n", xprt);
>  		rpc_wake_up_queued_task(&xprt->pending, xprt->snd_task);
> +		set_bit(XPRT_WRITE_SPACE, &xprt->state);
>  	}
>  	spin_unlock_bh(&xprt->transport_lock);
>  }
> @@ -957,6 +958,66 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
>  	spin_unlock(&xprt->reserve_lock);
>  }
>  

Is the above a potential race as well? I looks possible (if unlikely)
that we'd wake up the task, and it find that XPRT_WRITE_SPACE is still
unset. Would it make more sense to do the set_bit call before waking up
the task?

-- 
Jeff Layton <jlayton@redhat.com>
