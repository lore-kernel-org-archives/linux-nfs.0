Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33679 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbIGU7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Sep 2015 16:59:23 -0400
Received: by qkdw123 with SMTP id w123so20175523qkd.0
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2015 13:59:23 -0700 (PDT)
Message-ID: <1441659544.3163.4.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, Doug Ledford <dledford@redhat.com>
Date: Mon, 07 Sep 2015 16:59:04 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 74d33293e467df61de1b1d8b2fbe29e550dec33b:

  Linux 4.2-rc5 (2015-08-02 18:34:55 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.3-1

for you to fetch changes up to 5445b1fbd123420bffed5e629a420aa2a16bf849:

  NFSv4: Respect the server imposed limit on how many changes we may cache (2015-09-07 12:36:17 -0400)


Please note this aside from the usual NFS and RPC related commits, this
series includes 1 core inifiniband change (acked-by Doug Ledford) and a
corresponding fixup for the RPC layer and one for the Lustre filesystem
(acked-by Oleg Drokin).

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 4.3

Highlights include:

Stable patches:
- Fix atomicity of pNFS commit list updates
- Fix NFSv4 handling of open(O_CREAT|O_EXCL|O_RDONLY)
- nfs_set_pgio_error sometimes misses errors
- Fix a thinko in xs_connect()
- Fix borkage in _same_data_server_addrs_locked()
- Fix a NULL pointer dereference of migration recovery ops for v4.2 client
- Don't let the ctime override attribute barriers.
- Revert "NFSv4: Remove incorrect check in can_open_delegated()"
- Ensure flexfiles pNFS driver updates the inode after write finishes
- flexfiles must not pollute the attribute cache with attrbutes from the DS
- Fix a protocol error in layoutreturn
- Fix a protocol issue with NFSv4.1 CLOSE stateids

Bugfixes + cleanups
- pNFS blocks bugfixes from Christoph
- Various cleanups from Anna
- More fixes for delegation corner cases
- Don't fsync twice for O_SYNC/IS_SYNC files
- Fix pNFS and flexfiles layoutstats bugs
- pnfs/flexfiles: avoid duplicate tracking of mirror data
- pnfs: Fix layoutget/layoutreturn/return-on-close serialisation issues.
- pnfs/flexfiles: error handling retries a layoutget before fallback to MDS

Features:
- Full support for the OPEN NFS4_CREATE_EXCLUSIVE4_1 mode from Kinglong
- More RDMA client transport improvements from Chuck
- Removal of the deprecated ib_reg_phys_mr() and ib_rereg_phys_mr() verbs
  from the SUNRPC, Lustre and core infiniband tree.
- Optimise away the close-to-open getattr if there is no cached data

----------------------------------------------------------------
Anna Schumaker (9):
      NFS: Remove unused variable "pages_ptr"
      NFS: Rename nfs_readdir_free_pagearray() and nfs_readdir_large_page()
      SUNRPC: Drop double-underscores from rpc_cmp_addr{4|6}()
      SUNRPC: Add an rpc_cmp_addr_port() function
      NFS: Use RPC functions for matching sockaddrs
      NFS: Combine nfs_idmap_{init|quit}() and nfs_idmap_{init|quit}_keyring()
      NFS: Remove nfs41_server_notify_{target|highest}_slotid_update()
      NFS: Rename nfs_commit_unstable_pages() to nfs_write_inode()
      NFS: Remove nfs_release()

Christoph Hellwig (5):
      pnfs/blocklayout: calculate layoutupdate size correctly
      pnfs/blocklayout: set up layoutupdate_pages properly
      pnfs/blocklayout: reject too long signatures
      pnfs/blocklayout: pass proper file mode to blkdev_get/put
      pnfs: move common blocklayout XDR defintions to nfs4.h

Chuck Lever (15):
      xprtrdma: Make xprt_setup_rdma() agnostic to family of server address
      xprtrdma: Raise maximum payload size to one megabyte
      xprtrdma: Increase default credit limit
      xprtrdma: Don't fall back to PHYSICAL memory registration
      xprtrdma: Remove last ib_reg_phys_mr() call site
      xprtrdma: Clean up rpcrdma_ia_open()
      xprtrdma: Remove logic that constructs RDMA_MSGP type calls
      xprtrdma: Account for RPC/RDMA header size when deciding to inline
      xprtrdma: Always provide a write list when sending NFS READ
      xprtrdma: Don't provide a reply chunk when expecting a short reply
      xprtrdma: Fix XDR tail buffer marshalling
      xprtrdma: Fix large NFS SYMLINK calls
      xprtrdma: Clean up xprt_rdma_print_stats()
      xprtrdma: Count RDMA_NOMSG type calls
      core: Remove the ib_reg_phys_mr() and ib_rereg_phys_mr() verbs

Devesh Sharma (1):
      xprtrdma: take HCA driver refcount at client

Jeff Layton (2):
      sunrpc: increase UNX_MAXNODENAME from 32 to __NEW_UTS_LEN bytes
      nfs: remove some dead code in ff_layout_pg_get_mirror_count_write

Kinglong Mee (10):
      NFS: Error out when register_shrinker fail in register_nfs_fs
      NFS: Remove duplicate svc_xprt_put from nfs41_callback_up
      NFS: Fix a NULL pointer dereference of migration recovery ops for v4.2 client
      NFS: Check size by inode_newsize_ok in nfs_setattr
      NFS: Make opened as optional argument in _nfs4_do_open
      NFS: Update NFS4_BITMAP_SIZE
      NFS: Get suppattr_exclcreat when getting server capabilities
      NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
      nfs: Fix truncated client owner id without proto type
      nfs: Remove unneeded checking of the return value from scnprintf

NeilBrown (1):
      NFSv4: don't set SETATTR for O_RDONLY|O_EXCL

Oleg Drokin (1):
      staging/lustre/o2iblnd: remove references to ib_reg_phsy_mr()

Peng Tao (8):
      pnfs/flexfiles: LAYOUTSTATS ii_count should be ops instead of bytes
      NFS41: make sure sending LAYOUTRETURN before close if marked so
      NFS41/flexfiles: update inode after write finishes
      NFS41: fix list splice type
      NFS41: remove NFS_LAYOUT_ROC flag
      NFS41/flexfiles: zero out DS write wcc
      nfs42: decode_layoutstats does not need res parameter
      nfs42: remove unused declaration

Trond Myklebust (58):
      NFSv4.1/pnfs: Fix atomicity of commit list updates
      NFSv4.2/pnfs: Use GFP_NOIO for layoutstat reporting in the writeback path
      pNFS: Tighten up locking around DS commit buckets
      NFSv4.1/pnfs: Remove redundant checks in pnfs_layoutgets_blocked()
      NFSv4.1/pnfs: Fix serialisation of layout return and layoutget
      NFSv4.1/pnfs: Don't prevent layoutgets when doing return-on-close
      NFSv4.1/pnfs: Remove redundant lo->plh_block_lgets in layoutreturn
      NFSv4.1/pnfs: Remove redundant check in pnfs_layoutgets_blocked()
      NFSv4.1/pnfs: Remove redundant wakeup in pnfs_send_layoutreturn()
      NFS: nfs_set_pgio_error sometimes misses errors
      NFSv4.1/pNFS: Fix borken function _same_data_server_addrs_locked()
      SUNRPC: Fix a thinko in xs_connect()
      Merge tag 'nfs-rdma-for-4.3' of git://git.linux-nfs.org/projects/anna/nfs-rdma
      Merge branch 'bugfixes'
      Merge branch 'layoutfixes'
      NFS: Don't let the ctime override attribute barriers.
      SUNRPC: Drop double-underscores from __rpc_cmp_addr6()
      NFS: Don't fsync twice for O_SYNC/IS_SYNC files
      NFSv4.1/pnfs: Fix a close/delegreturn hang when return-on-close is set
      NFSv4.1/pnfs: Play safe w.r.t. close() races when return-on-close is set
      Revert "NFSv4: Remove incorrect check in can_open_delegated()"
      SUNRPC: Allow sockets to do GFP_NOIO allocations
      pNFS: Fix an unused variable warning in pnfs_roc_get_barrier
      NFSv4: Enable delegated opens even when reboot recovery is pending
      NFSv4.1/pnfs: Ensure the flexfiles layoutstats timers are consistent
      NFSv4.1/pnfs Ensure flexfiles reports all connection related errors
      NFSv4: Force a post-op attribute update when holding a delegation
      NFSv4.1/pnfs: Add a tracepoint for return-on-close events
      NFSv4: Add a tracepoint for CB_GETATTR
      NFSv4: Add a tracepoint for CB_LAYOUTRECALL
      NFSv4.1/flexfiles: Add refcounting to struct nfs4_ff_layout_mirror
      NFSv4.1/flexfiles: Remove mirror backpointer to lseg.
      NFSv4.1/flexfile: Ensure uniqueness of mirrors across layout segments
      NFSv4.2/pnfs: Make the layoutstats timer configurable
      NFSv4.1/pnfs Improve the packing of struct pnfs_layout_hdr
      NFSv4.1/pnfs: Add sanity check for the layout range returned by the server
      NFSv4.1/pnfs: Allow pNFS device drivers to customise layout segment insertion
      NFSv4.1/flexfiles: Allow coalescing of new layout segments and existing ones
      NFSv4.1/pNFS: pnfs_mark_matching_lsegs_return must notify of layout return
      NFSv4.1/flexfiles: Fix a protocol error in layoutreturn
      NFSv4.1/pnfs: Ensure layoutreturn reserves space for the opaque payload
      SUNRPC: xs_reset_transport must mark the connection as disconnected
      SUNRPC: Prevent SYN+SYNACK+RST storms
      NFSv4.1/flexfiles: Don't mark the entire deviceid as bad for file errors
      NFSv4.1: Fix a protocol issue with CLOSE stateids
      NFSv4.1/pnfs: Don't ask for a read layout for an empty file.
      NFSv4.1/pnfs: Handle LAYOUTGET return values correctly
      NFSv4.1/pNFS: Don't request a minimal read layout beyond the end of file
      NFSv4.1/flexfiles: Fix freeing of mirrors
      NFSv4.1/flexfiles: Fix incorrect usage of pnfs_generic_mark_devid_invalid()
      NFSv4.1/flexfiles: RW layouts are valid only if all mirrors are valid
      NFSv4.1/flexfiles: Mark layout for return if the mirrors are invalid
      NFSv4.1/flexfiles: Mark the layout for return in ff_layout_io_track_ds_error()
      NFSv4.1/flexfiles: Clean up ff_layout_write_done_cb/ff_layout_commit_done_cb
      NFS: Optimise away the close-to-open getattr if there is no cached data
      Revert "NFS: Make close(2) asynchronous when closing NFS O_DIRECT files"
      NFSv4: Express delegation limit in units of pages
      NFSv4: Respect the server imposed limit on how many changes we may cache

kbuild test robot (1):
      NFSv4.1/flexfile: ff_layout_remove_mirror can be static

 Documentation/kernel-parameters.txt                |   9 +
 drivers/infiniband/core/verbs.c                    |  67 ----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 251 +-----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  32 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  55 +--
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   6 -
 fs/nfs/blocklayout/blocklayout.h                   |  19 +-
 fs/nfs/blocklayout/dev.c                           |   9 +-
 fs/nfs/blocklayout/extent_tree.c                   |  19 +-
 fs/nfs/callback.c                                  |   4 -
 fs/nfs/callback_proc.c                             |   9 +-
 fs/nfs/client.c                                    | 113 +-----
 fs/nfs/delegation.c                                |  29 +-
 fs/nfs/delegation.h                                |   3 +-
 fs/nfs/dir.c                                       |  20 +-
 fs/nfs/file.c                                      |  21 +-
 fs/nfs/flexfilelayout/flexfilelayout.c             | 424 ++++++++++++++-------
 fs/nfs/flexfilelayout/flexfilelayout.h             |   5 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c          |  82 +++-
 fs/nfs/inode.c                                     |  61 +--
 fs/nfs/internal.h                                  |  20 +-
 fs/nfs/nfs3xdr.c                                   |   1 +
 fs/nfs/nfs42.h                                     |   2 -
 fs/nfs/nfs42xdr.c                                  |   5 +-
 fs/nfs/nfs4_fs.h                                   |   4 +-
 fs/nfs/nfs4client.c                                |   5 +-
 fs/nfs/nfs4file.c                                  |  32 +-
 fs/nfs/nfs4idmap.c                                 |  14 +-
 fs/nfs/nfs4proc.c                                  | 136 ++++---
 fs/nfs/nfs4state.c                                 |  12 +-
 fs/nfs/nfs4trace.h                                 |  61 +++
 fs/nfs/nfs4xdr.c                                   |  75 +++-
 fs/nfs/pagelist.c                                  |   4 +-
 fs/nfs/pnfs.c                                      | 227 ++++++-----
 fs/nfs/pnfs.h                                      |  48 ++-
 fs/nfs/pnfs_nfs.c                                  |  88 +++--
 fs/nfs/super.c                                     |   7 +-
 fs/nfs/write.c                                     |  36 +-
 fs/nfsd/blocklayoutxdr.c                           |   2 +-
 fs/nfsd/blocklayoutxdr.h                           |  15 -
 include/linux/nfs4.h                               |  18 +
 include/linux/nfs_fs.h                             |   2 +-
 include/linux/nfs_fs_sb.h                          |   5 +
 include/linux/nfs_xdr.h                            |   8 +-
 include/linux/sunrpc/addr.h                        |  27 +-
 include/linux/sunrpc/auth.h                        |   8 +-
 include/linux/sunrpc/xprtrdma.h                    |   2 +-
 include/rdma/ib_verbs.h                            |  46 ---
 include/uapi/linux/nfs4.h                          |   2 +-
 net/sunrpc/auth_unix.c                             |   2 +-
 net/sunrpc/xprtrdma/fmr_ops.c                      |  19 +
 net/sunrpc/xprtrdma/frwr_ops.c                     |   5 +
 net/sunrpc/xprtrdma/physical_ops.c                 |  25 +-
 net/sunrpc/xprtrdma/rpc_rdma.c                     | 197 +++++-----
 net/sunrpc/xprtrdma/transport.c                    |  77 ++--
 net/sunrpc/xprtrdma/verbs.c                        | 234 ++++--------
 net/sunrpc/xprtrdma/xprt_rdma.h                    |  27 +-
 net/sunrpc/xprtsock.c                              |  18 +-
 58 files changed, 1340 insertions(+), 1414 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



