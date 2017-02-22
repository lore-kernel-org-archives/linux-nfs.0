Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23908 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933769AbdBVVb2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2017 16:31:28 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: supporting DEVICE_REMOVAL on RPC-over-RDMA transports
Date: Wed, 22 Feb 2017 16:31:21 -0500
Message-Id: <9EF7BDF7-35DF-4723-A903-54AEC9A9787A@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond-

To support the ability to unload the underlying RDMA device's kernel
driver while NFS mounts are active, xprtrdma needs the ability to
suspend RPC sends temporarily while the transport hands HW resources
back to the driver. Once the device driver is unloaded, the RDMA
transport is left disconnected, and RPCs will be suspended normally
until a connection is possible again (eg, a new device is made
available).

A DEVICE_REMOVAL event is an upcall to xprtrdma that may sleep. Upon
its return, the device driver unloads itself. Currently my prototype
frees all HW resources during the upcall, but that doesn't block
new RPCs from trying to use those resources at the same time.

Seems like the most natural way to temporarily block sends would be
to grab the transport's write lock, just like "connect" does, while
the transport is dealing with DEVICE_REMOVAL, then release it once
all HW resources have been freed.

Unfortunately an RPC task is needed to acquire the write lock. But
disconnect is just an asynchronous event, there is no RPC task
associated with it, and thus no context that the RPC scheduler
can put to sleep if there happens to be another RPC sending at the
moment a device removal event occurs.

I was looking at xprt_lock_connect, but that doesn't appear to do
quite what I need.

Another thought was to have the DEVICE_REMOVAL upcall mark the
transport disconnected, send an asynchronous NULL RPC, then wait
on a kernel waitqueue.

The NULL RPC would grab the write lock and kick the transport's
connect worker. The connect worker would free HW resources, then
awaken the waiter. Then the upcall could return to the driver.

The problem with this scheme is the same as it was for the
keepalive work: there's no task or rpc_clnt available to the
DEVICE_REMOVAL upcall. Sleeping until the write lock is available
would require a task, and sending a NULL RPC would require an
rpc_clnt.

Any advice/thoughts about this?


--
Chuck Lever



