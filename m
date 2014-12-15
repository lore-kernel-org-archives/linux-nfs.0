Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47411 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbaLORNo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2014 12:13:44 -0500
Date: Mon, 15 Dec 2014 12:13:42 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 3.19
Message-ID: <20141215171342.GD20089@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 3.19 from

  git://linux-nfs.org/~bfields/linux.git for-3.19

A comparatively quieter cycle for nfsd this time, but still with two
larger changes:

	- RPC server scalability improvements from Jeff Layton (using
	  RCU instead of a spinlock to find idle threads).
	- server-side NFSv4.2 ALLOCATE/DEALLOCATE support from Anna
	  Schumaker, enabling fallocate on new clients

--b.

----------------------------------------------------------------
Andy Shevchenko (1):
      sunrpc/cache: convert to use string_escape_str()

Anna Schumaker (3):
      VFS: Rename do_fallocate() to vfs_fallocate()
      nfsd: Add ALLOCATE support
      nfsd: Add DEALLOCATE support

Benjamin Coddington (2):
      nfsd4: fix xdr4 inclusion of escaped char
      nfsd4: fix xdr4 count of server in fs_location4

Chuck Lever (1):
      NFSD: Always initialize cl_cb_addr

Dan Carpenter (2):
      SUNRPC: off by one in BUG_ON()
      nfsd: minor off by one checks in __write_versions()

J. Bruce Fields (4):
      RPC: remove unneeded checks from xdr_truncate_encode()
      rpc: change comments to assertions
      merge nfs bugfixes into nfsd for-3.19 branch
      Merge tag 'nfs-for-3.19-1' into nfsd for-3.19 branch

Jeff Layton (19):
      nfsd: clean up comments over nfs4_file definition
      lockd: ratelimit "lockd: cannot monitor" messages
      nfsd: convert nfs4_file searches to use RCU
      sunrpc: eliminate the XPT_DETACHED flag
      sunrpc: release svc_pool_map reference when serv allocation fails
      sunrpc: add a generic rq_flags field to svc_rqst and move rq_secure to it
      sunrpc: move rq_local field to rq_flags
      sunrpc: move rq_usedeferral flag to rq_flags
      sunrpc: move rq_dropme flag into rq_flags
      sunrpc: move rq_splice_ok flag into rq_flags
      sunrpc: move rq_cachetype field to better optimize space
      sunrpc: convert sp_task_pending flag to use atomic bitops
      sunrpc: have svc_wake_up only deal with pool 0
      sunrpc: require svc_create callers to pass in meaningful shutdown routine
      sunrpc: add a rcu_head to svc_rqst and use kfree_rcu to free it
      sunrpc: fix potential races in pool_stats collection
      sunrpc: convert to lockless lookup of queued server threads
      sunrpc: add some tracepoints around enqueue and dequeue of svc_xprt
      sunrpc: only call test_bit once in svc_xprt_received

Rasmus Villemoes (1):
      fs: nfsd: Fix signedness bug in compare_blob

Zach Brown (1):
      nfsd: fix inclusive vfs_fsync_range() end

 drivers/staging/android/ashmem.c  |   2 +-
 fs/ioctl.c                        |   2 +-
 fs/lockd/mon.c                    |   2 +-
 fs/lockd/svc.c                    |   2 +-
 fs/nfsd/nfs4proc.c                |  57 +++++++-
 fs/nfsd/nfs4state.c               |  68 +++++----
 fs/nfsd/nfs4xdr.c                 |  34 ++++-
 fs/nfsd/nfscache.c                |   4 +-
 fs/nfsd/nfsctl.c                  |   6 +-
 fs/nfsd/nfsd.h                    |   9 +-
 fs/nfsd/nfsfh.c                   |   2 +-
 fs/nfsd/nfssvc.c                  |   2 +-
 fs/nfsd/state.h                   |  19 ++-
 fs/nfsd/vfs.c                     |  37 ++++-
 fs/nfsd/vfs.h                     |   2 +
 fs/nfsd/xdr4.h                    |   9 ++
 fs/open.c                         |   5 +-
 include/linux/fs.h                |   2 +-
 include/linux/sunrpc/svc.h        |  34 +++--
 include/linux/sunrpc/svc_xprt.h   |   7 +-
 include/trace/events/sunrpc.h     | 120 +++++++++++++++-
 mm/madvise.c                      |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c |   2 +-
 net/sunrpc/cache.c                |  26 +---
 net/sunrpc/svc.c                  |  42 +++---
 net/sunrpc/svc_xprt.c             | 292 +++++++++++++++++++++-----------------
 net/sunrpc/svcsock.c              |  32 +++--
 net/sunrpc/xdr.c                  |   9 +-
 28 files changed, 547 insertions(+), 283 deletions(-)
