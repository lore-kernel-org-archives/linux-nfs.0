Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:17218 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751854AbeFASIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 14:08:02 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull nfs-over-rdma updates for 4.18
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <14ba1e8e-0386-4142-1a95-daa484322bc8@Netapp.com>
Date: Fri, 1 Jun 2018 14:07:54 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes since commit 75bc37fefc4471e718ba8e651aa74673d4e0a9eb:

  Linux 4.17-rc4 (2018-05-06 16:57:38 -1000)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-rdma-for-4.18-1

for you to fetch changes up to 11d0ac16b02eab8cda32efcb51bfab452dab760b:

  xprtrdma: Remove transfertypes array (2018-06-01 13:56:30 -0400)

----------------------------------------------------------------
Stable patches:
- xprtrdma: Return -ENOBUFS when no pages are available

New features:
- Add ->alloc_slot() and ->free_slot() functions

Bugfixes and cleanups:
- Add missing SPDX tags to some files
- Try to fail mount quickly if client has no RDMA devices
- Create transport IDs in the correct network namespace
- Fix max_send_wr computation
- Clean up receive tracepoints
- Refactor receive handling
- Remove unused functions

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (19):
      xprtrdma: Add proper SPDX tags for NetApp-contributed source
      xprtrdma: Try to fail quickly if proto=rdma
      xprtrdma: Create transport's CM ID in the correct network namespace
      xprtrdma: Fix max_send_wr computation
      SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
      SUNRPC: Add a ->free_slot transport callout
      xprtrdma: Introduce ->alloc_slot call-out for xprtrdma
      xprtrdma: Make rpc_rqst part of rpcrdma_req
      xprtrdma: Clean up Receive trace points
      xprtrdma: Move Receive posting to Receive handler
      xprtrdma: Remove rpcrdma_ep_{post_recv, post_extra_recv}
      xprtrdma: Remove rpcrdma_buffer_get_req_locked()
      xprtrdma: Remove rpcrdma_buffer_get_rep_locked()
      xprtrdma: Make rpcrdma_sendctx_put_locked() a static function
      xprtrdma: Return -ENOBUFS when no pages are available
      xprtrdma: Move common wait_for_buffer_space call to parent function
      xprtrdma: Wait on empty sendctx queue
      xprtrdma: Add trace_xprtrdma_dma_map(mr)
      xprtrdma: Remove transfertypes array

 include/linux/sunrpc/rpc_rdma.h            |   1 +
 include/linux/sunrpc/xprt.h                |   6 ++++-
 include/linux/sunrpc/xprtrdma.h            |   1 +
 include/trace/events/rpcrdma.h             |  76 ++++++++++++++++++++++++++++++++++++++++++++--------------------
 net/sunrpc/clnt.c                          |   1 +
 net/sunrpc/xprt.c                          |  17 +++++++++------
 net/sunrpc/xprtrdma/backchannel.c          | 105 +++++++++++++++++++++++++++++++++-------------------------------------------------------
 net/sunrpc/xprtrdma/fmr_ops.c              |  23 ++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c             |  31 ++++++++++++++++++++++----
 net/sunrpc/xprtrdma/module.c               |   1 +
 net/sunrpc/xprtrdma/rpc_rdma.c             |  66 +++++++++++++++++++------------------------------------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   1 +
 net/sunrpc/xprtrdma/transport.c            |  64 +++++++++++++++++++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/verbs.c                | 291 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------------------------------------------------------------------------------------------------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h            |  26 ++++++++++------------
 net/sunrpc/xprtsock.c                      |   4 ++++
 16 files changed, 359 insertions(+), 355 deletions(-)
