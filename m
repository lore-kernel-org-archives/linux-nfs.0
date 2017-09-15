Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33774 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751703AbdIOCnr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Sep 2017 22:43:47 -0400
Message-ID: <1505443424.11417.1.camel@gmail.com>
Subject: [GIT PULL] Please pull 3 more NFS client fixes...
From: Trond Myklebust <trondmy@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Thu, 14 Sep 2017 22:43:44 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 1bd5d6d08ea7ed0794c8a3908383d6d6fc202cdd:

  NFS: Count the bytes of skipped subrequests in nfs_lock_and_join_requests() (2017-09-09 16:43:09 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.14-2

for you to fetch changes up to bf4b49059718b2217339eb15c60f8753d5b0da99:

  NFS: various changes relating to reporting IO errors. (2017-09-11 22:28:56 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.14

Hightlights include:

bugfixes:
- Various changes relating to reporting IO errors.
- pnfs: Use the standard I/O stateid when calling LAYOUTGET

Features:
- Add static NFS I/O tracepoints for debugging

----------------------------------------------------------------
Chuck Lever (1):
      NFS: Add static NFS I/O tracepoints

NeilBrown (1):
      NFS: various changes relating to reporting IO errors.

Trond Myklebust (1):
      pNFS: Use the standard I/O stateid when calling LAYOUTGET

 fs/nfs/file.c     |  16 ++--
 fs/nfs/internal.h |   7 ++
 fs/nfs/nfstrace.h | 248 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pagelist.c |   4 +-
 fs/nfs/pnfs.c     |  14 +--
 fs/nfs/read.c     |   4 +
 fs/nfs/write.c    |  14 +--
 7 files changed, 287 insertions(+), 20 deletions(-)
