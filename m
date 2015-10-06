Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33286 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbJFDzi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 23:55:38 -0400
Received: by obbbh8 with SMTP id bh8so144804001obb.0
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 20:55:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <97B47F0A-B0B3-4B11-8498-3616CD761D4A@oracle.com>
References: <1444086211-4811-1-git-send-email-trond.myklebust@primarydata.com>
	<1444086211-4811-2-git-send-email-trond.myklebust@primarydata.com>
	<1444086211-4811-3-git-send-email-trond.myklebust@primarydata.com>
	<97B47F0A-B0B3-4B11-8498-3616CD761D4A@oracle.com>
Date: Mon, 5 Oct 2015 23:55:37 -0400
Message-ID: <CAHQdGtRFNnTAJ4bSk4fpcnU5QjZAfdwYc__Z1QGmMkJDvW6B4w@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] SUNRPC: Allow TCP to replace the bh-safe lock in
 receive path
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 5, 2015 at 8:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Oct 5, 2015, at 7:03 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> This patch attempts to eke out a couple more iops by allowing the TCP code
>> to replace bh-safe spinlock with an ordinary one while receiving data. We
>> still need to use the bh-safe spinlock when completing.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> net/sunrpc/xprt.c     |  4 ++++
>> net/sunrpc/xprtsock.c | 17 ++++++++++-------
>> 2 files changed, 14 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 2e98f4a243e5..e604bb680bcf 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -951,6 +951,7 @@ void xprt_transmit(struct rpc_task *task)
>>                       /*
>>                        * Add to the list only if we're expecting a reply
>>                        */
>> +                     spin_lock(&xprt->reserve_lock);
>>                       spin_lock_bh(&xprt->transport_lock);
>
> This is painful. spin_lock_bh is a pre-emption point, where
> the kernel can handle interrupts while others are spinning
> waiting for both of these locks. It can result in waiting
> for more than 100us to get the lock.
>

I thought, the problem isn't so much the spin_lock_bh() but rather the
spin_unlock_bh(). If this is the outermost bh-safe lock, then
spin_unlock_bh() may call do_softirq(), which can take a while, and
therefore increase the chances of contention for any outer
(non-bh-safe) locks.

Note, however, that PATCH 2/3 significantly cuts down on the total
amount of time spent in do_softirq(), and therefore explains most of
the performance increase. We can drop patch 3/3 without losing much.

> Was there an increase or decrease in CPU utilization with
> this change?

I'm seeing less overall contention.

>>                       /* Update the softirq receive buffer */
>>                       memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
>> @@ -958,6 +959,7 @@ void xprt_transmit(struct rpc_task *task)
>>                       /* Add request to the receive list */
>>                       list_add_tail(&req->rq_list, &xprt->recv);
>>                       spin_unlock_bh(&xprt->transport_lock);
>> +                     spin_unlock(&xprt->reserve_lock);
>>                       xprt_reset_majortimeo(req);
>>                       /* Turn off autodisconnect */
>>                       del_singleshot_timer_sync(&xprt->timer);
>> @@ -1278,6 +1280,7 @@ void xprt_release(struct rpc_task *task)
>>               task->tk_ops->rpc_count_stats(task, task->tk_calldata);
>>       else if (task->tk_client)
>>               rpc_count_iostats(task, task->tk_client->cl_metrics);
>> +     spin_lock(&xprt->reserve_lock);
>>       spin_lock_bh(&xprt->transport_lock);
>>       xprt->ops->release_xprt(xprt, task);
>>       if (xprt->ops->release_request)
>> @@ -1289,6 +1292,7 @@ void xprt_release(struct rpc_task *task)
>>               mod_timer(&xprt->timer,
>>                               xprt->last_used + xprt->idle_timeout);
>>       spin_unlock_bh(&xprt->transport_lock);
>> +     spin_unlock(&xprt->reserve_lock);
>>       if (req->rq_buffer)
>>               xprt->ops->buf_free(req->rq_buffer);
>>       xprt_inject_disconnect(xprt);
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 58dc90ccebb6..063d2eb20d8e 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1246,21 +1246,24 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
>>       dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
>>
>>       /* Find and lock the request corresponding to this xid */
>> -     spin_lock_bh(&xprt->transport_lock);
>> +     spin_lock(&xprt->reserve_lock);
>>       req = xprt_lookup_rqst(xprt, transport->tcp_xid);
>>       if (!req) {
>>               dprintk("RPC:       XID %08x request not found!\n",
>>                               ntohl(transport->tcp_xid));
>> -             spin_unlock_bh(&xprt->transport_lock);
>> +             spin_unlock(&xprt->reserve_lock);
>>               return -1;
>>       }
>
> Is a similar change needed for rpcrdma_reply_handler() ? If
> that can’t be changed until it runs in a WQ context, I have
> that patch right now. It can be ready for 4.4.
>
>
>>       xs_tcp_read_common(xprt, desc, req);
>>
>> -     if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>> +     if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
>> +             spin_lock_bh(&xprt->transport_lock);
>>               xprt_complete_rqst(req->rq_task, transport->tcp_copied);
>> +             spin_unlock_bh(&xprt->transport_lock);
>> +     }
>>
>> -     spin_unlock_bh(&xprt->transport_lock);
>> +     spin_unlock(&xprt->reserve_lock);
>>       return 0;
>> }
>
> xprt_complete_rqst() is actually the top source of contention
> on transport_lock in my tests, thanks to the locking under
> rpc_wake_up_queued_task(). Is there a plan to mitigate locking
> costs in the RPC scheduler?

I'm not understanding how rpc_wake_up_queued_task() could cause a
problem here. Can you explain?

>> @@ -1280,10 +1283,10 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>       struct rpc_rqst *req;
>>
>>       /* Look up and lock the request corresponding to the given XID */
>> -     spin_lock_bh(&xprt->transport_lock);
>> +     spin_lock(&xprt->reserve_lock);
>>       req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
>>       if (req == NULL) {
>> -             spin_unlock_bh(&xprt->transport_lock);
>> +             spin_unlock(&xprt->reserve_lock);
>>               printk(KERN_WARNING "Callback slot table overflowed\n");
>>               xprt_force_disconnect(xprt);
>>               return -1;
>> @@ -1294,7 +1297,7 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
>>
>>       if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
>>               xprt_complete_bc_request(req, transport->tcp_copied);
>> -     spin_unlock_bh(&xprt->transport_lock);
>> +     spin_unlock(&xprt->reserve_lock);
>>
>>       return 0;
>> }
>> --
>> 2.4.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> —
> Chuck Lever
>
>
>
