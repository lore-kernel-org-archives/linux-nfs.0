Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35517 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753094AbdC0OGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:06:16 -0400
Subject: [PATCH v2 00/13] NFS/RDMA client-side patches proposed for 4.12
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:05:35 -0400
Message-ID: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The two main improvements in this series are:


1. Break RPC-over-RDMA connections after an RPC timeout.

This gives the client's CM an opportunity to perform server and
network path rediscovery before retrying the timed-out RPC.

This design was selected because it is simple, and does not make any
changes to the normal RPC Call send hot path. Also, note the logic
already in xprt_rdma_send_request() that breaks the connection
anyway, just before sending a retransmit.

Internal testing at Oracle has demonstrated this logic is effective.


2. Support unloading the driver of the underlying device.

Full support for the DEVICE_REMOVAL CM upcall is implemented in the
client-side RPC-over-RDMA consumer. Devesh's workaround is reverted,
since it is now no longer necessary.

In addition, support is added for restoring transport operation when
a new driver is subsequently loaded or when another device is
already available with connectivity to the NFS server.

Hopefully this work can be the basis for device hotplug,
suspend/resume with NFS/RDMA mounts, and handling device failover.


Available in the "nfs-rdma-for-4.12" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.12


Changes since v1:
- Rebased on v4.11-rc4 + recent non-rdma fixes
- Reordered so bug fixes come first
- Three small new clean ups

---

Chuck Lever (13):
      xprtrdma: Cancel refresh worker during buffer shutdown
      sunrpc: Export xprt_force_disconnect()
      xprtrdma: Detect unreachable NFS/RDMA servers more reliably
      xprtrdma: Refactor rpcrdma_ia_open()
      xprtrdma: Use same device when mapping or syncing DMA buffers
      xprtrdma: Support unplugging an HCA from under an NFS mount
      xprtrdma: Refactor rpcrdma_ep_connect
      xprtrdma: Restore transport after device removal
      xprtrdma: Revert commit d0f36c46deea
      xprtrdma: Annotate receive workqueue
      xprtrdma: Squelch ENOBUFS warnings
      sunrpc: Fix xdr_init_decode_pages() documenting comment
      xprtrdma: Remove rpcrdma_buffer::rb_pool


 net/sunrpc/xdr.c                |    2 
 net/sunrpc/xprt.c               |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c  |   12 +
 net/sunrpc/xprtrdma/transport.c |   57 ++++++-
 net/sunrpc/xprtrdma/verbs.c     |  323 ++++++++++++++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   22 ++-
 6 files changed, 295 insertions(+), 122 deletions(-)

--
Chuck Lever
