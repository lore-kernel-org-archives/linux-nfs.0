Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60908 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752804AbdEJTLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 15:11:06 -0400
Date: Wed, 10 May 2017 15:11:05 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.12
Message-ID: <20170510191105.GC10450@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.12

Another RDMA update from Chuck Lever, and a bunch of miscellaneous
bugfixes.

--b.

----------------------------------------------------------------
Ari Kauppi (1):
      nfsd: fix undefined behavior in nfsd4_layout_verify

Chuck Lever (14):
      svcrdma: Move send_wr to svc_rdma_op_ctxt
      svcrdma: Add svc_rdma_map_reply_hdr()
      svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
      svcrdma: Add helper to save pages under I/O
      svcrdma: Clean up svc_rdma_get_inv_rkey()
      svcrdma: Introduce local rdma_rw API helpers
      svcrdma: Use rdma_rw API in RPC reply path
      svcrdma: Clean up RDMA_ERROR path
      svcrdma: Report Write/Reply chunk overruns
      svcrdma: Clean up RPC-over-RDMA backchannel reply processing
      svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
      svcrdma: Remove unused RDMA Write completion handler
      svcrdma: Remove the req_map cache
      svcrdma: Clean out old XDR encoders

Colin Ian King (1):
      lockd: remove redundant check on block

Dmitry V. Levin (1):
      uapi: fix linux/nfsd/cld.h userspace compilation errors

J. Bruce Fields (3):
      nfsd: check for oversized NFSv2/v3 arguments
      lockd: fix lockd shutdown race
      nfsd: encoders mustn't use unitialized values in error cases

Kinglong Mee (1):
      NFSv4.x/callback: Create the callback service through svc_create_pooled

NeilBrown (2):
      nfsd4: remove pointless strdup_if_nonnull
      NFS: don't try to cross a mountpount when there isn't one there.

Trond Myklebust (3):
      SUNRPC: Refactor svc_set_num_threads()
      NFSv4: Fix callback server shutdown
      nfsd: Fix up the "supattr_exclcreat" attributes

 fs/lockd/svc.c                             |   6 +-
 fs/lockd/svclock.c                         |  18 +-
 fs/nfs/callback.c                          |  26 +-
 fs/nfsd/nfs3xdr.c                          |  23 +-
 fs/nfsd/nfs4proc.c                         |   3 +-
 fs/nfsd/nfs4state.c                        |  25 +-
 fs/nfsd/nfs4xdr.c                          |  19 +-
 fs/nfsd/nfsxdr.c                           |  13 +-
 fs/nfsd/vfs.c                              |  24 +-
 include/linux/sunrpc/rpc_rdma.h            |   3 +
 include/linux/sunrpc/svc.h                 |   4 +-
 include/linux/sunrpc/svc_rdma.h            |  75 +--
 include/uapi/linux/nfsd/cld.h              |  14 +-
 net/sunrpc/Kconfig                         |   1 +
 net/sunrpc/svc.c                           | 134 ++--
 net/sunrpc/xprtrdma/Makefile               |   2 +-
 net/sunrpc/xprtrdma/svc_rdma.c             |   8 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  71 +--
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  89 ---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  79 ++-
 net/sunrpc/xprtrdma/svc_rdma_rw.c          | 512 +++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 978 ++++++++++++++---------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 110 +---
 23 files changed, 1334 insertions(+), 903 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c
