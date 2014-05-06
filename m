Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:50882 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755382AbaEFVCu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 17:02:50 -0400
Message-ID: <53694DF1.5010808@opengridcomputing.com>
Date: Tue, 06 May 2014 16:02:41 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH V2 RFC 1/3] svcrdma: Transport and header file changes
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174626.18208.95519.stgit@build.ogc.int> <20140506192157.GJ18281@fieldses.org>
In-Reply-To: <20140506192157.GJ18281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/6/2014 2:21 PM, J. Bruce Fields wrote:
> On Tue, May 06, 2014 at 12:46:27PM -0500, Steve Wise wrote:
>> From: Tom Tucker <tom@opengridcomputing.com>
>>
>> Change poll logic to grab up to 6 completions at a time.
>>
>> RDMA write and send completions no longer deal with fastreg objects.
>>
>> Set SVCRDMA_DEVCAP_FAST_REG and allocate a dma_mr based on the device
>> capabilities.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>> ---
>>
>>   include/linux/sunrpc/svc_rdma.h          |    3 -
>>   net/sunrpc/xprtrdma/svc_rdma_transport.c |   62 +++++++++++++++++-------------
>>   2 files changed, 37 insertions(+), 28 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 0b8e3e6..5cf99a0 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -115,14 +115,13 @@ struct svc_rdma_fastreg_mr {
>>   	struct list_head frmr_list;
>>   };
>>   struct svc_rdma_req_map {
>> -	struct svc_rdma_fastreg_mr *frmr;
>>   	unsigned long count;
>>   	union {
>>   		struct kvec sge[RPCSVC_MAXPAGES];
>>   		struct svc_rdma_chunk_sge ch[RPCSVC_MAXPAGES];
>> +		unsigned long lkey[RPCSVC_MAXPAGES];
>>   	};
>>   };
>> -#define RDMACTXT_F_FAST_UNREG	1
>>   #define RDMACTXT_F_LAST_CTXT	2
>>   
>>   #define	SVCRDMA_DEVCAP_FAST_REG		1	/* fast mr registration */
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 25688fa..2c5b201 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -1,4 +1,5 @@
>>   /*
>> + * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>>    * Copyright (c) 2005-2007 Network Appliance, Inc. All rights reserved.
>>    *
>>    * This software is available to you under a choice of one of two
>> @@ -160,7 +161,6 @@ struct svc_rdma_req_map *svc_rdma_get_req_map(void)
>>   		schedule_timeout_uninterruptible(msecs_to_jiffies(500));
>>   	}
>>   	map->count = 0;
>> -	map->frmr = NULL;
>>   	return map;
>>   }
>>   
>> @@ -336,22 +336,21 @@ static void process_context(struct svcxprt_rdma *xprt,
>>   
>>   	switch (ctxt->wr_op) {
>>   	case IB_WR_SEND:
>> -		if (test_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags))
>> -			svc_rdma_put_frmr(xprt, ctxt->frmr);
>> +		BUG_ON(ctxt->frmr);
>>   		svc_rdma_put_context(ctxt, 1);
>>   		break;
>>   
>>   	case IB_WR_RDMA_WRITE:
>> +		BUG_ON(ctxt->frmr);
>>   		svc_rdma_put_context(ctxt, 0);
>>   		break;
>>   
>>   	case IB_WR_RDMA_READ:
>>   	case IB_WR_RDMA_READ_WITH_INV:
>> +		svc_rdma_put_frmr(xprt, ctxt->frmr);
>>   		if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
>>   			struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
>>   			BUG_ON(!read_hdr);
>> -			if (test_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags))
>> -				svc_rdma_put_frmr(xprt, ctxt->frmr);
>>   			spin_lock_bh(&xprt->sc_rq_dto_lock);
>>   			set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
>>   			list_add_tail(&read_hdr->dto_q,
>> @@ -363,6 +362,7 @@ static void process_context(struct svcxprt_rdma *xprt,
>>   		break;
>>   
>>   	default:
>> +		BUG_ON(1);
>>   		printk(KERN_ERR "svcrdma: unexpected completion type, "
>>   		       "opcode=%d\n",
>>   		       ctxt->wr_op);
> Note the printk's unreachable now.  Should some of these BUG_ON()'s be
> WARN_ON()'s?

I'll remove the printk.  And if any of the new BUG_ON()'s can be 
WARN_ON(), then I'll do that.  But only if proceeding after a WARN_ON() 
results in a working server.

>> @@ -378,29 +378,42 @@ static void process_context(struct svcxprt_rdma *xprt,
>>   static void sq_cq_reap(struct svcxprt_rdma *xprt)
>>   {
>>   	struct svc_rdma_op_ctxt *ctxt = NULL;
>> -	struct ib_wc wc;
>> +	struct ib_wc wc_a[6];
>> +	struct ib_wc *wc;
>>   	struct ib_cq *cq = xprt->sc_sq_cq;
>>   	int ret;
> May want to keep an eye on the stack usage here?

Ok.  Perhaps I'll put the array in the cvs_rdma_op_ctxt.


> --b.
>
>>   
>> +	memset(wc_a, 0, sizeof(wc_a));
>> +
>>   	if (!test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags))
>>   		return;
>>   
>>   	ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
>>   	atomic_inc(&rdma_stat_sq_poll);
>> -	while ((ret = ib_poll_cq(cq, 1, &wc)) > 0) {
>> -		if (wc.status != IB_WC_SUCCESS)
>> -			/* Close the transport */
>> -			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>> +	while ((ret = ib_poll_cq(cq, ARRAY_SIZE(wc_a), wc_a)) > 0) {
>> +		int i;
>>   
>> -		/* Decrement used SQ WR count */
>> -		atomic_dec(&xprt->sc_sq_count);
>> -		wake_up(&xprt->sc_send_wait);
>> +		for (i = 0; i < ret; i++) {
>> +			wc = &wc_a[i];
>> +			if (wc->status != IB_WC_SUCCESS) {
>> +				dprintk("svcrdma: sq wc err status %d\n",
>> +					wc->status);
>>   
>> -		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
>> -		if (ctxt)
>> -			process_context(xprt, ctxt);
>> +				/* Close the transport */
>> +				set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>> +			}
>>   
>> -		svc_xprt_put(&xprt->sc_xprt);
>> +			/* Decrement used SQ WR count */
>> +			atomic_dec(&xprt->sc_sq_count);
>> +			wake_up(&xprt->sc_send_wait);
>> +
>> +			ctxt = (struct svc_rdma_op_ctxt *)
>> +				(unsigned long)wc->wr_id;
>> +			if (ctxt)
>> +				process_context(xprt, ctxt);
>> +
>> +			svc_xprt_put(&xprt->sc_xprt);
>> +		}
>>   	}
>>   
>>   	if (ctxt)
>> @@ -993,7 +1006,11 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>   			need_dma_mr = 0;
>>   		break;
>>   	case RDMA_TRANSPORT_IB:
>> -		if (!(devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)) {
>> +		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
>> +			need_dma_mr = 1;
>> +			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>> +		} else if (!(devattr.device_cap_flags &
>> +			     IB_DEVICE_LOCAL_DMA_LKEY)) {
>>   			need_dma_mr = 1;
>>   			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>>   		} else
>> @@ -1190,14 +1207,7 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
>>   		container_of(xprt, struct svcxprt_rdma, sc_xprt);
>>   
>>   	/*
>> -	 * If there are fewer SQ WR available than required to send a
>> -	 * simple response, return false.
>> -	 */
>> -	if ((rdma->sc_sq_depth - atomic_read(&rdma->sc_sq_count) < 3))
>> -		return 0;
>> -
>> -	/*
>> -	 * ...or there are already waiters on the SQ,
>> +	 * If there are already waiters on the SQ,
>>   	 * return false.
>>   	 */
>>   	if (waitqueue_active(&rdma->sc_send_wait))
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

