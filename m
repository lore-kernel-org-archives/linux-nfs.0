Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:44420 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343AbaDPMsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 08:48:32 -0400
Received: by mail-we0-f171.google.com with SMTP id t61so10884768wes.30
        for <linux-nfs@vger.kernel.org>; Wed, 16 Apr 2014 05:48:30 -0700 (PDT)
Message-ID: <534E7C1C.5070407@dev.mellanox.co.il>
Date: Wed, 16 Apr 2014 15:48:28 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net>
In-Reply-To: <20140414222323.20646.66946.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/15/2014 1:23 AM, Chuck Lever wrote:
> The current CQ handler uses the ib_wc.opcode field to distinguish
> between event types. However, the contents of that field are not
> reliable if the completion status is not IB_WC_SUCCESS.
>
> When an error completion occurs on a send event, the CQ handler
> schedules a tasklet with something that is not a struct rpcrdma_rep.
> This is never correct behavior, and sometimes it results in a panic.
>
> To resolve this issue, split the completion queue into a send CQ and
> a receive CQ. The send CQ handler now handles only struct rpcrdma_mw
> wr_id's, and the receive CQ handler now handles only struct
> rpcrdma_rep wr_id's.

Hey Chuck,

So 2 suggestions related (although not directly) to this one.

1. I recommend suppressing Fastreg completions - no one cares that they 
succeeded.

2. If I understood correctly, I see that the CQs are loop-polled in an 
interrupt context.
     This may become problematic in stress workload where the CQ simply 
never drains (imagine
     some studios task keeps posting WRs as soon as IOs complete). This 
will cause CQ poll loop
     to go on forever. This situation may cause starvation of other CQs 
that share the same EQ (CPU
     is hogged by the endless poller).
     This may be solved in 2 ways:
     - Use blk-iopoll to maintain fairness - the downside will be moving 
from interrupt context to soft-irq (slower).
     - Set some configurable budget to CQ poller - after finishing the 
budget, notify the CQ and bail.
       If there is another CQ waiting to get in - it's only fair that it 
will be given with a chance, else another interrupt
       on that CQ will immediately come.

     I noticed that one with iSER which polls from tasklet context 
(under heavy workload).

Sagi.

> Fix suggested by Shirley Ma <shirley.ma@oracle.com>
>
> Reported-by: Rafael Reiter <rafael.reiter@ims.co.at>
> Fixes: 5c635e09cec0feeeb310968e51dad01040244851
> BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=73211
> Tested-by: Klemens Senn <klemens.senn@ims.co.at>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>
>   net/sunrpc/xprtrdma/verbs.c     |  228 +++++++++++++++++++++++----------------
>   net/sunrpc/xprtrdma/xprt_rdma.h |    1
>   2 files changed, 135 insertions(+), 94 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 0f8c22c..35f5ab6 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -142,96 +142,113 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
>   	}
>   }
>   
> -static inline
> -void rpcrdma_event_process(struct ib_wc *wc)
> +static void
> +rpcrdma_send_event_process(struct ib_wc *wc)
>   {
> -	struct rpcrdma_mw *frmr;
> -	struct rpcrdma_rep *rep =
> -			(struct rpcrdma_rep *)(unsigned long) wc->wr_id;
> +	struct rpcrdma_mw *frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
>   
> -	dprintk("RPC:       %s: event rep %p status %X opcode %X length %u\n",
> -		__func__, rep, wc->status, wc->opcode, wc->byte_len);
> +	dprintk("RPC:       %s: frmr %p status %X opcode %d\n",
> +		__func__, frmr, wc->status, wc->opcode);
>   
> -	if (!rep) /* send completion that we don't care about */
> +	if (wc->wr_id == 0ULL)
>   		return;
> -
> -	if (IB_WC_SUCCESS != wc->status) {
> -		dprintk("RPC:       %s: WC opcode %d status %X, connection lost\n",
> -			__func__, wc->opcode, wc->status);
> -		rep->rr_len = ~0U;
> -		if (wc->opcode != IB_WC_FAST_REG_MR && wc->opcode != IB_WC_LOCAL_INV)
> -			rpcrdma_schedule_tasklet(rep);
> +	if (wc->status != IB_WC_SUCCESS)
>   		return;
> -	}
>   
> -	switch (wc->opcode) {
> -	case IB_WC_FAST_REG_MR:
> -		frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
> +	if (wc->opcode == IB_WC_FAST_REG_MR)
>   		frmr->r.frmr.state = FRMR_IS_VALID;
> -		break;
> -	case IB_WC_LOCAL_INV:
> -		frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
> +	else if (wc->opcode == IB_WC_LOCAL_INV)
>   		frmr->r.frmr.state = FRMR_IS_INVALID;
> -		break;
> -	case IB_WC_RECV:
> -		rep->rr_len = wc->byte_len;
> -		ib_dma_sync_single_for_cpu(
> -			rdmab_to_ia(rep->rr_buffer)->ri_id->device,
> -			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
> -		/* Keep (only) the most recent credits, after check validity */
> -		if (rep->rr_len >= 16) {
> -			struct rpcrdma_msg *p =
> -					(struct rpcrdma_msg *) rep->rr_base;
> -			unsigned int credits = ntohl(p->rm_credit);
> -			if (credits == 0) {
> -				dprintk("RPC:       %s: server"
> -					" dropped credits to 0!\n", __func__);
> -				/* don't deadlock */
> -				credits = 1;
> -			} else if (credits > rep->rr_buffer->rb_max_requests) {
> -				dprintk("RPC:       %s: server"
> -					" over-crediting: %d (%d)\n",
> -					__func__, credits,
> -					rep->rr_buffer->rb_max_requests);
> -				credits = rep->rr_buffer->rb_max_requests;
> -			}
> -			atomic_set(&rep->rr_buffer->rb_credits, credits);
> -		}
> -		rpcrdma_schedule_tasklet(rep);
> -		break;
> -	default:
> -		dprintk("RPC:       %s: unexpected WC event %X\n",
> -			__func__, wc->opcode);
> -		break;
> -	}
>   }
>   
> -static inline int
> -rpcrdma_cq_poll(struct ib_cq *cq)
> +static int
> +rpcrdma_sendcq_poll(struct ib_cq *cq)
>   {
>   	struct ib_wc wc;
>   	int rc;
>   
> -	for (;;) {
> -		rc = ib_poll_cq(cq, 1, &wc);
> -		if (rc < 0) {
> -			dprintk("RPC:       %s: ib_poll_cq failed %i\n",
> -				__func__, rc);
> -			return rc;
> -		}
> -		if (rc == 0)
> -			break;
> +	while ((rc = ib_poll_cq(cq, 1, &wc)) == 1)
> +		rpcrdma_send_event_process(&wc);
> +	return rc;
> +}
>   
> -		rpcrdma_event_process(&wc);
> +/*
> + * Handle send, fast_reg_mr, and local_inv completions.
> + *
> + * Send events are typically suppressed and thus do not result
> + * in an upcall. Occasionally one is signaled, however. This
> + * prevents the provider's completion queue from wrapping and
> + * losing a completion.
> + */
> +static void
> +rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
> +{
> +	int rc;
> +
> +	rc = rpcrdma_sendcq_poll(cq);
> +	if (rc) {
> +		dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> +			__func__, rc);
> +		return;
>   	}
> +	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
> +	if (rc) {
> +		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
> +			__func__, rc);
> +		return;
> +	}
> +	rpcrdma_sendcq_poll(cq);
> +}
>   
> -	return 0;
> +static void
> +rpcrdma_recv_event_process(struct ib_wc *wc)
> +{
> +	struct rpcrdma_rep *rep =
> +			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
> +
> +	dprintk("RPC:       %s: rep %p status %X opcode %X length %u\n",
> +		__func__, rep, wc->status, wc->opcode, wc->byte_len);
> +
> +	if (wc->status != IB_WC_SUCCESS) {
> +		rep->rr_len = ~0U;
> +		goto out_schedule;
> +	}
> +	if (wc->opcode != IB_WC_RECV)
> +		return;
> +
> +	rep->rr_len = wc->byte_len;
> +	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
> +			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
> +
> +	if (rep->rr_len >= 16) {
> +		struct rpcrdma_msg *p = (struct rpcrdma_msg *)rep->rr_base;
> +		unsigned int credits = ntohl(p->rm_credit);
> +
> +		if (credits == 0)
> +			credits = 1;	/* don't deadlock */
> +		else if (credits > rep->rr_buffer->rb_max_requests)
> +			credits = rep->rr_buffer->rb_max_requests;
> +		atomic_set(&rep->rr_buffer->rb_credits, credits);
> +	}
> +
> +out_schedule:
> +	rpcrdma_schedule_tasklet(rep);
> +}
> +
> +static int
> +rpcrdma_recvcq_poll(struct ib_cq *cq)
> +{
> +	struct ib_wc wc;
> +	int rc;
> +
> +	while ((rc = ib_poll_cq(cq, 1, &wc)) == 1)
> +		rpcrdma_recv_event_process(&wc);
> +	return rc;
>   }
>   
>   /*
> - * rpcrdma_cq_event_upcall
> + * Handle receive completions.
>    *
> - * This upcall handles recv and send events.
>    * It is reentrant but processes single events in order to maintain
>    * ordering of receives to keep server credits.
>    *
> @@ -240,26 +257,25 @@ rpcrdma_cq_poll(struct ib_cq *cq)
>    * connection shutdown. That is, the structures required for
>    * the completion of the reply handler must remain intact until
>    * all memory has been reclaimed.
> - *
> - * Note that send events are suppressed and do not result in an upcall.
>    */
>   static void
> -rpcrdma_cq_event_upcall(struct ib_cq *cq, void *context)
> +rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
>   {
>   	int rc;
>   
> -	rc = rpcrdma_cq_poll(cq);
> -	if (rc)
> +	rc = rpcrdma_recvcq_poll(cq);
> +	if (rc) {
> +		dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
> +			__func__, rc);
>   		return;
> -
> +	}
>   	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
>   	if (rc) {
> -		dprintk("RPC:       %s: ib_req_notify_cq failed %i\n",
> +		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
>   			__func__, rc);
>   		return;
>   	}
> -
> -	rpcrdma_cq_poll(cq);
> +	rpcrdma_recvcq_poll(cq);
>   }
>   
>   #ifdef RPC_DEBUG
> @@ -613,6 +629,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>   				struct rpcrdma_create_data_internal *cdata)
>   {
>   	struct ib_device_attr devattr;
> +	struct ib_cq *sendcq, *recvcq;
>   	int rc, err;
>   
>   	rc = ib_query_device(ia->ri_id->device, &devattr);
> @@ -688,7 +705,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>   		ep->rep_attr.cap.max_recv_sge);
>   
>   	/* set trigger for requesting send completion */
> -	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 /*  - 1*/;
> +	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
>   	if (ep->rep_cqinit <= 2)
>   		ep->rep_cqinit = 0;
>   	INIT_CQCOUNT(ep);
> @@ -696,26 +713,43 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>   	init_waitqueue_head(&ep->rep_connect_wait);
>   	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
>   
> -	ep->rep_cq = ib_create_cq(ia->ri_id->device, rpcrdma_cq_event_upcall,
> +	sendcq = ib_create_cq(ia->ri_id->device, rpcrdma_sendcq_upcall,
>   				  rpcrdma_cq_async_error_upcall, NULL,
> -				  ep->rep_attr.cap.max_recv_wr +
>   				  ep->rep_attr.cap.max_send_wr + 1, 0);
> -	if (IS_ERR(ep->rep_cq)) {
> -		rc = PTR_ERR(ep->rep_cq);
> -		dprintk("RPC:       %s: ib_create_cq failed: %i\n",
> +	if (IS_ERR(sendcq)) {
> +		rc = PTR_ERR(sendcq);
> +		dprintk("RPC:       %s: failed to create send CQ: %i\n",
>   			__func__, rc);
>   		goto out1;
>   	}
>   
> -	rc = ib_req_notify_cq(ep->rep_cq, IB_CQ_NEXT_COMP);
> +	rc = ib_req_notify_cq(sendcq, IB_CQ_NEXT_COMP);
>   	if (rc) {
>   		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
>   			__func__, rc);
>   		goto out2;
>   	}
>   
> -	ep->rep_attr.send_cq = ep->rep_cq;
> -	ep->rep_attr.recv_cq = ep->rep_cq;
> +	recvcq = ib_create_cq(ia->ri_id->device, rpcrdma_recvcq_upcall,
> +				  rpcrdma_cq_async_error_upcall, NULL,
> +				  ep->rep_attr.cap.max_recv_wr + 1, 0);
> +	if (IS_ERR(recvcq)) {
> +		rc = PTR_ERR(recvcq);
> +		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
> +			__func__, rc);
> +		goto out2;
> +	}
> +
> +	rc = ib_req_notify_cq(recvcq, IB_CQ_NEXT_COMP);
> +	if (rc) {
> +		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
> +			__func__, rc);
> +		ib_destroy_cq(recvcq);
> +		goto out2;
> +	}
> +
> +	ep->rep_attr.send_cq = sendcq;
> +	ep->rep_attr.recv_cq = recvcq;
>   
>   	/* Initialize cma parameters */
>   
> @@ -737,7 +771,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>   	return 0;
>   
>   out2:
> -	err = ib_destroy_cq(ep->rep_cq);
> +	err = ib_destroy_cq(sendcq);
>   	if (err)
>   		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
>   			__func__, err);
> @@ -777,8 +811,14 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
>   		ep->rep_pad_mr = NULL;
>   	}
>   
> -	rpcrdma_clean_cq(ep->rep_cq);
> -	rc = ib_destroy_cq(ep->rep_cq);
> +	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
> +	rc = ib_destroy_cq(ep->rep_attr.recv_cq);
> +	if (rc)
> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
> +			__func__, rc);
> +
> +	rpcrdma_clean_cq(ep->rep_attr.send_cq);
> +	rc = ib_destroy_cq(ep->rep_attr.send_cq);
>   	if (rc)
>   		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
>   			__func__, rc);
> @@ -801,7 +841,9 @@ retry:
>   		if (rc && rc != -ENOTCONN)
>   			dprintk("RPC:       %s: rpcrdma_ep_disconnect"
>   				" status %i\n", __func__, rc);
> -		rpcrdma_clean_cq(ep->rep_cq);
> +
> +		rpcrdma_clean_cq(ep->rep_attr.recv_cq);
> +		rpcrdma_clean_cq(ep->rep_attr.send_cq);
>   
>   		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
>   		id = rpcrdma_create_id(xprt, ia,
> @@ -910,7 +952,8 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
>   {
>   	int rc;
>   
> -	rpcrdma_clean_cq(ep->rep_cq);
> +	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
> +	rpcrdma_clean_cq(ep->rep_attr.send_cq);
>   	rc = rdma_disconnect(ia->ri_id);
>   	if (!rc) {
>   		/* returns without wait if not connected */
> @@ -1793,7 +1836,6 @@ rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
>   	ib_dma_sync_single_for_cpu(ia->ri_id->device,
>   		rep->rr_iov.addr, rep->rr_iov.length, DMA_BIDIRECTIONAL);
>   
> -	DECR_CQCOUNT(ep);
>   	rc = ib_post_recv(ia->ri_id->qp, &recv_wr, &recv_wr_fail);
>   
>   	if (rc)
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 362a19d..334ab6e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -79,7 +79,6 @@ struct rpcrdma_ep {
>   	int			rep_cqinit;
>   	int			rep_connected;
>   	struct rpcrdma_ia	*rep_ia;
> -	struct ib_cq		*rep_cq;
>   	struct ib_qp_init_attr	rep_attr;
>   	wait_queue_head_t 	rep_connect_wait;
>   	struct ib_sge		rep_pad;	/* holds zeroed pad */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

