Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42863 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753245AbcIPR3o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 13:29:44 -0400
Subject: Re: [PATCHv1] sunrpc: fix write space race causing stalls
To: Trond Myklebust <trondmy@primarydata.com>
References: <1474028902-19838-1-git-send-email-david.vrabel@citrix.com>
 <DCD6291A-CE72-4888-AD77-37BB259CD026@primarydata.com>
 <57DC20C8.5000306@citrix.com>
 <4BCBEAB3-1AD4-455E-9C0B-CCD3172C2C17@primarydata.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux Network Devel Mailing <netdev@vger.kernel.org>
From: David Vrabel <david.vrabel@citrix.com>
Message-ID: <57DC2BFE.7040507@citrix.com>
Date: Fri, 16 Sep 2016 18:29:34 +0100
MIME-Version: 1.0
In-Reply-To: <4BCBEAB3-1AD4-455E-9C0B-CCD3172C2C17@primarydata.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16/09/16 18:06, Trond Myklebust wrote:
> 
>> On Sep 16, 2016, at 12:41, David Vrabel <david.vrabel@citrix.com> wrote:
>>
>> On 16/09/16 17:01, Trond Myklebust wrote:
>>>
>>>> On Sep 16, 2016, at 08:28, David Vrabel <david.vrabel@citrix.com> wrote:
>>>>
>>>> Write space becoming available may race with putting the task to sleep
>>>> in xprt_wait_for_buffer_space().  The existing mechanism to avoid the
>>>> race does not work.
>>>>
>>>> This (edited) partial trace illustrates the problem:
>>>>
>>>>  [1] rpc_task_run_action: task:43546@5 ... action=call_transmit
>>>>  [2] xs_write_space <-xs_tcp_write_space
>>>>  [3] xprt_write_space <-xs_write_space
>>>>  [4] rpc_task_sleep: task:43546@5 ...
>>>>  [5] xs_write_space <-xs_tcp_write_space
>>>>
>>>> [1] Task 43546 runs but is out of write space.
>>>>
>>>> [2] Space becomes available, xs_write_space() clears the
>>>>   SOCKWQ_ASYNC_NOSPACE bit.
>>>>
>>>> [3] xprt_write_space() attemts to wake xprt->snd_task (== 43546), but
>>>>   this has not yet been queued and the wake up is lost.
>>>>
>>>> [4] xs_nospace() is called which calls xprt_wait_for_buffer_space()
>>>>   which queues task 43546.
>>>>
>>>> [5] The call to sk->sk_write_space() at the end of xs_nospace() (which
>>>>   is supposed to handle the above race) does not call
>>>>   xprt_write_space() as the SOCKWQ_ASYNC_NOSPACE bit is clear and
>>>>   thus the task is not woken.
>>>>
>>>> Fix the race by have xprt_wait_for_buffer_space() check for write
>>>> space after putting the task to sleep.
>>>>
>>>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>>>> ---
>>>> include/linux/sunrpc/xprt.h |  1 +
>>>> net/sunrpc/xprt.c           |  4 ++++
>>>> net/sunrpc/xprtsock.c       | 21 +++++++++++++++++++--
>>>> 3 files changed, 24 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>>> index a16070d..621e74b 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -129,6 +129,7 @@ struct rpc_xprt_ops {
>>>> 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
>>>> 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
>>>> 	void		(*buf_free)(void *buffer);
>>>> +	bool            (*have_write_space)(struct rpc_xprt *task);
>>>> 	int		(*send_request)(struct rpc_task *task);
>>>> 	void		(*set_retrans_timeout)(struct rpc_task *task);
>>>> 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index ea244b2..d3c1b1e 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -502,6 +502,10 @@ void xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action)
>>>>
>>>> 	task->tk_timeout = RPC_IS_SOFT(task) ? req->rq_timeout : 0;
>>>> 	rpc_sleep_on(&xprt->pending, task, action);
>>>> +
>>>> +	/* Write space notification may race with putting task to sleep. */
>>>> +	if (xprt->ops->have_write_space(xprt))
>>>> +		rpc_wake_up_queued_task(&xprt->pending, task);
>>>> }
>>>> EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
>>>>
>>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>>> index bf16883..211de5b 100644
>>>> --- a/net/sunrpc/xprtsock.c
>>>> +++ b/net/sunrpc/xprtsock.c
>>>> @@ -472,8 +472,6 @@ static int xs_nospace(struct rpc_task *task)
>>>>
>>>> 	spin_unlock_bh(&xprt->transport_lock);
>>>>
>>>> -	/* Race breaker in case memory is freed before above code is called */
>>>> -	sk->sk_write_space(sk);
>>>> 	return ret;
>>>> }
>>>
>>> Instead of these callbacks, why not just add a call to
>>> sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk) after queueing the task in
>>> xs_nospace()? Won’t that fix the existing race breaker?
>>
>> I don't see how that would help.  If sk->sk_write_space was already
>> called, SOCKWQ_ASYNC_NOSPACE will still be clear and the next call to
>> sk->sk_write_space will still be a nop.
> 
> Sorry. Copy+paste error. I meant SOCKWQ_ASYNC_NOSPACE.
> 
>>
>> Or did you mean SOCKWQ_ASYNC_NOSPACE here?  It doesn't seem right to set
>> this bit when we don't know if there's space or not.
> 
> Why not?

I prefer my solution because:

a) It obviously fixes the race (games with bits are less understandable).

b) It requires fewer atomic ops.

c) It doesn't require me to understand what the behaviour of the
socket-internal SOCKWQ_ASYNC_NOSPACE bit is or should be.

d) I'm not sure I understand the objection to the additional
have_write_space method -- it has simple, clear behaviour.

David

