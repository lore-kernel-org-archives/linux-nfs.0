Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33276 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbcCVSg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2016 14:36:58 -0400
Received: by mail-io0-f172.google.com with SMTP id c63so72295384iof.0
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2016 11:36:58 -0700 (PDT)
Message-ID: <1458671795.3302.3.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client changes for Linux 4.6
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Tue, 22 Mar 2016 14:36:35 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit fc77dbd34c5c99bce46d40a2491937c3bcbd10af:

  Linux 4.5-rc6 (2016-02-28 08:41:20 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.6-1

for you to fetch changes up to f35592a97460f57d1089fd674176e9f34ba311f2:

  nfs/blocklayout: make sure making a aligned read request (2016-03-21 12:39:46 -0400)

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 4.6

Highlights include:

Features:
- Add support for multiple NFSv4.1 callbacks in flight
- Initial patchset for RPC multipath support
- Adapt RPC/RDMA to use the new completion queue API

Bugfixes and cleanups:
- nfs4: nfs4_ff_layout_prepare_ds should return NULL if connection failed
- Cleanups to remove nfs_inode_dio_wait and nfs4_file_fsync
- Fix RPC/RDMA credit accounting
- Properly handle RDMA_ERROR replies
- xprtrdma: Do not wait if ib_post_send() fails
- xprtrdma: Segment head and tail XDR buffers on page boundaries
- xprtrdma cleanups for dprintk, physical_op_map and unused macros

----------------------------------------------------------------
Andy Adamson (1):
      NFS add callback_ops to nfs4_proc_bind_conn_to_session_callback

Christoph Hellwig (2):
      nfs: remove nfs4_file_fsync
      nfs: remove nfs_inode_dio_wait

Chuck Lever (11):
      xprtrdma: Clean up unused RPCRDMA_INLINE_PAD_THRESH macro
      xprtrdma: Clean up physical_op_map()
      xprtrdma: Clean up dprintk format string containing a newline
      xprtrdma: Segment head and tail XDR buffers on page boundaries
      xprtrdma: Do not wait if ib_post_send() fails
      rpcrdma: Add RPCRDMA_HDRLEN_ERR
      xprtrdma: Properly handle RDMA_ERROR replies
      xprtrdma: Serialize credit accounting again
      xprtrdma: Use new CQ API for RPC-over-RDMA client receive CQs
      xprtrdma: Use an anonymous union in struct rpcrdma_mw
      xprtrdma: Use new CQ API for RPC-over-RDMA client send CQs

Jeff Layton (1):
      nfs4: nfs4_ff_layout_prepare_ds should return NULL if connection failed

Kinglong Mee (1):
      nfs/blocklayout: make sure making a aligned read request

Trond Myklebust (22):
      NFSv4.x: Remove hard coded slotids in callback channel
      NFSv4.x: CB_SEQUENCE should return NFS4ERR_DELAY if still executing
      NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel
      NFSv4.x: Fix wraparound issues when validing the callback sequence id
      NFSv4.x: Allow multiple callbacks in flight
      SUNRPC: Remove unused function rpc_task_reset_client
      SUNRPC: Reorder rpc_task to put waitqueue related info in same cachelines
      SUNRPC: Uninline xprt_get(); It isn't performance critical.
      SUNRPC: Make freeing of struct xprt rcu-safe
      NFSv4.x: Fix NFS4ERR_RETRY_UNCACHED_REP in nfs4_callback_sequence
      SUNRPC: Add a structure to track multiple transports
      SUNRPC: Make rpc_clnt store the multipath iterators
      SUNRPC: Use the multipath iterator to assign a transport to each task
      SUNRPC: Allow caller to specify the transport to use
      SUNRPC: Add a helper to apply a function to all the rpc_clnt's transports
      SUNRPC: Make NFS swap work with multipath
      NFSv4.1: nfs4_proc_bind_conn_to_session must iterate over all connections
      SUNRPC: Allow addition of new transports to a struct rpc_clnt
      pnfs/NFSv4.1: Add multipath capabilities to pNFS flexfiles servers over NFSv3
      Merge branch 'nfsv41_cb'
      Merge branch 'multipath'
      Merge tag 'nfs-rdma-4.6-1' of git://git.linux-nfs.org/projects/anna/nfs-rdma

 fs/nfs/blocklayout/blocklayout.c          |  13 +-
 fs/nfs/callback.h                         |   3 +-
 fs/nfs/callback_proc.c                    |  69 +++--
 fs/nfs/callback_xdr.c                     |  12 +-
 fs/nfs/file.c                             |  12 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   2 +
 fs/nfs/inode.c                            |   2 +-
 fs/nfs/internal.h                         |   6 +-
 fs/nfs/nfs4file.c                         |  33 +--
 fs/nfs/nfs4proc.c                         |  63 +++-
 fs/nfs/nfs4session.c                      |  54 +++-
 fs/nfs/nfs4session.h                      |   8 +
 fs/nfs/pnfs_nfs.c                         |  16 +-
 include/linux/sunrpc/clnt.h               |  18 +-
 include/linux/sunrpc/rpc_rdma.h           |  12 +-
 include/linux/sunrpc/sched.h              |  32 +-
 include/linux/sunrpc/xprt.h               |  22 +-
 include/linux/sunrpc/xprtmultipath.h      |  69 +++++
 include/linux/sunrpc/xprtrdma.h           |   2 -
 net/sunrpc/Makefile                       |   3 +-
 net/sunrpc/auth_gss/auth_gss.c            |   4 +-
 net/sunrpc/clnt.c                         | 328 ++++++++++++++++-----
 net/sunrpc/rpcb_clnt.c                    |  10 +-
 net/sunrpc/sched.c                        |   2 +
 net/sunrpc/xprt.c                         |  42 ++-
 net/sunrpc/xprtmultipath.c                | 475 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/fmr_ops.c             |  28 +-
 net/sunrpc/xprtrdma/frwr_ops.c            | 143 +++++----
 net/sunrpc/xprtrdma/physical_ops.c        |   1 -
 net/sunrpc/xprtrdma/rpc_rdma.c            | 108 +++++--
 net/sunrpc/xprtrdma/verbs.c               | 204 ++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h           |  14 +-
 net/sunrpc/xprtsock.c                     |   4 +-
 33 files changed, 1327 insertions(+), 487 deletions(-)
 create mode 100644 include/linux/sunrpc/xprtmultipath.h
 create mode 100644 net/sunrpc/xprtmultipath.c

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



