Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43492 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab2GaO3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:29:49 -0400
Date: Tue, 31 Jul 2012 10:29:48 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.6
Message-ID: <20120731142948.GC27834@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd (and some lockd and a couple locks/lease) changes from:

	git://linux-nfs.org/~bfields/linux.git nfsd-next

This has been an unusually quiet cycle--mostly bugfixes and cleanup.
The one large piece is Stanislav's work to containerize the server's
grace period--but that in itself is just one more step in a
not-yet-complete project to allow fully containerized nfs service.

There are a number of outstanding delegation, container, v4 state, and
gss patches that aren't quite ready yet; 3.7 may be wilder.

--b.

----------------------------------------------------------------
Chuck Lever (1):
      NFSD: TEST_STATEID should not return NFS4ERR_STALE_STATEID

Eldad Zack (2):
      sunrpc/cache.h: fix coding style
      sunrpc/cache.h: replace simple_strtoul

Filipe Brandenburger (1):
      locks: prevent side-effects of locks_release_private before file_lock is initialized

J. Bruce Fields (10):
      nfsd4: remove unnecessary comment
      nfsd4: nfsd4_lock() cleanup
      nfsd4: process_open2 cleanup
      nfsd4: our filesystems are normally case sensitive
      nfsd4: release openowners on free in >=4.1 case
      nfsd: allow owner_override only for regular files
      nfsd: share some function prototypes
      nfsd: add get_uint for u32's
      locks: move lease-specific code out of locks_delete_lock
      nfsd4: fix missing fault_inject.h include

NeilBrown (1):
      SUNRPC/cache: fix reporting of expired cache entries in 'content' file.

Stanislav Kinsbursky (18):
      NFSd: fix locking in nfsd_forget_delegations()
      NFSd: introduce nfsd_destroy() helper
      NFSd: set nfsd_serv to NULL after service destruction
      LockD: mark host per network namespace on garbage collect
      LockD: make garbage collector network namespace aware.
      LockD: manage garbage collection timeout per networks namespace
      LockD: manage used host count per networks namespace
      Lockd: host complaining function introduced
      Lockd: add more debug to host shutdown functions
      LockD: manage grace period per network namespace
      LockD: make lockd manager allocated per network namespace
      NFSd: make nfsd4_manager allocated per network namespace context.
      SUNRPC: service request network namespace helper introduced
      LockD: manage grace list per network namespace
      LockD: pass actual network namespace to grace period management functions
      Lockd: move grace period management from lockd() to per-net functions
      NFSd: make grace end flag per network namespace
      NFSd: make boot_time variable per network namespace

Vivek Trivedi (1):
      nfsd4: fix cr_principal comparison check in same_creds

Weston Andros Adamson (1):
      nfsd: probe the back channel on new connections

 fs/lockd/grace.c             |   16 ++--
 fs/lockd/host.c              |   92 ++++++++++++-------
 fs/lockd/netns.h             |    7 ++
 fs/lockd/svc.c               |   43 +++++----
 fs/lockd/svc4proc.c          |   13 +--
 fs/lockd/svclock.c           |   16 ++--
 fs/lockd/svcproc.c           |   15 ++--
 fs/lockd/svcsubs.c           |   19 ++--
 fs/locks.c                   |   28 +++---
 fs/nfs/callback_xdr.c        |    4 +-
 fs/nfsd/export.c             |   10 +--
 fs/nfsd/netns.h              |    4 +
 fs/nfsd/nfs4callback.c       |    1 -
 fs/nfsd/nfs4idmap.c          |    4 +-
 fs/nfsd/nfs4proc.c           |   18 ++--
 fs/nfsd/nfs4state.c          |  201 +++++++++++++++++++++++++-----------------
 fs/nfsd/nfs4xdr.c            |    2 +-
 fs/nfsd/nfsctl.c             |    8 +-
 fs/nfsd/nfsd.h               |   13 +++
 fs/nfsd/nfssvc.c             |   24 ++---
 fs/nfsd/state.h              |    5 +-
 fs/nfsd/vfs.c                |   10 ++-
 include/linux/fs.h           |    5 +-
 include/linux/lockd/lockd.h  |    6 +-
 include/linux/sunrpc/cache.h |   34 +++++--
 include/linux/sunrpc/svc.h   |    2 +
 net/sunrpc/cache.c           |    5 +-
 27 files changed, 368 insertions(+), 237 deletions(-)
