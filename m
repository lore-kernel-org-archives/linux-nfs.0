Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50226 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933394AbeFKVGl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Jun 2018 17:06:41 -0400
Date: Mon, 11 Jun 2018 17:06:41 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] knfsd changes for 4.18
Message-ID: <20180611210641.GA9628@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.18

A relatively quiet cycle for nfsd.  The largest piece is an RDMA update
from Chuck Lever with new trace points, miscellaneous cleanups, and
streamlining of the send and receive paths.  Other than that, some
miscellaneous bugfixes.

--b.

Andrew Elble (1):
      nfsd: fix error handling in nfs4_set_delegation()

Chuck Lever (20):
      svcrdma: Add proper SPDX tags for NetApp-contributed source
      svcrdma: Use passed-in net namespace when creating RDMA listener
      xprtrdma: Prepare RPC/RDMA includes for server-side trace points
      svcrdma: Trace key RPC/RDMA protocol events
      svcrdma: Trace key RDMA API events
      svcrdma: Introduce svc_rdma_recv_ctxt
      svcrdma: Remove sc_rq_depth
      svcrdma: Simplify svc_rdma_recv_ctxt_put
      svcrdma: Preserve Receive buffer until svc_rdma_sendto
      svcrdma: Persistently allocate and DMA-map Receive buffers
      svcrdma: Allocate recv_ctxt's on CPU handling Receives
      svcrdma: Refactor svc_rdma_dma_map_buf
      svcrdma: Clean up Send SGE accounting
      svcrdma: Introduce svc_rdma_send_ctxt
      svcrdma: Don't overrun the SGE array in svc_rdma_send_ctxt
      svcrdma: Remove post_send_wr
      svcrdma: Simplify svc_rdma_send()
      svcrdma: Persistently allocate and DMA-map Send buffers
      svcrdma: Remove unused svc_rdma_op_ctxt
      svcrdma: Fix incorrect return value/type in svc_rdma_post_recvs

Dave Wysochanski (1):
      Fix 16-byte memory leak in gssp_accept_sec_context_upcall

Scott Mayhew (3):
      nfsd: restrict rd_maxcount to svc_max_payload in nfsd_encode_readdir
      nfsd: make nfsd4_scsi_identify_device retry with a larger buffer
      nfsd: fix potential use-after-free in nfsd4_decode_getdeviceinfo

Trond Myklebust (1):
      nfsd: Do not refuse to serve out of cache

 fs/nfsd/blocklayout.c                      |  18 +-
 fs/nfsd/cache.h                            |   5 -
 fs/nfsd/nfs4state.c                        |   5 +-
 fs/nfsd/nfs4xdr.c                          |   7 +-
 fs/nfsd/nfscache.c                         |   6 +-
 include/linux/sunrpc/svc_rdma.h            |  95 ++---
 include/trace/events/rpcrdma.h             | 584 ++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/gss_rpc_upcall.c       |   4 +-
 net/sunrpc/xprtrdma/backchannel.c          |   2 +
 net/sunrpc/xprtrdma/fmr_ops.c              |   3 +
 net/sunrpc/xprtrdma/frwr_ops.c             |   2 +
 net/sunrpc/xprtrdma/module.c               |   4 +-
 net/sunrpc/xprtrdma/rpc_rdma.c             |   7 +-
 net/sunrpc/xprtrdma/svc_rdma.c             |   3 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  54 ++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    | 439 ++++++++++++++++------
 net/sunrpc/xprtrdma/svc_rdma_rw.c          | 133 +++----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 510 ++++++++++++++++---------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 481 ++++--------------------
 net/sunrpc/xprtrdma/transport.c            |   4 +
 net/sunrpc/xprtrdma/verbs.c                |   1 +
 net/sunrpc/xprtrdma/xprt_rdma.h            |   2 -
 22 files changed, 1489 insertions(+), 880 deletions(-)
