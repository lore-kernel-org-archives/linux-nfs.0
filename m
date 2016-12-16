Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41508 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761721AbcLPPLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Dec 2016 10:11:18 -0500
Date: Fri, 16 Dec 2016 10:11:15 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.10
Message-ID: <20161216151115.GB31705@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.10

The one new feature is support for a new NFSv4.2 mode_umask attribute
that makes ACL inheritance a little more useful in environments that
default to restrictive umasks.  Requires client-side support, also on
its way for 4.10.

Other than that, miscellaneous smaller fixes and cleanup, especially to
the server rdma code.

--b.

Andreas Gruenbacher (1):
      nfsd: add support for the umask attribute

Chuck Lever (10):
      svcrdma: Clear xpt_bc_xps in xprt_setup_rdma_bc() error exit arm
      svcauth_gss: Close connection when dropping an incoming message
      svcrdma: Renovate sendto chunk list parsing
      svcrdma: Remove BH-disabled spin locking in svc_rdma_send()
      svcrdma: Remove DMA map accounting
      svcrdma: Remove svc_rdma_op_ctxt::wc_status
      svcrdma: Remove unused variables in xprt_rdma_bc_allocate()
      svcrdma: Remove unused variable in rdma_copy_tail()
      svcrdma: Break up dprintk format in svc_rdma_accept()
      svcrdma: Further clean-up of svc_rdma_get_inv_rkey()

Fabian Frederick (1):
      sunrpc: use DEFINE_SPINLOCK()

J. Bruce Fields (4):
      nfsd: clean up supported attribute handling
      nfsd: catch errors in decode_fattr earlier
      sunrpc: GFP_KERNEL should be GFP_NOFS in crypto code
      nfsd: update workqueue creation

Jeff Layton (2):
      nfsd: more robust allocation failure handling in nfsd_reply_cache_init
      nfsd: fix error handling for clients that fail to return the layout

Julia Lawall (1):
      nfsd: constify reply_cache_stats_operations structure

 fs/nfsd/nfs4callback.c                     |   2 +-
 fs/nfsd/nfs4layouts.c                      |   8 +-
 fs/nfsd/nfs4proc.c                         |  46 ++++--------
 fs/nfsd/nfs4xdr.c                          |  79 +++++++++++++-------
 fs/nfsd/nfscache.c                         |  11 ++-
 fs/nfsd/nfsctl.c                           |   2 +-
 fs/nfsd/nfsd.h                             |  36 ++++-----
 fs/nfsd/nfssvc.c                           |   4 +-
 include/linux/nfs4.h                       |   1 +
 include/linux/sunrpc/svc_rdma.h            |   7 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c      |  12 +--
 net/sunrpc/auth_gss/gss_krb5_mech.c        |   3 +-
 net/sunrpc/auth_gss/svcauth_gss.c          |   2 +-
 net/sunrpc/svc.c                           |  14 ++--
 net/sunrpc/svcauth.c                       |   3 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   5 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  21 ++++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 116 +++++++++--------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  94 ++++++++---------------
 19 files changed, 206 insertions(+), 260 deletions(-)
