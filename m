From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  2/17] svcrdma: Fix race with dto_tasklet in
 svc_rdma_send
Date: Mon, 05 May 2008 21:26:02 -0500
Message-ID: <C4452BEA.4959F%tom@opengridcomputing.com>
References: <20080505220636.GG12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:11855 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754491AbYEFC0P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 22:26:15 -0400
In-Reply-To: <20080505220636.GG12814@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/5/08 5:06 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 02, 2008 at 11:28:34AM -0500, Tom Tucker wrote:
>> The svc_rdma_send function will attempt to reap SQ WR to make room for
>> a new request if it finds the SQ full. This function races with the
>> dto_tasklet that also reaps SQ WR. To avoid calling the function
>> unnecessarily use test_and_clear_bit with the RDMAXPRT_SQ_PENDING
>> flag to serialize access to the sq_cq_reap function.
> 
> OK.  I won't pretend to understand much of this, but--would it be worth
> pulling out the added code here into a helper function, since it now
> exists in two different places?  (Especially if correctness depends on
> the same thing happening in both the places this bit can be cleared.)

Yes. Good suggestions.

BTW, this code is here because the SQ is undersized for big data. Since a
single NFS_READ/WRITE can result in an attempt to fetch a large amount of
data from the client (2M) and depending on certain HW resources this can
result in a lot of WR being posted to the SQ.

That said, there is a change coming in the 2.6.27 time frame that supports
what is called Fast NSMR register. This allows the transport to effectively
DMA map the entire transfer size (32k -- 2M) all as a single SGE. This will
take a lot of pressure off the SQ and effectively make this code
unnecessary.

> 
> --b.
> 
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> 
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 ++++++--
>>  1 files changed, 6 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 1e0af2f..14f83a1 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -1010,8 +1010,12 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct
>> ib_send_wr *wr)
>> if (xprt->sc_sq_depth == atomic_read(&xprt->sc_sq_count)) {
>> spin_unlock_bh(&xprt->sc_lock);
>> atomic_inc(&rdma_stat_sq_starve);
>> -   /* See if we can reap some SQ WR */
>> -   sq_cq_reap(xprt);
>> +
>> +   /* See if we can opportunistically reap SQ WR to make room */
>> +   if (test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags)) {
>> +    ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
>> +    sq_cq_reap(xprt);
>> +   }
>>  
>> /* Wait until SQ WR available if SQ still full */
>> wait_event(xprt->sc_send_wait,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


