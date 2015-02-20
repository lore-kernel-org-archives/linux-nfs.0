Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:43062 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbbBTQQ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2015 11:16:28 -0500
Received: by pdev10 with SMTP id v10so8504782pde.10
        for <linux-nfs@vger.kernel.org>; Fri, 20 Feb 2015 08:16:28 -0800 (PST)
Message-ID: <1424448985.3641.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Fri, 20 Feb 2015 08:16:25 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 6bec0035286119eefc32a5b1102127e6a4032cb2:

  Merge branch 'for-3.20/bdi' of git://git.kernel.dk/linux-block (2015-02-12 13:50:21 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.20-2

for you to fetch changes up to 71a097c6de9a49afd0f96b3ecef70c4eb04efde7:

  NFSv4.1: Clean up bind_conn_to_session (2015-02-18 13:11:09 -0800)

----------------------------------------------------------------
NFS client updates for Linux 3.20

Highlights include:

- Fix a use-after-free in decode_cb_sequence_args()
- Fix a compile error when #undef CONFIG_PROC_FS
- NFSv4.1 backchannel spinlocking issue
- Cleanups in the NFS unstable write code requested by Linus
- NFSv4.1 fix issues when the server denies our backchannel request
- Cleanups in create_session and bind_conn_to_session

----------------------------------------------------------------
Chuck Lever (1):
      SUNRPC: Always manipulate rpc_rqst::rq_bc_pa_list under xprt->bc_pa_lock

Tom Haynes (3):
      nfs: Provide and use helper functions for marking a page as unstable
      nfs: Can call nfs_clear_page_commit() instead
      pnfs: Refactor the *_layout_mark_request_commit to use pnfs_layout_mark_request_commit

Trond Myklebust (10):
      NFSv4.1: Fix a kfree() of uninitialised pointers in decode_cb_sequence_args
      NFSv4.1: Convert open-coded array allocation calls to kmalloc_array()
      SUNRPC: Fix a compile error when #undef CONFIG_PROC_FS
      NFS: struct nfs_commit_info.lock must always point to inode->i_lock
      NFSv4: Kill unused nfs_inode->delegation_state field
      Merge branch 'cleanups'
      NFSv4.1: Clean up create_session
      NFSv4.1: Don't set up a backchannel if the server didn't agree to do so
      NFSv4.1: Always set up a forward channel when binding the session
      NFSv4.1: Clean up bind_conn_to_session

 fs/nfs/callback_proc.c                 |  2 +
 fs/nfs/callback_xdr.c                  |  8 ++--
 fs/nfs/delegation.c                    |  4 --
 fs/nfs/direct.c                        |  2 +-
 fs/nfs/filelayout/filelayout.c         | 53 +++++-------------------
 fs/nfs/flexfilelayout/flexfilelayout.c | 43 +------------------
 fs/nfs/inode.c                         |  1 -
 fs/nfs/internal.h                      | 13 ++++++
 fs/nfs/nfs4proc.c                      | 75 ++++++++++++++++++++++------------
 fs/nfs/nfs4session.c                   |  2 +-
 fs/nfs/nfs4session.h                   |  6 +++
 fs/nfs/nfs4xdr.c                       | 32 +++++++--------
 fs/nfs/pnfs.h                          |  4 ++
 fs/nfs/pnfs_nfs.c                      | 30 ++++++++++++++
 fs/nfs/write.c                         | 16 ++------
 include/linux/nfs_fs.h                 |  1 -
 include/linux/nfs_xdr.h                | 19 +++++++--
 include/linux/sunrpc/metrics.h         |  7 +++-
 net/sunrpc/backchannel_rqst.c          |  5 ++-
 19 files changed, 165 insertions(+), 158 deletions(-)


