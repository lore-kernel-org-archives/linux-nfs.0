Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793977766;
	b=N3FeFMDlB+utmqAu8xSWQwHYQdrJGxdqkLB1iYlEs7z94jTjbR6q9w4gjbM8bDCt4C5L
	 epKtdd5oqtxSyhaqO8xIMPDkWRdngAIEyAGGSs/WcTcm+d8EQJkjAqMoty3kqMQ2e8kK9
	 x6Ls2oyQNURRWQpPyQG4JB5RjqhjFFygUNJfh5d5GCsz549+W4DlaBGs1kSHdTx9W8VYA
	 MAU2hLREIjkBEFl7QSDI8K1m6++drQ4b19pVDc5dzjGXeA5rj/sIVLd7Kipsiud4Wjl93
	 Q/LIIfyEHCDoHPnueN14UX2UwTe332+yKRsVhJFZbTOMT8CleKq0gLRwPq8qGcbOiVQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793977766;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=npuYSel4O9FrV/jNGZ9cdAPDnmYjQUkDZB008eKUgGc=;
	b=LnPLqmURb7RfB86rzQvIxUkhg/b/8CvWViyy8JI1V4JgCsorKEobrRCSeuBWsDMUwfHj
	 ZaSVNXAsQjEDcm1pxNXj9HsV1kTFoiNKamxt2R+RtlukGlZuCtZHyB818dlsSICKBYx7B
	 CcICWbSV5BFjSNaFbZTahy+VfJzk+hxJcHPXs3sp+T1ncXd7U5nuzLpMZ/tlBPlFWhOX0
	 kkJZuG9O8L0rUD9HbajUh5uOH8qV0pSqsgpe5qiO1CeX1Cuk5hsqIx91gcd85/383UXlG
	 Qnem5NkLwp1rExoRzP1JHpWsfY/yoY7jpSNOA8F+YzW1vAEah5GUe1puHfv8UCWZrfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q6iIcqsC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57A12606A329
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 15:09:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q6iIcqsC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 88F5E1F0089F;
	Fri,  6 Nov 2026 15:09:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793977765;
	bh=npuYSel4O9FrV/jNGZ9cdAPDnmYjQUkDZB008eKUgGc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Q6iIcqsCd9wG7B1voqWAlSzFkSsgKNR1OrSEz/90X1y5NUSI3avVEaO2RTGm9tyEI
	 wXH7q2vQOW2/14yEN7bOwKgrz2n5xQlA+q6k3idVIWglCRPPzFUWPKl0ohV0kOHGcn
	 UV2z6ptrdtYa74ko27JCfY3vYGGb1mHw6cKvNy8NUXzdj42t7J/9sK+y8QRmS+6bfc
	 yr9NXbg32Tq0KPxx2IMnetHMv+XuD75QJL9iOpvyq08s6WsLTzbWhnrmQz5Us9Lpz2
	 d6C/JJewlJ5q0Q+KGdHmokvvgzL8onw8CkztLFz1aP3A+FfgNjn4Nyu5/0zuexfJBW
	 CSG9M8B+XFxEQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EA5B6F40066;
	Fri,  6 Nov 2026 10:09:24 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 06 Nov 2026 10:09:24 -0500
X-ME-Sender: <xms:pO3tavCpLhKAHBgB1GqJOZtIxf2vvwdmlMg8IaorUUw81lrmVn82YA>
    <xme:pO3tagXPWk9VQ-cL5bnGPzSlRAD3oWm0OvesAi2q7t5H0WyR3fnmpJa5sMmmJkEsa
    Fnx7CRxyWa9m9hkooh3_4c2lnkApxozb4rDjuwt5_73pV4kTsNZ0K8>
X-ME-Proxy-Cause: dmFkZTFEhyjgIWT9Pl7QSDXtVhusfaBv7ZIEID3b6YaYkY/PL4NFOj9jmbZBiJKasYMxrT
    cHTZQ+y/cKTOkkwTy3bgReD6eZWCZ4oFOP3Fheauuru/hu6APs/VMcM8CSa4tMi0yHZpV3
    Q055OM8A6Zu+3SdJrgCjERVT17kvzH7TihJ4vwOkhIBI7Sx8wYrOMWXuMe8oHbSYEJ633K
    TVgnEWoJGyQ2jyMWfbPQbJstCtXUnCk3uQ1UzH99NSAJjoueBgrsfby6dcWc95nK9JJk4l
    n9cdoA7lVuSur778GyQzFCPedD2JhDWkUG7+1a3cYAo/M4Q9bisUAXTeERjfmTvtsZWwQ6
    DL3JueRN62cGgtN4zFP17T4wtrdxw90UQ2A+kJ8WmDDz4wcJRhtsprKS+731WsC2kdEdcN
    Iovo9fGC9z6Bl8pcg3cl90ark4c/eFRbxxR0meVzU8n+CM9nOZ/wTfTAx/VWpP5iC18LQE
    T017Af6YvGdcZykgdjNz6/1QenNOfwjpEbsC8IQJlTkW2HyWM+YMlgvkTZUXwaAxvrjiD4
    j1o5XnmdBwXcQU3YzCGMG+s6S8XsBjZpjEjK1KXvsTkQB/liAWuGUYgzQFwkeoqmDdCb8R
    jC4eOaLYNHw8Br+kT+mG90lO84My3d3X5R6Avlt5IhPrOuslw6lIY3tq2Vgg
X-ME-Proxy: <xmx:pO3taskkJ7VxndqivvrJnBr5tevANTi-D6_ZFsCII6HJrdZwg3rNQg>
    <xmx:pO3tansS6HrnkCJ4h6NuE77MOPzzaE5UchXJGwMULm6V4M71pFcFJA>
    <xmx:pO3tanp7mVj9ajDYDwY-JLxXZaLPH9WvM4WvBCrUdiKdEncz080H0g>
    <xmx:pO3tateZ8vte2uvNWpQJVszzitYXsdCkGDYfNo9K1GXlVyxtmrn3hA>
    <xmx:pO3tavnjB0nh0BCcD8kbwKwlPtk0JjWADyclTpeBbHVi9mTxN_sKbrJk>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CFBA9782738; Fri,  6 Nov 2026 10:09:24 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: As7mHhrShI7Z
Date: Fri, 06 Nov 2026 10:09:04 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: anna@kernel.org, trondmy@kernel.org, ebadger@everpuredata.com,
 jcurley@everpuredata.com, linux-nfs@vger.kernel.org,
 slingappa@everpuredata.com, stable@vger.kernel.org, tom@talpey.com,
 mora@netapp.com, Rakesh.Bhargava@netapp.com
Message-Id: <dce03323-90e7-400f-8deb-63010d928460@slotpi15m67>
In-Reply-To: <20261106142039.1066437-1-tmenninger@everpuredata.com>
References: <20261106142039.1066437-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH v5] xprtrdma: serialize unmap_sync with xprt_disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 11/6/26 9:20 AM, Tim Menninger wrote:
> frwr_unmap_sync() posts LOCAL_INV Work Requests to the QP and waits
> for the matching CQE. This can race with rpcrdma_xprt_disconnect():

Thanks for sticking with this one. Before the rest, a pointer: a
second report of the same race went to the list yesterday, as a
list_debug BUG in frwr_unmap_sync() rather than a hang:

  https://lore.kernel.org/linux-nfs/20261105232137.4706-1-mora@netapp.com/

That is the other outcome of the same window. rpcrdma_req_reset()
and frwr_unmap_sync() both pop rl_registered with no lock, so which
symptom appears depends on timing. I've replied there suggesting the
two efforts be combined on this patch.

I'd like to see the patch get smaller.

> +	/*
> +	 * Hold an endpoint reference so ep, its QP, and its CM ID remain
> +	 * valid after the rwsem is dropped and through the completion wait.
> +	 */
> +	rpcrdma_ep_get(ep);

As far as I can tell, the only use of @ep after up_read() is the
rpcrdma_force_disconnect(ep) call on the error path. If that call
moves up before up_read(), the write side still holds disconnect
off while @ep is dereferenced, and the kref isn't needed:

	bad_wr = NULL;
	rc = ib_post_send(ep->re_id->qp, first, &bad_wr);
	if (rc) {
		trace_xprtrdma_post_linv_err(req, rc);
		rpcrdma_force_disconnect(ep);
	}
	up_read(&r_xprt->rx_unmap_rwsem);

	if (bad_wr != first)
		wait_for_completion(&req->rl_linv_done);

With that, the export of rpcrdma_ep_get(), the new
rpcrdma_ep_release(), the kernel-doc for both, and the header
changes for them all drop out. What remains is the rwsem and its
init, the down/up pairs, and the completion move. That is about
half the current diff for the same guarantee.

The ordering is the same as today for the error case:
rpcrdma_force_disconnect() only sets a flag and queues the
autoclose work, so calling it under the read side does not recurse
into rpcrdma_xprt_disconnect().


> +	/*
> +	 * Orders frwr_unmap_sync()'s LOCAL_INV submission ahead of the
> +	 * QP drain. Disconnect holds the write side across the drain
> +	 * and resource teardown.
> +	 */
> +	struct rw_semaphore	rx_unmap_rwsem;

With the write side held across rpcrdma_mrs_destroy(), every
xprt_release() on this transport waits out the ib_dereg_mr()
loop. The NetApp report describes that loop stalling in
mlx5_core_destroy_mkey when a couple hundred transports tear
down at once. I don't see a deadlock, since the drain needs only
the CQ workqueue, but it is added latency on rpciod. If that
turns out to matter, the write side could end after
rpcrdma_reqs_reset() rather than after the ep put. I'd leave
it as is unless someone measures a problem.

I'm a reviewer here, not the maintainer, so take the above as a
suggestion for Anna and Trond to weigh.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
