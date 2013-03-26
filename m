Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56727 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752941Ab3CZS0L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Mar 2013 14:26:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Tue, 26 Mar 2013 18:26:09 +0000
Message-ID: <1364322369.4784.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 6dbe51c251a327e012439c4772097a13df43c5b8:

  Linux 3.9-rc1 (2013-03-03 15:11:05 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.9-3

for you to fetch changes up to 1166fde6a923c30f4351515b6a9a1efc513e7d00:

  SUNRPC: Add barriers to ensure read ordering in rpc_wake_up_task_queue_locked (2013-03-25 11:23:40 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.9

- Fix an NFSv4 idmapper regression
- Fix an Oops in the pNFS blocks client
- Fix up various issues with pNFS layoutcommit
- Ensure correct read ordering of variables in rpc_wake_up_task_queue_locked

----------------------------------------------------------------
Trond Myklebust (5):
      NFSv4: Fix the string length returned by the idmapper
      NFSv4.1: Fix a race in pNFS layoutcommit
      NFSv4.1: Always clear the NFS_INO_LAYOUTCOMMIT in layoutreturn
      NFSv4.1: Add a helper pnfs_commit_and_return_layout
      SUNRPC: Add barriers to ensure read ordering in rpc_wake_up_task_queue_locked

fanchaoting (1):
      pnfs-block: removing DM device maybe cause oops when call dev_remove

 fs/nfs/blocklayout/blocklayoutdm.c |  4 +-
 fs/nfs/idmap.c                     | 13 +++---
 fs/nfs/nfs4filelayout.c            |  1 -
 fs/nfs/nfs4proc.c                  | 16 +-------
 fs/nfs/pnfs.c                      | 81 +++++++++++++++++++++++++++++++++-----
 fs/nfs/pnfs.h                      |  6 +++
 net/sunrpc/sched.c                 |  9 ++++-
 7 files changed, 96 insertions(+), 34 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
