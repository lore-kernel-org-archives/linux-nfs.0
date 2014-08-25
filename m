Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:51761 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaHYOzc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 10:55:32 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so9571445iec.5
        for <linux-nfs@vger.kernel.org>; Mon, 25 Aug 2014 07:55:31 -0700 (PDT)
Message-ID: <1408978530.6599.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Mon, 25 Aug 2014 10:55:30 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 451fd72219dd6f3355e2d036c598544c760ee532:

  Merge tag 'pwm/for-3.17-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/thierry.reding/linux-pwm (2014-08-22 14:50:21 -0700)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.17-2

for you to fetch changes up to 92a56555bd576c61b27a5cab9f38a33a1e9a1df5:

  nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait (2014-08-22 18:04:44 -0400)

----------------------------------------------------------------
NFS client fixes for 3.17

Highlights:

- More fixes for read/write codepath regressions
  - Sleeping while holding the inode lock
  - Stricter enforcement of page contiguity when coalescing requests
  - Fix up error handling in the page coalescing code
- Don't busy wait on SIGKILL in the file locking code

----------------------------------------------------------------
David Jeffery (1):
      nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait

Weston Andros Adamson (7):
      nfs: change nfs_page_group_lock argument
      nfs: fix nonblocking calls to nfs_page_group_lock
      nfs: use blocking page_group_lock in add_request
      nfs: fix error handling in lock_and_join_requests
      nfs: don't sleep with inode lock in lock_and_join_requests
      nfs: disallow duplicate pages in pgio page vectors
      nfs: can_coalesce_requests must enforce contiguity

 fs/nfs/pagelist.c        | 84 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/write.c           | 21 +++++++++---
 include/linux/nfs_page.h |  1 +
 3 files changed, 77 insertions(+), 29 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


