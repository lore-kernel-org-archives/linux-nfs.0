Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45656 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751332AbdB1VYN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Feb 2017 16:24:13 -0500
Date: Tue, 28 Feb 2017 16:23:33 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
Subject: [GIT PULL] nfsd changes for 4.11
Message-ID: <20170228212333.GA30667@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.11 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.11

The nfsd update this round is mainly a lot of miscellaneous cleanups and
bugfixes.

A couple changes could theoretically break working setups on upgrade.  I
don't expect complaints in practice, but they seem worth calling out
just in case:

	- NFS security labels are now off by default; a new
	  security_label export flag reenables it per export.  But,
	  having them on by default is a disaster, as it generally only
	  makes sense if all your clients and servers have similar
	  enough selinux policies.  Thanks to Jason Tibbitts for
	  pointing this out.

	- NFSv4/UDP support is off.  It was never really supported, and
	  the spec explicitly forbids it.  We only ever left it on out
	  of laziness; thanks to Jeff Layton for finally fixing that.

--b.

Christoph Hellwig (2):
      nfsd: minor nfsd_setattr cleanup
      nfsd: special case truncates some more

Chuck Lever (7):
      svcrdma: Another sendto chunk list parsing update
      svcrdma: Clean up RPC-over-RDMA Reply header encoder
      svcrdma: Clean up RPC-over-RDMA Call header decoder
      svcrdma: Clean up backchannel send header encoding
      svcrdma: Remove unused sc_dto_q field
      svcrdma: Combine list fields in struct svc_rdma_op_ctxt
      svcrdma: Poll CQs in "workqueue" mode

J. Bruce Fields (3):
      nfsd: constify nfsd_suppatttrs
      nfsd: opt in to labeled nfs per export
      nfsd: merge stable fix into main nfsd branch

Jeff Layton (4):
      sunrpc: turn bitfield flags in svc_version into bools
      sunrpc: flag transports as having congestion control
      nfs/nfsd/sunrpc: enforce transport requirements for NFSv4
      sunrpc: don't register UDP port with rpcbind when version needs congestion control

Kinglong Mee (11):
      NFSD: pass an integer for stable type to nfsd_vfs_write
      NFSD: cleanup dead codes and values in nfsd_write
      NFSD: Remove unused value inode in nfsd_vfs_write
      SUNRPC: Drop all entries from cache_detail when cache_purge()
      SUNRPC/Cache: Always treat the invalid cache as unexpired
      nfsd/idmap: return nfserr_inval for 0-length names
      nfsd/callback: Cleanup callback cred on shutdown
      nfsd/callback: skip the callback tag
      nfsd/callback: Drop a useless data copy when comparing sessionid
      NFSD: Get response size before operation for all RPCs
      NFSD: Reserve adequate space for LOCKT operation

Neil Brown (1):
      svcrpc: free contexts immediately on PROC_DESTROY

NeilBrown (2):
      NFSD: correctly range-check v4.x minor version when setting versions.
      NFSDv4: use export cache flushtime for changeid on V4ROOT objects.

Rasmus Villemoes (1):
      nfsd: remove superfluous KERN_INFO

Scott Mayhew (2):
      nfsd: initialize sin6_scope_id in nfsd_inet6addr_event()
      lockd: initialize sin6_scope_id in lockd_inet6addr_event()

Trond Myklebust (2):
      nfsd: fix configuration of supported minor versions
      nfsd: Fix display of the version string

 fs/lockd/svc.c                             |   2 +
 fs/nfs/callback_xdr.c                      |   6 +-
 fs/nfsd/export.c                           |   1 +
 fs/nfsd/nfs2acl.c                          |   1 -
 fs/nfsd/nfs3acl.c                          |   1 -
 fs/nfsd/nfs3proc.c                         |   8 +-
 fs/nfsd/nfs4callback.c                     |  19 +-
 fs/nfsd/nfs4idmap.c                        |   8 +
 fs/nfsd/nfs4proc.c                         |  88 +++++++--
 fs/nfsd/nfs4state.c                        |  12 +-
 fs/nfsd/nfs4xdr.c                          |  29 +--
 fs/nfsd/nfsctl.c                           |  70 +++----
 fs/nfsd/nfsd.h                             |   6 +-
 fs/nfsd/nfsproc.c                          |   8 +-
 fs/nfsd/nfssvc.c                           |  16 ++
 fs/nfsd/state.h                            |   1 +
 fs/nfsd/vfs.c                              | 104 +++++-----
 fs/nfsd/vfs.h                              |   6 +-
 include/linux/sunrpc/cache.h               |   6 +-
 include/linux/sunrpc/rpc_rdma.h            |   9 +
 include/linux/sunrpc/svc.h                 |  12 +-
 include/linux/sunrpc/svc_rdma.h            |  13 +-
 include/linux/sunrpc/svc_xprt.h            |   1 +
 include/uapi/linux/nfsd/export.h           |   5 +-
 net/sunrpc/auth_gss/svcauth_gss.c          |   4 +-
 net/sunrpc/cache.c                         |  53 +++--
 net/sunrpc/svc.c                           |  24 ++-
 net/sunrpc/svcsock.c                       |   1 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  17 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     | 299 ++++++++++-------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  20 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  22 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  69 ++++---
 33 files changed, 510 insertions(+), 431 deletions(-)
