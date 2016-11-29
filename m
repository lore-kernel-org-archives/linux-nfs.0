Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33875 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934003AbcK2PwC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 10:52:02 -0500
Subject: [PATCH v3 00/12] client-side NFS/RDMA patches proposed for v4.10
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 10:51:59 -0500
Message-ID: <20161129154845.23061.29385.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These are ready for you to consider for v4.10. This patch series makes
the following changes:

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


Changes since v2:
- Rebased on v4.9-rc7


Changes since v1:
- Rebased on v4.9-rc5
- "xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect" was merged
- "xprtrdma: Simplify synopsis of rpcrdma_ep_connect()" was postponed
- Clean-ups re-ordered to the end of the series
- Editorial changes to patch descriptions

---

Chuck Lever (12):
      xprtrdma: Cap size of callback buffer resources
      xprtrdma: Make FRWR send queue entry accounting more accurate
      xprtrdma: Support for SG_GAP devices
      SUNRPC: Proper metric accounting when RPC is not transmitted
      xprtrdma: Address coverity complaint about wait_for_completion()
      xprtrdma: Avoid calls to ro_unmap_safe()
      xprtrdma: Refactor FRMR invalidation
      xprtrdma: Update documenting comment
      xprtrdma: Squelch "max send, max recv" messages at connect time
      xprtrdma: Shorten QP access error message
      xprtrdma: Update dprintk in rpcrdma_count_chunks
      xprtrdma: Relocate connection helper functions


 net/sunrpc/stats.c                |   10 ++--
 net/sunrpc/xprtrdma/backchannel.c |    4 +-
 net/sunrpc/xprtrdma/frwr_ops.c    |   94 +++++++++++++++++--------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   36 --------------
 net/sunrpc/xprtrdma/transport.c   |   34 +++++++++++++
 net/sunrpc/xprtrdma/verbs.c       |   37 ++++++++-------
 net/sunrpc/xprtrdma/xprt_rdma.h   |   31 +++++++++---
 7 files changed, 128 insertions(+), 118 deletions(-)

--
Chuck Lever
