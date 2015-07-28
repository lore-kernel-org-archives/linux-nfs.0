Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36721 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbbG1QEF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 12:04:05 -0400
Received: by igbij6 with SMTP id ij6so122447268igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 09:04:04 -0700 (PDT)
Message-ID: <1438099420.6682.3.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tue, 28 Jul 2015 12:03:40 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit b4839ebe21fc5d543b933d83644981ea73e9ba36:

  nfs: Remove invalid tk_pid from debug message (2015-07-01 11:31:25 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.2-2

for you to fetch changes up to a49c269111a5b3c1fd2a98f36fa27423b94549f8:

  nfs: Fix an oops caused by using other thread's stack space in ASYNC mode (2015-07-28 09:07:03 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.2

Highlights include:

Stable patches:
- Fix a situation where the client uses the wrong (zero) stateid.
- Fix a memory leak in nfs_do_recoalesce

Bugfixes:
- Plug a memory leak when ->prepare_layoutcommit fails
- Fix an Oops in the NFSv4 open code
- Fix a backchannel deadlock
- Fix a livelock in sunrpc when sendmsg fails due to low memory availability
- Don't revalidate the mapping if both size and change attr are up to date
- Ensure we don't miss a file extension when doing pNFS
- Several fixes to handle NFSv4.1 sequence operation status bits correctly
- Several pNFS layout return bugfixes

----------------------------------------------------------------
J. Bruce Fields (1):
      NFSv4.2: handle NFS-specific llseek errors

Jeff Layton (1):
      nfs: plug memory leak when ->prepare_layoutcommit fails

Kinglong Mee (1):
      nfs: Fix an oops caused by using other thread's stack space in ASYNC mode

NeilBrown (1):
      sunrpc: translate -EAGAIN to -ENOBUFS when socket is writable.

Trond Myklebust (24):
      SUNRPC: Don't reencode message if transmission failed with ENOBUFS
      SUNRPC: Don't confuse ENOBUFS with a write_space issue
      NFSv4.1: Handle SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED status bit correctly.
      NFSv4.1: Handle SEQ4_STATUS_RECALLABLE_STATE_REVOKED status bit correctly
      NFSv4.1: Handle SEQ4_STATUS_BACKCHANNEL_FAULT correctly
      NFSv4.1: nfs41_sequence_done should handle sequence flag errors
      NFSv4: Leases are renewed in sequence_done when we have sessions
      NFSv4.2/flexfiles: Fix a typo in the flexfiles layoutstats code
      pNFS: Layoutreturn must invalidate all existing layout segments.
      pNFS: pnfs_roc_drain should return 'true' when sleeping
      pNFS: Fix races between return-on-close and layoutreturn.
      pNFS: pnfs_roc_drain() fix a race with open
      pNFS: Don't throw out valid layout segments
      SUNRPC: Fix a backchannel deadlock
      SUNRPC: xprt_complete_bc_request must also decrement the free slot count
      NFSv4: We must set NFS_OPEN_STATE flag in nfs_resync_open_stateid_locked
      NFSv4/pnfs: Ensure we don't miss a file extension
      NFS: Don't revalidate the mapping if both size and change attr are up to date
      NFS: Set NFS_INO_REVAL_PAGECACHE if the change attribute is uninitialised
      NFS: Remove the "NFS_CAP_CHANGE_ATTR" capability
      NFS: nfs_mark_for_revalidate should always set NFS_INO_REVAL_PAGECACHE
      NFS: Fix a memory leak in nfs_do_recoalesce
      NFS: Don't clear desc->pg_moreio in nfs_do_recoalesce()
      SUNRPC: Report TCP errors to the caller

 fs/nfs/client.c                        |   2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
 fs/nfs/inode.c                         |  15 ++---
 fs/nfs/internal.h                      |  21 +++++++
 fs/nfs/nfs42proc.c                     |  19 ++++++-
 fs/nfs/nfs4proc.c                      |  36 +++++++-----
 fs/nfs/nfs4state.c                     |  29 +++++++---
 fs/nfs/pagelist.c                      |   7 ++-
 fs/nfs/pnfs.c                          | 101 +++++++++++++++++++--------------
 fs/nfs/write.c                         |  15 +++--
 include/linux/nfs_fs.h                 |   7 ++-
 include/linux/nfs_fs_sb.h              |   2 +-
 net/sunrpc/backchannel_rqst.c          |   6 +-
 net/sunrpc/clnt.c                      |   5 +-
 net/sunrpc/xprtsock.c                  |  25 +++++---
 15 files changed, 189 insertions(+), 103 deletions(-)
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


