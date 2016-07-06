Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33066 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466AbcGFWae (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:34 -0400
Received: by mail-io0-f174.google.com with SMTP id t74so8026281ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/28] NFS writeback performance patches for v4.8
Date: Wed,  6 Jul 2016 18:29:37 -0400
Message-Id: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are about improving the NFS I/O.

1) a new locking scheme between O_DIRECT and buffered I/O in order to allow
   parallelisation of O_DIRECT.
2) Remove instances of inode_lock that are preventing parallelism of writes
   and attribute revalidation.
3) Remove a redundant write throttling scheme that was conspiring with
   the FLUSH_COND_STABLE mode to drive writeback performance down.
4) Cache attributes more aggressively when we can assume close to open cache
   consistency.
5) Don't force data sync to disk where it is not needed. If attributes need
   to be up to date, we can usually get by with unstable writes to the server,
   particularly when we're using NFSv4 and can rely on stateids to cause
   operations to fail on a server reboot.
6) Fix a number of bugs around pNFS and attributes. Some (but not all)
   pNFS dialects may need data sync + layoutcommit in order to ensure that
   data and attribute updates are visible.
   In particular fix one bug was causing file size changes to be clobbered
   when layoutcommit was pending.

Trond Myklebust (28):
  NFS: Don't flush caches for a getattr that races with writeback
  NFS: Cache access checks more aggressively
  NFS: Cache aggressively when file is open for writing
  NFS: Kill NFS_INO_NFS_INO_FLUSHING: it is a performance killer
  NFS: writepage of a single page should not be synchronous
  NFS: Don't hold the inode lock across fsync()
  NFS: Don't call COMMIT in ->releasepage()
  pNFS/files: Fix layoutcommit after a commit to DS
  pNFS/flexfiles: Fix layoutcommit after a commit to DS
  pNFS/flexfiles: Clean up calls to pnfs_set_layoutcommit()
  pNFS: Files and flexfiles always need to commit before layoutcommit
  pNFS: Ensure we layoutcommit before revalidating attributes
  pNFS: pnfs_layoutcommit_outstanding() is no longer used when
    !CONFIG_NFS_V4_1
  NFS: Fix O_DIRECT verifier problems
  NFS: Ensure we reset the write verifier 'committed' value on resend.
  NFS: Remove racy size manipulations in O_DIRECT
  NFS Cleanup: move call to generic_write_checks() into fs/nfs/direct.c
  NFS: Move buffered I/O locking into nfs_file_write()
  NFS: Do not serialise O_DIRECT reads and writes
  NFS: Cleanup nfs_direct_complete()
  NFS: Remove redundant waits for O_DIRECT in fsync() and write_begin()
  NFS: Remove unused function nfs_revalidate_mapping_protected()
  NFS: Do not aggressively cache file attributes in the case of O_DIRECT
  NFS: Getattr doesn't require data sync semantics
  NFSv4.2: Fix a race in nfs42_proc_deallocate()
  NFSv4.2: Fix writeback races in nfs4_copy_file_range
  NFSv4.2: llseek(SEEK_HOLE) and llseek(SEEK_DATA) don't require data
    sync
  NFS nfs_vm_page_mkwrite: Don't freeze me, Bro...

 fs/nfs/Makefile                        |   2 +-
 fs/nfs/dir.c                           |  52 +++++++-----
 fs/nfs/direct.c                        |  93 +++++++--------------
 fs/nfs/file.c                          |  96 ++++++---------------
 fs/nfs/filelayout/filelayout.c         |  12 +--
 fs/nfs/flexfilelayout/flexfilelayout.c |  23 +++---
 fs/nfs/inode.c                         | 133 ++++++++++++++---------------
 fs/nfs/internal.h                      |  40 +++++++++
 fs/nfs/io.c                            | 147 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs42proc.c                     |  21 ++++-
 fs/nfs/nfs4file.c                      |  14 +---
 fs/nfs/nfs4xdr.c                       |  11 ++-
 fs/nfs/nfstrace.h                      |   1 -
 fs/nfs/pnfs.c                          |   5 +-
 fs/nfs/pnfs.h                          |   7 --
 fs/nfs/pnfs_nfs.c                      |   7 ++
 fs/nfs/write.c                         |  33 +++++---
 include/linux/nfs_fs.h                 |   3 +-
 18 files changed, 420 insertions(+), 280 deletions(-)
 create mode 100644 fs/nfs/io.c

-- 
2.7.4

