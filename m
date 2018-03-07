Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:52971 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934877AbeCGUAJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 15:00:09 -0500
Subject: Re: [PATCH 5/9] SUNRPC: Initialize rpc_rqst outside of
 xprt->reserve_lock
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
 <20180305201318.10904.57825.stgit@manet.1015granger.net>
 <4dd8259a-e447-122b-c267-75e2e6b4714e@Netapp.com>
 <FA9A696D-3702-43DB-8FBA-E924B54E0F28@oracle.com>
 <41538F44-115C-4F64-9BCA-0A6B8723A9F5@oracle.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <9ac7ea34-d409-da6a-21cb-35fa6e09cd66@Netapp.com>
Date: Wed, 7 Mar 2018 15:00:01 -0500
MIME-Version: 1.0
In-Reply-To: <41538F44-115C-4F64-9BCA-0A6B8723A9F5@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/06/2018 05:30 PM, Chuck Lever wrote:
> 
> 
>> On Mar 6, 2018, at 5:07 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>
>>
>>> On Mar 6, 2018, at 5:02 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>>
>>> Hi Chuck,
>>>
>>> I'm seeing a huge performance hit with this patch.  I'm just running cthon over TCP, and it goes from finishing in 22 seconds to taking well over 5 minutes.  I seem to only see this on the read and write tests, such as basic test5 taking a minute to finish:
>>>
>>>   ./test5: read and write                                                                                       
>>>           wrote 1048576 byte file 10 times in 60.35 seconds (173737 bytes/sec)                                  
>>>           read 1048576 byte file 10 times in 0.0  seconds (-2147483648 bytes/sec)                               
>>>           ./test5 ok. 
>>
>> OK. This looks like write is impacted, but this test doesn't
>> actually perform any reads on the wire. Try iozone with -I,
>> maybe? That would show results for both read and write.
> 
> Hum.
> 
> Stock v4.16-rc4:
> 
> ./test5: read and write
> 	wrote 1048576 byte file 10 times in 0.2  seconds (350811642 bytes/sec)
> 	read 1048576 byte file 10 times in 0.0  seconds (-2147483648 bytes/sec)
> 	./test5 ok.
> 
> 
> v4.16-rc4 with my full set of patches:
> 
> ./test5: read and write
> 	wrote 1048576 byte file 10 times in 0.2  seconds (354236681 bytes/sec)
> 	read 1048576 byte file 10 times in 0.0  seconds (-2147483648 bytes/sec)
> 	./test5 ok.
> 
> I don't see a regression here. Let me know how it goes!

I'm using rc4 too, so maybe it's something different in my setup?  Making this change fixes the issue for me:

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a394b4635f8e..273847f7e455 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -987,8 +987,6 @@ bool xprt_prepare_transmit(struct rpc_task *task)
                task->tk_status = -EAGAIN;
                goto out_unlock;
        }
-       if (likely(!bc_prealloc(req)))
-               req->rq_xid = xprt_alloc_xid(xprt);
        ret = true;
 out_unlock:
        spin_unlock_bh(&xprt->transport_lock);
@@ -1315,6 +1313,7 @@ void xprt_request_init(struct rpc_task *task)
        req->rq_task    = task;
        req->rq_xprt    = xprt;
        req->rq_buffer  = NULL;
+       req->rq_xid     = xprt_alloc_xid(xprt);
        req->rq_connect_cookie = xprt->connect_cookie - 1;
        req->rq_bytes_sent = 0;
        req->rq_snd_buf.len = 0;


Anna

> 
> 
>>> I haven't dug into this too deeply, but my best guess is that maybe it's due to adding a call to xprt_request_init() in net/sunrpc/clnt.c:call_reserveresult()
>>
>> It wasn't added there, it was moved from xprt_alloc_slot. So,
>> it's not new work per-RPC.
>>
>> Any additional information would be appreciated!
>>
>>
>>> Thoughts?
>>> Anna
>>>
>>> On 03/05/2018 03:13 PM, Chuck Lever wrote:
>>>> alloc_slot is a transport-specific op, but initializing an rpc_rqst
>>>> is common to all transports. Move initialization to common code in
>>>> preparation for adding a transport-specific alloc_slot to xprtrdma.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> include/linux/sunrpc/xprt.h |    1 +
>>>> net/sunrpc/clnt.c           |    1 +
>>>> net/sunrpc/xprt.c           |   12 +++++++-----
>>>> 3 files changed, 9 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>>> index 5fea0fb..9784e28 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -324,6 +324,7 @@ struct xprt_class {
>>>> struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
>>>> void			xprt_connect(struct rpc_task *task);
>>>> void			xprt_reserve(struct rpc_task *task);
>>>> +void			xprt_request_init(struct rpc_task *task);
>>>> void			xprt_retry_reserve(struct rpc_task *task);
>>>> int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
>>>> int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>> index 6e432ec..226f558 100644
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -1546,6 +1546,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
>>>> 	task->tk_status = 0;
>>>> 	if (status >= 0) {
>>>> 		if (task->tk_rqstp) {
>>>> +			xprt_request_init(task);
>>>> 			task->tk_action = call_refresh;
>>>> 			return;
>>>> 		}
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index 70f0050..a394b46 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -66,7 +66,7 @@
>>>> * Local functions
>>>> */
>>>> static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
>>>> -static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
>>>> +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
>>>> static void	xprt_connect_status(struct rpc_task *task);
>>>> static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
>>>> static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
>>>> @@ -987,6 +987,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
>>>> 		task->tk_status = -EAGAIN;
>>>> 		goto out_unlock;
>>>> 	}
>>>> +	if (likely(!bc_prealloc(req)))
>>>> +		req->rq_xid = xprt_alloc_xid(xprt);
>>>> 	ret = true;
>>>> out_unlock:
>>>> 	spin_unlock_bh(&xprt->transport_lock);
>>>> @@ -1163,10 +1165,10 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
>>>> out_init_req:
>>>> 	xprt->stat.max_slots = max_t(unsigned int, xprt->stat.max_slots,
>>>> 				     xprt->num_reqs);
>>>> +	spin_unlock(&xprt->reserve_lock);
>>>> +
>>>> 	task->tk_status = 0;
>>>> 	task->tk_rqstp = req;
>>>> -	xprt_request_init(task, xprt);
>>>> -	spin_unlock(&xprt->reserve_lock);
>>>> }
>>>> EXPORT_SYMBOL_GPL(xprt_alloc_slot);
>>>>
>>>> @@ -1303,8 +1305,9 @@ static inline void xprt_init_xid(struct rpc_xprt *xprt)
>>>> 	xprt->xid = prandom_u32();
>>>> }
>>>>
>>>> -static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
>>>> +void xprt_request_init(struct rpc_task *task)
>>>> {
>>>> +	struct rpc_xprt *xprt = task->tk_xprt;
>>>> 	struct rpc_rqst	*req = task->tk_rqstp;
>>>>
>>>> 	INIT_LIST_HEAD(&req->rq_list);
>>>> @@ -1312,7 +1315,6 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
>>>> 	req->rq_task	= task;
>>>> 	req->rq_xprt    = xprt;
>>>> 	req->rq_buffer  = NULL;
>>>> -	req->rq_xid     = xprt_alloc_xid(xprt);
>>>> 	req->rq_connect_cookie = xprt->connect_cookie - 1;
>>>> 	req->rq_bytes_sent = 0;
>>>> 	req->rq_snd_buf.len = 0;
>>>>
>>
>> --
>> Chuck Lever
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
