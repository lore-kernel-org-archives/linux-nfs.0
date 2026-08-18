Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15C3C47143D
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:18:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787069930; cv=none; b=VwnRFDYg+uOfLCSuERjJuzabCeK90baRS7AVnYW+BxyFRZVSWvJGGemaf1wTpEb7EhBmfnXV5zswjC7oRy2efG2zZEfcQPcAbAtSWTNYiERikWo9z3k/64RyGSM/2DxunFga1zbUyYmEPxBW16KHz9TEvVUs0gHQK/GKP84AtFU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787069930; c=relaxed/simple;
	bh=GWU5KdSLWV8rWJOO//W8nutWbef8PKAMoOfJpM8pbu8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=aM2BGcTgAySCMrp/MW4eKN92PjuyFNjTXlFVAEmXAYMRT6mRG2VvP45+TF1dt/VAjHTYojD11yB5RltM7l0v75FVoOalMLOTOZUcv46+qs4/ZuDWR2e/VvoZTxyGW/1UVwyPfK9xLJrwg16aQl1069SbypoV5aeLQXjJeoXYKpY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mRTzNLyk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mRTzNLyk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81F9E1F00A3A;
	Tue, 18 Aug 2026 16:18:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787069928;
	bh=/wf4Bvcw2MEK7gKtSQmh6ukG99JT+pMLB28HaRd5Jgg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mRTzNLykiju/ouqGoeEOmBcoDGXWQWGeKdHOG7VR8Y0EbgCgRYShOJYzz6gzObBOK
	 FVPslGGdsIQBc4MIsGmJe5MU6cc22kD0/m7IUSYEFdiVRzJ3YDQ9xMjQ3TLWqNOqSx
	 xerRxbtmuHJBMEMQDGhsZ56MUwDpWiP7DaPKnD0faO8xLxhzyQx5BZqZ5SGzJiG+m1
	 h18ZX4kgxBYbBEW/ih1dd40MFjgR3ZakM3wcygINmeHswHMXYqut9Qh6vzweAXvjKQ
	 9jHnCpNe+kN89KKAhA39JfxoU0jDAKrBQgUSHC2SUYeJ4ClWc75nw/0kIv7mUMFcqA
	 qbPTO5FhsaLLw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BA656F40067;
	Tue, 18 Aug 2026 12:18:47 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 18 Aug 2026 12:18:47 -0400
X-ME-Sender: <xms:54WEal44vKyuUGSrc-PS8vtR2X5Ey-SC-4d-nAzvRGj5YpWmKjZ8gQ>
    <xme:54WEattH__zwaV8sqBU77PqZNM1YP8_3z_Ca6Oh_WQseF4fwBZLEf9fQyi8lDg_pQ
    V7ATyRwG7vrDr0XjB1jvdp47uqchqrarxM84D_sLFTLWpSpX_pn>
X-ME-Proxy-Cause: dmFkZTGNRYhoPoRa9poaLa5WX56G8v3lmSq9zXZBHFsSD//sKfvJE+sn4mq96U/N6dgriF
    cEa9sKnASglQMqTvc99VDNb0WzXrSyeJpkaP4Ml2Yu1z5CJ6MUvm6q1oUPSvT/S7Zz320m
    +nGLreKg+Ji8Ve/RxOzTr4otEveYTh5iV7hQGrMT9rbDBz6eoMq46hXMp9xF4yDTduR8KL
    2ovh0ahD/INeC/xnPOKBq5JspTfjjPY5YFL77Lzizxcsiet6UiOLtkAzzNbvTsUzTOpzc0
    QwadWQLMAtxALPSd1tyVuG4aPQx9XnlPgVvirng8QpCK9nD6WyDm9iuroPiWvVw6sIjBCT
    GEQ3S0kjyTDA7/1EZFvsLhiWpnKL6OC7KxdLFqLCOPdzT9MrlViW+ZlnY0FLJBYrApvwzy
    BBNEjTmLhmejMT69XKqUaXnVZQey5Ivlw6cxejFtAUEynDB8/4CYHKSGIbJo3FP9rVxYav
    fZZibux1SOItO8xIKi1zD7VYi/+aXEtWtdhpDRuPi2XvtszpypFBCJYk7kMJ1kDUIXhTu2
    T1IL7bo8oLQzO0zjYhnKQuna4BjWpS8s5nRFmZNPBrbYyX9e8PaW2Sq1rkwczBhIUAPQP4
    0x4LtObqa7IOhDbHUDD/NIzn2iRJ54e0elf9+eUx4Oxb/MbiEleqHa69cQGw
X-ME-Proxy: <xmx:54WEaq6cY50t8F8XWILgD3PmuVDF_oVmJQJA2gAVWuOHaapVXFodsw>
    <xmx:54WEau0oxmVjgGxR2OItRyms9PKI8j9zYRtEZm-GVcy0MtxC4VcH4A>
    <xmx:54WEaofRqKzjicFy2hyXJl8Wtm3dhlvKOM9mdCImhfNOCYppadp3RQ>
    <xmx:54WEaseEYmniTIHQvjaRWYIrH9Hcm32iEkUcj6yg-NyqMfjrK26QeA>
    <xmx:54WEarwu9UZGib_W2W5gz2PhjfSbWzGjA2DC7YMEcJaH6e-qfJCzY95G>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 985307811F4; Tue, 18 Aug 2026 12:18:47 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AWMsfxfueHdw
Date: Tue, 18 Aug 2026 12:18:27 -0400
From: "Chuck Lever" <cel@kernel.org>
To: tmenninger@purestorage.com, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>
Cc: "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 stable@vger.kernel.org
Message-Id: <6ac343d6-f220-4e18-b3f0-cf2a456afc67@app.fastmail.com>
In-Reply-To: <20260818122825.2347594-1-tmenninger@purestorage.com>
References: <20260818122825.2347594-1-tmenninger@purestorage.com>
Subject: Re: [PATCH] xprtrdma: serialize unmap_sync with xprt_disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Tim -

Reviewer hat on.

I went over this patch with several LLM reviewers and my own
recollection of the code. The combined findings are below.

Summary: I agree there is a bug. The proposed fix introduces
technical debt that I would rather not see in-tree. Importantly,
there are areas where you can reuse existing code instead of
open-coding, the Fixes: tag might be wrong, and a few code
comments need updating as part of the fix.


On Tue, Aug 18, 2026, at 8:28 AM, tmenninger@purestorage.com wrote:
>     xprtrdma: serialize unmap_sync with xprt_disconnect
>
>     frwr_unmap_sync() posts LOCAL_INV Work Requests to the QP and waits
>     for the matching CQE. This can race with rpcrdma_xprt_disconnect():
>
>       1. frwr_unmap_sync() snapshots r_xprt->rx_ep
>       2. rpcrdma_xprt_disconnect() drains the QP
>       3. frwr_unmap_sync() posts LOCAL_INV WRs after the drain
>       4. No CQE arrives and wait_for_completion() blocks indefinitely
>
>     The hung task appears in the rpciod workqueue:
>
>       Workqueue: rpciod rpc_async_schedule [sunrpc]
>       wait_for_completion()
>       frwr_unmap_sync()
>       xprt_rdma_free()
>       xprt_release()
>
>     Serialize synchronous MR invalidation against QP teardown with
>     rx_unmap_rwsem. frwr_unmap_sync() holds the read side through
>     ib_post_send(), then drops it before waiting for completion so that
>     disconnect can acquire the write side and drain the QP.
>
>     Track admitted synchronous unmaps with rx_unmap_active. Disconnect
>     waits for the count to reach zero after draining the QP and before
>     destroying transport resources. This ensures that no synchronous
>     unmap is still accessing the endpoint or MR completion state when
>     those resources are freed.
>
>     Tested on v7.2-rc6 under pNFS load with repeated data server restarts
>     to provoke rapid QP disconnect/reconnect cycling. Without the fix, a
>     hung task in frwr_unmap_sync() reproduced twice in six attempts. With
>     the fix, no hang occurred across 300 cycles.
>
>     The issue has also been observed on v6.8 and v6.18.34. The race has
>     been present since synchronous FRWR invalidation was introduced.
>
>     Fixes: c9918ff56dfb ("xprtrdma: Add ro_unmap_sync method for FRWR")
>     Signed-off-by: Tim Menninger <tmenninger@purestorage.com>
>

Nice find, and the read side around the rx_ep sample and ib_post_send()
does close the window.

On the tag: c9918ff56dfb landed in v4.5.  There rx_ep was an embedded
struct rpcrdma_ep rather than a pointer, frwr_op_unmap_sync() posted to
ia->ri_id->qp, and rpcrdma_ep_disconnect() called rpcrdma_flush_cqs()
without draining the QP.  ib_drain_qp() reached that path in v4.7 with
550d7502cf66 ("xprtrdma: Use core ib_drain_qp() API"), and the sync unmap
moved to xprt_rdma_free() in v5.3 with 0ab115237025 ("xprtrdma: Wake RPCs
directly in rpcrdma_wc_send path").

The race as described needs a freeable rx_ep and the "r_xprt->rx_ep =
NULL" store, and both arrive in v5.7.  Should the tag be:

  Fixes: e28ce90083f0 ("xprtrdma: kmalloc rpcrdma_ep separate from rpcrdma_xprt")

That would also make this sentence inaccurate:

>     The race has been present since synchronous FRWR invalidation was
>     introduced.

The changelog does not say why only the sync path needs this.
xprt_rdma_free() runs from xprt_release() after ->release_xprt has
dropped the transport send lock, so it is the one LOCAL_INV poster that
disconnect is not serialized against.  frwr_unmap_async() runs inline in
rpcrdma_wc_receive()->rpcrdma_reply_handler(), which ib_drain_rq() orders
ahead of ib_drain_sq().  Worth a sentence?

> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index e5c71cf705a3..a4733d75664f 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -567,11 +567,20 @@ static void frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
>  void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  {
>  	struct ib_send_wr *first, **prev, *last;
> -	struct rpcrdma_ep *ep = r_xprt->rx_ep;
>  	const struct ib_send_wr *bad_wr;
> +	struct rpcrdma_ep *ep;
>  	struct rpcrdma_mr *mr;
>  	int rc;
>  
> +	/* serialize against rpcrdma_xprt_disconnect() */
> +	down_read(&r_xprt->rx_unmap_rwsem);
> +
> +	ep = r_xprt->rx_ep;
> +	if (!ep)
> +		goto out_unlock;

The kernel-doc above frwr_unmap_sync() says it "Sleeps until it is safe
for the host CPU to access the previously mapped memory regions."  With
this early return that is now conditional.  Would it help to note there
that rpcrdma_reqs_reset() has already released this req's MRs whenever
rx_ep is NULL?  The correctness of returning here depends on that, and it
happens in another file.

> +
> +	atomic_inc(&r_xprt->rx_unmap_active);
> +
>  	/* ORDER: Invalidate all of the MRs first
>  	 *
>  	 * Chain the LOCAL_INV Work Requests and post them with
> @@ -614,6 +623,8 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  	bad_wr = NULL;
>  	rc = ib_post_send(ep->re_id->qp, first, &bad_wr);

The comment just above this hunk still reads:

	/* Transport disconnect drains the receive CQ before it
	 * replaces the QP. The RPC reply handler won't call us
	 * unless re_id->qp is a valid pointer.
	 */

Is that still the rationale here?  frwr_unmap_sync()'s only caller is
xprt_rdma_free(), not the reply handler, and the new down_read() is there
because the receive CQ drain does not cover this path.  The same comment
sits above frwr_unmap_async(), where it does still hold.

>  
> +	up_read(&r_xprt->rx_unmap_rwsem);
> +
>  	/* The final LOCAL_INV WR in the chain is supposed to
>  	 * do the wake. If it was never posted, the wake will
>  	 * not happen, so don't wait in that case.
> @@ -621,7 +632,7 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  	if (bad_wr != first)
>  		wait_for_completion(&mr->mr_linv_done);
>  	if (!rc)
> -		return;
> +		goto out_atomic_dec;
>  
>  	/* On error, the MRs get destroyed once the QP has drained. */
>  	trace_xprtrdma_post_linv_err(req, rc);
> @@ -629,6 +640,14 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
>  	/* Force a connection loss to ensure complete recovery.
>  	 */
>  	rpcrdma_force_disconnect(ep);
> +
> +out_atomic_dec:
> +	if (atomic_dec_and_test(&r_xprt->rx_unmap_active))
> +		wake_up_var(&r_xprt->rx_unmap_active);
> +	return;
> +
> +out_unlock:
> +	up_read(&r_xprt->rx_unmap_rwsem);
>  }
>  
>  /**

Could rx_unmap_active come out entirely?

It is needed because the waiter sleeps on mr->mr_linv_done, and
rpcrdma_mrs_destroy() frwr_mr_release()s that mr once the count reaches
zero.  Would moving that completion into struct rpcrdma_req decouple the
two?  A req is freed only by rpcrdma_req_destroy() from
rpcrdma_buffer_destroy(), and xprt_rdma_free() is running on this one, so
it cannot be freed under the wait.  rpcrdma_req_reset() leaves it alone
as well.

frwr_wc_localinv_wake() can reach it without a new field.  mr->mr_req is
already there, and frwr_wc_localinv_done() dereferences it the same way
for rl_reply.

The other use is keeping ep alive for the rpcrdma_force_disconnect(ep)
above, after up_read().  Would rpcrdma_ep_get() and rpcrdma_ep_put()
across the read section cover that one?

Together those would drop the atomic_t, the wait_var_event() in
rpcrdma_xprt_disconnect(), and the atomic_set() in xprt_setup_rdma(),
and leave the rwsem with one job.

This isn't a bug, but if the counter stays, is this
atomic_dec_and_wake_up() from linux/wait_bit.h?  nfsd41_cb_inflight_end()
uses it for the same inflight-counter pattern.

> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index d4e6746d8ecd..e2b6287511a4 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -364,6 +364,9 @@ xprt_setup_rdma(struct xprt_create *args)
>  	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
>  			  xprt_rdma_connect_worker);
>  
> +	init_rwsem(&new_xprt->rx_unmap_rwsem);
> +	atomic_set(&new_xprt->rx_unmap_active, 0);
> +
>  	xprt->max_payload = RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT;
>  
>  	return xprt;

This isn't a bug, but is the atomic_set() needed?  xprt_alloc() kzallocs
the whole struct rpcrdma_xprt.

> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 04b286223b24..ae8d06d1cf29 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -580,18 +580,24 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
>   */
>  void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
>  {
> -	struct rpcrdma_ep *ep = r_xprt->rx_ep;
> +	struct rpcrdma_ep *ep;
>  	struct rdma_cm_id *id;
>  	int rc;
>  
> +	down_write(&r_xprt->rx_unmap_rwsem);
> +
> +	ep = r_xprt->rx_ep;
>  	if (!ep)
> -		return;
> +		goto out_unlock;
>  
>  	id = ep->re_id;
>  	rc = rdma_disconnect(id);
>  	trace_xprtrdma_disconnect(r_xprt, rc);
>  
>  	rpcrdma_xprt_drain(r_xprt);
> +	wait_var_event(&r_xprt->rx_unmap_active,
> +		       !atomic_read(&r_xprt->rx_unmap_active));
> +
>  	rpcrdma_reps_unmap(r_xprt);
>  	rpcrdma_sendctxs_destroy(r_xprt);
>  	rpcrdma_reqs_reset(r_xprt);
> @@ -601,6 +607,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
>  		rdma_destroy_id(id);
>  
>  	r_xprt->rx_ep = NULL;
> +
> +out_unlock:
> +	up_write(&r_xprt->rx_unmap_rwsem);
>  }
>  
>  /* Fixed-size circular FIFO queue. This implementation is wait-free and

This wait is the half of rx_unmap_active that a req-resident completion
would remove, leaving drain-then-teardown as before.

> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 4cbc941e4a3e..419d5952150a 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h

[ ... ]

> @@ -449,6 +450,10 @@ struct rpcrdma_xprt {
>  	struct delayed_work	rx_connect_worker;
>  	struct rpc_timeout	rx_timeout;
>  	struct rpcrdma_stats	rx_stats;
> +
> +	/* for serializing xprt disconnect and sync MR unmap */
> +	struct rw_semaphore	rx_unmap_rwsem;
> +	atomic_t                rx_unmap_active;
>  };
>  
>  #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, rx_xprt)

Have you considered putting these on struct rpcrdma_ep instead?
rpcrdma_xprt_drain() already fences the receive side against the drain
with ep->re_receiving and ep->re_done, and an rwsem on the transport
outlives every ep it guards.

Would the comment be more useful naming the rule rather than the two
functions?  Something like: read side held across sampling rx_ep and
posting to its QP.

This isn't a bug, but rx_unmap_active is space-aligned where the rest of
the struct uses a tab.

-- 
Chuck Lever
