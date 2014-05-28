Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:56211 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbaE1Oby (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:31:54 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 00/24] Series short description
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:31:51 -0400
Message-ID: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Updates since v4:

- Rebased on v3.15-rc7
- Addressed Trond's review comment in "Reset connection timeout..."
- Wake up RPC tasks only when cwnd is growing in "Avoid deadlock when..."
- Fix patch description of "Remove MEMWINDOWS registration modes"

Pull from the "nfs-rdma-client" branch of my git repo:

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

---

Allen Andrews (1):
      nfs-rdma: Fix for FMR leaks

Chuck Lever (21):
      xprtrdma: Disconnect on registration failure
      xprtrdma: Remove BUG_ON() call sites
      xprtrdma: Avoid deadlock when credit window is reset
      SUNRPC: Move congestion window constants to header file
      xprtrdma: Reset connection timeout after successful reconnect
      xprtrdma: Use macros for reconnection timeout constants
      xprtrdma: Remove Tavor MTU setting
      xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting
      xprtrdma: Reduce the number of hardway buffer allocations
      xprtrdma: Limit work done by completion handler
      xprtrmda: Reduce calls to ib_poll_cq() in completion handlers
      xprtrmda: Reduce lock contention in completion handlers
      xprtrdma: Split the completion queue
      xprtrdma: Make rpcrdma_ep_destroy() return void
      xprtrdma: Simplify rpcrdma_deregister_external() synopsis
      xprtrdma: mount reports "Invalid mount option" if memreg mode not supported
      xprtrdma: Fall back to MTHCAFMR when FRMR is not supported
      xprtrdma: Remove REGISTER memory registration mode
      xprtrdma: Remove MEMWINDOWS registration modes
      xprtrdma: Remove BOUNCEBUFFERS memory registration mode
      xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process context

Shirley Ma (1):
      xprtrdma: Allocate missing pagelist

Steve Wise (1):
      xprtrdma: mind the device's max fast register page list depth


 include/linux/sunrpc/xprt.h     |    6 
 net/sunrpc/xprt.c               |   28 -
 net/sunrpc/xprtrdma/rpc_rdma.c  |  119 +++---
 net/sunrpc/xprtrdma/transport.c |   90 ++---
 net/sunrpc/xprtrdma/verbs.c     |  753 ++++++++++++++++-----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   17 +
 6 files changed, 411 insertions(+), 602 deletions(-)

-- 
Chuck Lever
