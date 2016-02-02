Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38368 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbcBBX4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Feb 2016 18:56:23 -0500
Received: by mail-ig0-f170.google.com with SMTP id mw1so23533656igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 02 Feb 2016 15:56:22 -0800 (PST)
Message-ID: <1454457374.19556.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfix+cleanup
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Tue, 02 Feb 2016 18:56:14 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 92e963f50fc74041b5e9e744c330dca48e04f08d:

  Linux 4.5-rc1 (2016-01-24 13:06:47 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.5-3

for you to fetch changes up to 2370abdab530718b61afc222c51901bdc2884ee2:

  NFS: Cleanup - rename NFS_LAYOUT_RETURN_BEFORE_CLOSE (2016-01-27 20:40:05 -0500)

Cheers,
  Trond
----------------------------------------------------------------
NFS client bugfixe and cleanup for Linux 4.5

Bugfix:
- pNFS: Fix for missing layoutreturn calls

Cleanup:
- pNFS: rename NFS_LAYOUT_RETURN_BEFORE_CLOSE for code clarity

----------------------------------------------------------------
Trond Myklebust (2):
      pNFS: Fix missing layoutreturn calls
      NFS: Cleanup - rename NFS_LAYOUT_RETURN_BEFORE_CLOSE

 fs/nfs/flexfilelayout/flexfilelayout.c    |   2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   2 +-
 fs/nfs/pnfs.c                             | 122 ++++++++++++++----------------
 fs/nfs/pnfs.h                             |   4 +-
 4 files changed, 62 insertions(+), 68 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



