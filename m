From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 04/10] svcrdma: Add a service to register a Fast Reg MR
 with the device
Date: Thu, 25 Sep 2008 08:31:17 -0500
Message-ID: <48DB92A5.7070003@opengridcomputing.com>
References: <1221564879-85046-1-git-send-email-tom@opengridcomputing.com> <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com> <1221564879-85046-4-git-send-email-tom@opengridcomputing.com> <1221564879-85046-5-git-send-email-tom@opengridcomputing.com> <20080924202556.GB10841@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44953 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbYIYNbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 09:31:18 -0400
In-Reply-To: <20080924202556.GB10841@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Sep 16, 2008 at 06:34:33AM -0500, Tom Tucker wrote:
>> Fast Reg MR introduces a new WR type. Add a service to register the
>> region with the adapter and update the completion handling to support
>> completions with a NULL WR context.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>
>> ---
>>  include/linux/sunrpc/svc_rdma.h          |    1 +
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   53 ++++++++++++++++++++++++++---
>>  2 files changed, 48 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 100754e..6899b71 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -219,6 +219,7 @@ extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
>>  extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
>>  extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
>> +extern int svc_rdma_fastreg(struct svcxprt_rdma *, struct svc_rdma_fastreg_mr *);
>>  extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
>>  extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
>>  			      struct svc_rdma_fastreg_mr *);
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 8586c7d..b8c642d 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -344,10 +344,6 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
>>  	ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
>>  	atomic_inc(&rdma_stat_sq_poll);
>>  	while ((ret = ib_poll_cq(cq, 1, &wc)) > 0) {
>> -		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
>> -		xprt = ctxt->xprt;
> 
> So this assignment to xprt was always unnecessary?
> 

Yes, the correct xprt is passed in as an argument.

BUG_ON(ctxt->xprt != xprt)

>> -
>> -		svc_rdma_unmap_dma(ctxt);
>>  		if (wc.status != IB_WC_SUCCESS)
>>  			/* Close the transport */
>>  			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
>> @@ -356,6 +352,11 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
>>  		atomic_dec(&xprt->sc_sq_count);
>>  		wake_up(&xprt->sc_send_wait);
>>  
>> +		ctxt = (struct svc_rdma_op_ctxt *)(unsigned long)wc.wr_id;
>> +		if (!ctxt)
>> +			goto skip_it;
>> +		svc_rdma_unmap_dma(ctxt);
>> +
>>  		switch (ctxt->wr_op) {
>>  		case IB_WR_SEND:
>>  			svc_rdma_put_context(ctxt, 1);
>> @@ -385,6 +386,7 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
>>  			       wc.opcode, wc.status);
>>  			break;
>>  		}
>> +	skip_it:
> 
> That big switch we just goto'd over might be a candidate for
> encapsulating in a separate function.

Yes, you're right, that would look better.

> 
> --b.
> 
>>  		svc_xprt_put(&xprt->sc_xprt);
>>  	}
>>  
>> @@ -1203,6 +1205,47 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
>>  	return 1;
>>  }
>>  
>> +/*
>> + * Attempt to register the kvec representing the RPC memory with the
>> + * device.
>> + *
>> + * Returns:
>> + *  NULL : The device does not support fastreg or there were no more
>> + *         fastreg mr.
>> + *  frmr : The kvec register request was successfully posted.
>> + *    <0 : An error was encountered attempting to register the kvec.
>> + */
>> +int svc_rdma_fastreg(struct svcxprt_rdma *xprt,
>> +		     struct svc_rdma_fastreg_mr *frmr)
>> +{
>> +	struct ib_send_wr fastreg_wr;
>> +	u8 key;
>> +	int ret;
>> +
>> +	/* Bump the key */
>> +	key = (u8)(frmr->mr->lkey & 0x000000FF);
>> +	ib_update_fast_reg_key(frmr->mr, ++key);
>> +
>> +	/* Prepare FASTREG WR */
>> +	memset(&fastreg_wr, 0, sizeof fastreg_wr);
>> +	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
>> +	fastreg_wr.send_flags = IB_SEND_SIGNALED;
>> +	fastreg_wr.wr.fast_reg.iova_start = (unsigned long)frmr->kva;
>> +	fastreg_wr.wr.fast_reg.page_list = frmr->page_list;
>> +	fastreg_wr.wr.fast_reg.page_list_len = frmr->page_list_len;
>> +	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
>> +	fastreg_wr.wr.fast_reg.length = frmr->map_len;
>> +	fastreg_wr.wr.fast_reg.access_flags = frmr->access_flags;
>> +	fastreg_wr.wr.fast_reg.rkey = frmr->mr->lkey;
>> +	ret = svc_rdma_send(xprt, &fastreg_wr);
>> +	dprintk("svcrdma:%s: reg lkey %08x kva %p mrlen %lu pages %d ret %d\n",
>> +		__func__, frmr->mr->lkey, frmr->kva, frmr->map_len,
>> +		frmr->page_list_len,
>> +		ret);
>> +
>> +	return ret;
>> +}
>> +
>>  int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
>>  {
>>  	struct ib_send_wr *bad_wr;
>> @@ -1212,8 +1255,6 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
>>  		return -ENOTCONN;
>>  
>>  	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
>> -	BUG_ON(((struct svc_rdma_op_ctxt *)(unsigned long)wr->wr_id)->wr_op !=
>> -		wr->opcode);
>>  	/* If the SQ is full, wait until an SQ entry is available */
>>  	while (1) {
>>  		spin_lock_bh(&xprt->sc_lock);

