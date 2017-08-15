Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49546 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdHOOXw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Aug 2017 10:23:52 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/3] SUNRPC: Don't hold the transport lock across socket copy operations
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1502759921.22283.23.camel@primarydata.com>
Date: Tue, 15 Aug 2017 10:23:46 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DE137089-1D71-47C3-BDC4-3BCE73DF235A@oracle.com>
References: <20170814191652.18263-1-trond.myklebust@primarydata.com> <20170814191652.18263-2-trond.myklebust@primarydata.com> <003E7C40-57BD-4F02-9157-97919FA206D5@oracle.com> <1502741277.19246.7.camel@primarydata.com> <55994DBE-0CE4-450A-8B19-B8C8F4CA0B69@oracle.com> <1502743109.19246.19.camel@primarydata.com> <7C0D016C-FBC3-4103-BA81-37AE0D6BAF5B@oracle.com> <1502759921.22283.23.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 14, 2017, at 9:18 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Mon, 2017-08-14 at 18:25 -0400, Chuck Lever wrote:
>>> On Aug 14, 2017, at 4:38 PM, Trond Myklebust <trondmy@primarydata.c
>>> om> wrote:
>>> 
>>> On Mon, 2017-08-14 at 16:23 -0400, Chuck Lever wrote:
>>>>> On Aug 14, 2017, at 4:07 PM, Trond Myklebust <trondmy@primaryda
>>>>> ta.c
>>>>> om> wrote:
>>>>> 
>>>>> On Mon, 2017-08-14 at 15:28 -0400, Chuck Lever wrote:
>>>>>>> On Aug 14, 2017, at 3:16 PM, Trond Myklebust <trond.myklebu
>>>>>>> st@p
>>>>>>> rima
>>>>>>> rydata.com> wrote:
>>>>>>> 
>>>>>>> Instead add a mechanism to ensure that the request doesn't
>>>>>>> disappear
>>>>>>> from underneath us while copying from the socket. We do
>>>>>>> this by
>>>>>>> preventing xprt_release() from freeing the XDR buffers
>>>>>>> until
>>>>>>> the
>>>>>>> flag RPC_TASK_MSG_RECV has been cleared from the request.
>>>>>>> 
>>>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata
>>>>>>> .com
>>>>>>>> 
>>>>>>> 
>>>>>>> ---
>>>>>>> include/linux/sunrpc/sched.h |  2 ++
>>>>>>> include/linux/sunrpc/xprt.h  |  2 ++
>>>>>>> net/sunrpc/xprt.c            | 42
>>>>>>> ++++++++++++++++++++++++++++++++++++++++++
>>>>>>> net/sunrpc/xprtsock.c        | 27 ++++++++++++++++++++++---
>>>>>>> --
>>>>>>> 4 files changed, 68 insertions(+), 5 deletions(-)
>>>>>>> 
>>>>>>> diff --git a/include/linux/sunrpc/sched.h
>>>>>>> b/include/linux/sunrpc/sched.h
>>>>>>> index 15bc1cd6ee5c..e972d9e05426 100644
>>>>>>> --- a/include/linux/sunrpc/sched.h
>>>>>>> +++ b/include/linux/sunrpc/sched.h
>>>>>>> @@ -141,6 +141,8 @@ struct rpc_task_setup {
>>>>>>> #define RPC_TASK_ACTIVE		2
>>>>>>> #define RPC_TASK_MSG_XMIT	3
>>>>>>> #define RPC_TASK_MSG_XMIT_WAIT	4
>>>>>>> +#define RPC_TASK_MSG_RECV	5
>>>>>>> +#define RPC_TASK_MSG_RECV_WAIT	6
>>>>>>> 
>>>>>>> #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING,
>>>>>>> &(t)-
>>>>>>>> tk_runstate)
>>>>>>> 
>>>>>>> #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING,
>>>>>>> &(t)-
>>>>>>>> tk_runstate)
>>>>>>> 
>>>>>>> diff --git a/include/linux/sunrpc/xprt.h
>>>>>>> b/include/linux/sunrpc/xprt.h
>>>>>>> index eab1c749e192..65b9e0224753 100644
>>>>>>> --- a/include/linux/sunrpc/xprt.h
>>>>>>> +++ b/include/linux/sunrpc/xprt.h
>>>>>>> @@ -372,6 +372,8 @@ void			xprt_write_
>>>>>>> spac
>>>>>>> e(st
>>>>>>> ruct rpc_xprt *xprt);
>>>>>>> void			xprt_adjust_cwnd(struct
>>>>>>> rpc_xprt
>>>>>>> *xprt,
>>>>>>> struct rpc_task *task, int result);
>>>>>>> struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt
>>>>>>> *xprt,
>>>>>>> __be32 xid);
>>>>>>> void			xprt_complete_rqst(struct
>>>>>>> rpc_task
>>>>>>> *task, int copied);
>>>>>>> +void			xprt_pin_rqst(struct rpc_rqst
>>>>>>> *req);
>>>>>>> +void			xprt_unpin_rqst(struct
>>>>>>> rpc_rqst
>>>>>>> *req);
>>>>>>> void			xprt_release_rqst_cong(struct
>>>>>>> rpc_task
>>>>>>> *task);
>>>>>>> void			xprt_disconnect_done(struct
>>>>>>> rpc_xprt
>>>>>>> *xprt);
>>>>>>> void			xprt_force_disconnect(struct
>>>>>>> rpc_xprt
>>>>>>> *xprt);
>>>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>>>> index 788c1b6138c2..62c379865f7c 100644
>>>>>>> --- a/net/sunrpc/xprt.c
>>>>>>> +++ b/net/sunrpc/xprt.c
>>>>>>> @@ -844,6 +844,47 @@ struct rpc_rqst
>>>>>>> *xprt_lookup_rqst(struct
>>>>>>> rpc_xprt *xprt, __be32 xid)
>>>>>>> }
>>>>>>> EXPORT_SYMBOL_GPL(xprt_lookup_rqst);
>>>>>>> 
>>>>>>> +/**
>>>>>>> + * xprt_pin_rqst - Pin a request on the transport receive
>>>>>>> list
>>>>>>> + * @req: Request to pin
>>>>>>> + *
>>>>>>> + * Caller must ensure this is atomic with the call to
>>>>>>> xprt_lookup_rqst()
>>>>>>> + * so should be holding the xprt transport lock.
>>>>>>> + */
>>>>>>> +void xprt_pin_rqst(struct rpc_rqst *req)
>>>>>>> +{
>>>>>>> +	set_bit(RPC_TASK_MSG_RECV, &req->rq_task-
>>>>>>>> tk_runstate);
>>>>>>> 
>>>>>>> +}
>>>>>>> +
>>>>>>> +/**
>>>>>>> + * xprt_unpin_rqst - Unpin a request on the transport
>>>>>>> receive
>>>>>>> list
>>>>>>> + * @req: Request to pin
>>>>>>> + *
>>>>>>> + * Caller should be holding the xprt transport lock.
>>>>>>> + */
>>>>>>> +void xprt_unpin_rqst(struct rpc_rqst *req)
>>>>>>> +{
>>>>>>> +	struct rpc_task *task = req->rq_task;
>>>>>>> +
>>>>>>> +	clear_bit(RPC_TASK_MSG_RECV, &task->tk_runstate);
>>>>>>> +	if (test_bit(RPC_TASK_MSG_RECV_WAIT, &task-
>>>>>>>> tk_runstate))
>>>>>>> 
>>>>>>> +		wake_up_bit(&task->tk_runstate,
>>>>>>> RPC_TASK_MSG_RECV);
>>>>>>> +}
>>>>>>> +
>>>>>>> +static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
>>>>>>> +__must_hold(&req->rq_xprt->transport_lock)
>>>>>>> +{
>>>>>>> +	struct rpc_task *task = req->rq_task;
>>>>>>> +	if (test_bit(RPC_TASK_MSG_RECV, &task-
>>>>>>>> tk_runstate)) {
>>>>>>> +		spin_unlock_bh(&req->rq_xprt-
>>>>>>>> transport_lock);
>>>>>>> +		set_bit(RPC_TASK_MSG_RECV_WAIT, &task-
>>>>>>>> tk_runstate);
>>>>>>> 
>>>>>>> +		wait_on_bit(&task->tk_runstate,
>>>>>>> RPC_TASK_MSG_RECV,
>>>>>>> +				TASK_UNINTERRUPTIBLE);
>>>>>>> +		clear_bit(RPC_TASK_MSG_RECV_WAIT, &task-
>>>>>>>> tk_runstate);
>>>>>>> 
>>>>>>> +		spin_lock_bh(&req->rq_xprt-
>>>>>>>> transport_lock);
>>>>>>> +	}
>>>>>>> +}

Looking at xprt_wait_for_pinned_rqst, I'm wondering
though what happens if a soft timeout occurs but the
RPC Reply never arrives because the server died. Will
it wait forever in that case?

I can't tell if wait-for-pinned always waits for the
Reply, or if it can allow the RPC to exit cleanly if
the Reply hasn't arrived.


>>>>>>> +
>>>>>>> static void xprt_update_rtt(struct rpc_task *task)
>>>>>>> {
>>>>>>> 	struct rpc_rqst *req = task->tk_rqstp;
>>>>>>> @@ -1301,6 +1342,7 @@ void xprt_release(struct rpc_task
>>>>>>> *task)
>>>>>>> 		list_del(&req->rq_list);
>>>>>>> 	xprt->last_used = jiffies;
>>>>>>> 	xprt_schedule_autodisconnect(xprt);
>>>>>>> +	xprt_wait_on_pinned_rqst(req);
>>>>>>> 	spin_unlock_bh(&xprt->transport_lock);
>>>>>> 
>>>>>> Is it OK to call wait_on_bit(TASK_UNINTERRUPTIBLE) while
>>>>>> holding
>>>>>> a BH spin lock? This could be prone to deadlock.
>>>>> 
>>>>> We drop the lock inside xprt_wait_on_pinned_rqst() if we need
>>>>> to
>>>>> wait.
>>>>> 
>>>>> The reason why we want to hold the lock there is to avoid a
>>>>> use-
>>>>> after-
>>>>> free in xprt_unpin_rqst(). Without the lock, there is a risk
>>>>> that
>>>>> xprt_release() could complete, and the task get freed before we
>>>>> have
>>>>> completed wake_up_bit().
>>>> 
>>>> Agree with the last bit. I had that challenge with the order of
>>>> memory invalidation (which waits) and
>>>> xprt_lookup_rqst/complete_rqst
>>>> in rpcrdma_reply_handler.
>>>> 
>>>> However my concern is that there are many other users of the
>>>> transport_lock. Does it become more tricky not to introduce a
>>>> problem by changing any one of the sites that take
>>>> transport_lock?
>>> 
>>> What is your concern? The main reason for taking the transport lock
>>> in
>>> the current code is twofold:
>>> 
>>> 1) Perform the lookup of the request on the receive list
>>> 2) Ensure the request doesn't disappear while we're writing to it.
>> 
>> Yes, I think we see the same problem space.
>> 
>> I missed, though, that xprt_wait_on_pinned_rqst always releases
>> transport_lock before invoking wait_on_bit.
>> 
>> 
>>>> Despite the deadlock concern, I don't think it makes sense to
>>>> call
>>>> wait_on_bit while holding a spin lock simply because spin locks
>>>> are
>>>> supposed to be for things that are quick, like updating a data
>>>> structure.
>>>> 
>>>> wait_on_bit can take microseconds: prepare_to_wait and
>>>> finish_wait
>>>> can both take a irqsave spin_lock, for example. bit_wait is the
>>>> action that is done if the bit is not ready, and that calls
>>>> schedule(). On a busy system, that kind of context switch can
>>>> take
>>>> dozens of microseconds.
>>> 
>>> Agreed, but we should only very rarely be hitting the wait case. In
>>> all
>>> successful RPC calls, the receive will have happened long before we
>>> call xprt_release(). In fact, the only 2 cases where this can
>>> happen
>>> would be when the RPC call itself is interrupted. Either:
>>> 
>>> 1) The task is synchronous and was interrupted by the user.
>>> 2) The task is terminating early due to a soft timeout.
>>> 
>>> In both those cases, we're in a non-performance path. Furthermore,
>>> they
>>> would currently end up spinning against the transport lock.
>> 
>> OK, no argument that there is any performance concern.
>> 
>> I can hit this case 2 or 3 times out of 5 with generic/029 on
>> NFSv4/RDMA. These days, the worse that happens is the client drops
>> the RDMA connection because I've spent a very long time immersed
>> in these code paths, trying to make the two cases you list above
>> work 100% without deadlock or crash. See commits 04d25b7d5d1b
>> through 431af645cf66, and commit 68791649a725.
>> 
>> It makes me uncertain that waiting for anything in xprt_release
>> is safe, even if the transport_lock is not being held. xprtrdma
>> used to perform synchronous memory invalidation in ->buf_free.
>> It doesn't any more for this reason.
> 
> 
> Full disclosure: I didn't actually enable this code for RDMA.

Noted that; I assumed I would be responsible for it
if it could be applied to xprtrdma.


> The reason is firstly that I won't pretend to understand the locking in
> rpcrdma_reply_handler(), but furthermore that RDMA doesn't really have
> a problem with bulk copy in the same way that the socket based code
> does: the direct placement into the reply buffer means the bulk of the
> code in rpcrdma_reply_handler() is all about checking the alignment
> (with, admittedly some scary bits in rpcrdma_inline_fixup()).

rpcrdma_reply_handler actually can use xprt_pin_rqst.

It's not doing a data copy (except for the pull-up in
rpcrdma_inline_fixup), but it is performing a possibly
long-running synchronous memory invalidation. During
that invalidation, the transport_lock cannot be held.

With xprt_pin_rqst, rpcrdma_reply_handler would
probably work like this:


spin_lock(transport_lock)
xprt_lookup_rqst
xprt_pin_rqst
spin_unlock(transport_lock)

invalidate memory associated with this rqst, and wait
for it to complete

reconstruct the Reply in rqst->rq_rcv_buf, including
maybe a substantial pull-up if the Reply is large and
inline

spin_lock(transport_lock)
xprt_complete_rqst
xprt_unpin_rqst
spin_unlock(transport_lock)


This would have to co-ordinate with xprt_rdma_free. If
there are still memory regions registered when
xprt_rdma_free is called, that means the RPC was
terminated before the Reply arrived. They still need to
be invalidated, but these functions have to ensure that
invalidation does not occur twice.


>>>>>>> IMO it would be a lot nicer if we had an FSM state
>>>>>>> available that
>>>> could allow another sleep while an RPC task during xprt_release.
>>> 
>>> Why would that be preferable, if the argument holds that this only
>>> happens in these 2 rare error cases?
>> 
>> Because FSM steps are the way this code manages sleeps. That
>> makes it easier to understand and less brittle. I don't think
>> it would be more overhead than test_bit().
> 
> The problem is that it would add new states to a number of functions
> that currently call xprt_release(). Right now, that would mean
> 
> call_reserveresult()
> rpc_verify_header()
> rpc_exit_task()

Right. That's why I wasn't bold enough to actually try adding
the FSM myself.

Your solution is helped somewhat by checking to see if a Call
was actually sent and a Reply is therefore expected. In some
of these cases, that means waiting can be avoided entirely
when the RPC exits before call_transmit.


> In addition, we'd need a separate solution for rpc_put_task(), and
> probably also for rpc_release_task() (since these are both called from
> outside the main state machine loop).
> 
> I'm getting a little worried about your reply above: the RPC engine
> offers no real-time guarantees, so if the RDMA code is really this
> latency-sensitive, then what will happen if we enable pre-emption
> and/or we just have a very congested workqueue?

The sensitivity is only performance-related. On CPU-intensive
workloads, RPC execution time can increase considerably. The
RDMA transport doesn't rely on timely execution for proper
operation, but maybe I don't understand your worry.


> Also, how would a state machine solution help? I'd expect that to make
> the latency worse not better, since the work item would end up getting
> requeued. If the worker thread then gets rescheduled as well...
> 
> One solution may be to simply say we're never going to use this
> mechanism for RDMA. I suspect that if we just replace the use of xprt-
>> transport_lock when protecting the receive queue with a new lock that
> wouldn't need to be bh-safe then that might suffice to deal with the
> RDMA latency issues. I have less confidence that would work for the
> others due to the bulk data copy issue.

I would like a separate non-BH lock, if that can be made to
work. That's in fact how xprtrdma currently works. xprtrdma
has its own receive list at the moment so that it can find
memory associated with a rqst _without_ needing to call
xprt_lookup_rqst. A non-BH lock is used to protect that
list.


--
Chuck Lever



