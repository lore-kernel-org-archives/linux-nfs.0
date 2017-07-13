Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35554 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752659AbdGMTpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 15:45:24 -0400
Date: Thu, 13 Jul 2017 15:45:23 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: [GIT PULL] nfsd changes for 4.13
Message-ID: <20170713194523.GA6142@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.13 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.13

Chuck's RDMA update overhauls the "call receive" side of the
RPC-over-RDMA transport to use the new rdma_rw API.

Christoph cleaned the way nfs operations are declared, removing a bunch
of function-pointer casts and declaring the operation vectors as const.

Christoph's changes touch both client and server, and both client and
server pulls this time around should be based on the same commits from
Christoph.

(Note: Anna and I initially didn't coordinate this well and we realized
our pull requests were going to leave you with Christoph's 33 patches
duplicated between our two trees.  We decided a last-minute rebase was
the lesser of two evils, so her pull request will show that last-minute
rebase.  Yell if that was the wrong choice, and we'll know better for
next time....)

--b.

Christoph Hellwig (33):
      sunrpc: properly type argument to kxdreproc_t
      sunrpc: fix encoder callback prototypes
      lockd: fix encoder callback prototypes
      nfs: fix encoder callback prototypes
      nfsd: fix encoder callback prototypes
      sunrpc/auth_gss: nfsd: fix encoder callback prototypes
      sunrpc: properly type argument to kxdrdproc_t
      sunrpc: fix decoder callback prototypes
      sunrpc/auth_gss: fix decoder callback prototypes
      nfsd: fix decoder callback prototypes
      lockd: fix decoder callback prototypes
      nfs: fix decoder callback prototypes
      nfs: don't cast callback decode/proc/encode routines
      lockd: fix some weird indentation
      sunrpc: move p_count out of struct rpc_procinfo
      nfs: use ARRAY_SIZE() in the nfsacl_version3 declaration
      sunrpc: mark all struct rpc_procinfo instances as const
      nfsd4: const-ify nfs_cb_version4
      nfsd: use named initializers in PROC()
      nfsd: remove the unused PROC() macro in nfs3proc.c
      sunrpc: properly type pc_func callbacks
      sunrpc: properly type pc_release callbacks
      sunrpc: properly type pc_decode callbacks
      sunrpc: properly type pc_encode callbacks
      sunrpc: remove kxdrproc_t
      nfsd4: properly type op_set_currentstateid callbacks
      nfsd4: properly type op_get_currentstateid callbacks
      nfsd4: remove nfsd4op_rsize
      nfsd4: properly type op_func callbacks
      sunrpc: move pc_count out of struct svc_procinfo
      sunrpc: mark all struct svc_procinfo instances as const
      sunrpc: mark all struct svc_version instances as const
      nfsd4: const-ify nfsd4_ops

Chuck Lever (18):
      sunrpc: Disable splice for krb5i
      svcrdma: Squelch disconnection messages
      svcrdma: Avoid Send Queue overflow
      svcrdma: Remove svc_rdma_marshal.c
      svcrdma: Improve Read chunk sanity checking
      svcrdma: Improve Write chunk sanity checking
      svcrdma: Improve Reply chunk sanity checking
      svcrdma: Don't account for Receive queue "starvation"
      sunrpc: Allocate up to RPCSVC_MAXPAGES per svc_rqst
      svcrdma: Add recvfrom helpers to svc_rdma_rw.c
      svcrdma: Use generic RDMA R/W API in RPC Call path
      svcrdma: Properly compute .len and .buflen for received RPC Calls
      svcrdma: Remove unused Read completion handlers
      svcrdma: Remove frmr cache
      svcrdma: Clean-up svc_rdma_unmap_dma
      svcrdma: Clean up after converting svc_rdma_recvfrom to rdma_rw API
      svcrdma: use offset_in_page() macro
      svcrdma: Remove svc_rdma_chunk_ctxt::cc_dir field

Colin Ian King (1):
      svcrdma: fix an incorrect check on -E2BIG and -EINVAL

J. Bruce Fields (2):
      Merge tag 'v4.12-rc5' into nfsd tree
      nfsd4: factor ctime into change attribute

 fs/lockd/clnt4xdr.c                      |  34 +-
 fs/lockd/clntxdr.c                       |  58 ++-
 fs/lockd/mon.c                           |  38 +-
 fs/lockd/svc.c                           |  38 +-
 fs/lockd/svc4proc.c                      | 124 ++++--
 fs/lockd/svcproc.c                       | 124 ++++--
 fs/lockd/xdr.c                           |  43 +-
 fs/lockd/xdr4.c                          |  43 +-
 fs/nfs/callback.c                        |   2 +-
 fs/nfs/callback.h                        |  27 +-
 fs/nfs/callback_proc.c                   |  33 +-
 fs/nfs/callback_xdr.c                    | 113 ++---
 fs/nfs/internal.h                        |  10 +-
 fs/nfs/mount_clnt.c                      |  29 +-
 fs/nfs/nfs2xdr.c                         |  70 ++-
 fs/nfs/nfs3xdr.c                         | 151 ++++---
 fs/nfs/nfs42xdr.c                        |  52 ++-
 fs/nfs/nfs4_fs.h                         |   6 +-
 fs/nfs/nfs4xdr.c                         | 331 +++++++++-----
 fs/nfsd/current_stateid.h                |  36 +-
 fs/nfsd/nfs2acl.c                        | 116 ++---
 fs/nfsd/nfs3acl.c                        |  75 ++--
 fs/nfsd/nfs3proc.c                       | 301 +++++++------
 fs/nfsd/nfs3xdr.c                        | 166 ++++---
 fs/nfsd/nfs4callback.c                   |  32 +-
 fs/nfsd/nfs4proc.c                       | 412 ++++++++---------
 fs/nfsd/nfs4state.c                      | 142 +++---
 fs/nfsd/nfs4xdr.c                        |  15 +-
 fs/nfsd/nfsd.h                           |   6 +-
 fs/nfsd/nfsfh.h                          |  24 +-
 fs/nfsd/nfsproc.c                        | 206 +++++----
 fs/nfsd/nfssvc.c                         |  24 +-
 fs/nfsd/nfsxdr.c                         |  92 ++--
 fs/nfsd/xdr.h                            |  50 +--
 fs/nfsd/xdr3.h                           | 100 ++---
 fs/nfsd/xdr4.h                           |  78 ++--
 include/linux/lockd/lockd.h              |   4 +-
 include/linux/lockd/xdr.h                |  26 +-
 include/linux/lockd/xdr4.h               |  26 +-
 include/linux/sunrpc/clnt.h              |   6 +-
 include/linux/sunrpc/sched.h             |   2 +-
 include/linux/sunrpc/svc.h               |  23 +-
 include/linux/sunrpc/svc_rdma.h          |  46 +-
 include/linux/sunrpc/xdr.h               |  15 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c     |   9 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.c        |  14 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h        |   4 +-
 net/sunrpc/auth_gss/svcauth_gss.c        |   8 +
 net/sunrpc/clnt.c                        |  16 +-
 net/sunrpc/rpcb_clnt.c                   |  82 ++--
 net/sunrpc/stats.c                       |  16 +-
 net/sunrpc/svc.c                         |  35 +-
 net/sunrpc/svc_xprt.c                    |  10 +-
 net/sunrpc/xprtrdma/Makefile             |   4 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   | 168 -------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 734 ++++++++++++-------------------
 net/sunrpc/xprtrdma/svc_rdma_rw.c        | 449 ++++++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  15 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 250 +----------
 59 files changed, 2758 insertions(+), 2405 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/svc_rdma_marshal.c
