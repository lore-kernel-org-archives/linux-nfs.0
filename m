Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:38305 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbcBKSqF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2016 13:46:05 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160208171756.13423.14384.stgit@klimt.1015granger.net> <20160208172537.13423.97332.stgit@klimt.1015granger.net>
In-Reply-To: <20160208172537.13423.97332.stgit@klimt.1015granger.net>
Subject: RE: [PATCH v2 9/9] svcrdma: Use new CQ API for RPC-over-RDMA server send CQs
Date: Thu, 11 Feb 2016 12:46:09 -0600
Message-ID: <01d001d164fc$78fae5e0$6af0b1a0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Monday, February 08, 2016 11:26 AM
> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: [PATCH v2 9/9] svcrdma: Use new CQ API for RPC-over-RDMA server send CQs
> 
> Calling ib_poll_cq() to sort through WCs during a completion is a
> common pattern amongst RDMA consumers. Since commit 14d3a3b2498e
> ("IB: add a proper completion queue abstraction"), WC sorting can
> be handled by the IB core.
> 
> By converting to this new API, svcrdma is made a better neighbor to
> other RDMA consumers, as it allows the core to schedule the delivery
> of completions more fairly amongst all active consumers.
> 
> This new API also aims each completion at a function that is
> specific to the WR's opcode. Thus the ctxt->wr_op field and the
> switch in process_context is replaced by a set of methods that
> handle each completion type.
> 
> The server's rdma_stat_sq_poll and rdma_stat_sq_prod metrics are no
> longer updated.
> 
> As a clean up, the cq_event_handler, the dto_tasklet, and all
> associated locking is removed, as they are no longer referenced or
> used.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

<snip>

> @@ -310,26 +311,26 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> 
>  	/* Prepare RDMA_READ */
>  	memset(&read_wr, 0, sizeof(read_wr));
> +	ctxt->cqe.done = svc_rdma_wc_read;
> +	read_wr.wr.wr_cqe = &ctxt->cqe;
>  	read_wr.wr.send_flags = IB_SEND_SIGNALED;
>  	read_wr.rkey = rs_handle;
>  	read_wr.remote_addr = rs_offset;
>  	read_wr.wr.sg_list = ctxt->sge;
>  	read_wr.wr.num_sge = 1;
>  	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_READ_W_INV) {
> -		read_wr.wr.opcode = IB_WR_RDMA_READ_WITH_INV;
> -		read_wr.wr.wr_id = (unsigned long)ctxt;
>  		read_wr.wr.ex.invalidate_rkey = ctxt->frmr->mr->lkey;

Hey Chuck, I found this bug by testing.  You mistakenly removed setting the wr opcode for READ_WITH_INV above.

This fixed it:

@@ -319,6 +319,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
        read_wr.wr.sg_list = ctxt->sge;
        read_wr.wr.num_sge = 1;
        if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_READ_W_INV) {
+               read_wr.wr.opcode = IB_WR_RDMA_READ_WITH_INV;
                read_wr.wr.ex.invalidate_rkey = ctxt->frmr->mr->lkey;
        } else {
                read_wr.wr.opcode = IB_WR_RDMA_READ;

And with this patch, it tests out over iWARP/cxgb4.

Tested-by: Steve Wise <swise@opengridcomputing.com>


