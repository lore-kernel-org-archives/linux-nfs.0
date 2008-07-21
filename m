From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [git] nfsd changes for 2.6.27
Date: Sun, 20 Jul 2008 21:45:26 -0400
Message-ID: <20080721014526.GA3895@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34514 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546AbYGUBp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2008 21:45:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd-related changes from the for-2.6.27 branch of:

  git://linux-nfs.org/~bfields/linux.git for-2.6.27

A few lockd patches are included too (and one minor locks.c patch).

Changes include

	- server rdma bug fixes and improvements from Tom Tucker.
	- Jeff Layton's work converting nfsd to kthreads, fixing some
	  startup/shutdown races, and simplifying the way that nfsd
	  threads handle signals.
	- from Benny Halevy, some of the first patches resulting from
	  the NFSv4.1/pNFS effort, for now just cleanups of existing 4.0
	  code.

Plus various cleanup and bugfixes.

--b.

Benny Halevy (10):
      nfsd: make nfs4xdr WRITEMEM safe against zero count
      nfsd: eliminate unused nfs4_callback.cb_program
      nfsd: eliminate unused nfs4_callback.cb_stat
      nfsd: return nfserr_minor_vers_mismatch when compound minorversion != 0
      nfsd: tabulate nfs4 xdr decoding functions
      nfsd: unsupported nfs4 ops should fail with nfserr_opnotsupp
      nfsd: nfs4 minorversion decoder vectors
      nfsd: dprint operation names
      nfsd: tabulate nfs4 xdr encoding functions
      nfsd: take file and mnt write in nfs4_upgrade_open

Chuck Lever (1):
      lockd: Pass "struct sockaddr *" to new failover-by-IP function

Harvey Harrison (1):
      nfsd: nfs4xdr.c do-while is not a compound statement

J. Bruce Fields (9):
      nfsd: remove unnecessary atomic ops
      nfsd: add dprintk of compound return
      nfsd: remove three unused NFS4_ACE_* defines
      nfs: rewrap NFS/RDMA documentation to 80 lines
      Merge branch 'for-bfields' of git://linux-nfs.org/~tomtucker/xprt-switch-2.6 into for-2.6.27
      nfsd: document open share bit tracking
      lockd: minor svclock.c style fixes
      lockd: get host reference in nlmsvc_create_block() instead of callers
      nfsd: Use C99 initializers in fs/nfsd/nfs4xdr.c

James Lentini (1):
      update NFS/RDMA documentation

Jeff Layton (9):
      knfsd: clean up nfsd filesystem interfaces
      knfsd: remove special handling for SIGHUP
      knfsd: convert knfsd to kthread API
      sunrpc: remove sv_kill_signal field from svc_serv struct
      lockd: close potential race with rapid lockd_up/lockd_down cycle
      nfsd: treat all shutdown signals as equivalent
      lockd: nlm_release_host() checks for NULL, caller needn't
      lockd: eliminate duplicate nlmsvc_lookup_host call from nlmsvc_testlock
      lockd: eliminate duplicate nlmsvc_lookup_host call from nlmsvc_lock

Kevin Coffman (3):
      gss_krb5: create a define for token header size and clean up ptr location
      gss_krb5: move gss_krb5_crypto into the krb5 module
      gss_krb5: Use random value to initialize confounder

Miklos Szeredi (2):
      nfsd: rename MAY_ flags
      nfsd: clean up mnt_want_write calls

Neil Brown (3):
      knfsd: Replace lock_kernel with a mutex for nfsd thread startup/shutdown locking.
      nfsd: fix race in nfsd_nrthreads()
      nfsd: fix spurious EACCESS in reconnect_path()

NeilBrown (1):
      knfsd: nfsd: Handle ERESTARTSYS from syscalls.

Richard Kennedy (1):
      file lock: reorder struct file_lock to save space on 64 bit builds

Tom Tucker (11):
      svcrdma: Add a type for keeping NFS RPC mapping
      svcrdma: Use RPC reply map for RDMA_WRITE processing
      svcrdma: Use reply and chunk map for RDMA_READ processing
      svcrdma: Move the DMA unmap logic to the CQ handler
      svcrdma: Add dma map count and WARN_ON
      svcrdma: Remove unneeded spin locks from __svc_rdma_free
      svcrdma: Remove unused wait q from svcrdma_xprt structure
      svcrdma: Limit ORD based on client's advertised IRD
      svcrdma: Add flush_scheduled_work to module exit function
      svcrdma: Create a kmem cache for the WR contexts
      svcrdma: Change WR context get/put to use the kmem cache

 Documentation/filesystems/nfs-rdma.txt   |  103 +++++----
 fs/lockd/svc.c                           |   33 +--
 fs/lockd/svc4proc.c                      |    7 +-
 fs/lockd/svclock.c                       |   33 +--
 fs/lockd/svcproc.c                       |    7 +-
 fs/lockd/svcsubs.c                       |   32 ++-
 fs/nfsd/lockd.c                          |    2 +-
 fs/nfsd/nfs2acl.c                        |    7 +-
 fs/nfsd/nfs3acl.c                        |    5 +-
 fs/nfsd/nfs3proc.c                       |    8 +-
 fs/nfsd/nfs4proc.c                       |   76 +++++-
 fs/nfsd/nfs4state.c                      |   49 +++-
 fs/nfsd/nfs4xdr.c                        |  392 +++++++++++++-----------------
 fs/nfsd/nfsctl.c                         |  118 +++++++---
 fs/nfsd/nfsfh.c                          |   31 ++-
 fs/nfsd/nfsproc.c                        |    9 +-
 fs/nfsd/nfssvc.c                         |  148 ++++++------
 fs/nfsd/vfs.c                            |  140 ++++++------
 include/linux/fs.h                       |    4 +-
 include/linux/lockd/lockd.h              |    8 +-
 include/linux/nfs4.h                     |    3 -
 include/linux/nfsd/nfsd.h                |   27 +-
 include/linux/nfsd/state.h               |    2 -
 include/linux/sunrpc/gss_krb5.h          |    3 +
 include/linux/sunrpc/svc.h               |    7 +-
 include/linux/sunrpc/svc_rdma.h          |   36 +++-
 net/sunrpc/auth_gss/Makefile             |    4 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c    |   10 -
 net/sunrpc/auth_gss/gss_krb5_seal.c      |   26 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c    |   16 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c      |   72 ++++---
 net/sunrpc/svc.c                         |  110 +++------
 net/sunrpc/xprtrdma/svc_rdma.c           |   35 +++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   84 +++----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  166 ++++++-------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  195 ++++++----------
 36 files changed, 1042 insertions(+), 966 deletions(-)
