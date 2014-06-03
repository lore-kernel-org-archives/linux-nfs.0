Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26813 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933055AbaFCP7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2014 11:59:53 -0400
Message-ID: <538DF0F5.8090500@netapp.com>
Date: Tue, 3 Jun 2014 11:59:49 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [GIT PULL] Please pull NFS client RDMA changes for 3.16
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

The following changes since commit fad01e866afdbe01a1f3ec06a39c3a8b9e197014:

  Linux 3.15-rc8 (2014-06-01 19:12:24 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git nfs-rdma

for you to fetch changes up to dc7e3277e118e5bfd4796dc7cb386c1162c7c647:

  xprtrdma: Disconnect on registration failure (2014-06-02 14:09:00 -0400)

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
