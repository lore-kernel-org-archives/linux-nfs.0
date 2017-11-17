Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34330 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936410AbdKQVvC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 16:51:02 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Subject: [GIT PULL] Please pull NFS client fixes for 4.15
Message-ID: <561a7df8-6778-9d5f-ffb6-6806a17a1487@gmail.com>
Date: Fri, 17 Nov 2017 16:50:57 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 33d930e59a98fa10a0db9f56c7fa2f21a4aef9b9:

  Linux 4.14-rc5 (2017-10-15 21:01:12 -0400)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.15-1

for you to fetch changes up to fcfa447062b2061e11f68b846d61cbfe60d0d604:

  NFS: Revert "NFS: Move the flock open mode check into nfs_flock()" (2017-11-17 16:43:52 -0500)

----------------------------------------------------------------
Stable bugfixes:
- Revalidate "." and ".." correctly on open
- Avoid RCU usage in tracepoints
- Fix ugly referral attributes
- Fix a typo in nomigration mount option
- Revert "NFS: Move the flock open mode check into nfs_flock()"

Features:
- Implement a stronger send queue accounting system for NFS over RDMA
- Switch some atomics to the new refcount_t type

Other bugfixes and cleanups:
- Clean up access mode bits
- Remove special-case revalidations in nfs_opendir()
- Improve invalidating NFS over RDMA memory for async operations that time out
- Handle NFS over RDMA replies with a worqueue
- Handle NFS over RDMA sends with a workqueue
- Fix up replaying interrupted requests
- Remove dead NFS over RDMA definitions
- Update NFS over RDMA copyright information
- Be more consistent with bool initialization and comparisons
- Mark expected switch fall throughs
- Various sunrpc tracepoint cleanups
- Fix various OPEN races
- Fix a typo in nfs_rename()
- Use common error handling code in nfs_lock_and_join_request()
- Check that some structures are properly cleaned up during net_exit()
- Remove net pointer from dprintk()s

Have a good weekend!
Anna
----------------------------------------------------------------
Anna Schumaker (3):
      NFS: Create NFS_ACCESS_* flags
      NFS: Don't compare apples to elephants to determine access bits
      NFS: Avoid RCU usage in tracepoints

Benjamin Coddington (1):
      NFS: Revert "NFS: Move the flock open mode check into nfs_flock()"

Chuck Lever (25):
      xprtrdma: Don't defer fencing an async RPC's chunks
      xprtrdma: Use ro_unmap_sync in xprt_rdma_send_request
      xprtrdma: Remove ro_unmap_safe
      xprtrdma: Throw away reply when version is unrecognized
      xprtrdma: Move decoded header fields into rpcrdma_rep
      xprtrdma: Refactor rpcrdma_reply_handler some more
      xprtrdma: Invoke rpcrdma_reply_handler directly from RECV completion
      xprtrdma: Decode credits field in rpcrdma_reply_handler
      xprtrdma: Clean up SGE accounting in rpcrdma_prepare_msg_sges()
      xprtrdma: Fix error handling in rpcrdma_prepare_msg_sges()
      xprtrdma: Change return value of rpcrdma_prepare_send_sges()
      xprtrdma: "Unoptimize" rpcrdma_prepare_hdr_sge()
      xprtrdma: Add data structure to manage RDMA Send arguments
      xprtrdma: Add a field of bit flags to struct rpcrdma_req
      xprtrdma: Refactor rpcrdma_deferred_completion
      xprtrdma: RPC completion should wait for Send completion
      xprtrdma: Remove atomic send completion counting
      xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode
      rpcrdma: Remove C structure definitions of XDR data items
      xprtrdma: Remove include for linux/prefetch.h
      xprtrdma: Update copyright notices
      SUNRPC: Fix parsing failure in trace points with XIDs
      sunrpc: Fix rpc_task_begin trace point
      sunrpc: Add rpc_request static trace point
      nfs: Fix ugly referral attributes

Elena Reshetova (8):
      fs, nfs: convert nfs4_pnfs_ds.ds_count from atomic_t to refcount_t
      fs, nfs: convert pnfs_layout_segment.pls_refcount from atomic_t to refcount_t
      fs, nfs: convert pnfs_layout_hdr.plh_refcount from atomic_t to refcount_t
      fs, nfs: convert nfs4_ff_layout_mirror.ref from atomic_t to refcount_t
      fs, nfs: convert nfs_cache_defer_req.count from atomic_t to refcount_t
      fs, nfs: convert nfs4_lock_state.ls_count from atomic_t to refcount_t
      fs, nfs: convert nfs_lock_context.count from atomic_t to refcount_t
      fs, nfs: convert nfs_client.cl_count from atomic_t to refcount_t

Gustavo A. R. Silva (2):
      net: sunrpc: mark expected switch fall-throughs
      NFS: super: mark expected switch fall-throughs

Joshua Watt (1):
      NFS: Fix typo in nomigration mount option

Markus Elfring (1):
      nfs/write: Use common error handling code in nfs_lock_and_join_requests()

NeilBrown (2):
      NFS: revalidate "." etc correctly on "open".
      NFS: remove special-case revalidate in nfs_opendir()

Thomas Meyer (1):
      NFS: Fix bool initialization/comparison

Trond Myklebust (14):
      NFSv4.1: Fix up replays of interrupted requests
      NFSv4: Fix OPEN / CLOSE race
      NFSv4: Add a tracepoint to document open stateid updates
      NFSv4: Fix open create exclusive when the server reboots
      NFS: Fix a typo in nfs_rename()
      NFSv4: Retry CLOSE and DELEGRETURN on NFS4ERR_OLD_STATEID.
      NFSv4: Don't try to CLOSE if the stateid 'other' field has changed
      pNFS: Retry NFS4ERR_OLD_STATEID errors in layoutreturn-on-close
      NFSv4: Retry NFS4ERR_OLD_STATEID errors in layoutreturn
      NFSv4: cleanup nfs4_close_done
      NFSv4: Clean up nfs4_delegreturn_done
      NFSv4: Check the open stateid when searching for expired state
      NFSv4: nfs_set_open_stateid must not trigger state recovery for closed state
      NFSv4: Replace closed stateids with the "invalid special stateid"

Vasily Averin (4):
      nfs client: exit_net cleanup check added
      sunrpc: exit_net cleanup check added
      nfs: remove net pointer from messages
      sunrpc: remove net pointer from messages

 fs/nfs/cache_lib.c                     |   6 +-
 fs/nfs/cache_lib.h                     |   2 +-
 fs/nfs/callback.c                      |  14 +-
 fs/nfs/callback_proc.c                 |   2 +-
 fs/nfs/client.c                        |  10 +-
 fs/nfs/delegation.c                    |  27 ++
 fs/nfs/delegation.h                    |   1 +
 fs/nfs/dir.c                           |  50 ++--
 fs/nfs/file.c                          |  18 +-
 fs/nfs/filelayout/filelayout.c         |  12 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |  20 +-
 fs/nfs/flexfilelayout/flexfilelayout.h |   3 +-
 fs/nfs/inode.c                         |  16 +-
 fs/nfs/nfs3proc.c                      |  17 +-
 fs/nfs/nfs4_fs.h                       |  12 +-
 fs/nfs/nfs4client.c                    |  12 +-
 fs/nfs/nfs4proc.c                      | 511 ++++++++++++++++++++++-----------
 fs/nfs/nfs4state.c                     |  53 +++-
 fs/nfs/nfs4trace.h                     |  26 +-
 fs/nfs/nfs4xdr.c                       |  12 +-
 fs/nfs/pnfs.c                          |  44 ++-
 fs/nfs/pnfs.h                          |  15 +-
 fs/nfs/pnfs_nfs.c                      |  10 +-
 fs/nfs/super.c                         |  14 +-
 fs/nfs/write.c                         |  17 +-
 include/linux/nfs_fs.h                 |  13 +-
 include/linux/nfs_fs_sb.h              |   3 +-
 include/linux/sunrpc/rpc_rdma.h        |  60 +---
 include/trace/events/sunrpc.h          |  79 +++--
 net/sunrpc/clnt.c                      |  14 +-
 net/sunrpc/rpc_pipe.c                  |   8 +-
 net/sunrpc/rpcb_clnt.c                 |   6 +-
 net/sunrpc/sched.c                     |   3 +-
 net/sunrpc/sunrpc_syms.c               |   3 +
 net/sunrpc/xprt.c                      |   1 +
 net/sunrpc/xprtrdma/backchannel.c      |   6 +-
 net/sunrpc/xprtrdma/fmr_ops.c          |  19 --
 net/sunrpc/xprtrdma/frwr_ops.c         |  27 --
 net/sunrpc/xprtrdma/rpc_rdma.c         | 363 ++++++++++++++---------
 net/sunrpc/xprtrdma/transport.c        |  19 +-
 net/sunrpc/xprtrdma/verbs.c            | 236 ++++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h        | 119 ++++----
 net/sunrpc/xprtsock.c                  |   4 +
 43 files changed, 1191 insertions(+), 716 deletions(-)
