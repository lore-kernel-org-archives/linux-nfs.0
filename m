Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38544 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbcCXTUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2016 15:20:38 -0400
Date: Thu, 24 Mar 2016 15:20:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@primarydata.com>
Subject: [GIT PULL] nfsd changes for 4.6, take 2
Message-ID: <20160324192036.GB23783@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.6 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.6-1

Apologies for the previous request, which omitted the top 8 commits from
my for-next branch (including the SCSI layout commits).  This is just a
fast-forward from the previous nfsd-4.6 tag so if necessary merging both
should be no problem (except for the redundant descriptions on the
tags).  Thanks to Trond for spotting my error!

----------------------------------------------------------------
Various bugfixes, a RDMA update from Chuck Lever, and support for a new
pnfs layout type from Christoph Hellwig.  The new layout type is a
variant of the block layout which uses SCSI features to offer improved
fencing and device identification.

Note this pull request also includes the client side of SCSI layout,
with Trond's permission.

----------------------------------------------------------------
Benjamin Coddington (1):
      nfsd: use short read as well as i_size to set eof

Christoph Hellwig (6):
      nfs4.h: add SCSI layout definitions
      nfs/blocklayout: add SCSI layout support
      nfsd: add a new config option for the block layout driver
      nfsd: move some blocklayout code
      nfsd: add SCSI layout support
      nfsd: block and scsi layout drivers need to depend on CONFIG_BLOCK

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

J. Bruce Fields (4):
      nfsd4: fix bad bounds checking
      nfsd4: resfh unused in nfsd4_secinfo
      nfsd: fix deadlock secinfo+readdir compound
      nfsd: better layoutupdate bounds-checking

Kinglong Mee (1):
      nfsd: Fix a memory leak when meeting unsupported state_protect_how4

NeilBrown (1):
      sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall() detects a race

Sudip Mukherjee (1):
      nfsd: recover: fix memory leak

 Documentation/filesystems/nfs/pnfs-scsi-server.txt |  23 ++
 fs/nfs/blocklayout/blocklayout.c                   |  59 ++-
 fs/nfs/blocklayout/blocklayout.h                   |  14 +-
 fs/nfs/blocklayout/dev.c                           | 144 ++++++-
 fs/nfs/blocklayout/extent_tree.c                   |  44 +-
 fs/nfs/blocklayout/rpc_pipefs.c                    |   2 +-
 fs/nfsd/Kconfig                                    |  28 +-
 fs/nfsd/Makefile                                   |   4 +-
 fs/nfsd/blocklayout.c                              | 298 ++++++++++++--
 fs/nfsd/blocklayoutxdr.c                           |  77 +++-
 fs/nfsd/blocklayoutxdr.h                           |  14 +
 fs/nfsd/nfs3proc.c                                 |   7 +-
 fs/nfsd/nfs4layouts.c                              |  31 +-
 fs/nfsd/nfs4proc.c                                 |   9 +-
 fs/nfsd/nfs4recover.c                              |   1 +
 fs/nfsd/nfs4state.c                                |  29 +-
 fs/nfsd/nfs4xdr.c                                  |  26 +-
 fs/nfsd/pnfs.h                                     |   8 +
 fs/nfsd/vfs.h                                      |  19 +
 fs/xfs/Makefile                                    |   3 +-
 fs/xfs/xfs_export.c                                |   2 +-
 fs/xfs/xfs_pnfs.h                                  |   2 +-
 include/linux/nfs4.h                               |  19 +
 include/linux/sunrpc/auth.h                        |   7 +
 include/linux/sunrpc/rpc_rdma.h                    |   1 +
 include/linux/sunrpc/svc_rdma.h                    |  20 +-
 net/sunrpc/auth_null.c                             |   4 +-
 net/sunrpc/auth_unix.c                             |   6 +-
 net/sunrpc/cache.c                                 |   6 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |  17 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c             |  64 ++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c            |  60 ++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              | 196 ++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c           | 445 +++++++--------------
 34 files changed, 1131 insertions(+), 558 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/pnfs-scsi-server.txt
