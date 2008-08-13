From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] svcrdma: Fix race between svc_rdma_recvfrom thread and
 the dto_tasklet
Date: Wed, 13 Aug 2008 16:31:42 -0500
Message-ID: <48A352BE.1080204@opengridcomputing.com>
References: <48A30655.3070208@opengridcomputing.com> <20080813211018.GM26765@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48448 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbYHMVbm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 17:31:42 -0400
In-Reply-To: <20080813211018.GM26765@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 11:05:41AM -0500, Tom Tucker wrote:
>> RDMA_READ completions are kept on a separate queue from the general
>> I/O request queue. Since a separate lock is used to protect the RDMA_READ
>> completion queue, a race exists between the dto_tasklet and the
>> svc_rdma_recvfrom thread where the dto_tasklet sets the XPT_DATA
>> bit and adds I/O to the read-completion queue. Concurrently, the
>> recvfrom thread checks the generic queue, finds it empty and resets
>> the XPT_DATA bit. A subsequent svc_xprt_enqueue will fail to enqueue
>> the transport for I/O and cause the transport to "stall".
>>
>> The fix is to protect both lists with the same lock and set the XPT_DATA
>> bit with this lock held.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> OK.  As a bugfix, would you like this sent in now for 2.6.27?
> 

Yes I would if that's possible. I put it before all the other patches so it
would be independent.

Thanks,
Tom

> --b.
> 
>> ---
>> include/linux/sunrpc/svc_rdma.h          |    1 -
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    8 ++++----
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++---
>> 3 files changed, 6 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index ef2e3a2..dc05b54 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -143,7 +143,6 @@ struct svcxprt_rdma {
>> 	unsigned long	     sc_flags;
>> 	struct list_head     sc_dto_q;		/* DTO tasklet I/O pending Q */
>> 	struct list_head     sc_read_complete_q;
>> -	spinlock_t           sc_read_complete_lock;
>> 	struct work_struct   sc_work;
>> };
>> /* sc_flags */
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index b4b17f4..74de31a 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -443,18 +443,18 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>>
>> 	dprintk("svcrdma: rqstp=%p\n", rqstp);
>>
>> -	spin_lock_bh(&rdma_xprt->sc_read_complete_lock);
>> +	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
>> 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
>> 		ctxt = list_entry(rdma_xprt->sc_read_complete_q.next,
>> 				  struct svc_rdma_op_ctxt,
>> 				  dto_q);
>> 		list_del_init(&ctxt->dto_q);
>> 	}
>> -	spin_unlock_bh(&rdma_xprt->sc_read_complete_lock);
>> -	if (ctxt)
>> +	if (ctxt) {
>> +		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
>> 		return rdma_read_complete(rqstp, ctxt);
>> +	}
>>
>> -	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
>> 	if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
>> 		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
>> 				  struct svc_rdma_op_ctxt,
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 19ddc38..900cb69 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -359,11 +359,11 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
>> 			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
>> 				struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
>> 				BUG_ON(!read_hdr);
>> +				spin_lock_bh(&xprt->sc_rq_dto_lock);
>> 				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
>> -				spin_lock_bh(&xprt->sc_read_complete_lock);
>> 				list_add_tail(&read_hdr->dto_q,
>> 					      &xprt->sc_read_complete_q);
>> -				spin_unlock_bh(&xprt->sc_read_complete_lock);
>> +				spin_unlock_bh(&xprt->sc_rq_dto_lock);
>> 				svc_xprt_enqueue(&xprt->sc_xprt);
>> 			}
>> 			svc_rdma_put_context(ctxt, 0);
>> @@ -428,7 +428,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
>> 	init_waitqueue_head(&cma_xprt->sc_send_wait);
>>
>> 	spin_lock_init(&cma_xprt->sc_lock);
>> -	spin_lock_init(&cma_xprt->sc_read_complete_lock);
>> 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
>>
>> 	cma_xprt->sc_ord = svcrdma_ord;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

