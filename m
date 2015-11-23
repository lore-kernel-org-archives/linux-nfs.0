Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35268 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbbKWWNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 17:13:51 -0500
Subject: [PATCH v1 0/9] NFS/RDMA client patches for 4.5
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Nov 2015 17:13:48 -0500
Message-ID: <20151123220627.32702.62667.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For 4.5, I'd like to address the send queue accounting and
invalidation/unmap ordering issues Jason brought up a couple of
months ago. Here's a first shot at that.

Also available in the "nfs-rdma-for-4.5" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.5

---

Chuck Lever (9):
      xprtrdma: Add a safety margin for receive buffers
      xprtrdma: Move struct ib_send_wr off the stack
      xprtrdma: Introduce ro_unmap_sync method
      xprtrdma: Add ro_unmap_sync method for FRWR
      xprtrdma: Add ro_unmap_sync method for FMR
      xprtrdma: Add ro_unmap_sync method for all-physical registration
      SUNRPC: Introduce xprt_commit_rqst()
      xprtrdma: Invalidate in the RPC reply handler
      xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').


 include/linux/sunrpc/xprt.h        |    1 
 net/sunrpc/xprt.c                  |   14 +++
 net/sunrpc/xprtrdma/fmr_ops.c      |   64 +++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |  175 +++++++++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/physical_ops.c |   13 +++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   21 ++++
 net/sunrpc/xprtrdma/verbs.c        |   12 +-
 net/sunrpc/xprtrdma/xprt_rdma.h    |   17 ++-
 8 files changed, 284 insertions(+), 33 deletions(-)

--
Chuck Lever
