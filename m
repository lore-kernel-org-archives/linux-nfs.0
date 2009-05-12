From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.30
Date: Tue, 12 May 2009 15:29:12 -0400
Message-ID: <20090512192912.GH19164@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42281 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZELT3L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 15:29:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd fixes are available from the for-2.6.30 branch at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.30

(Note: I wasn't sure of the last one, "nfsd: silence lockdep warning":
on the one hand, it's just a warning.  On the other hand, a lot of users
may assume it's something more serious and freak out, just because
there's a backtrace in it.  Should this have been saved for the next
merge window?)

--b.

Andy Adamson (1):
      nfsd41: slots are freed with session

J. Bruce Fields (3):
      nfsd4: check for negative dentry before use in nfsv4 readdir
      lockd: fix list corruption on lockd restart
      nfsd: silence lockdep warning

Steve Wise (2):
      svcrdma: Fix dma map direction for rdma read targets
      svcrdma: clean up error paths.

 fs/lockd/svc.c                           |   15 +++++++++++----
 fs/nfsd/nfs4recover.c                    |    4 ++--
 fs/nfsd/nfs4state.c                      |    1 -
 fs/nfsd/nfs4xdr.c                        |   16 +++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 ++-
 7 files changed, 34 insertions(+), 10 deletions(-)
