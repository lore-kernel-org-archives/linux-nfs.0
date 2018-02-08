Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41256 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbeBHW6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Feb 2018 17:58:05 -0500
Date: Thu, 8 Feb 2018 17:58:04 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] please pull nfsd changes for 4.16
Message-ID: <20180208225804.GA17653@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.16 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.16

This request is late, apologies.

But it's also a fairly small update this time around.  Some cleanup,
RDMA fixes, overlayfs fixes, and a fix for an NFSv4 state bug.

The bigger deal for nfsd this time around is Jeff Layton's
already-merged i_version patches.  This series has a minor conflict with
that one, and the resolution should be obvious.  (Stephen Rothwell has
been carrying it in linux-next for what it's worth.)

--b.

Amir Goldstein (2):
      nfsd: encode stat->mtime for getattr instead of inode->i_mtime
      nfsd: store stat times in fill_pre_wcc() instead of inode times

Arnd Bergmann (1):
      NFSD: hide unused svcxdr_dupstr()

Benjamin Coddington (1):
      nfsd4: permit layoutget of executable-only files

Christoph Hellwig (1):
      sunrpc: remove dead code in svc_sock_setbufsize

Chuck Lever (2):
      svcrdma: Post Receives in the Receive completion handler
      svcrdma: Fix Read chunk round-up

Elena Reshetova (3):
      lockd: convert nsm_handle.sm_count from atomic_t to refcount_t
      lockd: convert nlm_lockowner.count from atomic_t to refcount_t
      lockd: convert nlm_rqst.a_count from atomic_t to refcount_t

J. Bruce Fields (2):
      nfsd4: don't set lock stateid's sc_type to CLOSED
      nfsd: return RESOURCE not GARBAGE_ARGS on too many ops

Trond Myklebust (1):
      nfsd: Detect unhashed stids in nfsd4_verify_open_stid()

 fs/lockd/clntproc.c                        | 14 +++++++-------
 fs/lockd/host.c                            |  2 +-
 fs/lockd/mon.c                             | 14 +++++++-------
 fs/lockd/svcproc.c                         |  2 +-
 fs/locks.c                                 |  6 ++----
 fs/nfsd/nfs3xdr.c                          | 31 +++++++++++++++++++++++++++++-
 fs/nfsd/nfs4proc.c                         |  9 ++++++---
 fs/nfsd/nfs4state.c                        |  6 ++----
 fs/nfsd/nfs4xdr.c                          | 16 +++++++++------
 fs/nfsd/nfsfh.h                            | 28 ++++++---------------------
 fs/nfsd/nfsxdr.c                           |  1 +
 include/linux/lockd/lockd.h                |  6 +++---
 include/linux/sunrpc/svc_rdma.h            |  2 --
 net/sunrpc/svcsock.c                       | 14 --------------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  5 -----
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  9 +--------
 net/sunrpc/xprtrdma/svc_rdma_rw.c          | 12 ++++++++----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  6 ------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 25 +++++++-----------------
 19 files changed, 92 insertions(+), 116 deletions(-)
