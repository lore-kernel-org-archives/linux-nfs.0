Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54834 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934031AbcHDVYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 17:24:48 -0400
Date: Thu, 4 Aug 2016 17:24:44 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.8
Message-ID: <20160804212444.GC3907@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.8

for nfsd changes for 4.8.

--b.

----------------------------------------------------------------
Highlights:

	Trond made a change to the server's tcp logic that allows a fast
	client to better take advantage of high bandwidth networks, but
	may increase the risk that a single client could starve other
	clients; a new sunrpc.svc_rpc_per_connection_limit parameter
	should help mitigate this in the (hopefully unlikely) event this
	becomes a problem in practice.

	Tom Haynes added a minimal flex-layout pnfs server, which is of
	no use in production for now--don't build it unless you're doing
	client testing or further server development.

----------------------------------------------------------------
Andrew Elble (3):
      nfs/nfsd: Move useful bitfield ops to a commonly accessible place
      nfsd: allow mach_creds_match to be used more broadly
      nfsd: implement machine credential support for some operations

Benjamin Coddington (1):
      xfs: abstract block export operations from nfsd layouts

Christophe JAILLET (1):
      nfsd: Fix some indent inconsistancy

Chuck Lever (1):
      nfsd: Close race between nfsd4_release_lockowner and nfsd4_lock

Dan Carpenter (1):
      nfsd: remove some dead code in nfsd_create_locked()

J. Bruce Fields (6):
      nfsd: remove redundant zero-length check from create
      nfsd: check d_can_lookup in fh_verify of directories
      nfsd: reorganize nfsd_create
      nfsd: remove unnecessary positive-dentry check
      nfsd: clean up bad-type check in nfsd_create_locked
      nfsd: drop unnecessary MAY_EXEC check from create

Jeff Layton (1):
      nfsd: allow nfsd to advertise multiple layout types

Kinglong Mee (1):
      nfsd/blocklayout: Make sure calculate signature/designator length aligned

NeilBrown (1):
      sunrpc: remove 'inuse' flag from struct cache_detail.

Oleg Drokin (2):
      nfsd: Correct a comment for NFSD_MAY_ defines location
      nfsd: Make creates return EEXIST instead of EACCES

Scott Mayhew (1):
      sunrpc: add gss minor status to svcauth_gss_proxy_init

Tom Haynes (2):
      nfsd: flex file device id encoding will need the server address
      nfsd: Add a super simple flex file server

Trond Myklebust (11):
      SUNRPC: Don't allocate a full sockaddr_storage for tracing
      SUNRPC: Add a tracepoint for server socket out-of-space conditions
      SUNRPC: Add tracepoints for dropped and deferred requests
      SUNRPC: lock the socket while detaching it
      SUNRPC: Call the default socket callbacks instead of open coding
      SUNRPC: Micro optimisation for svc_data_ready
      SUNRPC: Add a server side per-connection limit
      SUNRPC: Change TCP socket space reservation
      SUNRPC: Remove unused callback xpo_adjust_wspace()
      SUNRPC: accept() may return sockets that are still in SYN_RECV
      SUNRPC: Detect immediate closure of accepted sockets

 Documentation/kernel-parameters.txt |   6 ++
 fs/Kconfig                          |   6 ++
 fs/nfsd/Kconfig                     |  19 +++++
 fs/nfsd/Makefile                    |   1 +
 fs/nfsd/blocklayout.c               |   2 +
 fs/nfsd/blocklayoutxdr.c            |   4 +-
 fs/nfsd/export.c                    |  14 +++-
 fs/nfsd/export.h                    |   2 +-
 fs/nfsd/flexfilelayout.c            | 133 ++++++++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.c         | 115 +++++++++++++++++++++++++++
 fs/nfsd/flexfilelayoutxdr.h         |  49 ++++++++++++
 fs/nfsd/nfs4layouts.c               |  16 +++-
 fs/nfsd/nfs4proc.c                  |  48 ++++++++++--
 fs/nfsd/nfs4state.c                 |  74 ++++++++++--------
 fs/nfsd/nfs4xdr.c                   |  81 +++++++++----------
 fs/nfsd/nfsd.h                      |   5 ++
 fs/nfsd/nfsfh.c                     |  18 +++--
 fs/nfsd/nfsproc.c                   |   7 +-
 fs/nfsd/nfsxdr.c                    |   2 +-
 fs/nfsd/pnfs.h                      |   4 +
 fs/nfsd/state.h                     |   1 +
 fs/nfsd/vfs.c                       | 142 +++++++++++++++-------------------
 fs/nfsd/vfs.h                       |   3 +
 fs/nfsd/xdr4.h                      |   5 ++
 fs/xfs/Makefile                     |   3 +-
 fs/xfs/xfs_export.c                 |   2 +-
 fs/xfs/xfs_pnfs.h                   |   4 +-
 include/linux/nfs4.h                |  11 +++
 include/linux/nfs_xdr.h             |  11 ---
 include/linux/sunrpc/cache.h        |   2 -
 include/linux/sunrpc/svc.h          |   1 +
 include/linux/sunrpc/svc_xprt.h     |   2 +-
 include/trace/events/sunrpc.h       | 118 ++++++++++++++++++++++++----
 net/sunrpc/auth_gss/svcauth_gss.c   |   5 +-
 net/sunrpc/cache.c                  |   2 +-
 net/sunrpc/svc_xprt.c               |  51 ++++++++++--
 net/sunrpc/svcsock.c                | 150 +++++++++---------------------------
 37 files changed, 784 insertions(+), 335 deletions(-)
 create mode 100644 fs/nfsd/flexfilelayout.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.c
 create mode 100644 fs/nfsd/flexfilelayoutxdr.h

--b.
