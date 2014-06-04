Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:57300 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbaFDN6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 09:58:21 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so15332247qgd.4
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 06:58:21 -0700 (PDT)
Message-ID: <538F25FA.7030805@gmail.com>
Date: Wed, 04 Jun 2014 09:58:18 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux- >> \"linux-nfs@vger.kernel.org\"" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL v3] Please pull NFS client RDMA changes for 3.16
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

The following changes since commit b5968725f46d9535e908689bd04bf676f71138bb:

  Push the file layout driver into a subdirectory (2014-05-29 20:21:56 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-3.16

for you to fetch changes up to c93c62231cf55df4a26bd08937efeea97e6fc5e8:

  xprtrdma: Disconnect on registration failure (2014-06-04 08:56:53 -0400)

Changes since v2:
	- Rebase onto nfs-for-next to fix bad commits in linux-next

There are no RDMA-related code changes since v2.

Anna

----------------------------------------------------------------
NFS: Client side changes for RDMA

These patches are mostly cleanups and bugfixes for using RDMA as an
over-the-wire transport.

Highlights include:

- Remove obsolete memory registration modes.
- Removing BUG_ON()s to keep client's running.
- Fix deadlocks, NULL-pointer dereferences, and memory leaks.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Allen Andrews (1):
      nfs-rdma: Fix for FMR leaks

Chuck Lever (21):
      xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process context
      xprtrdma: Remove BOUNCEBUFFERS memory registration mode
      xprtrdma: Remove MEMWINDOWS registration modes
      xprtrdma: Remove REGISTER memory registration mode
      xprtrdma: Fall back to MTHCAFMR when FRMR is not supported
      xprtrdma: mount reports "Invalid mount option" if memreg mode not supported
      xprtrdma: Simplify rpcrdma_deregister_external() synopsis
      xprtrdma: Make rpcrdma_ep_destroy() return void
      xprtrdma: Split the completion queue
      xprtrmda: Reduce lock contention in completion handlers
      xprtrmda: Reduce calls to ib_poll_cq() in completion handlers
      xprtrdma: Limit work done by completion handler
      xprtrdma: Reduce the number of hardway buffer allocations
      xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting
      xprtrdma: Remove Tavor MTU setting
      xprtrdma: Use macros for reconnection timeout constants
      xprtrdma: Reset connection timeout after successful reconnect
      SUNRPC: Move congestion window constants to header file
      xprtrdma: Avoid deadlock when credit window is reset
      xprtrdma: Remove BUG_ON() call sites
      xprtrdma: Disconnect on registration failure

Shirley Ma (1):
      xprtrdma: Allocate missing pagelist

Steve Wise (1):
      xprtrdma: mind the device's max fast register page list depth

 include/linux/sunrpc/xprt.h     |   6 ++
 net/sunrpc/xprt.c               |  28 +++------
 net/sunrpc/xprtrdma/rpc_rdma.c  | 119 +++++++++++++++++---------------------
 net/sunrpc/xprtrdma/transport.c |  90 ++++++++++-------------------
 net/sunrpc/xprtrdma/verbs.c     | 753 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------------------------------------------------------------------------------------------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |  17 ++++--
 6 files changed, 411 insertions(+), 602 deletions(-)
