Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22373 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752494AbdCCVrP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 16:47:15 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: supporting DEVICE_REMOVAL on RPC-over-RDMA transports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1487863839.3145.1.camel@primarydata.com>
Date: Fri, 3 Mar 2017 13:46:49 -0800
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2B8A92DC-F21A-4881-B4A8-25D97751FA1E@oracle.com>
References: <9EF7BDF7-35DF-4723-A903-54AEC9A9787A@oracle.com> <1487820335.3577.1.camel@primarydata.com> <2C6ED2EF-F715-4EBB-A36B-A7BCBFB60CBE@oracle.com> <1487863839.3145.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 23, 2017, at 7:30 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Thu, 2017-02-23 at 09:54 -0500, Chuck Lever wrote:
>>> On Feb 22, 2017, at 10:25 PM, Trond Myklebust <trondmy@primarydata.
>>> com> wrote:
>>> 
>>> On Wed, 2017-02-22 at 16:31 -0500, Chuck Lever wrote:
>>>> Hey Trond-
>>>> 
>>>> To support the ability to unload the underlying RDMA device's
>>>> kernel
>>>> driver while NFS mounts are active, xprtrdma needs the ability to
>>>> suspend RPC sends temporarily while the transport hands HW
>>>> resources
>>>> back to the driver. Once the device driver is unloaded, the RDMA
>>>> transport is left disconnected, and RPCs will be suspended
>>>> normally
>>>> until a connection is possible again (eg, a new device is made
>>>> available).
>>>> 
>>>> A DEVICE_REMOVAL event is an upcall to xprtrdma that may sleep.
>>>> Upon
>>>> its return, the device driver unloads itself. Currently my
>>>> prototype
>>>> frees all HW resources during the upcall, but that doesn't block
>>>> new RPCs from trying to use those resources at the same time.
>>>> 
>>>> Seems like the most natural way to temporarily block sends would
>>>> be
>>>> to grab the transport's write lock, just like "connect" does,
>>>> while
>>>> the transport is dealing with DEVICE_REMOVAL, then release it
>>>> once
>>>> all HW resources have been freed.
>>>> 
>>>> Unfortunately an RPC task is needed to acquire the write lock.
>>>> But
>>>> disconnect is just an asynchronous event, there is no RPC task
>>>> associated with it, and thus no context that the RPC scheduler
>>>> can put to sleep if there happens to be another RPC sending at
>>>> the
>>>> moment a device removal event occurs.
>>>> 
>>>> I was looking at xprt_lock_connect, but that doesn't appear to do
>>>> quite what I need.
>>>> 
>>>> Another thought was to have the DEVICE_REMOVAL upcall mark the
>>>> transport disconnected, send an asynchronous NULL RPC, then wait
>>>> on a kernel waitqueue.
>>>> 
>>>> The NULL RPC would grab the write lock and kick the transport's
>>>> connect worker. The connect worker would free HW resources, then
>>>> awaken the waiter. Then the upcall could return to the driver.
>>>> 
>>>> The problem with this scheme is the same as it was for the
>>>> keepalive work: there's no task or rpc_clnt available to the
>>>> DEVICE_REMOVAL upcall. Sleeping until the write lock is available
>>>> would require a task, and sending a NULL RPC would require an
>>>> rpc_clnt.
>>>> 
>>>> Any advice/thoughts about this?
>>>> 
>>> 
>>> Can you perhaps use XPRT_FORCE_DISCONNECT? That does end up calling
>>> the
>>> xprt->ops->close() callback as soon as the XPRT_LOCK state has been
>>> freed. You still won't have a client, but you will be guaranteed
>>> exclusive access to the transport, and you can do things like
>>> waking up
>>> any sleeping tasks on the transmit and receive queue to help you.
>>> However you also have to deal with the case where the transport was
>>> idle to start with.
>> 
>> The case where the transport is idle is indeed the most bothersome.
>> 
>> I hadn't realized that ->close guaranteed exclusive access to
>> the transport. If ->close guarantees access to the transport, then
>> I don't need an RPC task or the NULL RPC because we don't ever have
>> to wait for write access.
>> 
> 
> Yes, ->close() must always be taken with XPRT_LOCK set, and it is
> guaranteed to be called the instant that the current holder of
> XPRT_LOCK relinquishes it. This is why we have the test for
> XPRT_CLOSE_WAIT in xprt_clear_locked(); it short-circuits the wait
> queues and immediately starts queue_work(xprtiod_workqueue, &xprt-
>> task_cleanup).
> 
>> The hardware resources can be torn down immediately in
>> xprt_rdma_close.
> 
> Sounds like the right thing to do then.

This approach seems to be working well, except for one
unexpected behavior.

->send_request seems to be called even though
XPRT_CONNECTED is clear. I expected that after a transport
has been disconnected, ->send_request would never be
invoked when that bit is clear.

Occasionally, ->send_request is invoked with
XPRT_CONNECTING set.

If those are OK, then I will have something to post for
review next week.


--
Chuck Lever



