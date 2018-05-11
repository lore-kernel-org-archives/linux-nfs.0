Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5029 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752122AbeEKUyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 May 2018 16:54:51 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client fixes for 4.17
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <296e0a9d-4bb1-af5f-719a-eb6e62b1fe0b@Netapp.com>
Date: Fri, 11 May 2018 16:54:05 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 98de9ce6f6660d02aa72d7b9b17696fa68a2ed9b:

  NFS: advance nfs_entry cookie only after decoding completes successfully (2018-04-10 16:06:22 -0400)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.17-2

for you to fetch changes up to 04ac6fdba1afffad664377a324b017e63ac08bd8:

  Change Trond's email address in MAINTAINERS (2018-05-11 14:39:06 -0400)

----------------------------------------------------------------

These patches fix both a possible corruption during NFSoRDMA MR recovery, and a sunrpc tracepoint crash.  Additionally, Trond has a new email address to put in the MAINTAINERS file.

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (2):
      xprtrdma: Fix list corruption / DMAR errors during MR recovery
      sunrpc: Fix latency trace point crashes

Trond Myklebust (1):
      Change Trond's email address in MAINTAINERS

 MAINTAINERS                     |  2 +-
 include/trace/events/sunrpc.h   | 16 ++++++----------
 net/sunrpc/xprtrdma/fmr_ops.c   |  5 +----
 net/sunrpc/xprtrdma/frwr_ops.c  |  9 +++------
 net/sunrpc/xprtrdma/verbs.c     |  5 +++++
 net/sunrpc/xprtrdma/xprt_rdma.h |  2 +-
 6 files changed, 17 insertions(+), 22 deletions(-)
