Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34322 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbcANVJd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2016 16:09:33 -0500
Received: by mail-ob0-f172.google.com with SMTP id vt7so94169934obb.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jan 2016 13:09:32 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 14 Jan 2016 16:09:32 -0500
Message-ID: <CAHQdGtRkayaA2CabCULTWP3Dq5q_j_0QTzQi6=JQjCetW85G1A@mail.gmail.com>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 74bf8efb5fa6e958d2d7c7917b8bb672085ec0c6:

  Linux 4.4-rc7 (2015-12-27 18:17:37 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.5-1

for you to fetch changes up to 44aab3e09ef947e546ee61c5082c41b86dd15e53:

  NFS: Fix a compile warning about unused variable in
nfs_generic_pg_pgios() (2016-01-08 08:12:47 -0500)

Please note that Stephen saw a conflict between commits:
 926ea40a7ee2 ("NFSv4: Fix a compile warning about no prototype for
nfs4_ioctl()")
and
  04b38d601239 ("vfs: pull btrfs clone API to vfs layer")
from Al's vfs tree. The fixup should be trivial.

Cheers
  Trond


----------------------------------------------------------------
NFS client updates for Linux 4.5

Highlights include:

Stable fixes:
- Fix a regression in the SunRPC socket polling code
- Fix the attribute cache revalidation code
- Fix race in __update_open_stateid()
- Fix an lo->plh_block_lgets imbalance in layoutreturn
- Fix an Oopsable typo in ff_mirror_match_fh()

Features:
- pNFS layout recall performance improvements.
- pNFS/flexfiles: Support server-supplied layoutstats sampling period

Bugfixes + cleanups:
- NFSv4: Don't perform cached access checks before we've OPENed the file
- Fix starvation issues with background flushes
- Reclaim writes should be flushed as unstable writes if there are already
  entries in the commit lists
- Various bugfixes from Chuck to fix NFS/RDMA send queue ordering problems
- Ensure that we propagate fatal layoutget errors back to the application
- Fixes for sundry flexfiles layoutstats bugs
- Fix files/flexfiles to not cache invalidated layouts in the DS commit buckets

----------------------------------------------------------------
Andrew Elble (3):
      nfs: fix missing assignment in nfs4_sequence_done tracepoint
      nfs: Fix race in __update_open_stateid()
      nfs: machine credential support for additional operations

Benjamin Coddington (1):
      NFS: Use wait_on_atomic_t() for unlock after readahead

Chuck Lever (10):
      xprtrdma: Fix additional uses of spin_lock_irqsave(rb_lock)
      xprtrdma: xprt_rdma_free() must not release backchannel reqs
      xprtrdma: Disable RPC/RDMA backchannel debugging messages
      xprtrdma: Move struct ib_send_wr off the stack
      xprtrdma: Introduce ro_unmap_sync method
      xprtrdma: Add ro_unmap_sync method for FRWR
      xprtrdma: Add ro_unmap_sync method for FMR
      xprtrdma: Add ro_unmap_sync method for all-physical registration
      xprtrdma: Invalidate in the RPC reply handler
      xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').

Dan Carpenter (2):
      xprtrdma: clean up some curly braces
      xprtrdma: checking for NULL instead of IS_ERR()

Jeff Layton (1):
      nfs: add new tracepoint for pnfs_update_layout

Olga Kornievskaia (2):
      Adding stateid information to tracepoints
      Adding tracepoint to cached open

Peng Tao (9):
      NFS42: handle layoutstats stateid error
      NFS41: pop some layoutget errors to application
      nfs: clean up rest of reqs when failing to add one
      nfs: centralize pgio error cleanup
      nfs: handle request add failure properly
      nfs: only remove page from mapping if launder_page fails
      NFS41: map NFS4ERR_LAYOUTUNAVAILABLE to ENODATA
      pnfs/flexfiles: do not mark delay-like status as DS failure
      pnfs/flexfiles: count io stat in rpc_count_stats callback

Stefan Hajnoczi (1):
      SUNRPC: drop unused xs_reclassify_socketX() helpers

Trond Myklebust (42):
      NFS: Allow the combination pNFS and labeled NFS
      NFSv4: Fix unused variable warnings in nfs4_init_*_client_string()
      pNFS: Modify pnfs_update_layout tracepoints to use layout stateid
      NFSv4: Don't perform cached access checks before we've OPENed the file
      NFSv4.1/pnfs: Fixup an lo->plh_block_lgets imbalance in layoutreturn
      NFS: Background flush should not be low priority
      NFS: Flush reclaim writes using FLUSH_COND_STABLE
      pNFS/flexfiles: Support server-supplied layoutstats sampling period
      pNFS/flexfiles: Don't prevent flexfiles client from retrying LAYOUTGET
      pNFS/flexfiles: Don't mark the entire layout as failed, when returning it
      pNFS/flexfiles: Fix a statistics gathering imbalance
      pNFS: Add flag to track if we've called
nfs4_ff_layout_stat_io_start_read/write
      pNFS/flexfiles: Ensure we record layoutstats even if RPC is
terminated early
      pNFS: Ensure nfs4_layoutget_prepare returns the correct error
      NFSv4.1/pNFS: Add a helper to mark the layout as returned
      pNFS: If we have to delay the layout callback, mark the layout for return
      NFSv4.1/pNFS: Ensure we enforce RFC5661 Section 12.5.5.2.1
      NFSv4.1/pNFS: Don't return NFS4ERR_DELAY unnecessarily in CB_LAYOUTRECALL
      NFSv4: List stateid information in the callback tracepoints
      Merge tag 'nfs-rdma-4.5' of git://git.linux-nfs.org/projects/anna/nfs-rdma
      Merge branch 'flexfiles'
      NFS: Ensure we revalidate attributes before using execute_ok()
      NFS: Fix attribute cache revalidation
      pNFS/flexfiles: Fix an Oopsable typo in ff_mirror_match_fh()
      SUNRPC: Fix a missing break in rpc_anyaddr()
      NFS/pNFS: Fix up pNFS write reschedule layering violations and bugs
      NFS: Allow multiple commit requests in flight per file
      NFSv4.1/pNFS: Don't queue up a new commit if the layout segment is invalid
      NFS: Relax requirements in nfs_flush_incompatible
      NFSv4.1/pNFS: Don't pass stateids by value to pnfs_send_layoutreturn()
      NFSv4.1/pNFS: Use nfs4_stateid_copy for copying stateids
      NFSv4.1/pNFS: pnfs_mark_matching_lsegs_return() should set the iomode
      NFSv4.1/pNFS: pnfs_error_mark_layout_for_return() must always
return layout
      NFSv4.1/pNFS: Fix a race in initiate_file_draining()
      NFSv4.1/pNFS: Cleanup pnfs_mark_matching_lsegs_invalid()
      NFSv4.1/pnfs: Cleanup copying of pnfs_layout_range structures
      NFSv4.1/pNFS: Cleanup constify struct pnfs_layout_range arguments
      Merge branch 'pnfs_generic'
      SUNRPC: Fixup socket wait for memory
      Merge branch 'bugfixes'
      NFSv4: Fix a compile warning about no prototype for nfs4_ioctl()
      NFS: Fix a compile warning about unused variable in nfs_generic_pg_pgios()

Wei Tang (1):
      nfs: do not initialise statics to 0

 fs/nfs/callback_proc.c                    |  52 +++-
 fs/nfs/dir.c                              |  21 +-
 fs/nfs/direct.c                           |  48 +++-
 fs/nfs/file.c                             |   6 +-
 fs/nfs/filelayout/filelayout.c            |  18 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 205 ++++++++++----
 fs/nfs/flexfilelayout/flexfilelayout.h    |   1 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  16 +-
 fs/nfs/inode.c                            |  78 ++++--
 fs/nfs/internal.h                         |  39 ++-
 fs/nfs/nfs42proc.c                        |  29 +-
 fs/nfs/nfs4file.c                         |   2 +-
 fs/nfs/nfs4proc.c                         |  71 +++--
 fs/nfs/nfs4sysctl.c                       |   2 +-
 fs/nfs/nfs4trace.c                        |   1 +
 fs/nfs/nfs4trace.h                        | 431 ++++++++++++++++++++++++++++--
 fs/nfs/nfstrace.h                         |   1 -
 fs/nfs/pagelist.c                         | 126 ++++-----
 fs/nfs/pnfs.c                             | 180 ++++++++-----
 fs/nfs/pnfs.h                             |  54 ++--
 fs/nfs/pnfs_nfs.c                         |  10 +-
 fs/nfs/read.c                             |  43 +--
 fs/nfs/write.c                            | 133 +++++----
 include/linux/nfs4.h                      |  14 +
 include/linux/nfs_fs.h                    |  23 +-
 include/linux/nfs_fs_sb.h                 |   1 +
 include/linux/nfs_xdr.h                   |   6 +-
 net/sunrpc/clnt.c                         |   1 +
 net/sunrpc/xprtrdma/backchannel.c         |  26 +-
 net/sunrpc/xprtrdma/fmr_ops.c             |  64 +++++
 net/sunrpc/xprtrdma/frwr_ops.c            | 174 ++++++++++--
 net/sunrpc/xprtrdma/physical_ops.c        |  13 +
 net/sunrpc/xprtrdma/rpc_rdma.c            |  16 ++
 net/sunrpc/xprtrdma/transport.c           |   3 +
 net/sunrpc/xprtrdma/verbs.c               |  16 +-
 net/sunrpc/xprtrdma/xprt_rdma.h           |  14 +-
 net/sunrpc/xprtsock.c                     |  63 ++---
 37 files changed, 1481 insertions(+), 520 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
