Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795781640;
	b=X4R9B231VFf8b/2sEvEZ54yCJg0wMRdFm1WveqJFQx/e5YrQoEq2RcCMGk9IH0TSceb5
	 Y4Ra58DqZcynkwZ6F81EBbn0WgLCm++5vqdbSxsb04SbjeVRSC8/tkROFtZwhuNPDD6KX
	 zPshnj1tkOHBgFldpndch0cmgpIf0O6SDhGqcohn061ieG+09VuXWMqiIC24tXZhNJgy9
	 T9orz1plQPZf2yhLzkWONZ8Rp5AR7tCm5Aa432sofOdPM8lY4MuJ2M/2oL359iAcStOZQ
	 i86nIGMCBYvW995kgM0BHJudTdTl4EWTzn+u773QcjoLiOgThmStC97pHHBCV4wRqtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795781640;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=qCoEzJI5/N2sQ/738mLqdHEf8qRTgH5fccEHKybhjlI=;
	b=PTP0/N1suBvqc13JifxKUuJbEAWtGyX1mtFcuiAOsHkNMlnWZE+4aaGNhudkD2x/ZlDo
	 92e42oLrf0ued8i9heV/c2riFUDNr8V8sFt745sP8ZU4i2LM/hpCVcLHfMvknL6xyptc+
	 ssyipE8foAw2sUKB1YtCF46jOcXHbxMnu90baFO3fZRQtYQpeTI8SxH2WZ3Qm6JtcDTTm
	 2GW1apBMQvyJPgg0XKbNkQyNfv9GsxdYiisu4jKJOEKFejFzOD/kOb3tMpXetHqzDFgfC
	 MTBsKdtCWROHrNhBSrAhHbc7qyJlmXAIv4YOcdewszNbj2Q0Kg+NzBjCWoN28Jeypkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=lu79UmFN;
	arc=none smtp.remote-ip=95.215.58.45
Received: from mta1.migadu.com (out-45.mta1.migadu.com [95.215.58.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D08EE606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 12:13:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D08EE606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=lu79UmFN
X-Envelope-To: linux-nfs@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=6vHRWvrua0fQYBdh7FtUgGXCTKDmCgIIqUhwP5LG/Xo=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1795781637; v=1; x=1796386437;
 b=lu79UmFN4HW9fTuJoYrmpHrKSONr7DoC/Kuxf+HEhdviW0Rutz38qxELgpMESgTSVdOrEuWb
 K96T0ho7diIYpECkcYDSt2N5FKkd05djRG+PpMwtglxa/tDAORrovm90fOydSamanO/CRZ44rF4
 sbkPoWofoIrD6tAqddybBmIE=
X-Envelope-To: linux-nfs@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 1c9234c01c8a2ff2;
	Fri, 27 Nov 2026 12:13:57 +0000
X-Mizu-Trace-ID: 1c9234c01c8a2ff2
X-Migadu-Flow: FLOW_OUT
Message-ID: <4611d7da-478c-43ba-917a-03e5bba4fbbe@linux.dev>
Date: Fri, 27 Nov 2026 13:13:51 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2] RDMA/siw: don't complete a fenced READ twice on flush
To: Cygnus Qiu <eritque-arcus@ikuyo.dev>, jgg@ziepe.ca, leon@kernel.org
Cc: cel@kernel.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
References: <20261127005304.366336-1-eritque-arcus@ikuyo.dev>
From: Bernard Metzler <bernard.metzler@linux.dev>
In-Reply-To: <20261127005304.366336-1-eritque-arcus@ikuyo.dev>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 27.11.2026 01:53, Cygnus Qiu wrote:
> siw_sq_flush() completes a QUEUED READ in the TX slot, assuming the READ
> is not in the ORQ yet. That holds only while a full ORQ fences it.
> siw_check_tx_fence() copies a fenced READ into the ORQ when a Read
> Response frees a slot, and siw_activate_tx_from_sq() copies a READ into
> a free slot. In both cases the READ stays QUEUED until the TX path sends
> it, and a flush in that window completes it twice.
> 
> A peer can hold the window open. It advertises IRD 1, so the ORQ holds
> one READ: READ1 is in the ORQ and sent, READ2 waits fenced in the TX
> slot. The peer then sends Read Response 1 and a FIN in one TCP segment:
> 
>    softirq (TCP receive)                 siw_cm_wq worker
>    tcp_data_queue()
>    |-tcp_fin()
>    | \-siw_cm_llp_state_change()
>    |   Sets tx_suspend and
>    |   queues the close.
>    |
>    \-tcp_data_ready()
>      \-siw_qp_llp_data_ready()
>        |-down_read_trylock(state_lock)
>        |-tcp_read_sock()
>        | \-siw_tcp_rx_data()
>        |   \-siw_rdmap_complete()
>        |     \-siw_check_tx_fence()
>        |       |-siw_read_to_orq()
>        |       | READ2 enters the ORQ.
>        |       |
>        |       \-siw_sq_start()
>        |         orq_fence is now 0.
>        |         TX is suspended:
>        |         READ2 stays QUEUED.
>        |
>        \-up_read(state_lock)
>                                          siw_cm_work_handler()
>                                          \-siw_qp_llp_close()
>                                            |-down_write(state_lock)
>                                            \-siw_sq_flush()
>                                              |-siw_sqe_complete()
>                                              | READ2 from the ORQ.
>                                              |
>                                              \-siw_sqe_complete()
>                                                READ2 again, from the
>                                                TX slot.
> 
> The FIN only queues the close, so the receive path normally gets
> qp->state_lock first.
> 
> nfsd's svcrdma gets two flush completions for one Read chunk:
> 
>    svc_rdma_wc_read_done()
>    \-svc_rdma_recv_ctxt_put()
>      Runs twice for the same ctxt. The second llist_add()
>      links ctxt->rc_node to itself.
> 
>    svc_rdma_free()
>    \-svc_rdma_recv_ctxts_destroy()
>      |-svc_rdma_recv_ctxt_destroy()
>      | Frees ctxt.
>      |
>      |-llist_del_first()
>      | Reads the freed ctxt and returns it again.
>      |
>      \-svc_rdma_recv_ctxt_destroy()
>        Frees ctxt a second time.
> 
> svcrdma pulls the Read chunk before it decodes the RPC, so the peer
> needs no RPC credentials and no export access.
> 
> Complete a QUEUED READ from the TX slot only while orq_fence is set.
> orq_fence now decides whether the TX slot completes the READ, so move
> it out of the bitfield it shared with tx_suspend:
> siw_cm_llp_state_change() sets tx_suspend without taking a QP lock,
> and a lost update could drop or duplicate the completion.
> 
> Found with afb-afl, an LLM-driven kernel audit/repro pipeline; the fix
> and this changelog were also drafted with LLM assistance.
> 
> Reproduced on an unmodified KASAN build of mainline. A plain TCP client
> sends nfsd's svcrdma listener on siw an RDMA_NOMSG call with a
> two-segment Read chunk and answers as above. KASAN reports the read of
> the freed ctxt; here the second destroy then faults in kfree():
> 
>    BUG: KASAN: slab-use-after-free in llist_del_first+0x150/0x170
>    Read of size 8 at addr ffff8881119d9000 by task nfsd/183
> 
>    Call Trace:
>     <TASK>
>     dump_stack_lvl+0x5d/0x80
>     print_report+0x14b/0x4b0
>     kasan_report+0xfa/0x120
>     llist_del_first+0x150/0x170
>     svc_rdma_recv_ctxts_destroy+0xf3/0x1b0
>     svc_rdma_free+0xd8/0x2e0
>     svc_xprt_free+0x22c/0x420
>     svc_recv+0x103f/0x25b0
>     nfsd+0x35c/0xc80
>     kthread+0x34d/0x460
>     ret_from_fork+0x339/0x620
>     ret_from_fork_asm+0x1a/0x30
>     </TASK>
> 
>    Allocated by task 183:
>     kasan_save_stack+0x2f/0x50
>     kasan_save_track+0x14/0x40
>     __kasan_kmalloc+0x7f/0x90
>     __kmalloc_node_noprof+0x207/0x680
>     svc_rdma_post_recvs+0x664/0xbf0
>     svc_rdma_accept+0xc27/0x1980
>     svc_recv+0x12c2/0x25b0
>     nfsd+0x35c/0xc80
>     kthread+0x34d/0x460
>     ret_from_fork+0x339/0x620
>     ret_from_fork_asm+0x1a/0x30
> 
>    Freed by task 183:
>     kasan_save_stack+0x2f/0x50
>     kasan_save_track+0x14/0x40
>     kasan_save_free_info+0x3b/0x60
>     __kasan_slab_free+0x57/0x80
>     kfree+0x162/0x500
>     svc_rdma_recv_ctxts_destroy+0xe7/0x1b0
>     svc_rdma_free+0xd8/0x2e0
>     svc_xprt_free+0x22c/0x420
>     svc_recv+0x103f/0x25b0
>     nfsd+0x35c/0xc80
>     kthread+0x34d/0x460
>     ret_from_fork+0x339/0x620
>     ret_from_fork_asm+0x1a/0x30
> 
>    The buggy address belongs to the object at ffff8881119d9000
>     which belongs to the cache kmalloc-2k of size 2048
>    The buggy address is located 0 bytes inside of
>     freed 2048-byte region [ffff8881119d9000, ffff8881119d9800)
> 
>    BUG: unable to handle page fault for address: ffffeb860011a6c8
>    #PF: supervisor read access in kernel mode
>    #PF: error_code(0x0000) - not-present page
>    Oops: Oops: 0000 [#1] SMP KASAN NOPTI
>    RIP: 0010:kfree+0x69/0x500
>    Call Trace:
>     <TASK>
>     svc_rdma_recv_ctxts_destroy+0xdf/0x1b0
>     svc_rdma_free+0xd8/0x2e0
>     svc_xprt_free+0x22c/0x420
>     svc_recv+0x103f/0x25b0
>     nfsd+0x35c/0xc80
>     kthread+0x34d/0x460
>     ret_from_fork+0x339/0x620
>     ret_from_fork_asm+0x1a/0x30
>     </TASK>
> 
> Without KASAN, SLAB_FREELIST_HARDENED catches the double free as
> "kernel BUG at mm/slub.c:605" in kfree() from
> svc_rdma_recv_ctxts_destroy(). With neither KASAN nor
> SLAB_FREELIST_HARDENED, nfsd pops the freed ctxt again. If another
> kmalloc-2k allocation has overwritten it by then, nfsd faults; if not,
> nfsd frees it again and repeats, so later allocations can get that one
> object many times.
> 
> With this patch the READ is flushed once and KASAN stays silent.
> 
> Fixes: f29dd55b0236 ("rdma/siw: queue pair methods")
> Cc: stable@vger.kernel.org
> Signed-off-by: Cygnus Qiu <eritque-arcus@ikuyo.dev>
> ---
> Changes in v2:
> - Rewrite the commit message: charts for the race and the svcrdma free
>    path, and the full KASAN report.
> - Give orq_fence its own byte, as Sashiko suggested on v1. The lost
>    update was not reproduced.
> - v1: https://lore.kernel.org/r/20261125060646.155172-1-eritque-arcus@ikuyo.dev
> 
> Tested on mainline 4405c18c95d2 (v7.4-rc3+) in QEMU. Applies to rdma
> for-next 94e81a1f3ffa, wip/leon-for-next d24184a64765 and
> wip/leon-for-rc e7732ec135b5.
> 
> Unpatched, the KASAN use-after-free report came in 5 of 5 runs, the
> hardened BUG in 4 of 4, and with neither, nfsd faulted or spun in
> svc_rdma_recv_ctxts_destroy() in 15 of 15; add_key() as an
> unprivileged user got three keys backed by one object in 1 of 6.
> Patched, the KASAN build flushed once in 3 of 3 runs, and the build
> with neither showed no fault, spin or shared key in 10 of 10.
> 
> Controls (FIN after the second Read Request, or no Read Response)
> flush once with and without the patch. The rdma-core tests could not
> run: rdma-core 66's siw provider asserts in siw_destroy_cq() on the
> first test, on an unpatched kernel and with v1.
> 
> A reproducer and the test logs are available on request.
> 
>   drivers/infiniband/sw/siw/siw.h    | 2 +-
>   drivers/infiniband/sw/siw/siw_qp.c | 7 ++++---
>   2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/infiniband/sw/siw/siw.h b/drivers/infiniband/sw/siw/siw.h
> index dbc998248b..82dc88b6a4 100644
> --- a/drivers/infiniband/sw/siw/siw.h
> +++ b/drivers/infiniband/sw/siw/siw.h
> @@ -394,12 +394,12 @@ struct siw_iwarp_tx {
>   
>   	u32 mpa_crc;
>   	bool mpa_crc_enabled;
> +	bool orq_fence; /* ORQ full or Send fenced: not a bitfield */

"not a bitfield" is a strange /* comment */ to me.
A brief explanation of why the change was made fits very well
in the commit message.

>   
>   	u8 do_crc : 1; /* do crc for segment */
>   	u8 use_sendpage : 1; /* send w/o copy */
>   	u8 tx_suspend : 1; /* stop sending DDP segs. */
>   	u8 pad : 2; /* # pad in current fpdu */
> -	u8 orq_fence : 1; /* ORQ full or Send fenced */
>   	u8 in_syscall : 1; /* TX out of user context */
>   	u8 zcopy_tx : 1; /* Use TCP_SENDPAGE if possible */
>   	u8 gso_seg_limit; /* Maximum segments for GSO, 0 = unbound */
> diff --git a/drivers/infiniband/sw/siw/siw_qp.c b/drivers/infiniband/sw/siw/siw_qp.c
> index bb780e3904..2cc0f466e7 100644
> --- a/drivers/infiniband/sw/siw/siw_qp.c
> +++ b/drivers/infiniband/sw/siw/siw_qp.c
> @@ -1188,10 +1188,11 @@ void siw_sq_flush(struct siw_qp *qp)
>   		if (tx_type(wqe) != SIW_OP_READ_RESPONSE &&
>   		    ((tx_type(wqe) != SIW_OP_READ &&
>   		      tx_type(wqe) != SIW_OP_READ_LOCAL_INV) ||
> -		     wqe->wr_status == SIW_WR_QUEUED))
> +		     (wqe->wr_status == SIW_WR_QUEUED &&
> +		      qp->tx_ctx.orq_fence)))
>   			/*
> -			 * An in-progress Read Request is already in
> -			 * the ORQ
> +			 * A Read Request is already in the ORQ unless
> +			 * a full ORQ fenced it
>   			 */
>   			siw_sqe_complete(qp, &wqe->sqe, wqe->bytes,
>   					 SIW_WC_WR_FLUSH_ERR);

Otherwise: Excellent finding, thanks!

Acked-by: Bernard Metzler <bernard.metzler@linux.dev>

