Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21411 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbJFO6L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 10:58:11 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC PATCH 3/3] SUNRPC: Allow TCP to replace the bh-safe lock in receive path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtR4jsm89DnA2S+AYoqNsK1JdWOiCbb0h64mSACDfhWeug@mail.gmail.com>
Date: Tue, 6 Oct 2015 10:58:04 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <334D8F98-DE14-4972-AA03-F75C8A3550EA@oracle.com>
References: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com> <1444086211-4811-2-git-send-email-trond.myklebust@primarydata.com> <1444086211-4811-3-git-send-email-trond.myklebust@primarydata.com> <97B47F0A-B0B3-4B11-8498-3616CD761D4A@oracle.com> <CAHQdGtRFNnTAJ4bSk4fpcnU5QjZAfdwYc__Z1QGmMkJDvW6B4w@mail.gmail.com> <70202CF9-BD35-4BAB-BDC1-B374FBF71D59@oracle.com> <CAHQdGtR4jsm89DnA2S+AYoqNsK1JdWOiCbb0h64mSACDfhWeug@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 6, 2015, at 10:17 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> On Tue, Oct 6, 2015 at 9:56 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> On Oct 5, 2015, at 11:55 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>> 
>>> On Mon, Oct 5, 2015 at 8:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>>> On Oct 5, 2015, at 7:03 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>>> 
>>>>> This patch attempts to eke out a couple more iops by allowing the TCP code
>>>>> to replace bh-safe spinlock with an ordinary one while receiving data. We
>>>>> still need to use the bh-safe spinlock when completing.
>>>>> 
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>>> ---
>>>>> net/sunrpc/xprt.c     |  4 ++++
>>>>> net/sunrpc/xprtsock.c | 17 ++++++++++-------
>>>>> 2 files changed, 14 insertions(+), 7 deletions(-)
>>>>> 
>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>> index 2e98f4a243e5..e604bb680bcf 100644
>>>>> --- a/net/sunrpc/xprt.c
>>>>> +++ b/net/sunrpc/xprt.c
>>>>> @@ -951,6 +951,7 @@ void xprt_transmit(struct rpc_task *task)
>>>>>                     /*
>>>>>                      * Add to the list only if we're expecting a reply
>>>>>                      */
>>>>> +                     spin_lock(&xprt->reserve_lock);
>>>>>                     spin_lock_bh(&xprt->transport_lock);
>>>> 
>>>> This is painful. spin_lock_bh is a pre-emption point, where
>>>> the kernel can handle interrupts while others are spinning
>>>> waiting for both of these locks. It can result in waiting
>>>> for more than 100us to get the lock.
>>>> 
>>> 
>>> I thought, the problem isn't so much the spin_lock_bh() but rather the
>>> spin_unlock_bh(). If this is the outermost bh-safe lock, then
>>> spin_unlock_bh() may call do_softirq(), which can take a while, and
>>> therefore increase the chances of contention for any outer
>>> (non-bh-safe) locks.
>>> 
>>> Note, however, that PATCH 2/3 significantly cuts down on the total
>>> amount of time spent in do_softirq(), and therefore explains most of
>>> the performance increase. We can drop patch 3/3 without losing much.
>> 
>> My only quibble is the double locking in xprt_transmit().
>> Wondering if it is sensible to use llist for the receive
>> list.
> 
> Possibly.
> 
>> I actually need to drop locks between xprt_lookup_rqst()
>> and xprt_complete_rqst() for other reasons. That part of
>> this patch is desirable!
>> 
>> In fact, I wasn’t aware that it was safe to drop the
>> lock after xprt_lookup_rqst without first having removed
>> the found request from the receive list.
> 
> That's what I'm using the reserve_lock for. We still need something
> like it in order to pin the request on the receive list while we're
> doing the copy.

My feeble attempt at this was to add a separate step to remove
the request from the list, once the caller was sure that the
request was not going to get dropped. Then the transport_lock
is dropped, and later xprt_complete_rqst finishes retiring
the request with the wake_up_queued_task.

When split out this way, it is clear that xprt_complete_rqst
is the top contender for the transport_lock.


> As the subject message says, though, this is an RFC series. I'm still
> playing with the code in order to figure out what is needed.
> 
>>>> Was there an increase or decrease in CPU utilization with
>>>> this change?
>>> 
>>> I'm seeing less overall contention.
>>> 
>>>>>                     /* Update the softirq receive buffer */
>>>>>                     memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
>>>>> @@ -958,6 +959,7 @@ void xprt_transmit(struct rpc_task *task)
>>>>>                     /* Add request to the receive list */
>>>>>                     list_add_tail(&req->rq_list, &xprt->recv);
>>>>>                     spin_unlock_bh(&xprt->transport_lock);
>>>>> +                     spin_unlock(&xprt->reserve_lock);
>>>>>                     xprt_reset_majortimeo(req);
>>>>>                     /* Turn off autodisconnect */
>>>>>                     del_singleshot_timer_sync(&xprt->timer);
>>>>> @@ -1278,6 +1280,7 @@ void xprt_release(struct rpc_task *task)
>>>>>             task->tk_ops->rpc_count_stats(task, task->tk_calldata);
>>>>>     else if (task->tk_client)
>>>>>             rpc_count_iostats(task, task->tk_client->cl_metrics);
>>>>> +     spin_lock(&xprt->reserve_lock);
>>>>>     spin_lock_bh(&xprt->transport_lock);
>>>>>     xprt->ops->release_xprt(xprt, task);
>>>>>     if (xprt->ops->release_request)
>>>>> @@ -1289,6 +1292,7 @@ void xprt_release(struct rpc_task *task)
>>>>>             mod_timer(&xprt->timer,
>>>>>                             xprt->last_used + xprt->idle_timeout);
>>>>>     spin_unlock_bh(&xprt->transport_lock);
>>>>> +     spin_unlock(&xprt->reserve_lock);
>>>>>     if (req->rq_buffer)
>>>>>             xprt->ops->buf_free(req->rq_buffer);
>>>>>     xprt_inject_disconnect(xprt);
>>>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>>>> index 58dc90ccebb6..063d2eb20d8e 100644
>>>>> --- a/net/sunrpc/xprtsock.c
>>>>> +++ b/net/sunrpc/xprtsock.c
>>>>> @@ -1246,21 +1246,24 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
>>>>>     dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
>>>>> 
>>>>>     /* Find and lock the request corresponding to this xid */
>>>>> -     spin_lock_bh(&xprt->transport_lock);
>>>>> +     spin_lock(&xprt->reserve_lock);
>>>>>     req = xprt_lookup_rqst(xprt, transport->tcp_xid);
>>>>>     if (!req) {
>>>>>             dprintk("RPC:       XID %08x request not found!\n",
>>>>>                             ntohl(transport->tcp_xid));
>>>>> -             spin_unlock_bh(&xprt->transport_lock);
>>>>> +             spin_unlock(&xprt->reserve_lock);
>>>>>             return -1;
>>>>>     }
>>>> 
>>>> Is a similar change needed for rpcrdma_reply_handler() ? If
>>>> that can’t be changed until it runs in a WQ context, I have
>>>> that patch right now. It can be ready for 4.4.
>>>> 
>>>> 
>>>>>     xs_tcp_read_common(xprt, desc, req);
>>>>> 
>>>>> -     if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>>>>> +     if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
>>>>> +             spin_lock_bh(&xprt->transport_lock);
>>>>>             xprt_complete_rqst(req->rq_task, transport->tcp_copied);
>>>>> +             spin_unlock_bh(&xprt->transport_lock);
>>>>> +     }
>>>>> 
>>>>> -     spin_unlock_bh(&xprt->transport_lock);
>>>>> +     spin_unlock(&xprt->reserve_lock);
>>>>>     return 0;
>>>>> }
>>>> 
>>>> xprt_complete_rqst() is actually the top source of contention
>>>> on transport_lock in my tests, thanks to the locking under
>>>> rpc_wake_up_queued_task(). Is there a plan to mitigate locking
>>>> costs in the RPC scheduler?
>>> 
>>> I'm not understanding how rpc_wake_up_queued_task() could cause a
>>> problem here. Can you explain?
>> 
>> xprt_complete_rqst() is holding the transport_lock, and
>> rpc_wake_up_queued_task is holding the wait queue lock.
>> 
>> During complex workloads like database or multi-threaded software
>> build, I’ve observed the rpc_make_runnable -> wake_up_bit path
>> take a very long time while both of these locks are held.
>> 
>> The problem seems similar to the above: pre-emption allows the
>> kernel to perform housekeeping while RPC-related threads are
>> spinning on these locks.
>> 
>> There is likewise a problem with xprt_lock_write_next, which
>> invokes rpc_wake_up_first while the transport_lock is held.
> 
> I'm still not understanding. Apologies if I'm just being dense.

NP, we had a discussion about this at LSF this spring. There
wasn't agreement on exactly what’s going on.


> The call to do_softirq() shouldn't happen until after the last bh-safe
> lock is released, so I wouldn't normally expect it to be called until
> after the transport lock has been released in xprt_complete_rqst(). In
> the existing upstream code, because all of this is being called from a
> bh-safe context in xs_tcp_data_ready(), the do_softirq() will be
> deferred until at least then, and possibly even later, depending on
> where in the socket code the ->data_ready() callback originated from.

I’ve ftraced this (with RPC/RDMA, anyway), and the softIRQ pre-emption
appears to happen at spin_lock_bh time. I’d be very happy to be
incorrect about this, and it’s certainly possible I didn’t understand
what I was looking at.

Even if spin_unlock_bh is where pre-emption occurs, the order of taking
the locks would matter:

1. spin_lock A
2. spin_lock_bh B
3. do_work
4. spin_unlock_bh B -> do_softIRQ
5. spin_unlock A

The thread continues to hold lock A while handling a non-deterministic
amount of other work, forcing those waiting on A to spin. But I think
that’s what you were saying above.

I haven’t been able to nail down exactly why wake_up_bit outliers
take so long. It is either softIRQ pre-emption or the fact that
wake_up_bit depends on the latency for a trip through the scheduler.


—-
Chuck Lever



