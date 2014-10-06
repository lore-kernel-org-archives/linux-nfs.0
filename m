Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37776 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbaJFSmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 14:42:36 -0400
Date: Mon, 6 Oct 2014 14:42:34 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jeff Layton <jlayton@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [GIT PULL] nfsd changes for 3.18
Message-ID: <20141006184234.GA13733@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull 3.18 nfsd changes from:

  git://linux-nfs.org/~bfields/linux.git for-3.18

Highlights:

	- support the NFSv4.2 SEEK operation (allowing clients to
	  support SEEK_HOLE/SEEK_DATA), thanks to Anna.
	- end the grace period early in a number of cases, mitigating a
	  long-standing annoyance, thanks to Jeff.
	- improve SMP scalability, thanks to Trond.

--b.

----------------------------------------------------------------
Anna Schumaker (3):
      NFSD: Update some as-yet unused 4.2 error codes
      NFSD: Add generic v4.2 infrastructure
      NFSD: Implement SEEK

Benny Halevy (1):
      nfsd: do not clear rpc_resp in nfsd4_cb_done_sequence

Christoph Hellwig (6):
      nfsd: update mtime on truncate
      nfsd: fix nfsd4_cb_recall_done error handling
      nfsd: remove nfsd4_callback.cb_op
      nfsd: introduce a generic nfsd4_cb
      nfsd: split nfsd4_callback initialization and use
      nfsd: introduce nfsd4_callback_ops

Chuck Lever (1):
      sunrpc: fix byte-swapping of displayed XID

J. Bruce Fields (6):
      nfsd4: remove obsolete comment
      nfsd4: reserve adequate space for LOCK op
      SUNRPC: Fix compile on non-x86
      nfsd4: remove labeled NFS warning from config help
      nfsd4: stop grace_time update at end of grace period
      nfsd4: clarify how grace period ends

Jeff Layton (12):
      nfsd: protect lease-related nfs4_file fields with fi_lock
      nfsd: call nfs4_put_deleg_lease outside of state_lock
      lockd: move lockd's grace period handling into its own module
      nfsd: remove redundant boot_time parm from grace_done client tracking op
      nfsd: reject reclaim request when client has already sent RECLAIM_COMPLETE
      lockd: add a /proc/fs/lockd/nlm_end_grace file
      nfsd: add a v4_end_grace file to /proc/fs/nfsd
      nfsd: pass extra info in env vars to upcalls to allow for early grace period end
      nfsd: serialize nfsdcltrack upcalls for a particular client
      nfsd: set and test NFSD4_CLIENT_STABLE bit to reduce nfsdcltrack upcalls
      nfsd: skip subsequent UMH "create" operations after the first one for v4.0 clients
      nfsd: eliminate "to_delegation" define

Kinglong Mee (7):
      NFSD: Remove duplicate initialization of file_lock
      NFSD: Put file after ima_file_check fail in nfsd_open()
      NFSD: Reset creds after mnt_want_write_file() fail
      NFSD: Fix a memory leak if nfsd4_recdir_load fail
      NFSD: Fix bad using of return value from qword_get
      NFSD: Full checking of authentication name
      NFSD: Put export if prepare_creds() fail

Rajesh Ghanekar (1):
      nfsd: allow turning off nfsv3 readdir_plus

Ross Lagerwall (1):
      nfsd3: Check write permission after checking existence

Steve Wise (1):
      svcrdma: advertise the correct max payload

Trond Myklebust (16):
      SUNRPC: Do not override wspace tests in svc_handle_xprt
      lockd: Ensure that lockd_start_svc sets the server rq_task...
      nfs: Ensure that nfs_callback_start_svc sets the server rq_task...
      SUNRPC: Do not grab pool->sp_lock unnecessarily in svc_get_next_xprt
      SUNRPC: get rid of the request wait queue
      SUNRPC: Fix broken kthread_should_stop test in svc_get_next_xprt
      SUNRPC: More optimisations of svc_xprt_enqueue()
      SUNRPC: Optimise away svc_recv_available
      nfsd: Clean up drc cache in preparation for global spinlock elimination
      nfsd: convert the lru list into a per-bucket thing
      nfsd: Remove the cache_hash list
      nfsd: convert num_drc_entries to an atomic_t
      nfsd: split DRC global spinlock into per-bucket locks
      nfsd: Reorder nfsd_cache_match to check more powerful discriminators first
      lockd: Do not start the lockd thread before we've set nlmsvc_rqst->rq_task
      nfs: do not start the callback thread until we set rqstp->rq_task

 fs/Kconfig                               |   6 +-
 fs/lockd/Makefile                        |   3 +-
 fs/lockd/netns.h                         |   1 -
 fs/lockd/procfs.c                        |  92 +++++++++++++
 fs/lockd/procfs.h                        |  28 ++++
 fs/lockd/svc.c                           |  16 ++-
 fs/nfs/callback.c                        |   4 +-
 fs/nfs_common/Makefile                   |   3 +-
 fs/{lockd => nfs_common}/grace.c         |  68 ++++++++--
 fs/nfsd/Kconfig                          |   4 +-
 fs/nfsd/cache.h                          |   1 -
 fs/nfsd/export.c                         |   1 +
 fs/nfsd/nfs3proc.c                       |  13 +-
 fs/nfsd/nfs4callback.c                   | 144 ++++++---------------
 fs/nfsd/nfs4idmap.c                      |  20 ++-
 fs/nfsd/nfs4proc.c                       |  49 +++++++
 fs/nfsd/nfs4recover.c                    | 205 +++++++++++++++++++++++------
 fs/nfsd/nfs4state.c                      | 115 +++++++++++++----
 fs/nfsd/nfs4xdr.c                        |  75 ++++++++++-
 fs/nfsd/nfscache.c                       | 214 ++++++++++++++++---------------
 fs/nfsd/nfsctl.c                         |  45 +++++++
 fs/nfsd/nfsd.h                           |   2 +-
 fs/nfsd/nfsfh.c                          |   6 +-
 fs/nfsd/state.h                          |  31 ++++-
 fs/nfsd/vfs.c                            |  37 ++++--
 fs/nfsd/xdr4.h                           |  14 ++
 include/linux/nfs4.h                     |  26 +++-
 include/linux/proc_fs.h                  |   2 +
 include/linux/sunrpc/svc.h               |   1 -
 include/uapi/linux/nfsd/export.h         |   5 +-
 net/sunrpc/svc.c                         |   2 -
 net/sunrpc/svc_xprt.c                    |  81 +++++-------
 net/sunrpc/svcsock.c                     |  25 +---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h          |   7 +
 35 files changed, 942 insertions(+), 406 deletions(-)
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h
 rename fs/{lockd => nfs_common}/grace.c (50%)
