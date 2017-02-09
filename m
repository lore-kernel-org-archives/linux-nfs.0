Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:27043 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbdBIXyt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 18:54:49 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 12/12] sunrpc: Allow keepalive ping on a credit-full transport
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1486671236.5570.4.camel@primarydata.com>
Date: Thu, 9 Feb 2017 15:39:43 -0500
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E7D6979F-06F5-4D1A-8542-2DBA6750F264@oracle.com>
References: <20170208214854.7152.83331.stgit@manet.1015granger.net> <20170208220116.7152.87626.stgit@manet.1015granger.net> <1486598713.11028.3.camel@primarydata.com> <9D6B8B44-9C23-427C-9E06-7C92302EB04D@oracle.com> <1486601331.11028.5.camel@primarydata.com> <2AFD96A3-8D49-4E2E-B1F1-9F5C46D0C9C8@oracle.com> <4E4245D4-8F9C-4CF3-8B2D-E4528B9E791F@oracle.com> <1486671236.5570.4.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 9, 2017, at 3:13 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Thu, 2017-02-09 at 14:42 -0500, Chuck Lever wrote:
>>> On Feb 9, 2017, at 10:37 AM, Chuck Lever <chuck.lever@oracle.com>
>>> wrote:
>>> 
>>>> 
>>>> On Feb 8, 2017, at 7:48 PM, Trond Myklebust <trondmy@primarydata.
>>>> com> wrote:
>>>> 
>>>> On Wed, 2017-02-08 at 19:19 -0500, Chuck Lever wrote:
>>>>>> On Feb 8, 2017, at 7:05 PM, Trond Myklebust <trondmy@primaryd
>>>>>> ata.co
>>>>>> m> wrote:
>>>>>> 
>>>>>> On Wed, 2017-02-08 at 17:01 -0500, Chuck Lever wrote:
>>>>>>> Allow RPC-over-RDMA to send NULL pings even when the
>>>>>>> transport
>>>>>>> has
>>>>>>> hit its credit limit. One RPC-over-RDMA credit is reserved
>>>>>>> for
>>>>>>> operations like keepalive.
>>>>>>> 
>>>>>>> For transports that convey NFSv4, it seems like lease
>>>>>>> renewal
>>>>>>> would
>>>>>>> also be a candidate for using a priority transport slot.
>>>>>>> I'd like
>>>>>>> to
>>>>>>> see a mechanism better than RPCRDMA_PRIORITY that can
>>>>>>> ensure only
>>>>>>> one priority operation is in use at a time.
>>>>>>> 
>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>> ---
>>>>>>> include/linux/sunrpc/sched.h聽聽聽聽|聽聽聽聽2 ++
>>>>>>> net/sunrpc/xprt.c聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽|聽聽聽聽4 ++++
>>>>>>> net/sunrpc/xprtrdma/transport.c |聽聽聽聽3 ++-
>>>>>>> net/sunrpc/xprtrdma/verbs.c聽聽聽聽聽|聽聽聽13 ++++++++-----
>>>>>>> 4 files changed, 16 insertions(+), 6 deletions(-)
>>>>>>> 
>>>>>>> diff --git a/include/linux/sunrpc/sched.h
>>>>>>> b/include/linux/sunrpc/sched.h
>>>>>>> index 13822e6..fcea158 100644
>>>>>>> --- a/include/linux/sunrpc/sched.h
>>>>>>> +++ b/include/linux/sunrpc/sched.h
>>>>>>> @@ -127,6 +127,7 @@ struct rpc_task_setup {
>>>>>>> #define RPC_TASK_TIMEOUT	0x1000		/*
>>>>>>> fail
>>>>>>> with
>>>>>>> ETIMEDOUT on timeout */
>>>>>>> #define RPC_TASK_NOCONNECT	0x2000		/*
>>>>>>> return
>>>>>>> ENOTCONN if not connected */
>>>>>>> #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		
>>>>>>> /*
>>>>>>> wait forever for a reply */
>>>>>>> +#define RPC_TASK_NO_CONG	0x8000		/*
>>>>>>> skip
>>>>>>> congestion control */
>>>>>>> 
>>>>>>> #define RPC_TASK_SOFTPING	(RPC_TASK_SOFT |
>>>>>>> RPC_TASK_SOFTCONN)
>>>>>>> 
>>>>>>> @@ -137,6 +138,7 @@ struct rpc_task_setup {
>>>>>>> #define RPC_IS_SOFT(t)		((t)->tk_flags &
>>>>>>> (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
>>>>>>> #define RPC_IS_SOFTCONN(t)	((t)->tk_flags &
>>>>>>> RPC_TASK_SOFTCONN)
>>>>>>> #define RPC_WAS_SENT(t)		((t)->tk_flags &
>>>>>>> RPC_TASK_SENT)
>>>>>>> +#define RPC_SKIP_CONG(t)	((t)->tk_flags &
>>>>>>> RPC_TASK_NO_CONG)
>>>>>>> 
>>>>>>> #define RPC_TASK_RUNNING	0
>>>>>>> #define RPC_TASK_QUEUED		1
>>>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>>>> index b530a28..a477ee6 100644
>>>>>>> --- a/net/sunrpc/xprt.c
>>>>>>> +++ b/net/sunrpc/xprt.c
>>>>>>> @@ -392,6 +392,10 @@ static inline void
>>>>>>> xprt_release_write(struct
>>>>>>> rpc_xprt *xprt, struct rpc_task *ta
>>>>>>> {
>>>>>>> 	struct rpc_rqst *req = task->tk_rqstp;
>>>>>>> 
>>>>>>> +	if (RPC_SKIP_CONG(task)) {
>>>>>>> +		req->rq_cong = 0;
>>>>>>> +		return 1;
>>>>>>> +	}
>>>>>> 
>>>>>> Why not just have the RDMA layer call xprt_reserve_xprt()
>>>>>> (and
>>>>>> xprt_release_xprt()) if this flag is set? It seems to me that
>>>>>> you
>>>>>> will
>>>>>> need some kind of extra congestion control in the RDMA layer
>>>>>> anyway
>>>>>> since you only have one reserved credit for these privileged
>>>>>> tasks
>>>>>> (or
>>>>>> did I miss where that is being gated?).
>>>>> 
>>>>> Thanks for the review.
>>>>> 
>>>>> See RPCRDMA_IA_RSVD_CREDIT in 11/12. It's a hack I'm not
>>>>> terribly happy with.
>>>>> 
>>>>> So, I think you are suggesting replacing xprtrdma's
>>>>> ->reserve_xprt with something like:
>>>>> 
>>>>> int xprt_rdma_reserve_xprt(xprt, task)
>>>>> {
>>>>> 聽聽聽聽聽if (RPC_SKIP_CONG(task))
>>>>> 聽聽聽聽聽聽聽聽聽聽return xprt_reserve_xprt(xprt, task);
>>>>> 聽聽聽聽聽return xprt_reserve_xprt_cong(xprt, task);
>>>>> }
>>>>> 
>>>>> and likewise for ->release_xprt ?
>>>> 
>>>> Right.
>> 
>> This seems to work fine for the normal cases.
>> 
>> I'm confused about how to construct xprt_rdma_release_xprt()
>> so it never releases a normal RPC task when a SKIP_CONG
>> task completes and the credit limit is still full.
>> 
>> If it should send a normal task using the reserved credit
>> and that task hangs too, we're in exactly the position
>> we wanted to avoid.
>> 
>> My original solution might have had a similar problem,
>> come to think of it.
>> 
>> 
> 
> That's true... You may need to set up a separate waitqueue that is
> reserved for SKIP_CONG tasks. Again, it makes sense to keep that in the
> RDMA code.

Understood.

At this late date, probably the best thing to do is drop the
keepalive patches for the v4.11 merge window. That would be
10/12, 11/12, and 12/12.


--
Chuck Lever



