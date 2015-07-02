Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33178 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbbGBQV4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 12:21:56 -0400
Message-ID: <1435854102.4771.1.camel@gmail.com>
Subject: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <trondmy@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Thu, 02 Jul 2015 12:21:42 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit d4a4f75cd8f29cd9464a5a32e9224a91571d6649:

  Linux 4.1-rc7 (2015-06-07 20:23:50 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.2-1

for you to fetch changes up to b4839ebe21fc5d543b933d83644981ea73e9ba36:

  nfs: Remove invalid tk_pid from debug message (2015-07-01 11:31:25 -0400)

----------------------------------------------------------------
NFS client updates for Linux 4.2

Highlights include:

Stable patches:
- Fix a crash in the NFSv4 file locking code.
- Fix an fsync() regression, where we were failing to retry I/O in some
  circumstances.
- Fix an infinite loop in NFSv4.0 OPEN stateid recovery
- Fix a memory leak when an attempted pnfs fails.
- Fix a memory leak in the backchannel code
- Large hostnames were not supported correctly in NFSv4.1
- Fix a pNFS/flexfiles bug that was impeding error reporting on I/O.
- Fix a couple of credential issues in pNFS/flexfiles

Bugfixes + cleanups:
- Open flag sanity checks in the NFSv4 atomic open codepath
- More NFSv4 delegation related bugfixes
- Various NFSv4.1 backchannel bugfixes and cleanups
- Fix the NFS swap socket code
- Various cleanups of the NFSv4 SETCLIENTID and EXCHANGE_ID code
- Fix a UDP transport deadlock issue

Features:
- More RDMA client transport improvements
- NFSv4.2 LAYOUTSTATS functionality for pnfs flexfiles.

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Remove unused nfs_rw_ops->rw_release() function

Benjamin Coddington (1):
      nfs: verify open flags before allowing open

Chuck Lever (18):
      NFS: Fix size of NFSACL SETACL operations
      SUNRPC: Clean up bc_send()
      SUNRPC: Transport fault injection
      SUNRPC: Address kbuild warning in net/sunrpc/debugfs.c
      xprtrdma: Warn when there are orphaned IB objects
      xprtrdma: Replace rpcrdma_rep::rr_buffer with rr_rxprt
      xprtrdma: Remove rr_func
      xprtrdma: Use ib_device pointer safely
      xprtrdma: Introduce helpers for allocating MWs
      xprtrdma: Acquire FMRs in rpcrdma_fmr_register_external()
      xprtrdma: Introduce an FRMR recovery workqueue
      xprtrdma: Acquire MRs in rpcrdma_register_external()
      xprtrdma: Remove unused LOCAL_INV recovery logic
      xprtrdma: Remove ->ro_reset
      xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
      xprtrdma: Split rb_lock
      xprtrdma: Stack relief in fmr_op_map()
      xprtrdma: Reduce per-transport MR allocation

Dominique Martinet (1):
      NFSv4: handle nfs4_get_referral failure

Fabian Frederick (2):
      pnfs/flexfiles: use swap() in ff_layout_sort_mirrors()
      sunrpc: use sg_init_one() in krb5_rc4_setup_enc/seq_key()

Jeff Layton (14):
      sunrpc: keep a count of swapfiles associated with the rpc_clnt
      sunrpc: make xprt->swapper an atomic_t
      sunrpc: if we're closing down a socket, clear memalloc on it first
      sunrpc: lock xprt before trying to set memalloc on the sockets
      sunrpc: turn swapper_enable/disable functions into rpc_xprt_ops
      nfs: deny backchannel RPCs with an incorrect authflavor instead of dropping them
      nfs: increase size of EXCHANGE_ID name string buffer
      nfs: convert setclientid and exchange_id encoders to use clp->cl_owner_id
      nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
      nfs: make nfs4_init_nonuniform_client_string use a dynamically allocated buffer
      nfs: make nfs4_init_uniform_client_string use a dynamically allocated buffer
      nfs: fix potential credential leak in ff_layout_update_mirror_cred
      nfs: always update creds in mirror, even when we have an already connected ds
      nfs: take extra reference to fl->fl_file when running a LOCKU operation

Julia Lawall (1):
      NFS: drop unneeded goto

Kinglong Mee (11):
      nfs: Only update callback sequnce id when CB_SEQUENCE success
      nfs: Initialize cb_sequenceres information before validate_seqid()
      nfs: Fix showing truncated fsid/dev in, /proc/net/nfsfs/volumes
      nfs: Fix a memory leak when meeting an unsupported state protect
      nfs: Remove unused argument in nfs_server_set_fsinfo()
      nfs: Use remove_proc_subtree() instead remove_proc_entry()
      nfs: Don't setting FILE_CREATED flags always
      nfs: Remove unneeded micro checking of CONFIG_PROC_FS
      nfs: Drop bad comment in nfs41_walk_client_list()
      nfs: Remove invalid NFS_ATTR_FATTR_V4_REFERRAL checking in nfs4_get_rootfh
      nfs: Remove invalid tk_pid from debug message

Neil Brown (1):
      SUNRPC: never enqueue a ->rq_cong request on ->sending

NeilBrown (2):
      NFS: report more appropriate block size for directories.
      NFSv4: When returning a delegation, don't reclaim an incompatible open mode.

Olga Kornievskaia (2):
      fixing infinite OPEN loop in 4.0 stateid recovery
      Recover from stateid-type error on SETATTR

Peng Tao (9):
      pNFS: fill in nfs42_layoutstat_ops
      pnfs: add pnfs_report_layoutstat helper function
      pNFS/flexfiles: track when layout is first used
      pnfs/flexfiles: add ff_layout_prepare_layoutstats
      pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data
      nfs42: serialize LAYOUTSTATS calls of the same file
      pnfs/flexfiles: report layoutstat regularly
      nfs: provide pnfs_report_layoutstat when NFS42 is disabled
      pnfs/flexfiles: protect ktime manipulation with mirror lock

Stefan Hajnoczi (1):
      SUNRPC: drop stale doc comments in xprtsock.c

Trond Myklebust (24):
      NFSv4: Always drain the slot table before re-establishing the lease
      SUNRPC: Fix a memory leak in the backchannel code
      SUNRPC: Backchannel handle socket nospace
      NFSv4: nfs4_handle_delegation_recall_error should ignore EAGAIN
      SUNRPC: Remove unused argument 'tk_ops' in rpc_run_bc_task
      SUNRPC: Clean up allocation and freeing of back channel requests
      SUNRPC: Fix a backchannel race
      NFS: Ensure that we update the sequence id under the slot table lock
      NFSv4: Fix stateid recovery on revoked delegations
      Merge tag 'nfs-rdma-for-4.2' of git://git.linux-nfs.org/projects/anna/nfs-rdma
      pNFS: Fix a memory leak when attempted pnfs fails
      NFS: Ensure we set NFS_CONTEXT_RESEND_WRITES when requeuing writes
      SUNRPC: Handle connection issues correctly on the back channel
      SUNRPC: Ensure we release the TCP socket once it has been closed
      SUNRPC: Set the TCP user timeout option on client sockets
      Merge branch 'bugfixes'
      NFSv.2/pnfs Add a LAYOUTSTATS rpc function
      pNFS/flexfiles: Remove unused struct members user_name, group_name
      pNFS/flexfiles: add layoutstats tracking
      Merge branch 'layoutstats'
      pNFS/flexfiles: Turn off layoutcommit for servers that don't need it
      pNFS/flexfiles: Fix the reset of struct pgio_header when resending
      NFSv4.2: Fix up a decoding error in layoutstats
      NFSv4.2: LAYOUTSTATS is optional to implement

Vaishali Thakkar (1):
      NFS: Convert use of __constant_htonl to htonl

Yijing Wang (1):
      nfs: Fix comment for nfs_pageio_init() and nfs_pageio_complete_mirror()

 fs/nfs/callback.c                         |   6 +-
 fs/nfs/callback_proc.c                    |  38 ++-
 fs/nfs/callback_xdr.c                     |   2 +-
 fs/nfs/client.c                           |  40 +--
 fs/nfs/dir.c                              |   3 -
 fs/nfs/file.c                             |  15 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 480 ++++++++++++++++++++++++++++--
 fs/nfs/flexfilelayout/flexfilelayout.h    |  33 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   7 +-
 fs/nfs/inode.c                            |  12 +-
 fs/nfs/nfs3xdr.c                          |   2 +-
 fs/nfs/nfs42.h                            |   9 +-
 fs/nfs/nfs42proc.c                        |  87 ++++++
 fs/nfs/nfs42xdr.c                         | 106 +++++++
 fs/nfs/nfs4_fs.h                          |   1 +
 fs/nfs/nfs4client.c                       |   1 -
 fs/nfs/nfs4file.c                         |   4 +
 fs/nfs/nfs4getroot.c                      |   7 -
 fs/nfs/nfs4idmap.c                        |   7 +-
 fs/nfs/nfs4proc.c                         | 221 ++++++++++----
 fs/nfs/nfs4state.c                        |   4 +-
 fs/nfs/nfs4xdr.c                          |  15 +-
 fs/nfs/pagelist.c                         |  10 +-
 fs/nfs/pnfs.c                             |  64 ++++
 fs/nfs/pnfs.h                             |  13 +-
 fs/nfs/write.c                            |   9 +-
 include/linux/nfs4.h                      |   1 +
 include/linux/nfs_fs.h                    |   1 +
 include/linux/nfs_fs_sb.h                 |   1 +
 include/linux/nfs_page.h                  |   1 -
 include/linux/nfs_xdr.h                   |  51 +++-
 include/linux/sunrpc/bc_xprt.h            |   1 -
 include/linux/sunrpc/clnt.h               |   1 +
 include/linux/sunrpc/sched.h              |  19 +-
 include/linux/sunrpc/xprt.h               |  39 ++-
 include/linux/sunrpc/xprtrdma.h           |   3 +-
 net/sunrpc/Makefile                       |   2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c     |   8 +-
 net/sunrpc/backchannel_rqst.c             | 134 +++++----
 net/sunrpc/bc_svc.c                       |  63 ----
 net/sunrpc/clnt.c                         | 109 +++++--
 net/sunrpc/debugfs.c                      |  78 +++++
 net/sunrpc/svc.c                          |  36 ++-
 net/sunrpc/xprt.c                         |   7 +-
 net/sunrpc/xprtrdma/fmr_ops.c             | 120 +++++---
 net/sunrpc/xprtrdma/frwr_ops.c            | 227 ++++++++++----
 net/sunrpc/xprtrdma/physical_ops.c        |  14 +-
 net/sunrpc/xprtrdma/rpc_rdma.c            |   8 +-
 net/sunrpc/xprtrdma/transport.c           |  43 ++-
 net/sunrpc/xprtrdma/verbs.c               | 257 ++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h           |  38 ++-
 net/sunrpc/xprtsock.c                     | 151 +++++++---
 52 files changed, 1862 insertions(+), 747 deletions(-)
 delete mode 100644 net/sunrpc/bc_svc.c
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


