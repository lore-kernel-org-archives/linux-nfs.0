Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:42956 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751941AbeAWT2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Jan 2018 14:28:36 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFSoRDMA client side changes for 4.16
Message-ID: <e1e6ae05-89a3-c247-519f-a720c5a41303@Netapp.com>
Date: Tue, 23 Jan 2018 14:28:29 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 1291a0d5049dbc06baaaf66a9ff3f53db493b19b:

  Linux 4.15-rc4 (2017-12-17 18:59:59 -0800)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-rdma-for-4.16-1

for you to fetch changes up to 21ead9ff3dc72604d89499a1da5a18cc193ec4ff:

  SUNRPC: Micro-optimize __rpc_execute (2018-01-23 09:44:40 -0500)

----------------------------------------------------------------
These patches include a handful of bugfixes and cleanups in addition to adding
tracepoints to xprtrdma.  There are also a few generic sunrpc tracepoint fixes
tagged on at the end to keep the display format consistent.

Thanks,
Anna
----------------------------------------------------------------
Chuck Lever (34):
      xprtrdma: Fix buffer leak after transport set up failure
      xprtrdma: Fix backchannel allocation of extra rpcrdma_reps
      xprtrdma: Eliminate unnecessary lock cycle in xprt_rdma_send_request
      xprtrdma: Per-mode handling for Remote Invalidation
      xprtrdma: Remove ri_reminv_expected
      xprtrdma: Remove unused padding variables
      xprtrdma: Initialize the xprt address string array earlier
      xprtrdma: Remove another sockaddr_storage field (cdata::addr)
      xprtrdma: Support IPv6 in xprt_rdma_set_port
      xprtrdma: Move unmap-safe logic to rpcrdma_marshal_req
      xprtrdma: buf_free not called for CB replies
      xprtrdma: Split xprt_rdma_send_request
      xprtrdma: Don't clear RPC_BC_PA_IN_USE on pre-allocated rpc_rqst's
      xprtrdma: Replace all usage of "frmr" with "frwr"
      xprtrdma: Remove usage of "mw"
      xprtrdma: Introduce rpcrdma_mw_unmap_and_put
      rdma/ib: Add trace point macros to display human-readable values
      rpcrdma: infrastructure for static trace points in rpcrdma.ko
      xprtrdma: Add trace points in RPC Call transmit paths
      xprtrdma: Add trace points in the RPC Reply handler paths
      xprtrdma: Add trace points to instrument memory registration
      xprtrdma: Add trace points in reply decoder path
      xprtrdma: Add trace points to instrument memory invalidation
      xprtrdma: Add trace points to instrument MR allocation and recovery
      xprtrdma: Add trace points for connect events
      xprtrdma: Add trace points in the client-side backchannel code paths
      xprtrdma: Add trace points to instrument QP and CQ access upcalls
      xprtrdma: Instrument allocation/release of rpcrdma_req/rep objects
      xprtrdma: Fix "bytes registered" accounting
      xprtrdma: Correct some documenting comments
      SUNRPC: Trace xprt_timer events
      sunrpc: Format RPC events consistently for display
      SUNRPC: task_run_action should display tk_callback
      SUNRPC: Micro-optimize __rpc_execute

 include/linux/sunrpc/xprtrdma.h   |   2 +-
 include/trace/events/rdma.h       | 129 ++++++
 include/trace/events/rpcrdma.h    | 890 ++++++++++++++++++++++++++++++++++++++
 include/trace/events/sunrpc.h     |   8 +-
 net/sunrpc/sched.c                |  26 +-
 net/sunrpc/xprt.c                 |   2 +-
 net/sunrpc/xprtrdma/backchannel.c |  78 ++--
 net/sunrpc/xprtrdma/fmr_ops.c     | 157 ++++---
 net/sunrpc/xprtrdma/frwr_ops.c    | 329 +++++++-------
 net/sunrpc/xprtrdma/module.c      |  12 +-
 net/sunrpc/xprtrdma/rpc_rdma.c    | 162 +++----
 net/sunrpc/xprtrdma/transport.c   | 128 +++---
 net/sunrpc/xprtrdma/verbs.c       | 280 ++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h   | 116 ++---
 14 files changed, 1662 insertions(+), 657 deletions(-)
 create mode 100644 include/trace/events/rdma.h
 create mode 100644 include/trace/events/rpcrdma.h
