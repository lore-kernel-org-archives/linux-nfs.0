From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfs server (mainly rdma) fixes
Date: Tue, 20 May 2008 20:57:46 -0400
Message-ID: <20080521005746.GM8177@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59166 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765553AbYEUA5w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 20:57:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes are available in the git repository at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.26

This is almost all server-side nfs rdma fixes.  It's a little more than
I'd normally hope for post-rc1, but it's pretty self-contained.

--b.

J. Bruce Fields (3):
      nfsd: reorder printk in do_probe_callback to avoid use-after-free
      svcrpc: fix proc/net/rpc/auth.unix.ip/content display
      Merge branch 'from-tomtucker' into for-2.6.26

Tom Tucker (23):
      svc: Remove extra check for XPT_DEAD bit in svc_xprt_enqueue
      svc: Remove unused header files from svc_xprt.c
      svcrdma: Simplify receive buffer posting
      svcrdma: Fix race with dto_tasklet in svc_rdma_send
      svcrdma: Fix return value in svc_rdma_send
      svcrdma: Add put of connection ESTABLISHED reference in rdma_cma_handler
      svcrdma: Free context on ib_post_recv error
      svcrdma: Free context on post_recv error in send_reply
      svcrdma: Fix error handling during listening endpoint creation
      svcrdma: Return error from rdma_read_xdr so caller knows to free context
      svcrdma: Remove unused READ_DONE context flags bit
      svcrdma: Simplify RDMA_READ deferral buffer management
      svcrdma: Use standard Linux lists for context cache
      svcrdma: Shrink scope of spinlock on RQ CQ
      svcrdma: Move destroy to kernel thread
      svcrdma: Add reference for each SQ/RQ WR
      svcrdma: Move the QP and cm_id destruction to svc_rdma_free
      svcrdma: Cleanup queued, but unprocessed I/O in svc_rdma_free
      svcrdma: Use ib verbs version of dma_unmap
      svcrdma: Set rqstp transport address in rdma_read_complete function
      svcrdma: Copy transport address and arm CQ before calling rdma_accept
      svcrdma: Change svc_rdma_send_error return type to void
      svcrdma: Verify read-list fits within RPCSVC_MAXPAGES

 fs/nfsd/nfs4callback.c                   |    2 +-
 include/linux/sunrpc/svc_rdma.h          |   12 +-
 net/sunrpc/svc_xprt.c                    |   23 ---
 net/sunrpc/svcauth_unix.c                |    4 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  102 ++++--------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   11 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  290 ++++++++++++++++++------------
 7 files changed, 226 insertions(+), 218 deletions(-)
