Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38222 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbcCXNfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2016 09:35:53 -0400
Date: Thu, 24 Mar 2016 09:35:51 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jeff Layton <jlayton@primarydata.com>
Subject: [GIT PULL] nfsd changes for 4.6
Message-ID: <20160324133551.GA21950@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.6 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.6

----------------------------------------------------------------
Various bugfixes, a RDMA update from Chuck Lever, and support for a new
pnfs layout type from Christoph Hellwig.  The new layout type is a
variant of the block layout which uses SCSI features to offer improved
fencing and device identification.

(Also: note this pull request also includes the client side of SCSI
layout, with Trond's permission.)

----------------------------------------------------------------
Chuck Lever (14):
      nfsd: Update NFS server comments related to RDMA support
      svcrdma: Find client-provided write and reply chunks once per reply
      svcrdma: Do not write xdr_buf::tail in a Write chunk
      svcrdma: Do not send Write chunk XDR pad with inline content
      nfsd: Lower NFSv4.1 callback message size limit
      svcrdma: Close connection when a send error occurs
      svcrdma: svc_rdma_post_recv() should close connection on error
      rpcrdma: Add RPCRDMA_HDRLEN_ERR
      svcrdma: Make RDMA_ERROR messages work
      svcrdma: Use correct XID in error replies
      svcrdma: Hook up the logic to return ERR_CHUNK
      svcrdma: Remove close_out exit path
      svcrdma: Use new CQ API for RPC-over-RDMA server receive CQs
      svcrdma: Use new CQ API for RPC-over-RDMA server send CQs

J. Bruce Fields (3):
      nfsd4: fix bad bounds checking
      nfsd4: resfh unused in nfsd4_secinfo
      nfsd: fix deadlock secinfo+readdir compound

Kinglong Mee (1):
      nfsd: Fix a memory leak when meeting unsupported state_protect_how4

NeilBrown (1):
      sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall() detects a race

Sudip Mukherjee (1):
      nfsd: recover: fix memory leak

 fs/nfsd/nfs4proc.c                         |   3 +-
 fs/nfsd/nfs4recover.c                      |   1 +
 fs/nfsd/nfs4state.c                        |  29 +-
 fs/nfsd/nfs4xdr.c                          |  15 +-
 include/linux/sunrpc/auth.h                |   7 +
 include/linux/sunrpc/rpc_rdma.h            |   1 +
 include/linux/sunrpc/svc_rdma.h            |  20 +-
 net/sunrpc/auth_null.c                     |   4 +-
 net/sunrpc/auth_unix.c                     |   6 +-
 net/sunrpc/cache.c                         |   6 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  17 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  64 +++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  60 ++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 196 +++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 445 ++++++++++-------------------
 15 files changed, 408 insertions(+), 466 deletions(-)
