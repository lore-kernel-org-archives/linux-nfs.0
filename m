Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38590 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab0ESU5x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 16:57:53 -0400
Date: Wed, 19 May 2010 16:57:52 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd changes for 2.6.35
Message-ID: <20100519205752.GO9720@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please pull the following nfsd changes from the for-2.6.35 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.35

Changes include implementation of RECLAIM_COMPLETE.  That depended on
improvements to the nfsv4 state code from Benny Halevy, which a) allow
us to safely deference a client from an associated session as long as
we're processing a compound associated with that session, b) keep down
the scope of the state lock, and c) prevent us from rudely expiring a
client while we're still processing a compound from that client.

The grace and lease-time setting interfaces have been fixed.  (For
developers, one improvement is that it's easier to set shorter grace and
lease periods if necessary to reduce testing time.)

We now support a long-neglected NFSv4.0 SETCLIENTID feature which allows
a client to change its callback path.  It's little-used in 4.0, though
mandatory.  More importantly, it sets the groundwork for some callback
improvements which will be needed to bring the 4.1 session
implementation up to spec.

Neil Brown did some cleanup of the cache code in preparation for some
improvements to the deferral behavior, which unfortunately haven't
themselves been merged yet.

And there are miscellaneous fixes and cleanup from a number of people.
Thanks to all contributors!

--b.

Benny Halevy (10):
      nfsd4: use local variable in nfs4svc_encode_compoundres
      nfsd4: rename sessionid_lock to client_lock
      nfsd4: fold release_session into expire_client
      nfsd4: use list_move in move_to_confirmed
      nfsd4: extend the client_lock to cover cl_lru
      nfsd4: refactor expire_client
      nfsd4: introduce nfs4_client.cl_refcount
      nfsd4: mark_client_expired
      nfsd4: keep a reference count on client while in use
      nfsd4: nfsd4_destroy_session must set callback client under the state lock

Dan Carpenter (1):
      nfsd: potential ERR_PTR dereference on exp_export() error paths.

J. Bruce Fields (27):
      nfsd4: simplify references to nfsd4 lease time
      nfsd4: simplify lease/grace interaction
      nfsd4: remove unnecessary lease-setting function
      nfsd4: reshuffle lease-setting code to allow reuse
      nfsd4: allow setting grace period time
      nfsd4: document lease/grace-period limits
      Merge commit 'v2.6.34-rc1' into for-2.6.35-incoming
      svcrpc: don't hold sv_lock over svc_xprt_put()
      nfsd4: preallocate nfs4_rpc_args
      nfsd4: shutdown callbacks on expiry
      nfsd4: remove dprintk
      nfsd4: remove probe task's reference on client
      nfsd4: consistent session flag setting
      nfsd4: indentation cleanup
      nfsd4: don't sleep in lease-break callback
      nfsd4: cl_count is unused
      nfsd4: rearrange cb data structures
      nfsd4: allow 4.0 clients to change callback path
      nfsd4: complete enforcement of 4.1 op ordering
      nfsd4: fix filehandle comment
      nfsd4: fix unlikely race in session replay case
      nfsd: further comment typos
      Merge commit 'v2.6.34-rc6'
      nfsd4: fix bare destroy_session null dereference
      nfsd4: implement reclaim_complete
      nfs4: minor callback code simplification, comment
      Revert "nfsd4: distinguish expired from stale stateids"

Jeff Layton (1):
      nfsd: don't break lease while servicing a COMMIT

Li Zefan (1):
      sunrpc/cache: fix module refcnt leak in a failure path

Neil Brown (1):
      sunrpc: centralise most calls to svc_xprt_received

NeilBrown (4):
      sunrpc: don't keep expired entries in the auth caches.
      sunrpc/cache: factor out cache_is_expired
      sunrpc: never return expired entries in sunrpc_cache_lookup
      nfsd: factor out hash functions for export caches.

Pavel Emelyanov (2):
      NFSD: don't report compiled-out versions as present
      nfsd: safer initialization order in find_file()

 Documentation/filesystems/nfs/nfs41-server.txt |    2 +-
 fs/nfsd/export.c                               |   44 ++--
 fs/nfsd/nfs4callback.c                         |  140 ++++++---
 fs/nfsd/nfs4proc.c                             |   50 +++-
 fs/nfsd/nfs4state.c                            |  376 ++++++++++++-----------
 fs/nfsd/nfs4xdr.c                              |   27 ++-
 fs/nfsd/nfsctl.c                               |   64 +++-
 fs/nfsd/nfsd.h                                 |    6 +-
 fs/nfsd/nfssvc.c                               |    2 +-
 fs/nfsd/state.h                                |   47 +++-
 fs/nfsd/vfs.c                                  |    8 +-
 fs/nfsd/vfs.h                                  |    1 +
 fs/nfsd/xdr4.h                                 |   11 +-
 include/linux/nfsd/nfsfh.h                     |    6 +-
 net/sunrpc/cache.c                             |   45 ++-
 net/sunrpc/svc_xprt.c                          |    6 +-
 net/sunrpc/svcsock.c                           |   15 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c        |    3 -
 18 files changed, 510 insertions(+), 343 deletions(-)
