Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36850 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEDR4o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 13:56:44 -0400
Subject: [PATCH v1 00/14] client NFS/RDMA patches for 4.2
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 13:56:39 -0400
Message-ID: <20150504174626.3483.97639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like these patches considered for merging upstream. This patch
series includes:

 - JIT allocation of rpcrdma_mw structures
 - Break-up of rb_lock
 - Reduction of how many rpcrdma_mw structs are needed per transport

These are pre-requisites for increasing the RPC slot count and
r/wsize on RPC/RDMA transports. And:

 - An RPC/RDMA transport fault injector

This is useful to discover regressions in logic for handling
transport disconnection and recovery.

You can find these in my git repo in the "nfs-rdma-for-4.2" topic
branch. See:

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary

Thanks in advance for patch review!

---

Chuck Lever (14):
      xprtrdma: Transport fault injection
      xprtrdma: Warn when there are orphaned IB objects
      xprtrdma: Replace rpcrdma_rep::rr_buffer with rr_rxprt
      xprtrdma: Use ib_device pointer safely
      xprtrdma: Introduce helpers for allocating MWs
      xprtrdma: Acquire FMRs in rpcrdma_fmr_register_external()
      xprtrdma: Introduce an FRMR recovery workqueue
      xprtrdma: Acquire MRs in rpcrdma_register_external()
      xprtrdma: Remove unused LOCAL_INV recovery logic
      xprtrdma: Remove ->ro_reset
      xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
      xprtrdma: Split rb_lock
      xprtrdma: Stack relief in fmr_op_map()
      xprtrmda: Reduce per-transport MR allocation


 include/linux/sunrpc/xprtrdma.h    |    3 
 net/sunrpc/Kconfig                 |   12 ++
 net/sunrpc/xprtrdma/fmr_ops.c      |  120 +++++++++++-------
 net/sunrpc/xprtrdma/frwr_ops.c     |  224 ++++++++++++++++++++++++---------
 net/sunrpc/xprtrdma/physical_ops.c |   14 --
 net/sunrpc/xprtrdma/rpc_rdma.c     |    7 -
 net/sunrpc/xprtrdma/transport.c    |   52 +++++++-
 net/sunrpc/xprtrdma/verbs.c        |  241 +++++++++---------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |   38 ++++--
 9 files changed, 387 insertions(+), 324 deletions(-)

--
Chuck Lever
