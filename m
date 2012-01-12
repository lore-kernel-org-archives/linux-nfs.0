Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47391 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab2ALWWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 17:22:06 -0500
Date: Thu, 12 Jan 2012 17:22:04 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.3
Message-ID: <20120112222204.GB9592@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd changes for 3.3 are available from

  git://linux-nfs.org/~bfields/linux.git for-3.3

This was a fairly quiet cycle.  About the only new feature is Bryan's
fault-injection code, which simulates certain kinds of bad server
behavior as a way to test client recovery paths.

Other than that, mostly bugfixes: some fixes for reboot recovery
(especially in the NFSv4.1 case), fixes for unusual races on shutdown of
the nfsd server, and some continuing overhaul of the NFSv4 state
(especially handling of lockowners).

Neil also asked to have his name taken out of the MAINTAINER entry,
though he continues to be an important (if now more occasional)
contributor.  Thanks very much to Neil for his service over the years!

--b.

Bryan Schumaker (7):
      NFSD: Added fault injection
      NFSD: Added fault injection script
      NFSD: Added fault injection documentation
      NFSD: Call nfsd4_init_slabs() from init_nfsd()
      NFSD: Remove unnecessary whitespace
      NFSD: Only reinitilize the recall_lru list under the recall lock
      NFSD: forget_delegations should use list_for_each_entry_safe

Chuck Lever (1):
      NFSD: Change name of extended attribute containing junction

J. Bruce Fields (17):
      nfsd4: fix lockowner matching
      nfsd4: cleanup lock clientid handling in sessions case
      nfsd4: maintain one seqid stream per (lockowner, file)
      nfsd4: hash lockowners to simplify RELEASE_LOCKOWNER
      nfsd4: share open and lock owner hash tables
      nfsd4: fix CONFIG_NFSD_FAULT_INJECTION compile error
      nfsd4: add a separate (lockowner, inode) lookup
      svcrpc: make svc_delete_xprt static
      svcrpc: destroy server sockets all at once
      svcrpc: avoid memory-corruption on pool shutdown
      svcrpc: update outdated BKL comment
      nfsd4: initialize special stateid's at compile time
      nfsd4: fix spurious 4.1 post-reboot failures
      nfsd4: be forgiving in the absence of the recovery directory
      svcrpc: fix double-free on shutdown of nfsd after changing pool mode
      svcrpc: don't revert to SVC_POOL_DEFAULT on nfsd shutdown
      nfsd4: nfsd4_create_clid_dir return value is unused

Mi Jinlong (1):
      nfsd41: allow non-reclaim open-by-fh's in 4.1

NeilBrown (1):
      Update NFSD MAINTAINER

Sasha Levin (1):
      nfsd: Fix oops when parsing a 0 length export

Stanislav Kinsbursky (2):
      SUNRPC: create svc_xprt in proper network namespace
      NFSd: use network-namespace-aware cache registering routines

Thomas Meyer (1):
      nfsd4: Use kmemdup rather than duplicating its implementation

 CREDITS                                           |    5 +
 Documentation/filesystems/nfs/00-INDEX            |    2 +
 Documentation/filesystems/nfs/fault_injection.txt |   69 +++++
 MAINTAINERS                                       |    1 -
 fs/nfsd/Kconfig                                   |   10 +
 fs/nfsd/Makefile                                  |    1 +
 fs/nfsd/export.c                                  |   12 +-
 fs/nfsd/fault_inject.c                            |   91 ++++++
 fs/nfsd/fault_inject.h                            |   28 ++
 fs/nfsd/nfs4idmap.c                               |   11 +-
 fs/nfsd/nfs4proc.c                                |    7 +-
 fs/nfsd/nfs4recover.c                             |   22 +-
 fs/nfsd/nfs4state.c                               |  328 +++++++++++++++------
 fs/nfsd/nfs4xdr.c                                 |    3 +-
 fs/nfsd/nfsctl.c                                  |   10 +-
 fs/nfsd/nfsd.h                                    |   20 +-
 fs/nfsd/state.h                                   |    3 +-
 fs/nfsd/vfs.c                                     |   17 +-
 include/linux/sunrpc/svc_xprt.h                   |    3 +-
 include/linux/sunrpc/svcsock.h                    |    2 +-
 net/sunrpc/cache.c                                |    2 +
 net/sunrpc/svc.c                                  |   25 +-
 net/sunrpc/svc_xprt.c                             |   62 +++--
 net/sunrpc/svcsock.c                              |    8 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c          |    2 +-
 tools/nfsd/inject_fault.sh                        |   49 +++
 26 files changed, 624 insertions(+), 169 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/fault_injection.txt
 create mode 100644 fs/nfsd/fault_inject.c
 create mode 100644 fs/nfsd/fault_inject.h
 create mode 100755 tools/nfsd/inject_fault.sh
