Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35217 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbbDXQkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 12:40:06 -0400
Received: by iejt8 with SMTP id t8so87646854iej.2
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2015 09:40:05 -0700 (PDT)
Message-ID: <1429893602.11515.2.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client updates for 4.1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Fri, 24 Apr 2015 12:40:02 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Another set of mainly bugfixes and a couple of cleanups. No new
functionality in this round.

The following changes since commit
e42391cd048809d903291d07f86ed3934ce138e9:

  Linux 4.0-rc6 (2015-03-29 15:26:31 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
tags/nfs-for-4.1-1

for you to fetch changes up to f139b6c676c7e49b66016b28bf3f8ec5c54be891:

  Merge tag 'nfs-rdma-for-4.1-1' of
git://git.linux-nfs.org/projects/anna/nfs-rdma (2015-04-23 15:16:37
-0400)

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 4.1

Highlights include:

Stable patches:
- Fix a regression in /proc/self/mountstats
- Fix the pNFS flexfiles O_DIRECT support
- Fix high load average due to callback thread sleeping

Bugfixes:
- Various patches to fix the pNFS layoutcommit support
- Do not cache pNFS deviceids unless server notifications are enabled
- Fix a SUNRPC transport reconnection regression
- make debugfs file creation failure non-fatal in SUNRPC
- Another fix for circular directory warnings on NFSv4 "junctioned"
mountpoints
- Fix locking around NFSv4.2 fallocate() support
- Truncating NFSv4 file opens should also sync O_DIRECT writes
- Prevent infinite loop in rpcrdma_ep_create()

Features:
- Various improvements to the RDMA transport code's handling of memory
  registration
- Various code cleanups

----------------------------------------------------------------
Andre Przywara (1):
      fs/nfs: fix new compiler warning about boolean in switch

Anna Schumaker (7):
      NFS: Don't zap caches on fallocate()
      NFS: Reduce time spent holding the i_mutex during fallocate()
      nfs: Fetch MOUNTED_ON_FILEID when updating an inode
      NFS: Add a stub for GETDEVICELIST
      NFS: Remove CONFIG_NFS_V4 checks from nfs_idmap.h
      NFS: Move nfs_idmap.h into fs/nfs/
      NFS: Rename idmap.c to nfs4idmap.c

Arnd Bergmann (1):
      nfs: do not export discarded symbols

Benjamin Coddington (2):
      NFS: remount with security change should return EINVAL
      NFS: Don't attempt to decode missing directory entries

Chuck Lever (15):
      SUNRPC: Introduce missing well-known netids
      xprtrdma: Display IPv6 addresses and port numbers correctly
      xprtrdma: Perform a full marshal on retransmit
      xprtrdma: Byte-align FRWR registration
      xprtrdma: Prevent infinite loop in rpcrdma_ep_create()
      xprtrdma: Add vector of ops for each memory registration strategy
      xprtrdma: Add a "max_payload" op for each memreg mode
      xprtrdma: Add a "register_external" op for each memreg mode
      xprtrdma: Add a "deregister_external" op for each memreg mode
      xprtrdma: Add "init MRs" memreg op
      xprtrdma: Add "reset MRs" memreg op
      xprtrdma: Add "destroy MRs" memreg op
      xprtrdma: Add "open" memreg op
      xprtrdma: Handle non-SEND completions via a callout
      xprtrdma: Make rpcrdma_{un}map_one() into inline functions

Firo Yang (1):
      nfs: Remove unneeded casts in nfs

Jeff Layton (2):
      nfs: fix high load average due to callback thread sleeping
      sunrpc: make debugfs file creation failure non-fatal

Julia Lawall (1):
      NFSv4.1: don't export static symbol

Nicholas Mc Guire (2):
      SUNRPC: use jiffies_to_msecs for converting jiffies
      SUNRPC: fix build-warning due to format missmatch

Nicolas Iooss (1):
      Revert "nfs: replace nfs_add_stats with nfs_inc_stats when add
one"

Peng Tao (3):
      nfs: clean up nfs_direct_IO
      nfs: fix DIO good bytes calculation
      nfs: remove WARN_ON_ONCE from nfs_direct_good_bytes

Trond Myklebust (21):
      NFSv4: Append delegations to the per-client list instead of
prepending
      SUNRPC: Fix a regression when reconnecting
      NFSv4: Return delegations synchronously in evict_inode
      NFSv4.1: Convert pNFS deviceid to use kfree_rcu()
      NFSv4.1: Cleanup - don't opencode nfs4_put_deviceid_node()
      NFSv4.1: Allow getdeviceinfo to return notification info back to
caller
      NFSv4.1: Don't cache deviceids that have no notifications
      NFS: Fix free_deveiceid -> free_deviceid
      NFSv4: Allow tracing of NFSv4 fsync calls
      NFSv4: Return the delegation before returning the layout in
evict_inode()
      NFSv4.1/pnfs: Fix setting of layoutcommit last write byte
      NFSv4.1/pnfs: Refactor pnfs_set_layoutcommit()
      NFS: Add a helper to sync both O_DIRECT and buffered writes
      NFS: File unlock needs to be a metadata synchronisation point
      NFSv4: Truncating file opens should also sync O_DIRECT writes
      NFSv4.1/pnfs: Ensure that writes respect the O_SYNC flag when
doing O_DIRECT
      NFSv4.1/pnfs: Ensure we send layoutcommit before return-on-close
      NFSv4.1/pnfs: Separate out metadata and data consistency for pNFS
      NFS: Block new writes while syncing data in nfs_getattr()
      Merge branch 'bugfixes'
      Merge tag 'nfs-rdma-for-4.1-1' of
git://git.linux-nfs.org/projects/anna/nfs-rdma

 fs/nfs/Makefile                                 |   2 +-
 fs/nfs/blocklayout/blocklayout.c                |   1 +
 fs/nfs/blocklayout/dev.c                        |   2 +-
 fs/nfs/callback.c                               |   6 +-
 fs/nfs/client.c                                 |   1 -
 fs/nfs/delegation.c                             |   4 +-
 fs/nfs/dir.c                                    |   4 +
 fs/nfs/direct.c                                 |  39 +-
 fs/nfs/file.c                                   |   3 +-
 fs/nfs/filelayout/filelayout.c                  |  10 +-
 fs/nfs/filelayout/filelayoutdev.c               |   2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c          |  12 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c       |   2 +-
 fs/nfs/inode.c                                  |  36 +-
 fs/nfs/nfs42proc.c                              |  31 +-
 fs/nfs/nfs42xdr.c                               |  20 +-
 fs/nfs/nfs4client.c                             |   2 +-
 fs/nfs/nfs4file.c                               |  20 +-
 fs/nfs/{idmap.c => nfs4idmap.c}                 |   2 +-
 include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h |  13 +-
 fs/nfs/nfs4proc.c                               |  23 +-
 fs/nfs/nfs4state.c                              |   2 +-
 fs/nfs/nfs4super.c                              |   7 +-
 fs/nfs/nfs4sysctl.c                             |   2 +-
 fs/nfs/nfs4xdr.c                                |  22 +-
 fs/nfs/nfstrace.c                               |   3 +
 fs/nfs/objlayout/objio_osd.c                    |   4 +-
 fs/nfs/pnfs.c                                   |  68 +--
 fs/nfs/pnfs.h                                   |  24 +-
 fs/nfs/pnfs_dev.c                               |  21 +-
 fs/nfs/pnfs_nfs.c                               |  12 +-
 fs/nfs/read.c                                   |   2 +-
 fs/nfs/super.c                                  |   4 +-
 fs/nfs/write.c                                  |  15 +-
 include/linux/nfs_fs.h                          |   1 +
 include/linux/nfs_xdr.h                         |   6 +
 include/linux/sunrpc/debug.h                    |  18 +-
 include/linux/sunrpc/msg_prot.h                 |   8 +-
 include/linux/sunrpc/xprtrdma.h                 |   5 -
 include/uapi/linux/nfs_idmap.h                  |   2 +-
 net/sunrpc/clnt.c                               |   4 +-
 net/sunrpc/debugfs.c                            |  52 +-
 net/sunrpc/sched.c                              |   4 +-
 net/sunrpc/sunrpc_syms.c                        |   7 +-
 net/sunrpc/xprt.c                               |  29 +-
 net/sunrpc/xprtrdma/Makefile                    |   3 +-
 net/sunrpc/xprtrdma/fmr_ops.c                   | 208 +++++++
 net/sunrpc/xprtrdma/frwr_ops.c                  | 353 ++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c              |  94 ++++
 net/sunrpc/xprtrdma/rpc_rdma.c                  |  87 ++-
 net/sunrpc/xprtrdma/transport.c                 |  61 ++-
 net/sunrpc/xprtrdma/verbs.c                     | 699
++----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h                 |  90 ++-
 53 files changed, 1191 insertions(+), 961 deletions(-)
 rename fs/nfs/{idmap.c => nfs4idmap.c} (99%)
 rename include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h (94%)
 create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/physical_ops.c

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


