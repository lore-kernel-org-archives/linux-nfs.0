Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:35582 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbJGCw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 22:52:56 -0400
Received: by ykdz138 with SMTP id z138so4446900ykd.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 19:52:56 -0700 (PDT)
Message-ID: <1444186352.25629.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tue, 06 Oct 2015 22:52:32 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 5634347dee31373a8faf084f4cdbf6d5ea0b03a4:

  Merge tag 'arm64-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux (2015-10-02 14:54:16 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.3-3

for you to fetch changes up to 39d0d3bdf7bab3021a31e501172ac0f18947f9b3:

  NFS: Fix a tracepoint NULL-pointer dereference (2015-10-06 18:56:25 -0400)

Cheers
  Trond

----------------------------------------------------------------
NFS client bugfixes for Linux 4.3

Highlights include:

Bugfixes:
- Fix a use-after-free bug in the RPC/RDMA client
- Fix a write performance regression
- Fix up page writeback accounting
- Don't try to reclaim unused state owners
- Fix a NFSv4 nograce recovery hang
- reset states to use open_stateid when returning delegation voluntarily
- Fix a tracepoint NULL-pointer dereference

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Fix a tracepoint NULL-pointer dereference

Benjamin Coddington (1):
      NFSv4: Fix a nograce recovery hang

Jeff Layton (1):
      nfs4: reset states to use open_stateid when returning delegation voluntarily

Steve Wise (1):
      xprtrdma: disconnect and flush cqs before freeing buffers

Trond Myklebust (5):
      NFS: Fix up page writeback accounting
      NFS: Fix a write performance regression
      NFSv4: Don't try to reclaim unused state owners
      NFSv4.1: nfs4_opendata_check_deleg needs to handle NFS4_OPEN_CLAIM_DELEG_CUR_FH
      Merge tag 'nfs-rdma-for-4.3-2' of git://git.linux-nfs.org/projects/anna/nfs-rdma

 fs/nfs/nfs4proc.c               | 15 +++++++++++++--
 fs/nfs/nfs4state.c              |  3 ++-
 fs/nfs/nfs4trace.h              |  2 +-
 fs/nfs/write.c                  | 14 +++++++-------
 net/sunrpc/xprtrdma/transport.c |  2 +-
 net/sunrpc/xprtrdma/verbs.c     |  9 ++++++---
 6 files changed, 30 insertions(+), 15 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



