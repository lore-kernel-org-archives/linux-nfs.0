Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60764 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933672AbcKDTOa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Nov 2016 15:14:30 -0400
Date: Fri, 4 Nov 2016 15:14:29 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.9
Message-ID: <20161104191429.GA4601@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.9-1

--b.

----------------------------------------------------------------
Fixes for some recent regressions including fallout from the vmalloc'd
stack change (after which we can no longer encrypt stuff on the stack).

----------------------------------------------------------------
Chuck Lever (2):
      svcrdma: backchannel cannot share a page for send and rcv buffers
      nfsd: Fix general protection fault in release_lock_stateid()

J. Bruce Fields (1):
      sunrpc: don't pass on-stack memory to sg_set_buf

Jeff Layton (2):
      nfsd: move blocked lock handling under a dedicated spinlock
      sunrpc: fix some missing rq_rbuffer assignments

 fs/nfsd/netns.h                            |  5 ++
 fs/nfsd/nfs4state.c                        | 38 +++++++-------
 net/sunrpc/auth_gss/auth_gss.c             | 13 +++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c      | 82 +++++++++++++++++-------------
 net/sunrpc/auth_gss/svcauth_gss.c          | 21 +++++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 12 ++++-
 net/sunrpc/xprtsock.c                      |  1 +
 7 files changed, 106 insertions(+), 66 deletions(-)
