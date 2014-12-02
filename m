Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:53282 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026AbaLBAiU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 19:38:20 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so10717907ieb.3
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2014 16:38:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141201234759.GF30749@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<1416597571-4265-4-git-send-email-jlayton@primarydata.com>
	<20141201234759.GF30749@fieldses.org>
Date: Mon, 1 Dec 2014 19:38:19 -0500
Message-ID: <CAABAsM6cikgA-gJZUNHzoqZCGxQaS9hagy9vcY4yfOzaqi4QyQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] sunrpc: convert to lockless lookup of queued server threads
From: Trond Myklebust <trondmy@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 1, 2014 at 6:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Nov 21, 2014 at 02:19:30PM -0500, Jeff Layton wrote:
>> Testing has shown that the pool->sp_lock can be a bottleneck on a busy
>> server. Every time data is received on a socket, the server must take
>> that lock in order to dequeue a thread from the sp_threads list.
>>
>> Address this problem by eliminating the sp_threads list (which contains
>> threads that are currently idle) and replacing it with a RQ_BUSY flag in
>> svc_rqst. This allows us to walk the sp_all_threads list under the
>> rcu_read_lock and find a suitable thread for the xprt by doing a
>> test_and_set_bit.
>>
>> Note that we do still have a potential atomicity problem however with
>> this approach.  We don't want svc_xprt_do_enqueue to set the
>> rqst->rq_xprt pointer unless a test_and_set_bit of RQ_BUSY returned
>> negative (which indicates that the thread was idle). But, by the time we
>> check that, the big could be flipped by a waking thread.
>
> (Nits: replacing "negative" by "zero" and "big" by "bit".)
>
>> To address this, we acquire a new per-rqst spinlock (rq_lock) and take
>> that before doing the test_and_set_bit. If that returns false, then we
>> can set rq_xprt and drop the spinlock. Then, when the thread wakes up,
>> it must set the bit under the same spinlock and can trust that if it was
>> already set then the rq_xprt is also properly set.
>>
>> With this scheme, the case where we have an idle thread no longer needs
>> to take the highly contended pool->sp_lock at all, and that removes the
>> bottleneck.
>>
>> That still leaves one issue: What of the case where we walk the whole
>> sp_all_threads list and don't find an idle thread? Because the search is
>> lockess, it's possible for the queueing to race with a thread that is
>> going to sleep. To address that, we queue the xprt and then search again.
>>
>> If we find an idle thread at that point, we can't attach the xprt to it
>> directly since that might race with a different thread waking up and
>> finding it.  All we can do is wake the idle thread back up and let it
>> attempt to find the now-queued xprt.
>
> I find it hard to think about how we expect this to affect performance.
> So it comes down to the observed results, I guess, but just trying to
> get an idea:
>
>         - this eliminates sp_lock.  I think the original idea here was
>           that if interrupts could be routed correctly then there
>           shouldn't normally be cross-cpu contention on this lock.  Do
>           we understand why that didn't pan out?  Is hardware capable of
>           doing this really rare, or is it just too hard to configure it
>           correctly?

One problem is that a 1MB incoming write will generate a lot of
interrupts. While that is not so noticeable on a 1GigE network, it is
on a 40GigE network. The other thing you should note is that this
workload was generated with ~100 clients pounding on that server, so
there are a fair amount of TCP connections to service in parallel.
Playing with the interrupt routing doesn't necessarily help you so
much when all those connections are hot.

>         - instead we're walking the list of all threads looking for an
>           idle one.  I suppose that's tpyically not more than a few
>           hundred.  Does this being fast depend on the fact that that
>           list is almost never changed?  Should we be rearranging
>           svc_rqst so frequently-written fields aren't nearby?

Given a 64-byte cache line, that is 8 pointers worth on a 64-bit processor.

- rq_all, rq_server, rq_pool, rq_task don't ever change, so perhaps
shove them together into the same cacheline?

- rq_xprt does get set often until we have a full RPC request worth of
data, so perhaps consider moving that.

- OTOH, rq_addr, rq_addrlen, rq_daddr, rq_daddrlen are only set once
we have a full RPC to process, and then keep their values until that
RPC call is finished. That doesn't look too bad.

Cheers
  Trond
