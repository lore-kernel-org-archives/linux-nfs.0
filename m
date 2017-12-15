Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:30021 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756143AbdLOVxe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Dec 2017 16:53:34 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes for 4.15
Message-ID: <a0189ebe-a038-99ec-a388-59572b1549cd@Netapp.com>
Date: Fri, 15 Dec 2017 16:43:49 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit eb5b46faa693470681ec7c28cc2436edd1571198:

  SUNRPC: Handle ENETDOWN errors (2017-11-30 11:52:52 -0500)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.15-3

for you to fetch changes up to 90d91b0cd371193d9dbfa9beacab8ab9a4cb75e0:

  SUNRPC: Fix a race in the receive code path (2017-12-15 14:31:56 -0500)

----------------------------------------------------------------
This pull request has two stable bugfixes, one to fix a BUG_ON() when nfs_commit_inode() is called with no outstanding commit requests and another to fix a race in the SUNRPC receive codepath.

Additionally, there are also fixes for an NFS client deadlock and an xprtrdma performance regression.

Cheers,
Anna
----------------------------------------------------------------
Chuck Lever (1):
      xprtrdma: Spread reply processing over more CPUs

Scott Mayhew (2):
      nfs: fix a deadlock in nfs client initialization
      nfs: don't wait on commit in nfs_commit_inode() if there were no commit requests

Trond Myklebust (1):
      SUNRPC: Fix a race in the receive code path

 fs/nfs/client.c                 | 11 +++++++++++
 fs/nfs/nfs4client.c             | 17 +++++++++++++----
 fs/nfs/write.c                  |  2 ++
 net/sunrpc/xprt.c               | 28 +++++++++++++++++++---------
 net/sunrpc/xprtrdma/rpc_rdma.c  |  6 +-----
 net/sunrpc/xprtrdma/transport.c |  2 ++
 net/sunrpc/xprtrdma/verbs.c     |  2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h |  1 +
 8 files changed, 50 insertions(+), 19 deletions(-)
