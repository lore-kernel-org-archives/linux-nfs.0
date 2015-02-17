Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:56934 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbbBQOTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 09:19:34 -0500
Message-ID: <54E34DF4.1010003@Netapp.com>
Date: Tue, 17 Feb 2015 09:19:32 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] xprtrdma: Store RDMA credits in unsigned variables
References: <20150212151451.18290.89745.stgit@manet.1015granger.net> <1423867419.18925.0.camel@primarydata.com>
In-Reply-To: <1423867419.18925.0.camel@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/13/2015 05:43 PM, Trond Myklebust wrote:
> On Thu, 2015-02-12 at 10:14 -0500, Chuck Lever wrote:
>> Dan Carpenter's static checker pointed out:
>>
>>    net/sunrpc/xprtrdma/rpc_rdma.c:879 rpcrdma_reply_handler()
>>    warn: can 'credits' be negative?
>>
>> "credits" is defined as an int. The credits value comes from the
>> server as a 32-bit unsigned integer.
>>
>> A malicious or broken server can plant a large unsigned integer in
>> that field which would result in an underflow in the following
>> logic, potentially triggering a deadlock of the mount point by
>> blocking the client from issuing more RPC requests.
>>
>> net/sunrpc/xprtrdma/rpc_rdma.c:
>>
>>   876          credits = be32_to_cpu(headerp->rm_credit);
>>   877          if (credits == 0)
>>   878                  credits = 1;    /* don't deadlock */
>>   879          else if (credits > r_xprt->rx_buf.rb_max_requests)
>>   880                  credits = r_xprt->rx_buf.rb_max_requests;
>>   881
>>   882          cwnd = xprt->cwnd;
>>   883          xprt->cwnd = credits << RPC_CWNDSHIFT;
>>   884          if (xprt->cwnd > cwnd)
>>   885                  xprt_release_rqst_cong(rqst->rq_task);
>>
>> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>> Fixes: eba8ff660b2d ("xprtrdma: Move credit update to RPC . . .")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  net/sunrpc/xprtrdma/rpc_rdma.c  |    3 ++-
>>  net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>>  2 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index 7e9acd9..91ffde8 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -738,8 +738,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>  	struct rpc_xprt *xprt = rep->rr_xprt;
>>  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>>  	__be32 *iptr;
>> -	int credits, rdmalen, status;
>> +	int rdmalen, status;
>>  	unsigned long cwnd;
>> +	u32 credits;
>>  
>>  	/* Check status. If bad, signal disconnect and return rep to pool */
>>  	if (rep->rr_len == ~0U) {
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index d1b7039..0a16fb6 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -285,7 +285,7 @@ rpcr_to_rdmar(struct rpc_rqst *rqst)
>>   */
>>  struct rpcrdma_buffer {
>>  	spinlock_t	rb_lock;	/* protects indexes */
>> -	int		rb_max_requests;/* client max requests */
>> +	u32		rb_max_requests;/* client max requests */
>>  	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
>>  	struct list_head rb_all;
>>  	int		rb_send_index;
>>
> 
> Anna, do you want me to take this one directly, or are you preparing a
> pull request?

I'll make a pull request.

Thanks,
Anna
> 
> Cheers
>   Trond
> 

