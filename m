Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33884 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933050AbdCJQFu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 11:05:50 -0500
Subject: [PATCH v1 00/11] [RFC] NFS/RDMA client-side patches for 4.12
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 10 Mar 2017 11:05:46 -0500
Message-ID: <20170310154131.6314.35201.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These have seen some testing, but there remain some corner cases
that I need to chase down. Therefore this posting is for review
only.

The two main changes in this series are:

1. Break RPC-over-RDMA connections after an RPC timeout.

This gives the client's CM an opportunity to perform server and
network path rediscovery before retrying the timed-out RPC.

This design was selected because it is simple, and does not make any
changes to the normal RPC Call send hot path. Also, note the logic
already in xprt_rdma_send_request() that breaks the connection
anyway just before sending a retransmit.

2. Support unloading the driver of the underlying device.

Full support for the DEVICE_REMOVAL CM upcall is implemented in the
client-side RPC-over-RDMA consumer. Devesh's workaround is reverted,
since it is now no longer necessary.

In addition, support is added for restoring transport operation when
a new driver is subsequently loaded or when another device is
already available with connectivity to the NFS server.

Hopefully this is the basis for device hotplug, suspend/resume with
NFS/RDMA mounts, and handling device failover.


Available in the "nfs-rdma-for-4.12" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.12

---

Chuck Lever (11):
      xprtrdma: Annotate receive workqueue
      xprtrdma: Cancel refresh worker during buffer shutdown
      xprtrdma: Clean up rpcrdma_marshal_req()
      sunrpc: Export xprt_force_disconnect()
      xprtrdma: Detect unreachable NFS/RDMA servers more reliably
      xprtrdma: Refactor rpcrdma_ia_open()
      xprtrdma: Use same device when mapping or syncing DMA buffers
      xprtrdma: Support unplugging an HCA from under an NFS mount
      xprtrdma: Refactor rpcrdma_ep_connect
      xprtrdma: Restore transport after device removal
      xprtrdma: Revert commit d0f36c46deea


 net/sunrpc/xprt.c               |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c  |   67 +++++---
 net/sunrpc/xprtrdma/transport.c |   59 ++++++-
 net/sunrpc/xprtrdma/verbs.c     |  323 ++++++++++++++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   23 ++-
 5 files changed, 327 insertions(+), 146 deletions(-)

--
Chuck Lever
