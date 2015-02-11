Return-Path: linux-kernel-owner@vger.kernel.org
Date: Wed, 11 Feb 2015 16:17:25 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT] nfsd changes for 3.20 merge window
Message-ID: <20150211211725.GA28796@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.20 from

	git://linux-nfs.org/~bfields/linux.git for-3.20

The main change is the pNFS block server support from Christoph, which
allows an NFS client connected to shared disk to do block IO to the
shared disk in place of NFS reads and writes.  This also requires xfs
patches, which should arrive soon through the xfs tree, barring
unexpected problems.  Support for other filesystems is also possible if
there's interest.

Thanks also to Chuck Lever for continuing work to get NFS/RDMA into
shape.

--b.

----------------------------------------------------------------
Christoph Hellwig (15):
      nfsd: factor out a helper to decode nfstime4 values
      nfs: add LAYOUT_TYPE_MAX enum value
      fs: track fl_owner for leases
      fs: add FL_LAYOUT lease type
      nfsd: move nfsd_fh_match to nfsfh.h
      nfsd: add fh_fsid_match helper
      nfsd: make lookup/alloc/unhash_stid available outside nfs4state.c
      nfsd: make find/get/put file available outside nfs4state.c
      nfsd: make find_any_file available outside nfs4state.c
      nfsd: implement pNFS operations
      nfsd: implement pNFS layout recalls
      nfsd: update documentation for pNFS support
      nfsd: add trace events
      exportfs: add methods for block layout exports
      nfsd: pNFS block layout driver

Chuck Lever (10):
      svcrdma: Clean up dprintk
      svcrdma: Remove unused variable
      svcrdma: Clean up read chunk counting
      svcrdma: Scrub BUG_ON() and WARN_ON() call sites
      svcrdma: Find rmsgp more reliably
      svcrdma: Plant reader function in struct svcxprt_rdma
      svcrdma: rc_position sanity checking
      svcrdma: Support RDMA_NOMSG requests
      svcrdma: Move read list XDR round-up logic
      svcrdma: Handle additional inline content

J. Bruce Fields (4):
      nfsd4: tweak rd_dircount accounting
      nfsd: fix year-2038 nfs4 state problem
      Merge branch 'locks-3.20' of git://git.samba.org/jlayton/linux into for-3.20
      nfsd: default NFSv4.2 to on

Jeff Layton (2):
      nfsd: fi_delegees doesn't need to be an atomic_t
      sunrpc/lockd: fix references to the BKL

Rickard Strandqvist (2):
      lockd: xdr: Remove unused function
      nfsd: nfs4state: Remove unused function

 Documentation/filesystems/nfs/nfs41-server.txt     |  23 +-
 .../filesystems/nfs/pnfs-block-server.txt          |  37 ++
 fs/lockd/svclock.c                                 |   4 +-
 fs/lockd/xdr.c                                     |   8 -
 fs/locks.c                                         |  26 +-
 fs/nfsd/Kconfig                                    |  10 +
 fs/nfsd/Makefile                                   |   8 +-
 fs/nfsd/blocklayout.c                              | 189 ++++++
 fs/nfsd/blocklayoutxdr.c                           | 157 +++++
 fs/nfsd/blocklayoutxdr.h                           |  62 ++
 fs/nfsd/export.c                                   |   8 +
 fs/nfsd/export.h                                   |   2 +
 fs/nfsd/nfs4callback.c                             |  99 +++
 fs/nfsd/nfs4layouts.c                              | 721 +++++++++++++++++++++
 fs/nfsd/nfs4proc.c                                 | 310 +++++++++
 fs/nfsd/nfs4state.c                                |  76 +--
 fs/nfsd/nfs4xdr.c                                  | 362 ++++++++++-
 fs/nfsd/nfsctl.c                                   |   9 +-
 fs/nfsd/nfsd.h                                     |  16 +-
 fs/nfsd/nfsfh.h                                    |  18 +
 fs/nfsd/nfssvc.c                                   |   1 +
 fs/nfsd/pnfs.h                                     |  81 +++
 fs/nfsd/state.h                                    |  43 +-
 fs/nfsd/trace.c                                    |   5 +
 fs/nfsd/trace.h                                    |  54 ++
 fs/nfsd/xdr4.h                                     |  59 ++
 fs/nfsd/xdr4cb.h                                   |   7 +
 include/linux/exportfs.h                           |  23 +
 include/linux/fs.h                                 |  16 +
 include/linux/nfs4.h                               |   2 +
 include/linux/sunrpc/svc.h                         |   2 +-
 include/linux/sunrpc/svc_rdma.h                    |  13 +-
 include/uapi/linux/nfsd/debug.h                    |   1 +
 include/uapi/linux/nfsd/export.h                   |   4 +-
 net/sunrpc/svc.c                                   |   4 +-
 net/sunrpc/svc_xprt.c                              |   3 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c             |  16 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c            | 244 ++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  46 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |  47 +-
 40 files changed, 2562 insertions(+), 254 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/pnfs-block-server.txt
 create mode 100644 fs/nfsd/blocklayout.c
 create mode 100644 fs/nfsd/blocklayoutxdr.c
 create mode 100644 fs/nfsd/blocklayoutxdr.h
 create mode 100644 fs/nfsd/nfs4layouts.c
 create mode 100644 fs/nfsd/pnfs.h
 create mode 100644 fs/nfsd/trace.c
 create mode 100644 fs/nfsd/trace.h
