Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795701313;
	b=VzB07uF0iXTuBdxIGyJqPGi2vO98JVbi8fiB2SRUUVoGRer5lW42Szwn/fj3ia346hj+
	 rF8B+fAR5P0E+IVTrVHWP5Z1RvpnszaTtSZ1lkUwHcjjb5L9/nuhf/PspV08LviDkqGiu
	 p+dmqKCwtwb4OkjLqhtuNRQs3v0yFa1XkEigkNktoJjwlT9i9Z3UDPcAAOJ92Zqe3NDM6
	 nzvElu5wMi5j6JtAd1K91JPZ626HS7yWpNUiWux0efniOl07OXuHlaIOzmAd24ARgSlCs
	 Q4/sEqqly2HJQvqAYM7js42entx3dMA50iJLBHdzgl0ENQ4niO98DBXS3gkyhNnKF6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795701313;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=vKIf+WNo5OzHHAJYkS+pAgKjd3TBVYejDD4IVW523e4=;
	b=XEiFfqvhZfdpAGYLkXDqOZRheyID5G7iXyR9kEuSzC3Hxag/IE0VScNmkqD34Zfy970y
	 Yfne4laIwmsx5uLFI68XPgSKDFGTUtYVHOHFyUFoL6nv71u1d/VooMPpO8ZwfKP0P58ss
	 46vjMy8h2tU399zi54x5Qm9lNo7sK7OsE2KjikSinsJ3mPUzERdP2IvP14N8yztTmhWa2
	 Pc/nFHDg0/0YSviWLrHLthUSwKIwgXVgJlrbFXWI10vYGYjeLYOnq9Mol71sH0UCdcHat
	 IZzKx6JiMhtij2yODGS7fn0UxQZopDgIlVHHfvRtcj+IlRIQ/W3/2kZNs6Xk6AJvEsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FDYomTmu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CB8E606A31C;
	Thu, 26 Nov 2026 13:55:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FDYomTmu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3A511F000C0;
	Thu, 26 Nov 2026 13:55:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795701312;
	bh=vKIf+WNo5OzHHAJYkS+pAgKjd3TBVYejDD4IVW523e4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FDYomTmuQZ6AIJRVZKh9cY6orkhEsTfU4F0Ule5osgzmdGCRgcoqotLvV3sk7l2R3
	 uAI3QddPJIxni3Bb3tDiBfknIbnBkRCeYm8a9slPLGqEa4Aly7+yPWOe7LT7CTWT0x
	 LsceOvQ/jI0j/YsNxbO1f7zkrZZsXr+nN7ai9HIxcaHjqcwL/DTjsNmPL9ugOEVPR8
	 H6E0xt4CDXjNFgKU1kMAub0O8JdtOf5ASAXTj7CZXQjmDcocUZvi/aTQAlMN7ibN6b
	 BDQLYD/ITt4mWndUxcclR/BIbZmam7P41NHEWDBm5QBbz4fiRH8+RNQ/eg2cvy1fVz
	 00wQKvPHYuQ9w==
Date: Thu, 26 Nov 2026 15:55:08 +0200
From: Leon Romanovsky <leon@kernel.org>
To: Cygnus Qiu <eritque-arcus@ikuyo.dev>
Cc: bernard.metzler@linux.dev, jgg@ziepe.ca, cel@kernel.org,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] RDMA/siw: don't complete a fenced READ twice on flush
Message-ID: <20261126135508.GO774860@unreal>
References: <20261125060646.155172-1-eritque-arcus@ikuyo.dev>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261125060646.155172-1-eritque-arcus@ikuyo.dev>

On Wed, Nov 25, 2026 at 01:06:46AM -0500, Cygnus Qiu wrote:
> siw_sq_flush() completes the READ in the TX slot while it is still
> SIW_WR_QUEUED, assuming a queued READ is not in the ORQ yet. That only
> holds when a full ORQ fenced it. siw_activate_tx_from_sq() copies a READ
> into a free ORQ slot, and siw_check_tx_fence() copies a fenced READ into
> the ORQ once a Read Response frees a slot; in both cases the WQE stays
> QUEUED until the TX path sends the Read Request. A flush in that window
> completes the READ from the ORQ and again from the TX slot: two
> IB_WC_WR_FLUSH_ERR completions for one work request.
> 
> The peer controls the window. It advertises IRD 1, so the ORQ holds one
> READ, and answers the first Read Request with a Read Response and a FIN
> in one TCP segment: the FIN suspends TX before the Read Response moves
> the next READ into the ORQ, and the close flushes it.
> 
> svcrdma's svc_rdma_wc_read_done() then puts the receive context twice,
> which links it into sc_recv_ctxts as a loop, and svc_rdma_free() reads
> it after freeing it and frees it a second time, a double free. svcrdma
> pulls the Read chunk before it decodes the RPC, so the peer needs no
> RPC credentials and no export access.
> 
> Complete a QUEUED READ from the TX slot only while the ORQ fence is set.
> 
> Found with afb-afl, an LLM-driven kernel audit/repro pipeline; the fix
> and this changelog were also drafted with LLM assistance. Reproduced on
> an unmodified KASAN build of mainline: a plain TCP client sends nfsd's
> svcrdma listener on siw an RDMA_NOMSG call whose Read chunk has two
> segments and answers the first Read Request as above.
> svcrdma_wc_read_flush fires twice for the chunk (5 of 5 runs), then:
> 
>   BUG: KASAN: slab-use-after-free in llist_del_first+0x150/0x170
>   Read of size 8 at addr ffff8881119d9000 by task nfsd/183
>    llist_del_first+0x150/0x170
>    svc_rdma_recv_ctxts_destroy+0xf3/0x1b0
>    svc_rdma_free+0xd8/0x2e0
>    svc_xprt_free+0x22c/0x420
>   Freed by task 183:
>    kfree+0x162/0x500
>    svc_rdma_recv_ctxts_destroy+0xe7/0x1b0
> 
> Without KASAN and with SLAB_FREELIST_HARDENED, the double free is
> caught as "kernel BUG at mm/slub.c:605" in kfree() from
> svc_rdma_recv_ctxts_destroy() (4 of 4 runs).
> 
> With this patch the chunk is flushed once and KASAN stays silent (4 of 4
> runs). The rdma-core tests could not run: the siw provider of rdma-core
> 66 fails an assertion in siw_destroy_cq() on the first test, with and
> without this patch.
> 
> Fixes: f29dd55b0236 ("rdma/siw: queue pair methods")
> Cc: stable@vger.kernel.org
> Signed-off-by: Cygnus Qiu <eritque-arcus@ikuyo.dev>
> ---
> Tested on mainline 4405c18c95d2 (v7.4-rc3+) in QEMU. Applies to
> mainline 8d7fe9885c62.
> 
> Sending the FIN only after the second Read Request has gone out, or
> with no Read Response at all (the fenced READ never enters the ORQ),
> gives one flush completion before and after the patch.
> 
> siw_sq_flush() now relies on orq_fence. That bit shares a byte with
> tx_suspend, which siw_cm_llp_state_change() sets without the QP state
> lock. A lost update there already stalls the fenced READ in
> siw_check_tx_fence(); with this patch it would also lose that READ's
> flush completion. I did not try to hit that window.
> 
> A reproducer and the test logs are available on request.
> 
>  drivers/infiniband/sw/siw/siw_qp.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)


Please read this suggestion https://lore.kernel.org/all/0037554862c0d9dce3ddafd1238347e4b16a5079.1795581896.git.wqu@suse.com
It is applicable to this patch as well. 

Rewrote the commit message, add full KASAN stack trace and resubmit.

Thanks
