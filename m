Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35045 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757141AbbIYPOR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 11:14:17 -0400
Received: by igbkq10 with SMTP id kq10so12108071igb.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 08:14:16 -0700 (PDT)
Message-ID: <1443194044.26785.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Fri, 25 Sep 2015 11:14:04 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 6ff33f3902c3b1c5d0db6b1e2c70b6d76fba357f:

  Linux 4.3-rc1 (2015-09-12 16:35:56 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.3-2

for you to fetch changes up to 500d701f336b2771d34e46da7875a4782515a652:

  NFS41: make close wait for layoutreturn (2015-09-23 08:55:32 -0400)

Cheers
  Trond

----------------------------------------------------------------
NFS client bugfixes for Linux 4.3

Highlights include:

Stable patches:
- fix v4.2 SEEK on files over 2 gigs
- Fix a layout segment reference leak when pNFS I/O falls back to inband I/O.
- Fix recovery of recalled read delegations

Bugfixes:
- Fix a case where NFSv4 fails to send CLOSE after a server reboot
- Fix sunrpc to wait for connections to complete before retrying
- Fix sunrpc races between transport connect/disconnect and shutdown
- Fix an infinite loop when layoutget fail with BAD_STATEID
- nfs/filelayout: Fix NULL reference caused by double freeing of fh_array
- Fix a bogus WARN_ON_ONCE() in O_DIRECT when layout commit_through_mds is set
- Fix layoutreturn/close ordering issues.

----------------------------------------------------------------
J. Bruce Fields (1):
      nfs: fix v4.2 SEEK on files over 2 gigs

Julia Lawall (1):
      SUNRPC: drop null test before destroy functions

Kinglong Mee (4):
      nfs/filelayout: Fix NULL reference caused by double freeing of fh_array
      NFS: Do cleanup before resetting pageio read/write to mds
      NFS: Fix an infinite loop when layoutget fail with BAD_STATEID
      NFS: Skip checking ds_cinfo.buckets when lseg's commit_through_mds is set

Olga Kornievskaia (1):
      Failing to send a CLOSE if file is opened WRONLY and server reboots on a 4.x mount

Peng Tao (2):
      nfs: fix pg_test page count calculation
      NFS41: make close wait for layoutreturn

Trond Myklebust (6):
      SUNRPC: Fix races between socket connection and destroy code
      SUNRPC: Ensure that we wait for connections to complete before retrying
      SUNRPC: Lock the transport layer on shutdown
      SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose
      NFSv4: Recovery of recalled read delegations is broken
      NFSv4.x/pnfs: Don't try to recover stateids twice in layoutget

 fs/nfs/delegation.c             |   8 ++-
 fs/nfs/delegation.h             |   2 +-
 fs/nfs/direct.c                 |   7 ++-
 fs/nfs/filelayout/filelayout.c  |  31 ++++------
 fs/nfs/nfs42proc.c              |   4 +-
 fs/nfs/nfs4proc.c               | 127 ++++++++++++++++++++++++++--------------
 fs/nfs/nfs4state.c              |   2 +-
 fs/nfs/pagelist.c               |   2 +-
 fs/nfs/pnfs.c                   |  35 +++++++----
 fs/nfs/pnfs.h                   |   7 +++
 fs/nfs/read.c                   |   3 +
 fs/nfs/write.c                  |   3 +
 include/linux/sunrpc/xprtsock.h |   3 +
 net/sunrpc/sched.c              |  12 ++--
 net/sunrpc/xprt.c               |   6 ++
 net/sunrpc/xprtsock.c           |  15 +++--
 16 files changed, 172 insertions(+), 95 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



