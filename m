Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20221 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbdBIAT5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 19:19:57 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 12/12] sunrpc: Allow keepalive ping on a credit-full transport
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1486598713.11028.3.camel@primarydata.com>
Date: Wed, 8 Feb 2017 19:19:49 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9D6B8B44-9C23-427C-9E06-7C92302EB04D@oracle.com>
References: <20170208214854.7152.83331.stgit@manet.1015granger.net> <20170208220116.7152.87626.stgit@manet.1015granger.net> <1486598713.11028.3.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 8, 2017, at 7:05 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Wed, 2017-02-08 at 17:01 -0500, Chuck Lever wrote:
>> Allow RPC-over-RDMA to send NULL pings even when the transport has
>> hit its credit limit. One RPC-over-RDMA credit is reserved for
>> operations like keepalive.
>> 
>> For transports that convey NFSv4, it seems like lease renewal would
>> also be a candidate for using a priority transport slot. I'd like to
>> see a mechanism better than RPCRDMA_PRIORITY that can ensure only
>> one priority operation is in use at a time.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  include/linux/sunrpc/sched.h    |    2 ++
>>  net/sunrpc/xprt.c               |    4 ++++
>>  net/sunrpc/xprtrdma/transport.c |    3 ++-
>>  net/sunrpc/xprtrdma/verbs.c     |   13 ++++++++-----
>>  4 files changed, 16 insertions(+), 6 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/sched.h
>> b/include/linux/sunrpc/sched.h
>> index 13822e6..fcea158 100644
>> --- a/include/linux/sunrpc/sched.h
>> +++ b/include/linux/sunrpc/sched.h
>> @@ -127,6 +127,7 @@ struct rpc_task_setup {
>>  #define RPC_TASK_TIMEOUT	0x1000		/* fail with
>> ETIMEDOUT on timeout */
>>  #define RPC_TASK_NOCONNECT	0x2000		/* return
>> ENOTCONN if not connected */
>>  #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/*
>> wait forever for a reply */
>> +#define RPC_TASK_NO_CONG	0x8000		/* skip
>> congestion control */
>>  
>>  #define RPC_TASK_SOFTPING	(RPC_TASK_SOFT | RPC_TASK_SOFTCONN)
>>  
>> @@ -137,6 +138,7 @@ struct rpc_task_setup {
>>  #define RPC_IS_SOFT(t)		((t)->tk_flags &
>> (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
>>  #define RPC_IS_SOFTCONN(t)	((t)->tk_flags &
>> RPC_TASK_SOFTCONN)
>>  #define RPC_WAS_SENT(t)		((t)->tk_flags &
>> RPC_TASK_SENT)
>> +#define RPC_SKIP_CONG(t)	((t)->tk_flags & RPC_TASK_NO_CONG)
>>  
>>  #define RPC_TASK_RUNNING	0
>>  #define RPC_TASK_QUEUED		1
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index b530a28..a477ee6 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -392,6 +392,10 @@ static inline void xprt_release_write(struct
>> rpc_xprt *xprt, struct rpc_task *ta
>>  {
>>  	struct rpc_rqst *req = task->tk_rqstp;
>>  
>> +	if (RPC_SKIP_CONG(task)) {
>> +		req->rq_cong = 0;
>> +		return 1;
>> +	}
> 
> Why not just have the RDMA layer call xprt_reserve_xprt() (and
> xprt_release_xprt()) if this flag is set? It seems to me that you will
> need some kind of extra congestion control in the RDMA layer anyway
> since you only have one reserved credit for these privileged tasks (or
> did I miss where that is being gated?).

Thanks for the review.

See RPCRDMA_IA_RSVD_CREDIT in 11/12. It's a hack I'm not
terribly happy with.

So, I think you are suggesting replacing xprtrdma's
->reserve_xprt with something like:

int xprt_rdma_reserve_xprt(xprt, task)
{
      if (RPC_SKIP_CONG(task))
           return xprt_reserve_xprt(xprt, task);
      return xprt_reserve_xprt_cong(xprt, task);
}

and likewise for ->release_xprt ?

What I'd really like to do is have the RPC layer
prevent more than one RPC at a time from using the
extra credit, and somehow ensure that those RPCs
are going to be short-lived (SOFT | SOFTCONN,
maybe).


>>  	if (req->rq_cong)
>>  		return 1;
>>  	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd =
>> %lu\n",
>> diff --git a/net/sunrpc/xprtrdma/transport.c
>> b/net/sunrpc/xprtrdma/transport.c
>> index 3a5a805..073fecd 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -546,7 +546,8 @@ static void rpcrdma_keepalive_release(void
>> *calldata)
>>  
>>  	data = xprt_get(xprt);
>>  	null_task = rpc_call_null_helper(task->tk_client, xprt,
>> NULL,
>> -					 RPC_TASK_SOFTPING |
>> RPC_TASK_ASYNC,
>> +					 RPC_TASK_SOFTPING |
>> RPC_TASK_ASYNC |
>> +					 RPC_TASK_NO_CONG,
>>  					 &rpcrdma_keepalive_call_ops
>> , data);
>>  	if (!IS_ERR(null_task))
>>  		rpc_put_task(null_task);
>> diff --git a/net/sunrpc/xprtrdma/verbs.c
>> b/net/sunrpc/xprtrdma/verbs.c
>> index 81cd31a..d9b5fa7 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -136,19 +136,20 @@
>>  static void
>>  rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
>>  {
>> -	struct rpcrdma_msg *rmsgp = rdmab_to_msg(rep->rr_rdmabuf);
>>  	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
>> +	__be32 *p = rep->rr_rdmabuf->rg_base;
>>  	u32 credits;
>>  
>>  	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
>>  		return;
>>  
>> -	credits = be32_to_cpu(rmsgp->rm_credit);
>> +	credits = be32_to_cpup(p + 2);
>> +	if (credits > buffer->rb_max_requests)
>> +		credits = buffer->rb_max_requests;
>> +	/* Reserve one credit for keepalive ping */
>> +	credits--;
>>  	if (credits == 0)
>>  		credits = 1;	/* don't deadlock */
>> -	else if (credits > buffer->rb_max_requests)
>> -		credits = buffer->rb_max_requests;
>> -
>>  	atomic_set(&buffer->rb_credits, credits);
>>  }
>>  
>> @@ -915,6 +916,8 @@ struct rpcrdma_rep *
>>  	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>>  	int i, rc;
>>  
>> +	if (r_xprt->rx_data.max_requests < 2)
>> +		return -EINVAL;
>>  	buf->rb_max_requests = r_xprt->rx_data.max_requests;
>>  	buf->rb_bc_srv_max_requests = 0;
>>  	atomic_set(&buf->rb_credits, 1);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> -- 
> 
> 
> 	
> 	
> 
> 
> Trond Myklebust
> Principal System Architect
> 4300 El Camino Real | Suite 100
> Los Altos, CA  94022
> W: 650-422-3800
> C: 801-921-4583 
> www.primarydata.com

--
Chuck Lever



