Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793977642;
	b=gEOOzEvIpC8UxSB9TXrVUou0jgrk9qU/7mGQPpe92mD/vSrxeivyps1FPOmNqvk9imx1
	 6MfXxerShAhqInfl203ckCR5aaznsSfv6X6pVcD59PmtXxXMQIt/SSr0qH4EZTdin8V47
	 jG2WU4yh2+LJf1ACD2tUUQ9ufPGLyW8sZW93Cnwc8bJwCjWfblLzkntlsvQz0odWkXiFj
	 vTu4VLlTuSut+ZuxQVHcR1JMvOiJu874XcbuQdfJg3e2FcVuDA/hsgD1nkLLiSlkDzDJc
	 JmVKbtzTspuv33wO6VRl6x0eiJHkjkstU3bTL0UWd7pUpjDLFbYEA7mT4Q/TOaNEQig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793977642;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=hjFtLT/eT39ja2rH1EdF5U1lL49IsAZiy06+1wX1i5Q=;
	b=zlLkN4IspmfUOHccR1hhYh7hbr8uAO/zTyvK4Flwt+UDT70CL30fC1K1LZFDgOGH+IHm
	 EZuu82CzXYqATX4W+YqGNCeho9zjGUOs5ABTt+TMo3vIK/8HrR5y1fSd/MQSkdN9120PI
	 XEZ84EmEsLF0eOv7615QtLjI7bDe3RWI4t6mnUAH5S6pvuukDiuExUar7zqHDQxByYCis
	 mWBqk6NbbUhUVrYQHvtLtvU+AD5CVZThBRYKEdWKtcpKqejaEfvAL28FtZKsNCn5cKJAS
	 sry3232k81wNnAP0fvWs/d+//Fqe2gxfmPWuISu4WVN9SWVNRshNOagZli+pu/O/Nrg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K+05ewYK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3431606A32E
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 15:07:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K+05ewYK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 443041F0089F;
	Fri,  6 Nov 2026 15:07:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793977641;
	bh=hjFtLT/eT39ja2rH1EdF5U1lL49IsAZiy06+1wX1i5Q=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=K+05ewYKnZAepnVsimd3G5S6jDSV7gprH48dKPBnxplAl6wpOAOhZqepW7muqO5mj
	 YNuwxVLy6JZ7M0KAUHoqg1OT5uOyWWoBIBrNQgmgiwG6AYHg22zA0uzzjANWmrg0y9
	 hWhRzI2/rr2m6YV1HNrBzpAuYOucyG8pTffTKuO6Lqr37XPCmg15Wc5FNGVQk5CeFE
	 X5dSiEZ2SluxLtSTYVNzV5x6t6yF3zmRlilr0tsCm+OGwJ1oHYEc2MiEdUl8CzarUO
	 6LzloG53gwJb660WBTHWMb9F4Aj2s+FeQVeHPWjdKRkWsv7ESGMIJcTPgtnSUB/ahR
	 98CRR33O+ogwQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A569CF40066;
	Fri,  6 Nov 2026 10:07:20 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 06 Nov 2026 10:07:20 -0500
X-ME-Sender: <xms:KO3tarTDSdmnh5AgX6SwR_4N3UgWO33HcNVlMW-GmF5A9Us7LQoEzg>
    <xme:KO3tannfuiepK2UNRkNEAne6Mt_TmmvaFlNVIOcJlpISUCcLbjWZRaw-GTMHOe1pj
    P1R61rcoc5VzAO4bt2w5w3wG8tV5Ab9dt5wprn8HfZZDJ4wR6vgYcY>
X-ME-Proxy-Cause: dmFkZTENjV9qYvDOprlF+HAgK8H6xLK52nqRTr0FiJq9Ts+Ql2TTUavN+P3rxeJX/uYPXr
    tXhvMCGowjxgZ0rSgSwSSgSgI25vIKm1hxsNNO6ccv5o0KyNrASkpnMiB0LN9SdY2Ju3PZ
    3JXdPqb2ym6Gs46w9YocT/SYusrBlmbmsU61pKR0woQFtMASEWlMGvcd7ETX/6n+bjbvZC
    cV11soYoJz1iMb7V1YQ/TWUkojMihU3t/bgZgxcfvkxZ3vxcRJn6HLK3AkTtGaqy9a17ev
    A6EB9dbjmn6ibiuwGBBcVKuiuoUUKT85g/+S51hwneRZDI2GssNP8u7A0sqS9PmIybp9G3
    K73L+iH945gnSO/zw2vjiB896xAMed3+XqCkytKbX/asmDX9PNpRVTbrqnulfEHtntr0ee
    x7uxx6tHwnNmj676r3fXU+jj+MoToa6D7ABjWi+dUCiaPiE+W7iPjo4ZE3UCcsBcYwGmKK
    7B7Q4gSMYQj+JUmm5kie9XsGOoTjLSz9FyS+Sl3MuSAHYSR7YeSsrGrlcRUTlBCCklzm5n
    N0CUHk5EIMGLK/tijEN1n+nSetvzrpBClW5mm2W73urLfCZP72xNpJI/Xozfhv1L/jg+xg
    PTRiRxZxrBir/B0X16f/UdUk/qUUmfUSV3LEhr0Llbex1ZGiOKFlnT2DBWjA
X-ME-Proxy: <xmx:KO3taiKpz3_c514sVhmcFy4NBkbWE5m-QuBa1HXAW3lU8qZpAqgyvQ>
    <xmx:KO3taq39ZvPG5SOwPx-ME6GgrKBMxT5MEfnH07Cvsl25vDG1rbHMNw>
    <xmx:KO3tag5F9FOxTREJ3TW8yiOHJgkb4ATdr3lrKaVGQQn4npynCFFpIQ>
    <xmx:KO3tar9aQVTgWNLhqh4xDkR2rp8qTR-QnMOvICMtH6xhN_t8HjLWPQ>
    <xmx:KO3tavWYSVVNcA8CAnn5WA3e5gEohfWrmiG0UtSeu3n83wkHOFna2Ctx>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8604478273B; Fri,  6 Nov 2026 10:07:20 -0500 (EST)
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
X-ThreadId: AAPwM5BZBMgc
Date: Fri, 06 Nov 2026 10:07:00 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Jorge Mora" <jmora1300@gmail.com>
Cc: linux-nfs@vger.kernel.org, trondmy@kernel.org, anna@kernel.org,
 Rakesh.Bhargava@netapp.com, Mohit.Kumar@netapp.com,
 tmenninger@everpuredata.com
Message-Id: <e62137dd-e1ce-46bb-8973-734ce8ed5489@slotpi15m67>
In-Reply-To: <20261105232137.4706-1-mora@netapp.com>
References: <20261105232137.4706-1-mora@netapp.com>
Subject: Re: [PATCH v2] xprtrdma: fix race between frwr_unmap_sync() and transport
 disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 11/5/26 6:21 PM, Jorge Mora wrote:
> frwr_unmap_sync() is called from xprt_rdma_free() via ->buf_free, which
> xprt_release() invokes without holding the transport send lock and
> without XPRT_LOCKED. rpcrdma_xprt_disconnect() runs from xprt_autoclose()
> under XPRT_LOCKED and, after draining the QP, resets every rpcrdma_req
> (rpcrdma_reqs_reset) and destroys every MR (rpcrdma_mrs_destroy). Nothing
> orders the two, so both can walk and list_del() the same req's
> rl_registered list and the same MRs.

Thanks for the vmcore analysis, and for the detail about the
destroy_mkey stall widening the window. That explains why the
list corruption is what shows up on your systems.

Tim Menninger has been working the same race from the other
symptom, a hung task in frwr_unmap_sync() when the LOCAL_INV chain
is posted after the QP drain. His v5 went out this morning:

  https://lore.kernel.org/linux-nfs/20261106142039.1066437-1-tmenninger@everpuredata.com/

> + - If rb_closing is set, frwr_unmap_sync() returns and leaves the MRs on
> +   rl_registered. rb_closing is only set after rdma_disconnect(), when
> +   the QP is in the error state and the peer cannot reach the MRs;
> +   rpcrdma_reqs_reset() then releases them.

When frwr_unmap_sync() returns here, xprt_rdma_free() returns and
the RPC's pages go back to the consumer while the MRs are still
DMA-mapped. frwr_mr_unmap() does not run until rpcrdma_req_reset()
reaches that req. On a platform with swiotlb or a bounce-buffering
IOMMU, the deferred dma_unmap_sg() for a FROM_DEVICE mapping copies
the bounce buffer into a page that may already be freed and reused.
Tim's version always unmaps before frwr_unmap_sync() returns,
either in the LOCAL_INV completion handler or because the reset
already ran.


> +	/* frwr_unmap_sync() runs without the transport send lock.
> +	 * Callers that claimed MRs before rb_closing was set may
> +	 * still be posting or waiting on LOCAL_INV Work Requests.
> +	 * Those complete (or flush) because the QP has been
> +	 * drained, but the callers still reference the MRs and the
> +	 * ep, so wait for them before anything is released.
> +	 */
> +	wait_event(buf->rb_unmap_wq, !READ_ONCE(buf->rb_unmap_users));

A caller that bumped rb_unmap_users just before rb_closing was set
can still reach ib_post_send() after rpcrdma_xprt_drain() has
returned. The comment relies on the provider flushing a WR posted
to an error-state QP. Tim's report is that no CQE arrived in that
case on his hardware. I can't tell from here which providers
guarantee the flush, but if his observation holds, this patch
leaves that hang in place and adds a second waiter: disconnect now
sleeps in wait_event() for the stuck caller, so the autoclose work
and the whole transport stop with it.

Tim's rwsem makes the post happen before the drain or not at all,
which removes the dependence on provider behavior. The counter,
flag, and waitqueue here are doing the same job as his rwsem by
hand, with that one ordering missing.

Would you be able to run Tim's v5 against your reproducer? If it
holds up, a Tested-by from NetApp, plus the vmcore details added
to his patch description, would make a stronger single submission
than either patch alone.

I'm a reviewer here, not the maintainer, so the final call on
which fix goes in is Anna's and Trond's. Tim's looks a little
more complete. Sorry I didn't realize earlier that both of you
were working the same issue.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
