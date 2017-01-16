Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40198 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdAPPm7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Jan 2017 10:42:59 -0500
Date: Mon, 16 Jan 2017 10:42:58 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.10
Message-ID: <20170116154258.GA2953@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.10-1

Miscellaneous nfsd bugfixes, one for a 4.10 regression, three for older
bugs.--b.

J. Bruce Fields (2):
      nfsd: fix supported attributes for acl & labels
      svcrpc: don't leak contexts on PROC_DESTROY

Scott Mayhew (1):
      sunrpc: don't call sleeping functions from the notifier block callbacks

Sriharsha Basavapatna (1):
      svcrdma: avoid duplicate dma unmapping during error recovery

 fs/nfsd/nfs4xdr.c                       |  4 +++-
 include/linux/sunrpc/svc_xprt.h         |  1 +
 net/sunrpc/auth_gss/svcauth_gss.c       |  2 +-
 net/sunrpc/svc_xprt.c                   | 10 +++++++---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  2 --
 5 files changed, 12 insertions(+), 7 deletions(-)
