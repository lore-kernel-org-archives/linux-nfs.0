Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39508 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754995AbcJLSyt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Oct 2016 14:54:49 -0400
Date: Wed, 12 Oct 2016 14:54:47 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.9
Message-ID: <20161012185447.GB14698@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.9

for you to fetch changes up to 29ae7f9dc21a7dda41d78b27bbda7d427ece8ad4:

  NFSD: Implement the COPY call (2016-10-07 14:54:25 -0400)

----------------------------------------------------------------
Some RDMA work and some good bugfixes, and two new features that could
benefit from user testing:

Anna Schumacker contributed a simple NFSv4.2 COPY implementation.  COPY
is already supported on the client side, so a call to copy_file_range()
on a recent client should now result in a server-side copy that doesn't
require all the data to make a round trip to the client and back.

Jeff Layton implemented callbacks to notify clients when contended locks
become available, which should reduce latency on workloads with
contended locks.

----------------------------------------------------------------
Anna Schumaker (1):
      NFSD: Implement the COPY call

Chuck Lever (5):
      svcrdma: Tail iovec leaves an orphaned DMA mapping
      svcrdma: Skip put_page() when send_reply() fails
      rpcrdma: RDMA/CM private message data structure
      svcrdma: Server-side support for rpcrdma_connect_private
      svcrdma: support Remote Invalidation

J. Bruce Fields (4):
      nfsd: randomize SETCLIENTID reply to help distinguish servers
      nfsd4: setclientid_confirm with unmatched verifier should fail
      nfsd: only WARN once on unmapped errors
      nfsd: handle EUCLEAN

Jeff Layton (8):
      nfsd: don't set a FL_LAYOUT lease for flexfiles layouts
      nfsd: eliminate cb_minorversion field
      nfsd: fix dprintk in nfsd4_encode_getdeviceinfo
      nfsd: plumb in a CB_NOTIFY_LOCK operation
      nfsd: have nfsd4_lock use blocking locks for v4.1+ locks
      nfsd: add a LRU list for blocked locks
      nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
      nfsd: set the MAY_NOTIFY_LOCK flag in OPEN replies

NeilBrown (1):
      exportfs: be careful to only return expected errors.

Vasily Averin (1):
      NFSD: fix corruption in notifier registration

 fs/exportfs/expfs.c                        |  10 +-
 fs/nfsd/flexfilelayout.c                   |   1 +
 fs/nfsd/netns.h                            |   1 +
 fs/nfsd/nfs4callback.c                     |  64 +++++++-
 fs/nfsd/nfs4layouts.c                      |   6 +-
 fs/nfsd/nfs4proc.c                         |  90 +++++++++--
 fs/nfsd/nfs4state.c                        | 237 ++++++++++++++++++++++++++---
 fs/nfsd/nfs4xdr.c                          |  65 +++++++-
 fs/nfsd/nfsctl.c                           |   2 +
 fs/nfsd/nfsproc.c                          |   3 +-
 fs/nfsd/nfssvc.c                           |  18 ++-
 fs/nfsd/pnfs.h                             |   1 +
 fs/nfsd/state.h                            |  22 ++-
 fs/nfsd/vfs.c                              |  16 ++
 fs/nfsd/vfs.h                              |   2 +
 fs/nfsd/xdr4.h                             |  23 +++
 fs/nfsd/xdr4cb.h                           |   9 ++
 include/linux/exportfs.h                   |  13 +-
 include/linux/sunrpc/rpc_rdma.h            |  35 +++++
 include/linux/sunrpc/svc_rdma.h            |  10 ++
 include/uapi/linux/nfs4.h                  |   5 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  82 +++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  60 ++++++--
 25 files changed, 683 insertions(+), 96 deletions(-)
