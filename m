Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36677 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbcBWSd0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2016 13:33:26 -0500
Received: by mail-io0-f171.google.com with SMTP id l127so221938018iof.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 Feb 2016 10:33:26 -0800 (PST)
Message-ID: <1456252389.10002.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Tue, 23 Feb 2016 13:33:09 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 388f7b1d6e8ca06762e2454d28d6c3c55ad0fe95:

  Linux 4.5-rc3 (2016-02-07 15:38:30 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.5-4

for you to fetch changes up to 9fd4b9fc7695a4da1363a0b439853f88fb6a034f:

  NFSv4.x/pnfs: Fix a race between layoutget and bulk recalls (2016-02-22 17:46:34 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.5

Stable bugfixes:
- Fix nfs_size_to_loff_t
- NFSv4: Fix a dentry leak on alias use

Other bugfixes:
- Don't schedule a layoutreturn if the layout segment can be freed immediately.
- Always set NFS_LAYOUT_RETURN_REQUESTED with lo->plh_return_iomode
- rpcrdma_bc_receive_call() should init rq_private_buf.len
- fix stateid handling for the NFS v4.2 operations
- pnfs/blocklayout: fix a memeory leak when using,vmalloc_to_page
- fix panic in gss_pipe_downcall() in fips mode
- Fix a race between layoutget and pnfs_destroy_layout
- Fix a race between layoutget and bulk recalls

----------------------------------------------------------------
Benjamin Coddington (1):
      NFSv4: Fix a dentry leak on alias use

Christoph Hellwig (2):
      nfs: fix nfs_size_to_loff_t
      nfs4: fix stateid handling for the NFS v4.2 operations

Chuck Lever (1):
      xprtrdma: rpcrdma_bc_receive_call() should init rq_private_buf.len

Kinglong Mee (1):
      pnfs/blocklayout: fix a memeory leak when using,vmalloc_to_page

Scott Mayhew (1):
      auth_gss: fix panic in gss_pipe_downcall() in fips mode

Trond Myklebust (5):
      pNFS: Fix pnfs_mark_matching_lsegs_return()
      pNFS: Always set NFS_LAYOUT_RETURN_REQUESTED with lo->plh_return_iomode
      Merge tag 'nfs-rdma-4.5-1' of git://git.linux-nfs.org/projects/anna/nfs-rdma
      NFSv4.x/pnfs: Fix a race between layoutget and pnfs_destroy_layout
      NFSv4.x/pnfs: Fix a race between layoutget and bulk recalls

 fs/nfs/blocklayout/extent_tree.c  |  10 +++-
 fs/nfs/nfs42proc.c                | 119 ++++++++++++++++++++++++--------------
 fs/nfs/nfs4proc.c                 |   4 +-
 fs/nfs/pnfs.c                     |  55 +++++++++++++-----
 include/linux/nfs_fs.h            |   4 +-
 include/linux/nfs_xdr.h           |   1 +
 net/sunrpc/auth_gss/auth_gss.c    |   2 +-
 net/sunrpc/xprtrdma/backchannel.c |   2 +
 8 files changed, 131 insertions(+), 66 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



