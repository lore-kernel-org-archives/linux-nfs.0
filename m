Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5901 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbaGaUyO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 16:54:14 -0400
Message-ID: <53DAACF2.7040307@Netapp.com>
Date: Thu, 31 Jul 2014 16:54:10 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client RDMA changes for 3.17
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

The following changes since commit 9a3c4145af32125c5ee39c0272662b47307a8323:

  Linux 3.16-rc6 (2014-07-20 21:04:16 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git nfs-rdma

for you to fetch changes up to 8079fb785e34de6dff34bd846b8b79c212861edf:

  xprtrdma: Handle additional connection events (2014-07-31 16:22:59 -0400)

Thanks!
Anna

----------------------------------------------------------------
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

Yan Burman (1):
      xprtrdma: Fix DMA-API-DEBUG warning by checking dma_map result

 include/linux/sunrpc/xprtrdma.h |   2 -
 net/sunrpc/xprtrdma/rpc_rdma.c  |  83 +++++------
 net/sunrpc/xprtrdma/transport.c |  17 ++-
 net/sunrpc/xprtrdma/verbs.c     | 739 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |  61 ++++++--
 5 files changed, 604 insertions(+), 298 deletions(-)
