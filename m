Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D05174248A9
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 15:17:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787325443; cv=none; b=VZCNx34qQSmXO1zBUrbV+MlUFotx3GZVtwKLQFK+xTJNJY3i0lkItFXPizeVZCPFxJPtbijGPhnljVWrC41BpP186NzVas4vzC5i1pI9trdk0eCQFlxaD/XFagCEE+Mdz7LDVKHGkQOj7q1RuXb0qjRT7JhbJufefvYVt+q9rzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787325443; c=relaxed/simple;
	bh=rAti/Zn6DkTzycBF1dJWEf3z6/b/B89LYvt8bIarUos=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Io5pdenT5Ov3G7ChK1W3aOPHyoXG+lQ48Crf2QPNX9vijN406ehh+djoOsAVTaNfTeSjmSwSUD9cxU+tp4WxZX265CD7WKE7Vo4uVmmpT4ew/q62F3IvqjCa8j+Ed/XaB3yXAmYy1wNNyU1vGWwVG0Idawve4YQ5A+cUvVv70h4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jMRmZ+ub; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jMRmZ+ub"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D3971F000E9;
	Fri, 21 Aug 2026 15:17:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787325441;
	bh=m1VXekkZt6ZWgEF8dmC/B7eTTxTwM6mm+nxnhnetuwU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jMRmZ+ubU4kuYcCyegwI9p/YKLya83cRvb0eRZWBQG1ITNXLIRWVxyaiTN3yVTRlK
	 Xih+V2BW0MeRmrot6HHwrdsaC68YPA80hBPo2wsbJOrdp2F/6/48WzIdWgfNW0+TT3
	 nmc3hpUBaesKu8q0EjGSMo6nSjl4rzQ/T5krD1ogQZiTKzFtTKYjMTYCKzjqDX0dX6
	 5h6vhMNRGDicqf3wfAmxYqxIsBxSZBRio9ENsznzso0FWIKMY5UnQfo8JBaSjhkrdm
	 1hd09tZOdGWMBUTZ0L91EqqkVgxKnoXz7c2tDUcVQpGFngIwcXZd0kydL3OETrzMgR
	 UEkc22VYzb3hg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5DEBBF40068;
	Fri, 21 Aug 2026 11:17:20 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 21 Aug 2026 11:17:20 -0400
X-ME-Sender: <xms:AGyIaniqX1uhbZoftz2KKM2C6NPCfLDQ2RNHQd_6M-ZqYJcsxHpJeg>
    <xme:AGyIau04Eu3wcfXSAFfrMihAacq_t_elP6sMKpkhywiwKgpjZQgljHVhMAR-UxdRN
    w1wQG2Vw_1jLBVlXePL44S3o4fuz3RksJtVcrKiSWYP6nO8gpRzXbzv>
X-ME-Proxy-Cause: dmFkZTGk045WuMFe57NUgwfAI6Uo3r7ggHdXMlZFoeaae06Efvdqao9l1eF3ew9kDXhMMI
    jGwUN3ovKWRWnrHu/byEbyQSbRWVb461kKnVsXslIcF4FHhj4QszFN+FckR18I2lQY/hXA
    LumT2I/5K2hkWuyI+sAxhWQHjkHJC5hyRFVPs+szzqyS2PhxBR+RczDuQ1HCt66L+p+yJt
    NCL1KGQRSqLXRYzH44bnFnFUxTcUC8uw2Lnxg7t09PxXLiRZ1Ost+46afk6fmpuFv/RIF5
    Ny0jxDNNoqp3Y8kKm+OkLCgB4HBYRd5bhHqWlmWIf7J9BzkCgGj7lEh9Fb5OoaIiQ6IQGa
    EUWgLJFQJYTvcX9cKtmazXVOXyLTVSr0GwNnRYaDp04U031rKAVtJlAOaWAtH+MdJ85NTF
    aZwGt3sBE3lBkvJxptw+jJ3h1rqND5MA8xkCoaI6uAEJmTKHyrQ2vwQML0RbqkmxHXBN6N
    H6kxl/gcXNQffitD6yHx/R/aWEJDVu2lRthDsWhgctuffzQ0AfGbdGIImznBrkw+hTZ+fV
    Zxk9xKadhFt+4D9EP44rHm+gW4mtsfLwopAeytGeUVuqZ6BR2ELZ7v+CPdzp7FxhErUQMI
    3mLIExHjom35XutqFVdB83IEnq0NvPAEy1MdRjA9uoKmIUeLlKmFgJlXNFyA
X-ME-Proxy: <xmx:AGyIagySRZiBY02LFDgB7EXx_kxn9sv6Bqy3Il7VBplx-5XzaZHY0g>
    <xmx:AGyIakuth3Oy0IaxFpITEN0TBxJ3AlH0JeGHnRGc-zua2YOaKkFtIA>
    <xmx:AGyIajAnoapjdKFwuapK7RxW_UIv8ajh6lEcl_B5XwYBS59kBubv9A>
    <xmx:AGyIamG23qewPdd2p_PW6QVSu6EVuBLfovF2KInbVlOS2Vu4NqBv8A>
    <xmx:AGyIajAGwUSXKquFtPRUBLhS96OSMDsRwaD_gh7FFils9gJN8hC9vbK7>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 30CA17811F0; Fri, 21 Aug 2026 11:17:20 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AWMsfxfueHdw
Date: Fri, 21 Aug 2026 11:17:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 stable@vger.kernel.org, slingappa@everpuredata.com, ebadger@everpuredata.com,
 jcurley@everpuredata.com
Message-Id: <aa454838-8574-404e-94c8-cca6b15a796c@app.fastmail.com>
In-Reply-To: <20260820211700.318824-1-tmenninger@everpuredata.com>
References: <20260818122825.2347594-1-tmenninger@purestorage.com>
 <20260820211700.318824-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH v2] xprtrdma: serialize unmap_sync with xprt_disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hey Tim -

I didn't find any correctness issues in this one.

Nits: A few comments were made stale, and a layering change.


On Thu, Aug 20, 2026, at 5:17 PM, Tim Menninger wrote:
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index e5c71cf705a3..77aff9c0533a 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c

[ ... ]

> @@ -538,40 +541,62 @@ static void frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)

[ ... ]

>  /**
> - * frwr_unmap_sync - invalidate memory regions that were registered for @req
> + * frwr_unmap_sync - synchronously invalidate MRs registered for @req
>   * @r_xprt: controlling transport instance
> - * @req: rpcrdma_req with a non-empty list of MRs to process
> + * @req: request whose registered MRs are to be invalidated
>   *
> - * Sleeps until it is safe for the host CPU to access the previously mapped
> - * memory regions. This guarantees that registered MRs are properly fenced
> - * from the server before the RPC consumer accesses the data in them. It
> - * also ensures proper Send flow control: waking the next RPC waits until
> - * this RPC has relinquished all its Send Queue entries.
> + * If @req still owns registered MRs after synchronizing with transport
> + * disconnect, post a chain of LOCAL_INV Work Requests and wait for the
> + * final completion. This fences the mapped regions from remote access
> + * and preserves Send Queue flow control.
> + *
> + * A concurrent disconnect can reset @req while this function waits for
> + * the read side. In that case the MRs have already been released and no
> + * LOCAL_INV Work Requests are posted.
>   */

The rewritten block drops the sleeping behavior the old text carried:

  * Sleeps until it is safe for the host CPU to access the previously mapped
  * memory regions.

frwr_unmap_sync() now also takes and releases a transport-wide rwsem.
Both facts belong in a Context: section.

	 * Context: Process context. Takes and releases
	 *	    @r_xprt->rx_unmap_rwsem for read. May sleep.

[ ... ]

> @@ -598,37 +623,44 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)

[ ... ]

>  	if (bad_wr != first)
> -		wait_for_completion(&mr->mr_linv_done);
> -	if (!rc)
> -		return;
> +		wait_for_completion(&req->rl_linv_done);
>
> -	/* On error, the MRs get destroyed once the QP has drained. */
> -	trace_xprtrdma_post_linv_err(req, rc);
> +	if (rc) {
> +		/* On error, the MRs get destroyed once the QP has drained. */
> +		trace_xprtrdma_post_linv_err(req, rc);
>
> -	/* Force a connection loss to ensure complete recovery.
> -	 */
> -	rpcrdma_force_disconnect(ep);
> +		/* Force a connection loss to ensure complete recovery.
> +		 */
> +		rpcrdma_force_disconnect(ep);
> +	}
> +
> +	if (rpcrdma_ep_put(ep))
> +		rdma_destroy_id(id);

This is not a defect, but it makes frwr_ops.c the only file outside
verbs.c that destroys a CM ID.  The other three teardowns are all in
verbs.c: rpcrdma_create_id() on its error path, rpcrdma_ep_create() on
its error path, and rpcrdma_xprt_disconnect().

The rule that a nonzero return obliges the caller to destroy the CM ID
lives in a comment above rpcrdma_ep_put():

net/sunrpc/xprtrdma/verbs.c {
	/*
	 *     %0 if @ep still has a positive kref count, or
	 *     %1 if @ep was destroyed successfully.
	 */
	noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
	{
		return kref_put(&ep->re_kref, rpcrdma_ep_destroy);
	}
}

A small helper in verbs.c would carry that rule instead of open coding
the idiom in a second file.

	void rpcrdma_ep_release(struct rpcrdma_ep *ep)
	{
		struct rdma_cm_id *id = ep->re_id;

		if (rpcrdma_ep_put(ep))
			rdma_destroy_id(id);
	}

That exports rpcrdma_ep_get() and rpcrdma_ep_release() rather than the
get/put pair.  The local id then goes away, because ib_post_send() can
read ep->re_id->qp directly while the read side is still held.

[ ... ]

> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 04b286223b24..193a90c97f7a 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c

[ ... ]

> @@ -580,18 +578,22 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
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

rpcrdma_xprt_disconnect() now holds rx_unmap_rwsem for write across the
QP drain and all of the resource teardown.  Its kernel-doc still records
only the caller-side rule:

  * Caller serializes. Either the transport send lock is held,
  * or we're being called to destroy the transport.

The rwsem belongs there as well.

The same block goes on to say:

  * On return, @r_xprt is completely divested of all hardware
  * resources and prepared for the next ->connect operation.

The first half of that no longer holds.  A concurrent frwr_unmap_sync()
holds an endpoint reference across its completion wait, so
rpcrdma_ep_put() below returns 0.  The QP, both completion queues, the
PD and the CM ID then outlive this return.

[ ... ]

> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 4cbc941e4a3e..e50b0af5adf8 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h

[ ... ]

> @@ -449,6 +450,12 @@ struct rpcrdma_xprt {
>  	struct delayed_work	rx_connect_worker;
>  	struct rpc_timeout	rx_timeout;
>  	struct rpcrdma_stats	rx_stats;
> +
> +	/*
> +	 * Read side protects sampling rx_ep and posting synchronous LOCAL_INV
> +	 * WRs; disconnect holds the write side across QP drain and teardown.
> +	 */
> +	struct rw_semaphore	rx_unmap_rwsem;
>  };

This is not a defect, but the comment claims more than the lock
delivers.  rx_ep is sampled without this rwsem in frwr_mr_init(),
frwr_map(), frwr_send(), frwr_unmap_async(), frwr_wp_create(),
rpcrdma_xprt_drain(), rpcrdma_mrs_create(), rpcrdma_mrs_refresh(),
rpcrdma_rep_create(), rpcrdma_rep_resize() and rpcrdma_post_recvs().

What the read side establishes is narrower: it orders
frwr_unmap_sync()'s LOCAL_INV submission ahead of the QP drain in
rpcrdma_xprt_disconnect().  Something closer to:

	/*
	 * Orders frwr_unmap_sync()'s LOCAL_INV submission ahead of the
	 * QP drain.  Disconnect holds the write side across the drain
	 * and resource teardown.
	 */

> @@ -479,6 +486,8 @@ extern unsigned int xprt_rdma_memreg_strategy;
>   * Endpoint calls - xprtrdma/verbs.c
>   */
>  void rpcrdma_force_disconnect(struct rpcrdma_ep *ep);
> +void rpcrdma_ep_get(struct rpcrdma_ep *ep);
> +int rpcrdma_ep_put(struct rpcrdma_ep *ep);

Nothing here says that a return of 1 leaves the CM ID for the caller to
destroy, which is the rule the frwr_unmap_sync() hunk above open codes.

-- 
Chuck Lever
