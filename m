Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34013 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752871AbcKITEu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:04:50 -0500
Subject: [PATCH v1 00/14] client-side NFS/RDMA patches proposed for v4.10
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:04:48 -0500
Message-ID: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch series makes these changes:

- Support for devices that support SG_GAP
- Several bug fixes
- A number of clean-ups and optimizations

SG_GAP devices allow the client transport implementation to register
non-contiguous memory regions using one offset and handle. Scatter
and gather from these regions are then managed entirely in hardware.

Normally a Reply chunk for a READDIR or GETACL is built of multiple
RDMA segments. Now, when our client wants to build a Reply chunk out
of the xdr_buf's head, page list, and tail, it appears to the server
as a single contiguous RDMA segment if the device supports SG_GAP.

Instead of a separate Write WR for each of several RDMA segments,
the server can then post a single Write WR to transmit the whole RPC
Reply (assuming the Reply is smaller than the server RNIC's max_sge)
and can invalidate the whole Reply chunk remotely.

SG_GAP is currently supported by mlx5 devices when using the FRWR
registration mechanism.


Available in the "nfs-rdma-for-4.10" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.10


---

Chuck Lever (14):
      xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect
      xprtrdma: Cap size of callback buffer resources
      xprtrdma: Make FRWR send queue entry accounting more accurate
      xprtrdma: Support for SG_GAP devices
      SUNRPC: Proper metric accounting when RPC is not transmitted
      xprtrdma: Address coverity complaint about wait_for_completion()
      xprtrdma: Avoid calls to ro_unmap_safe()
      xprtrdma: Squelch "max send, max recv" messages at connect time
      xprtrdma: Shorten QP access error message
      xprtrdma: Update dprintk in rpcrdma_count_chunks
      xprtrdma: Relocate connection helper functions
      xprtrdma: Simplify synopsis of rpcrdma_ep_connect()
      xprtrdma: Refactor FRMR invalidation
      xprtrdma: Update documenting comment


 net/sunrpc/stats.c                |   10 ++-
 net/sunrpc/xprtrdma/backchannel.c |    4 +
 net/sunrpc/xprtrdma/frwr_ops.c    |  131 +++++++++++++++++++------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   36 ----------
 net/sunrpc/xprtrdma/transport.c   |   36 +++++++++-
 net/sunrpc/xprtrdma/verbs.c       |   54 ++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h   |   36 +++++++---
 7 files changed, 161 insertions(+), 146 deletions(-)

--
Chuck Lever
