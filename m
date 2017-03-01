Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:64536 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751810AbdCAUhb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Mar 2017 15:37:31 -0500
To: <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client changes for Linux 4.11
Message-ID: <86f246da-9bea-869f-ee6c-d7ea298d80f7@Netapp.com>
Date: Wed, 1 Mar 2017 15:37:02 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 566cf877a1fcb6d6dc0126b076aad062054c2637:

  Linux 4.10-rc6 (2017-01-29 14:25:17 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.11-1

for you to fetch changes up to ed92d8c137b7794c2c2aa14479298b9885967607:

  NFSv4: fix getacl ERANGE for some ACL buffer sizes (2017-02-23 17:23:35 -0500)

Highlights include:

Stable bugfixes:
- NFSv4: Fix memory and state leak in _nfs4_open_and_get_state
- xprtrdma: Fix Read chunk padding
- xprtrdma: Per-connection pad optimization
- xprtrdma: Disable pad optimization by default
- xprtrdma: Reduce required number of send SGEs
- nlm: Ensure callback code also checks that the files match
- pNFS/flexfiles: If the layout is invalid, it must be updated before retrying
- NFSv4: Fix reboot recovery in copy offload
- Revert "NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION replies to OP_SEQUENCE"
- NFSv4: fix getacl head length estimation
- NFSv4: fix getacl ERANGE for sum ACL buffer sizes

Features:
- Add and use dprintk_cont macros
- Various cleanups to NFS v4.x to reduce code duplication and complexity
- Remove unused cr_magic related code
- Improvements to sunrpc "read from buffer" code
- Clean up sunrpc timeout code and allow changing TCP timeout parameters
- Remove duplicate mw_list management code in xprtrdma
- Add generic functions for encoding and decoding xdr streams

Bugfixes:
- Clean up nfs_show_mountd_netid
- Fix sparse warnings
- Properly handle -ERESTARTSYS in nfs_rename()
- Check if register_shrinker() failed during rpcauth_init()
- Properly clean up procfs/pipefs entries
- Various NFS over RDMA related fixes
- Silence uninitialized variable warning in sunrpc


Thanks,
Anna

----------------------------------------------------------------
Anna Schumaker (21):
      NFS: Move nfs4_get_session() into nfs4_session.h
      NFS: Change nfs4_get_session() to take an nfs_client structure
      NFS: Change nfs4_setup_sequence() to take an nfs_client structure
      NFS: Use nfs4_setup_sequence() everywhere
      NFS: Create a single nfs4_setup_sequence() function
      NFS: Move slot-already-allocated check into nfs_setup_sequence()
      NFS: Lock the slot table from a single place during setup sequence
      NFS: Handle setup sequence task rescheduling in a single place
      NFS: Check if the slot table is draining from nfs4_setup_sequence()
      NFS: Merge the remaining setup_sequence functions
      NFS: Make trace_nfs4_setup_sequence() available to NFS v4.0
      NFS: Fix inconsistent indentation in nfs4proc.c
      NFS: Clean up _nfs4_is_integrity_protected()
      NFS: Remove nfs4_wait_for_completion_rpc_task()
      NFS: Return errors directly in _nfs4_opendata_reclaim_to_nfs4_state()
      NFS: Remove an extra if in _nfs4_recover_proc_open()
      NFS: Remove nfs4_recover_expired_lease()
      NFS: Remove unnecessary goto in nfs4_lookup_root_sec()
      NFS: No need to set and return status in nfs41_lock_expired()
      NFS: Clean up nfs41_same_server_scope()
      NFS: Return the comparison result directly in nfs41_match_stateid()

Benjamin Coddington (1):
      NFS: nfs_rename() handle -ERESTARTSYS dentry left behind

Chuck Lever (9):
      xprtrdma: Fix Read chunk padding
      xprtrdma: Per-connection pad optimization
      xprtrdma: Disable pad optimization by default
      xprtrdma: Reduce required number of send SGEs
      xprtrdma: Shrink send SGEs array
      xprtrdma: Properly recover FRWRs with in-flight FASTREG WRs
      xprtrdma: Handle stale connection rejection
      xprtrdma: Refactor management of mw_list field
      sunrpc: Allow xprt->ops->timer method to sleep

Dan Carpenter (1):
      sunrpc: silence uninitialized variable warning

J. Bruce Fields (1):
      NFSv4: fix getacl head length estimation

Joe Perches (1):
      sunrpc & nfs: Add and use dprintk_cont macros

Kinglong Mee (7):
      sunrpc: error out if register_shrinker fail
      sunrpc/nfs: cleanup procfs/pipefs entry in cache_detail
      sunrpc: rename NFS_NGROUPS to UNX_NGROUPS for auth unix
      sunrpc: remove dead codes of cr_magic in rpc_cred
      sunrpc: update the comments of sunrpc proc path
      sunrpc: record rpc client pointer in seq->private directly
      sunrpc: use simple_read_from_buffer for reading cache flush

NeilBrown (2):
      SUNRPC: two small improvements to rpcauth shrinker.
      NFS: tidy up nfs_show_mountd_netid

Nicholas Piggin (1):
      nfs: no PG_private waiters remain, remove waker

Trond Myklebust (17):
      NFSv4: Fix memory and state leak in _nfs4_open_and_get_state
      SUNRPC: Remove unused function rpc_get_timeout()
      SUNRPC: Refactor TCP socket timeout code into a helper function
      SUNRPC: Allow changing of the TCP timeout parameters on the fly
      NFSv4: Set the connection timeout to match the lease period
      nlm: Ensure callback code also checks that the files match
      SUNRPC: Add generic helpers for xdr_stream encode/decode
      NFSv4: Replace ad-hoc xdr encode/decode helpers with xdr_stream_* generics
      NFSv4: Replace the open coded decode_opaque_inline() with the new generic
      NFSv4: Replace callback string decode function with a generic
      NFSv4: Fix the underestimation of delegation XDR space reservation
      NFSv4: Remove bogus "struct nfs_client" argument from decode_ace()
      SUNRPC: Add a helper function xdr_stream_decode_string_dup()
      NFSv4: Clean up owner/group attribute decode
      pNFS/flexfiles: If the layout is invalid, it must be updated before retrying
      NFSv4: Fix reboot recovery in copy offload
      Revert "NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION replies to OP_SEQUENCE"

Wei Yongjun (2):
      pNFS/flexfiles: Make local symbol layoutreturn_ops static
      NFSv4: Fix warning for using 0 as NULL

Weston Andros Adamson (1):
      NFSv4: fix getacl ERANGE for some ACL buffer sizes

 fs/nfs/cache_lib.c                     |   3 +-
 fs/nfs/callback_xdr.c                  |  38 +---
 fs/nfs/dir.c                           |  36 ++-
 fs/nfs/filelayout/filelayout.c         |   6 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |  60 ++---
 fs/nfs/nfs42proc.c                     |  69 +++---
 fs/nfs/nfs4_fs.h                       |  15 +-
 fs/nfs/nfs4proc.c                      | 390 +++++++++++----------------------
 fs/nfs/nfs4renewd.c                    |   2 +-
 fs/nfs/nfs4session.h                   |   7 +
 fs/nfs/nfs4state.c                     |   2 +-
 fs/nfs/nfs4trace.h                     |  64 +++---
 fs/nfs/nfs4xdr.c                       | 187 +++++++---------
 fs/nfs/super.c                         |  21 +-
 fs/nfs/write.c                         |   8 +-
 include/linux/lockd/lockd.h            |   3 +-
 include/linux/sunrpc/auth.h            |   6 +-
 include/linux/sunrpc/cache.h           |  15 +-
 include/linux/sunrpc/clnt.h            |   6 +-
 include/linux/sunrpc/debug.h           |  58 +++--
 include/linux/sunrpc/xdr.h             | 179 +++++++++++++++
 include/linux/sunrpc/xprt.h            |   4 +
 include/linux/sunrpc/xprtsock.h        |   3 +
 net/sunrpc/auth.c                      |  15 +-
 net/sunrpc/auth_null.c                 |   3 -
 net/sunrpc/auth_unix.c                 |  18 +-
 net/sunrpc/cache.c                     |  68 ++----
 net/sunrpc/clnt.c                      |  51 +++--
 net/sunrpc/debugfs.c                   |  35 +--
 net/sunrpc/svcauth_unix.c              |   4 +-
 net/sunrpc/xdr.c                       |  34 +++
 net/sunrpc/xprt.c                      |   2 -
 net/sunrpc/xprtrdma/fmr_ops.c          |   5 +-
 net/sunrpc/xprtrdma/frwr_ops.c         |  11 +-
 net/sunrpc/xprtrdma/rpc_rdma.c         |  82 ++++---
 net/sunrpc/xprtrdma/transport.c        |   6 +-
 net/sunrpc/xprtrdma/verbs.c            |  96 +++-----
 net/sunrpc/xprtrdma/xprt_rdma.h        |  30 ++-
 net/sunrpc/xprtsock.c                  |  94 ++++++--
 39 files changed, 902 insertions(+), 834 deletions(-)
