Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:52796 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731222AbeHIQbM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2018 12:31:12 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: RFC: xprt_lock_connect
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <f9a316e2de500bd4d4e4c3be8f29613e36bc1f3f.camel@hammerspace.com>
Date: Thu, 9 Aug 2018 10:05:57 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3A6E623E-19AB-438E-A083-C3C86E9DE48B@oracle.com>
References: <55352755-3A99-4193-98E6-25A9B8181F6E@oracle.com>
 <f9a316e2de500bd4d4e4c3be8f29613e36bc1f3f.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 8, 2018, at 5:19 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Wed, 2018-08-08 at 15:53 -0400, Chuck Lever wrote:
>> Hi Trond-
>>=20
>> For maintainability and legibility, I'm attempting to make the
>> the RPC/RDMA connect logic act a little more like the TCP
>> connect logic. I noticed this patch:
>>=20
>> commit 718ba5b87343df303017585200ee182e937eabfc
>> Author:     Trond Myklebust <trond.myklebust@primarydata.com>
>> AuthorDate: Sun Feb 8 18:19:25 2015 -0500
>> Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
>> CommitDate: Sun Feb 8 21:47:29 2015 -0500
>>=20
>>    SUNRPC: Add helpers to prevent socket create from racing
>>=20
>>    The socket lock is currently held by the task that is requesting
>> the
>>    connection be established. While that is efficient in the case
>> where
>>    the connection happens quickly, it is racy in the case where it
>> doesn't.
>>    What we really want is for the connect helper to be able to block
>> access
>>    to the socket while it is being set up.
>>=20
>>    This patch does so by arranging to transfer the socket lock from
>> the
>>    task that is requesting the connect attempt, and then releasing
>> that
>>    lock once everything is done.
>>    This scheme also gives us automatic protection against collisions
>> with
>>    the RPC close code, so we can kill the cancel_delayed_work_sync()
>>    call in xs_close().
>>=20
>>    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>=20
>> Your patch description refers to "the socket lock" but it appears
>> to be manipulating the transport send lock. The new helpers are
>> added in net/sunrpc/xprt.c, not in xprtsock.c. And, there is a
>> hunk that changes the generic xprt_connect() function.
>>=20
>> Therefore, I'm wondering if these helpers are of value also to
>> other transports that make use of connections. Should xprtrdma
>> adopt the use of these helpers too?
>>=20
>=20
> Heh... You're too late. =C3=A2=C2=98=C5=A1=C3=A2=C2=98=C5=A1=C3=A2=C2=98=
=C5=A1
>=20
> I'm pretty sure that lock is one of the biggest bottlenecks in the TCP
> send path today and so I'm in the process of rewriting that code.

> The problem is this: the above lock serialises all RPC tasks that go =
to
> a single socket, which is sort of desirable. However it does so by
> passing the lock from rpc_task to rpc_task, and so when the lock is
> contended, we end up putting each task to sleep, it waits for its turn
> in the queue, then the task gets scheduled on the workqueue, it does
> its thing (encodes the XDR, and puts itself through the socket), and
> then wakes up the next task.
> IOW: each time we hand off the lock, we take a workqueue queuing hit,
> with the task having to wait until any other send task or reply that =
is
> ahead of it in the queue has run. We also do the XDR encoding under =
the
> lock, further adding latency...

Indeed, RPC wake-ups are a major, if not the primary, limiter on RPC =
Call
rate on a contended transport. The transport send lock is a top source
of sleeps and wake-ups. The backlog queue is similar.

Fewer wake-ups will help reduce both per-RPC latency and latency =
variance.


> What I want to do (and am in the process of coding) is to convert that
> whole thing into a queue, where if the lock is contended, the incoming
> task simply adds itself to the queue and then puts itself to sleep.
> Then whoever actually first obtains the lock is tasked with trying to
> drain the queue by sending as many of those queued requests as will
> actually fit in the socket buffer.

I've also been exploring xprt reserve/release replacements for xprtrdma,
which needs a new reserve/release mechanism for a lot of reasons.

For instance, note the architectural differences:

 - RPC/TCP : stream-oriented, connection-oriented, no congestion control
 - RPC/UDP : datagram-oriented, not connection-oriented, needs =
congestion control
 - RPC/RDMA : datagram-oriented, connection-oriented, needs congestion =
control

xprtrdma currently uses the UDP congestion control scheme, but it's not =
a
perfect fit. rq_cong does not work very well after a reconnect where the
congestion accounting has to be reset during connection establishment, =
for
instance.

What changes do you intend to make to the UDP congestion control =
mechanism?

Would it be helpful to split out xprtrdma's reserve/release first before
going down this road?


> The assumption is that we can perform the XDR encoding before we
> enqueue the request (so we move that out of the lock too), which is
> usually the case, but might be a little awkward when doing RPCSEC_GSS.

The GSS sequence number will be an interesting challenge.

As you consider the internal APIs, please keep in mind issues related to
XDR encoding for xprtrdma:

- Today, xprtrdma schedules memory registration and constructs the
transport header in ->send_request, while the transport send lock is =
held.
For a retransmit on a new connection, RPC/RDMA requires that memory be
re-registered, for example, which means the transport header needs to be
constructed again (new R_keys).

- Scheduling memory registration outside the transport send lock might =
be
beneficial, but xprtrdma relies on this architecture to avoid =
fine-grained
locking of transport resources used while registering memory and =
constructing
the transport header.


--
Chuck Lever


