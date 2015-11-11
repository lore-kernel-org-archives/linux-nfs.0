Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957AbbKKUCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2015 15:02:15 -0500
Date: Wed, 11 Nov 2015 15:02:12 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.4
Message-ID: <20151111200212.GC29410@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.4

Apologies for coming a little late in the merge window.  Fortunately
this is another fairly quiet one, mainly smaller bugfixes and cleanup.

We're still finding some bugs from the breakup of the big NFSv4 state
lock in 3.17--thanks especially to Andrew Elble and Jeff Layton for
tracking down some of the remaining races.

--b.

----------------------------------------------------------------
Andrew Elble (2):
      nfsd: eliminate sending duplicate and repeated delegations
      nfsd: fix race with open / open upgrade stateids

Andrey Ryabinin (2):
      lockd: create NSM handles per net namespace
      lockd: get rid of reference-counted NSM RPC clients

Arnd Bergmann (1):
      sunrpc: avoid warning in gss_key_timeout

J. Bruce Fields (3):
      nfsd: fix clid_inuse on mount with security change
      nfsd: improve client_has_state to check for unused openowners
      svcrpc: document lack of some memory barriers

Jeff Layton (7):
      nfsd: serialize state seqid morphing operations
      nfsd: move svc_fh->fh_maxsize to just after fh_handle
      nfsd: switch unsigned char flags in svc_fh to bools
      nfsd: move include of state.h from trace.c to trace.h
      nfsd: serialize layout stateid morphing operations
      nfsd: ensure that seqid morphing operations are atomic wrt to copies
      nfsd: remove recurring workqueue job to clean DRC

Julia Lawall (1):
      nfsd: drop null test before destroy functions

Neil Brown (1):
      sunrpc/cache: make cache flushing more reliable.

Stefan Hajnoczi (1):
      SUNRPC: drop stale comment in svc_setup_socket()

Trond Myklebust (1):
      SUNRPC: Use MSG_SENDPAGE_NOTLAST when calling sendpage()

 fs/lockd/host.c                |   8 +-
 fs/lockd/mon.c                 | 125 ++++++-------------
 fs/lockd/netns.h               |   4 +-
 fs/lockd/svc.c                 |   2 +-
 fs/lockd/svc4proc.c            |   2 +-
 fs/lockd/svcproc.c             |   2 +-
 fs/nfsd/nfs3xdr.c              |   4 +-
 fs/nfsd/nfs4layouts.c          |  34 ++++--
 fs/nfsd/nfs4proc.c             |   4 +
 fs/nfsd/nfs4state.c            | 265 +++++++++++++++++++++++++++++++----------
 fs/nfsd/nfscache.c             |  32 +----
 fs/nfsd/nfsfh.c                |   5 +-
 fs/nfsd/nfsfh.h                |  20 ++--
 fs/nfsd/state.h                |  43 +++----
 fs/nfsd/trace.c                |   2 -
 fs/nfsd/trace.h                |   2 +
 fs/nfsd/vfs.c                  |   4 +-
 fs/nfsd/vfs.h                  |   4 +-
 fs/nfsd/xdr4.h                 |   2 +-
 include/linux/lockd/lockd.h    |  10 +-
 include/linux/sunrpc/cache.h   |  16 ++-
 net/sunrpc/auth_gss/auth_gss.c |  13 +-
 net/sunrpc/cache.c             |  53 +++++++--
 net/sunrpc/svcsock.c           |  40 +++++--
 net/sunrpc/xprtsock.c          |   4 +-
 25 files changed, 415 insertions(+), 285 deletions(-)
