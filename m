Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:34607 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660AbbAHQKk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 11:10:40 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 08/20] xprtrdma: Move credit update to RPC reply handler
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <54AEA7F3.5080802@Netapp.com>
Date: Thu, 8 Jan 2015 11:10:36 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FCFC2C87-4723-4E57-B1C1-A9F340D93914@oracle.com>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net> <20150107231252.13466.53108.stgit@manet.1015granger.net> <54AEA7F3.5080802@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 8, 2015, at 10:53 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hey Chuck,
> 
> On 01/07/2015 06:12 PM, Chuck Lever wrote:
>> Reduce work in the receive CQ handler, which is run at hardware
>> interrupt level, by moving the RPC/RDMA credit update logic to the
>> RPC reply handler.
>> 
>> This has some additional benefits: More header sanity checking is
>> done before trusting the incoming credit value, and the receive CQ
>> handler no longer touches the RPC/RDMA header. Finally, no longer
>> any need to update and read rb_credits atomically, so the rb_credits
>> field can be removed.
>> 
>> This further extends work begun by commit e7ce710a8802 ("xprtrdma:
>> Avoid deadlock when credit window is reset").
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/rpc_rdma.c  |   10 ++++++++--
>> net/sunrpc/xprtrdma/verbs.c     |   15 ++-------------
>> net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
>> 3 files changed, 10 insertions(+), 16 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index dcf5ebc..d731010 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -736,7 +736,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>> 	struct rpc_xprt *xprt = rep->rr_xprt;
>> 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>> 	__be32 *iptr;
>> -	int rdmalen, status;
>> +	int credits, rdmalen, status;
>> 	unsigned long cwnd;
>> 
>> 	/* Check status. If bad, signal disconnect and return rep to pool */
>> @@ -871,8 +871,14 @@ badheader:
>> 		break;
>> 	}
>> 
>> +	credits = be32_to_cpu(headerp->rm_credit);
>> +	if (credits == 0)
>> +		credits = 1;	/* don't deadlock */
>> +	else if (credits > r_xprt->rx_buf.rb_max_requests)
>> +		credits = r_xprt->rx_buf.rb_max_requests;
> 
> Can rb_max_requests ever drop to 0?

rb_max_requests is set at mount time to xprt_rdma_slot_table_entries.
rb_max_requests is not changed again.

xprt_rdma_slot_table_entries is set to a compile-time constant,
but can be changed via a /proc file setting. The lower and upper
bounds are min_slot_table_size and max_slot_table_size, both set
to compile-time constants.

IMO there’s no practical danger rb_max_requests will ever be zero
unless someone makes a coding mistake.

Did you want me to reverse the order of the if conditions as a
defensive coding measure?


> Anna
> 
>> +
>> 	cwnd = xprt->cwnd;
>> -	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
>> +	xprt->cwnd = credits << RPC_CWNDSHIFT;
>> 	if (xprt->cwnd > cwnd)
>> 		xprt_release_rqst_cong(rqst->rq_task);
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 1000f63..71a071a 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -49,6 +49,7 @@
>> 
>> #include <linux/interrupt.h>
>> #include <linux/slab.h>
>> +#include <linux/prefetch.h>
>> #include <asm/bitops.h>
>> 
>> #include "xprt_rdma.h"
>> @@ -298,17 +299,7 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
>> 	rep->rr_len = wc->byte_len;
>> 	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
>> 			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
>> -
>> -	if (rep->rr_len >= 16) {
>> -		struct rpcrdma_msg *p = (struct rpcrdma_msg *)rep->rr_base;
>> -		unsigned int credits = ntohl(p->rm_credit);
>> -
>> -		if (credits == 0)
>> -			credits = 1;	/* don't deadlock */
>> -		else if (credits > rep->rr_buffer->rb_max_requests)
>> -			credits = rep->rr_buffer->rb_max_requests;
>> -		atomic_set(&rep->rr_buffer->rb_credits, credits);
>> -	}
>> +	prefetch(rep->rr_base);
>> 
>> out_schedule:
>> 	list_add_tail(&rep->rr_list, sched_list);
>> @@ -480,7 +471,6 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
>> 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
>> 		connstate = -ENODEV;
>> connected:
>> -		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
>> 		dprintk("RPC:       %s: %sconnected\n",
>> 					__func__, connstate > 0 ? "" : "dis");
>> 		ep->rep_connected = connstate;
>> @@ -1186,7 +1176,6 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
>> 
>> 	buf->rb_max_requests = cdata->max_requests;
>> 	spin_lock_init(&buf->rb_lock);
>> -	atomic_set(&buf->rb_credits, 1);
>> 
>> 	/* Need to allocate:
>> 	 *   1.  arrays for send and recv pointers
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index 532d586..3fcc92b 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -248,7 +248,6 @@ struct rpcrdma_req {
>>  */
>> struct rpcrdma_buffer {
>> 	spinlock_t	rb_lock;	/* protects indexes */
>> -	atomic_t	rb_credits;	/* most recent server credits */
>> 	int		rb_max_requests;/* client max requests */
>> 	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
>> 	struct list_head rb_all;
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



