Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041Ab0HGUZY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Aug 2010 16:25:24 -0400
Date: Sat, 7 Aug 2010 16:23:50 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd patches for 2.6.36
Message-ID: <20100807202349.GA21311@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following nfsd changes are available from the for-2.6.36 branch of the git
repository at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.36

Mainly bugfixes: for delegation/callback races, for some long-standing
vfs abuse that could cause problems with NFSv4 open upgrades, and for
some error-handling on nfsd startup (thanks to Jeff Layton).

Chuck Lever also found a nice fix for a performance problem due to our
not providing atomic directory change information, when we easily could,
leading to poor performance when e.g. untarring a large tar file.

Thanks to everyone for your contributions!

--b.

Andi Kleen (1):
      gcc-4.6: nfsd: fix initialized but not read warnings

Andrea Gelmini (1):
      net: sunrpc: removed duplicated #include

Artem Bityutskiy (1):
      sunrpc: make the cache cleaner workqueue deferrable

Benny Halevy (1):
      nfsd: nfs4callback encode_stateid helper function

Boaz Harrosh (1):
      nfsd41: Fix a crash when a callback is retried

Chuck Lever (1):
      NFSD: Fill in WCC data for REMOVE, RMDIR, MKNOD, and MKDIR

J. Bruce Fields (23):
      nfsd4: remove extra put() on callback errors
      nfsd4: treat more recall errors as failures
      nfsd4: fix use of op_share_access
      nfsd4: don't bother storing callback reply tag
      nfsd4; fix session reference count leak
      nfsd4: translate memory errors to delay, not serverfault
      nfsd4: remove some debugging code
      nfsd4: fix deleg leak on callback error
      nfsd4: fix delegation recall race use-after-free
      nfsd4: comment nitpick
      nfsd: remove unused assignment from nfsd_link
      nfsd: move more into nfsd_startup()
      nfsd: minor nfsd_svc() cleanup
      nfsd: bypass readahead cache when have struct file
      nfsd4: don't pretend to support write delegations
      nfsd4: miscellaneous process_open2 cleanup
      nfsd4: fix openmode checking on IO using lock stateid
      nfsd4: share file descriptors between stateid's
      nfsd: minor nfsd read api cleanup
      nfsd: fix startup/shutdown order bug
      nfsd: initialize nfsd versions before creating svc
      nfsd: don't allow setting maxblksize after svc created
      nfsd4: fix file open accounting for RDWR opens

Jeff Layton (5):
      nfsd4: fix v4 state shutdown error paths
      nfsd: fix error handling when starting nfsd with rpcbind down
      nfsd: fix error handling in __write_ports_addxprt
      nfsd: clean up nfsd_create_serv error handling
      nfsd: just keep single lockd reference for nfsd

 fs/nfsd/nfs3proc.c           |    8 +-
 fs/nfsd/nfs4callback.c       |   57 ++++---
 fs/nfsd/nfs4state.c          |  381 ++++++++++++++++++++++++++----------------
 fs/nfsd/nfs4xdr.c            |    3 +-
 fs/nfsd/nfsctl.c             |   24 ++--
 fs/nfsd/nfsd.h               |    1 +
 fs/nfsd/nfsproc.c            |    4 +-
 fs/nfsd/nfssvc.c             |  151 +++++++++++------
 fs/nfsd/state.h              |   40 ++++-
 fs/nfsd/vfs.c                |   79 +++++----
 fs/nfsd/vfs.h                |    4 +-
 include/linux/sunrpc/cache.h |    1 +
 net/sunrpc/cache.c           |    8 +-
 net/sunrpc/sunrpc_syms.c     |    1 +
 14 files changed, 473 insertions(+), 289 deletions(-)
