Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:15234 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbcF2VEc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2016 17:04:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes for 4.7
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <aae88d1b-ce34-d0da-b971-a212a199bec9@Netapp.com>
Date: Wed, 29 Jun 2016 17:04:25 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 33688abb2802ff3a230bd2441f765477b94cc89e:

  Linux 4.7-rc4 (2016-06-19 21:30:02 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.7-2

for you to fetch changes up to e547f2628327fec6afd2e03b46f113f614cca05b:

  NFS: Fix another OPEN_DOWNGRADE bug (2016-06-28 16:55:34 -0400)

Thanks,
Anna

----------------------------------------------------------------
Al Viro (1):
      make nfs_atomic_open() call d_drop() on all ->open_context() errors.

Oleg Drokin (1):
      nfs4: Fix potential use after free of state in nfs4_do_reclaim.

Trond Myklebust (11):
      NFSv4.1/pnfs: Ensure we handle delegation errors in nfs4_proc_layoutget()
      NFSv4.1/pnfs: Layout stateids start out as being invalid
      NFSv4.1/pnfs: Add sparse lock annotations for pnfs_find_alloc_layout
      NFS/pnfs: handle bad delegation stateids in nfs4_layoutget_handle_exception
      NFS: Fix up O_DIRECT results
      NFS: Fix a double page unlock
      NFSv4.1/pnfs: Mark the layout stateid invalid when all segments are removed
      NFS: Don't let readdirplus revalidate an inode that was marked as stale
      NFS: Fix potential race in nfs_fhget()
      NFS: Fix an unused variable warning
      NFS: Fix another OPEN_DOWNGRADE bug

Weston Andros Adamson (1):
      pnfs_nfs: fix _cancel_empty_pagelist

 fs/nfs/dir.c       | 11 +++++++----
 fs/nfs/direct.c    | 10 +++++++---
 fs/nfs/inode.c     |  1 +
 fs/nfs/nfs4proc.c  | 18 ++++++++++--------
 fs/nfs/nfs4state.c |  2 +-
 fs/nfs/pnfs.c      | 10 +++++++---
 fs/nfs/pnfs_nfs.c  | 12 ++++++++++--
 fs/nfs/read.c      |  4 ++--
 8 files changed, 45 insertions(+), 23 deletions(-)
