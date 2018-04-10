Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37117 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbeDJUrJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2018 16:47:09 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Subject: [GIT PULL] Please pull NFS client updates for 4.17
Message-ID: <176ac3d9-dc2a-0a90-b41a-eb8b5cf006f5@gmail.com>
Date: Tue, 10 Apr 2018 16:47:05 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 661e50bc853209e41a5c14a290ca4decc43cbfd1:

  Linux 4.16-rc4 (2018-03-04 14:54:11 -0800)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.17-1

for you to fetch changes up to 98de9ce6f6660d02aa72d7b9b17696fa68a2ed9b:

  NFS: advance nfs_entry cookie only after decoding completes successfully (2018-04-10 16:06:22 -0400)

----------------------------------------------------------------
Stable bugfixes:
- xprtrdma: Fix corner cases when handling device removal # v4.12+
- xprtrdma: Fix latency regression on NUMA NFS/RDMA clients # v4.15+

Features:
- New sunrpc tracepoint for RPC pings
- Finer grained NFSv4 attribute checking
- Don't unnecessarily return NFS v4 delegations

Other bugfixes and cleanups:
- Several other small NFSoRDMA cleanups
- Improvements to the sunrpc RTT measurements
- A few sunrpc tracepoint cleanups
- Various fixes for NFS v4 lock notifications
- Various sunrpc and NFS v4 XDR encoding cleanups
- Switch to the ida_simple API
- Fix NFSv4.1 exclusive create
- Forget acl cache after setattr operation
- Don't advance the nfs_entry readdir cookie if xdr decoding fails

Cheers,
Anna

----------------------------------------------------------------
Chuck Lever (16):
      xprtrdma: Fix latency regression on NUMA NFS/RDMA clients
      xprtrdma: Remove arbitrary limit on initiator depth
      xprtrdma: Remove xprt-specific connect cookie
      xprtrdma: ->send_request returns -EAGAIN when there are no free MRs
      xprtrdma: Reduce number of MRs created by rpcrdma_mrs_create
      xprtrdma: "Support" call-only RPCs
      xprtrdma: Chain Send to FastReg WRs
      xprtrdma: Move creation of rl_rdmabuf to rpcrdma_create_req
      SUNRPC: Move xprt_update_rtt callsite
      SUNRPC: Make RTT measurement more precise (Receive)
      SUNRPC: Make RTT measurement more precise (Send)
      SUNRPC: Make num_reqs a non-atomic integer
      sunrpc: Simplify synopsis of some trace points
      sunrpc: Add static trace point to report RPC latency stats
      sunrpc: Add static trace point to report result of RPC ping
      xprtrdma: Fix corner cases when handling device removal

Frank Sorenson (1):
      NFS: advance nfs_entry cookie only after decoding completes successfully

Jeff Layton (3):
      nfs4: always reset notified flag to false before repolling for lock
      nfs4: don't compare clientid in nfs4_wake_lock_waiter
      nfs4: wake any lock waiters on successful RECLAIM_COMPLETE

Matthew Wilcox (1):
      nfs: Use ida_simple API

Trond Myklebust (25):
      NFSv4: Fix nfs4_return_incompatible_delegation
      NFS: Move the delegation return down into nfs4_proc_link()
      NFS: Move the delegation return down into nfs4_proc_remove()
      NFS: Move delegation recall into the NFSv4 callback for rename_setup()
      NFS: Add a delegation return into nfs4_proc_unlink_setup()
      NFS: Move the delegation return down into _nfs4_do_setattr()
      NFS: Remove the unused return_delegation() callback
      NFSv4: Don't return the delegation when not needed by NFSv4.x (x>0)
      NFS: Convert NFS_INO_INVALID flags to unsigned long
      NFS: Don't force a revalidation of all attributes if change is missing
      NFS: Don't redirty the attribute cache in nfs_wcc_update_inode()
      NFS: Don't force unnecessary cache invalidation in nfs_update_inode()
      NFS: More fine grained attribute tracking
      NFSv4: Ignore change attribute invalidations if we hold a delegation
      SUNRPC: Add helpers for decoding opaque and string types
      SUNRPC: Add a helper for encoding opaque data inline
      NFSv4: Allow GFP_NOIO sleeps in decode_attr_owner/decode_attr_group
      NFSv4; Clean up XDR encoding of type bitmap4
      NFSv4: Clean up encode_attrs
      NFSv4: Add a helper to encode/decode struct timespec
      NFSv4: Don't ask for attributes when ACCESS is protected by a delegation
      NFSv4: Clean up CB_GETATTR encoding
      NFSv4: Fix the nfs_inode_set_delegation() arguments
      NFSv4: Declare the size up to date after it was set.
      NFSv4.1: Fix exclusive create

chendt (1):
      NFSv3/acl: forget acl cache after setattr

 fs/nfs/callback_xdr.c             |  37 ++----
 fs/nfs/delegation.c               |  52 ++++++--
 fs/nfs/delegation.h               |   7 +-
 fs/nfs/dir.c                      |  15 +--
 fs/nfs/inode.c                    | 138 +++++++++++----------
 fs/nfs/nfs3proc.c                 |  24 ++--
 fs/nfs/nfs3xdr.c                  |   7 +-
 fs/nfs/nfs4proc.c                 | 168 ++++++++++++++++++--------
 fs/nfs/nfs4state.c                |  22 ++--
 fs/nfs/nfs4xdr.c                  | 245 ++++++++++++++++++--------------------
 fs/nfs/proc.c                     |  19 ++-
 fs/nfs/unlink.c                   |   7 +-
 fs/nfs/write.c                    |   8 +-
 include/linux/nfs_fs.h            |  35 ++++--
 include/linux/nfs_xdr.h           |   9 +-
 include/linux/sunrpc/clnt.h       |   7 ++
 include/linux/sunrpc/xdr.h        |  94 +++++++++++++++
 include/linux/sunrpc/xprt.h       |   3 +-
 include/trace/events/sunrpc.h     | 106 ++++++++++++++---
 net/sunrpc/clnt.c                 |   8 +-
 net/sunrpc/sched.c                |  10 +-
 net/sunrpc/stats.c                |  16 ++-
 net/sunrpc/sunrpc.h               |   6 -
 net/sunrpc/xdr.c                  |  82 +++++++++++++
 net/sunrpc/xprt.c                 |  34 +++---
 net/sunrpc/xprtrdma/backchannel.c |   7 --
 net/sunrpc/xprtrdma/fmr_ops.c     |  13 +-
 net/sunrpc/xprtrdma/frwr_ops.c    |  53 ++++++---
 net/sunrpc/xprtrdma/rpc_rdma.c    |  32 +++--
 net/sunrpc/xprtrdma/transport.c   |  43 ++-----
 net/sunrpc/xprtrdma/verbs.c       |  44 ++++---
 net/sunrpc/xprtrdma/xprt_rdma.h   |   4 +-
 net/sunrpc/xprtsock.c             |   4 +
 33 files changed, 866 insertions(+), 493 deletions(-)
