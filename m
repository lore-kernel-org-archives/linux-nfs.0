Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:53333 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416AbaGIQ4c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 12:56:32 -0400
Subject: [PATCH v2 00/21] NFS/RDMA client patches for 3.17
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Jul 2014 12:56:30 -0400
Message-ID: <20140709163326.3496.37893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main purpose of this series is to address connection drop
recovery issues by fixing FRMR re-use to make it less likely the
client will deadlock due to a memory management operation error.

Some clean-ups and other fixes are present as well.

See topic branch nfs-rdma-for-3.17 in

 git://git.linux-nfs.org/projects/cel/cel-2.6.git

I tested with NFSv3 and NFSv4 on all three supported memory
registration modes. Used cthon04, iozone, and dbench with both
Solaris and Linux NFS/RDMA servers. Used xfstests with Linux.

v2:
Many patches from v1 have been written or replaced.

The MW ref counting approach in v1 is abandoned. Instead, I've
eliminated signaling FAST_REG_MR and LOCAL_INV, and added
appropriate recovery mechanisms after a transport reconnect that
should prevent rkey dis-synchrony entirely.

A couple of optimizations have been added, including:

 - Allocating each MW separately rather than carving each out of a
   large piece of contiguous memory

 - Now that the receive CQ upcall handler dequeues a bundle of CQEs
   at once, fire off the reply handler tasklet just once per upcall
   to reduce context switches and how often hard IRQs are disabled

Jury is still out on the latter.

---

Chuck Lever (21):
      xprtrdma: Fix panic in rpcrdma_register_frmr_external()
      xprtrdma: Protect ia->ri_id when unmapping/invalidating MRs
      xprtrdma: Limit data payload size for ALLPHYSICAL
      xprtrdma: Update rkeys after transport reconnect
      xprtrdma: On disconnect, don't ignore pending CQEs
      xprtrdma: Don't invalidate FRMRs if registration fails
      xprtrdma: Unclutter struct rpcrdma_mr_seg
      xprtrdma: Back off rkey when FAST_REG_MR fails
      xprtrdma: Chain together all MWs in same buffer pool
      xprtrdma: Properly handle exhaustion of the rb_mws list
      xprtrdma: Reset FRMRs when FAST_REG_MR is flushed by a disconnect
      xprtrdma: Reset FRMRs after a flushed LOCAL_INV Work Request
      xprtrdma: Don't post a LOCAL_INV in rpcrdma_register_frmr_external()
      xprtrdma: Disable completions for FAST_REG_MR Work Requests
      xprtrdma: Disable completions for LOCAL_INV Work Requests
      xprtrdma: Rename frmr_wr
      xprtrdma: Allocate each struct rpcrdma_mw separately
      xprtrdma: Schedule reply tasklet once per upcall
      xprtrdma: Make rpcrdma_ep_disconnect() return void
      xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
      xprtrdma: Handle additional connection events


 include/linux/sunrpc/xprtrdma.h |    2 
 net/sunrpc/xprtrdma/rpc_rdma.c  |   83 ++--
 net/sunrpc/xprtrdma/transport.c |   17 +
 net/sunrpc/xprtrdma/verbs.c     |  758 +++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   61 +++
 5 files changed, 618 insertions(+), 303 deletions(-)

--
Chuck Lever
