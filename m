Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38287 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517AbbLPWWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 17:22:00 -0500
Subject: [PATCH v4 00/10] NFS/RDMA client patches for 4.5
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 16 Dec 2015 17:21:57 -0500
Message-ID: <20151216221444.13110.43538.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For 4.5, I'd like to address the send queue accounting and
invalidation/unmap ordering issues Jason brought up a couple of
months ago.

Also available in the "nfs-rdma-for-4.5" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.5


Changes since v3:
- Dropped xprt_commit_rqst()
- __frmr_dma_unmap now uses ib_dma_unmap_sg()
- Use transparent union in struct rpcrdma_frmr


Changes since v2:
- Rebased on Christoph's ib_device_attr branch


Changes since v1:

- Rebased on v4.4-rc3
- Receive buffer safety margin patch dropped
- Backchannel pr_err and pr_info converted to dprintk
- Backchannel spin locks converted to work queue-safe locks
- Fixed premature release of backchannel request buffer
- NFSv4.1 callbacks tested with for-4.5 server

---

Chuck Lever (10):
      xprtrdma: Fix additional uses of spin_lock_irqsave(rb_lock)
      xprtrdma: xprt_rdma_free() must not release backchannel reqs
      xprtrdma: Disable RPC/RDMA backchannel debugging messages
      xprtrdma: Move struct ib_send_wr off the stack
      xprtrdma: Introduce ro_unmap_sync method
      xprtrdma: Add ro_unmap_sync method for FRWR
      xprtrdma: Add ro_unmap_sync method for FMR
      xprtrdma: Add ro_unmap_sync method for all-physical registration
      xprtrdma: Invalidate in the RPC reply handler
      xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').


 net/sunrpc/xprtrdma/backchannel.c  |   22 ++---
 net/sunrpc/xprtrdma/fmr_ops.c      |   64 +++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |  174 +++++++++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/physical_ops.c |   13 +++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   16 +++
 net/sunrpc/xprtrdma/transport.c    |    3 +
 net/sunrpc/xprtrdma/verbs.c        |   13 +--
 net/sunrpc/xprtrdma/xprt_rdma.h    |   14 ++-
 8 files changed, 271 insertions(+), 48 deletions(-)

--
Chuck Lever
