Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:47102 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759310AbaD3T3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:29:30 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V3 00/17] NFS/RDMA client-side patches
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 30 Apr 2014 15:29:26 -0400
Message-ID: <20140430191433.5663.16217.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes since V2:

 - Rebased on v3.15-rc3

 - "enable pad optimization" dropped. Testing showed Linux NFS/RDMA
   server does not support pad optimization yet.

 - "ALLPHYSICAL CONFIG" dropped. There is a lack of consensus on
   this one. Christoph would like ALLPHYSICAL removed, but the HPC
   community prefers keeping a performance-at-all-costs option. And,
   with most other registration modes now removed, ALLPHYSICAL is
   the mode of last resort if an adapter does not support FRMR or
   MTHCAFMR, since ALLPHYSICAL is universally supported. We will
   very likely revisit this later. I'm erring on the side of less
   churn and dropping this until the community agrees on how to
   move forward.

 - Added a patch to ensure there is always a valid ->qp if RPCs
   might awaken while the transport is disconnected.

 - Added a patch to clean up an MTU settings hack for a very old
   adapter model.

Test and review the "nfs-rdma-client" branch:

 git://git.linux-nfs.org/projects/cel/cel-2.6.git

Thanks!

---

Allen Andrews (1):
      nfs-rdma: Fix for FMR leaks

Chuck Lever (15):
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

Steve Wise (1):
      xprtrdma: mind the device's max fast register page list depth


 net/sunrpc/xprtrdma/rpc_rdma.c  |   63 +--
 net/sunrpc/xprtrdma/transport.c |   32 --
 net/sunrpc/xprtrdma/verbs.c     |  735 +++++++++++++++------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   16 +
 4 files changed, 320 insertions(+), 526 deletions(-)

-- 
Chuck Lever
