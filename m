Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:34743 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaJFNDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 09:03:18 -0400
Received: by mail-qa0-f47.google.com with SMTP id cm18so3406740qab.34
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 06:03:16 -0700 (PDT)
Message-ID: <1412600594.3332.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Mon, 06 Oct 2014 09:03:14 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit cd9288ffaea4359d5cfe2b8d264911506aed26a4:

  NFSv4: Fix another bug in the close/open_downgrade code (2014-09-18 13:04:22 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.18-1

for you to fetch changes up to 72c23f0819977d37924af92a42a9b7fbfd1c95d8:

  Merge branch 'bugfixes' into linux-next (2014-09-30 17:21:41 -0400)

Please note the presence of the following 2 "non-NFS" patches which are
needed for Neil's nfs_release_page() deadlock avoidance:

cbbce8220949: SCHED: add some "wait..on_bit...timeout()" interfaces.
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Acked-by: Ingo Molnar <mingo@kernel.org>

and

a4796e37c12e: MM: export page_wakeup functions
Acked-by: Andrew Morton <akpm@linux-foundation.org>

Cheers
  Trond

----------------------------------------------------------------

NFS client updates for Linux 3.18

Highlights include:

Stable fixes:
- fix an NFSv4.1 state renewal regression
- fix open/lock state recovery error handling
- fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM fails
- fix statd when reconnection fails
- Don't wake tasks during connection abort
- Don't start reboot recovery if lease check fails
- fix duplicate proc entries

Features:
- pNFS block driver fixes and clean ups from Christoph
- More code cleanups from Anna
- Improve mmap() writeback performance
- Replace use of PF_TRANS with a more generic mechanism for avoiding
  deadlocks in nfs_release_page

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4.1: Fix an NFSv4.1 state renewal regression

Anna Schumaker (5):
      NFS: Clear up state owner lock usage
      NFS: Unconditionally enable commit code
      NFS: Move v3 declarations out of internal.h
      NFS: Remove v3 not compiled check from validate_mount_data()
      NFS: Move NFS v3 acl functions to nfs3_fs.h

Benjamin Coddington (2):
      SUNRPC: Don't wake tasks during connection abort
      lockd: Try to reconnect if statd has moved

Chris Perl (1):
      rpc: xs_bind - do not bind when requesting a random ephemeral port

Christoph Hellwig (32):
      nfs: cap request size to fit a kmalloced page array
      pnfs: do not pass uninitialized lsegs to ->free_lseg
      pnfs: don't check sequence on new stateids in layoutget
      pnfs: retry after a bad stateid error from layoutget
      pnfs: avoid using stale stateids after layoutreturn
      pnfs: allow splicing pre-encoded pages into the layoutcommit args
      pnfs/blocklayout: reject pnfs blocksize larger than page size
      pnfs/blocklayout: improve GETDEVICEINFO error reporting
      pnfs/blocklayout: plug block queues
      pnfs/blocklayout: correctly decrement extent length
      pnfs: force a layout commit when encountering busy segments during recall
      pnfs: add flag to force read-modify-write in ->write_begin
      pnfs: add return_range method
      pnfs/blocklayout: remove read-modify-write handling in bl_write_pagelist
      pnfs/blocklayout: don't set pages uptodate
      pnfs/blocklayout: rewrite extent tracking
      pnfs/blocklayout: implement the return_range method
      pnfs/blocklayout: return layouts on setattr
      pnfs: factor GETDEVICEINFO implementations
      pnfs: add a common GETDEVICELIST implementation
      pnfs: add a nfs4_get_deviceid helper
      pnfs/blocklayout: use the device id cache
      nfs: setattr can only change regular file sizes
      pnfs/blocklayout: remove some debugging
      pnfs/objlayout: fix endianess annotation in objio_alloc_deviceid_node
      pnfs: remove GETDEVICELIST implementation
      pnfs/blocklayout: allocate separate pages for the layoutcommit payload
      pnfs/blocklayout: move extent processing to blocklayout.c
      pnfs/blocklayout: refactor extent processing
      pnfs/blocklayout: move all rpc_pipefs related code into a single file
      pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing
      pnfs: enable CB_NOTIFY_DEVICEID support

David Howells (1):
      NFS: Fabricate fscache server index key correctly

Fabian Frederick (1):
      nfs: fix duplicate proc entries

Jason Baron (2):
      rpc: return sent and err from xs_sendpages()
      rpc: Add -EPERM processing for xs_udp_send_request()

Jeff Layton (2):
      nfs: fix RCU cl_xprt handling in nfs_swap_activate/deactivate
      nfs: add __acquires and __releases annotations to seqfile start/stop routines

NeilBrown (7):
      NFSv4: use exponential retry on NFS4ERR_DELAY for async requests.
      NFS: don't use STABLE writes during writeback.
      SCHED: add some "wait..on_bit...timeout()" interfaces.
      MM: export page_wakeup functions
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS: avoid waiting at all in nfs_release_page when congested.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()

Olga Kornievskaia (1):
      Fixing lease renewal

Peng Tao (3):
      nfs41: add a helper function to set layoutcommit after commit
      nfs/filelayout: set layoutcommit depending on write verifier
      nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return on truncation to smaller size

Stephen Rothwell (1):
      pnfs/blocklayout: include vmalloc.h for __vmalloc

Trond Myklebust (8):
      NFS: Fix a compile warning when !(CONFIG_NFS_V3 || CONFIG_NFS_V4)
      pNFS/blocklayout: Remove a couple of unused variables
      pnfs/blocklayout: Fix a 64-bit division/remainder issue in bl_map_stripe
      NFSv3: Fix missing includes of nfs3_fs.h
      SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
      NFSv4: Fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM fails
      NFSv4: fix open/lock state recovery error handling
      Merge branch 'bugfixes' into linux-next

 fs/lockd/mon.c                      |    6 +
 fs/nfs/blocklayout/Makefile         |    3 +-
 fs/nfs/blocklayout/blocklayout.c    | 1386 +++++++++++------------------------
 fs/nfs/blocklayout/blocklayout.h    |  213 +++---
 fs/nfs/blocklayout/blocklayoutdev.c |  384 ----------
 fs/nfs/blocklayout/blocklayoutdm.c  |  108 ---
 fs/nfs/blocklayout/dev.c            |  363 +++++++++
 fs/nfs/blocklayout/extent_tree.c    |  602 +++++++++++++++
 fs/nfs/blocklayout/extents.c        |  908 -----------------------
 fs/nfs/blocklayout/rpc_pipefs.c     |  285 +++++++
 fs/nfs/callback_proc.c              |   23 +-
 fs/nfs/client.c                     |    6 +-
 fs/nfs/direct.c                     |   14 -
 fs/nfs/file.c                       |   52 +-
 fs/nfs/filelayout/filelayout.c      |   34 +-
 fs/nfs/filelayout/filelayout.h      |    7 +-
 fs/nfs/filelayout/filelayoutdev.c   |  108 +--
 fs/nfs/fscache-index.c              |    3 +-
 fs/nfs/inode.c                      |    4 +-
 fs/nfs/internal.h                   |    7 -
 fs/nfs/nfs3_fs.h                    |   34 +
 fs/nfs/nfs3acl.c                    |    1 +
 fs/nfs/nfs3client.c                 |    1 +
 fs/nfs/nfs3proc.c                   |    1 +
 fs/nfs/nfs3super.c                  |    1 +
 fs/nfs/nfs4proc.c                   |  138 ++--
 fs/nfs/nfs4renewd.c                 |   12 +-
 fs/nfs/nfs4state.c                  |   18 +-
 fs/nfs/nfs4xdr.c                    |  179 +----
 fs/nfs/objlayout/objio_osd.c        |  113 ++-
 fs/nfs/objlayout/objlayout.c        |   70 --
 fs/nfs/objlayout/objlayout.h        |    5 -
 fs/nfs/pagelist.c                   |    8 +
 fs/nfs/pnfs.c                       |  105 ++-
 fs/nfs/pnfs.h                       |   50 +-
 fs/nfs/pnfs_dev.c                   |  150 ++--
 fs/nfs/super.c                      |   11 -
 fs/nfs/write.c                      |  150 ++--
 include/linux/nfs_fs.h              |   41 --
 include/linux/nfs_xdr.h             |   17 +-
 include/linux/pagemap.h             |   12 +-
 include/linux/sunrpc/xprt.h         |    1 +
 include/linux/wait.h                |    5 +-
 kernel/sched/wait.c                 |   36 +
 mm/filemap.c                        |   21 +-
 net/sunrpc/clnt.c                   |    5 +
 net/sunrpc/sched.c                  |    2 -
 net/sunrpc/xprtrdma/transport.c     |    2 -
 net/sunrpc/xprtsock.c               |  121 +--
 49 files changed, 2520 insertions(+), 3306 deletions(-)
 delete mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
 delete mode 100644 fs/nfs/blocklayout/blocklayoutdm.c
 create mode 100644 fs/nfs/blocklayout/dev.c
 create mode 100644 fs/nfs/blocklayout/extent_tree.c
 delete mode 100644 fs/nfs/blocklayout/extents.c
 create mode 100644 fs/nfs/blocklayout/rpc_pipefs.c
 create mode 100644 fs/nfs/nfs3_fs.h

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


