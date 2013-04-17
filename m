Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936095Ab3DQBqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 21:46:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 00/12] Implement NFSv4 delegations, take 7
Date: Tue, 16 Apr 2013 21:46:12 -0400
Message-Id: <1366163185-10317-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is just a rebase of the previous posting.  As far as I can tell, it's
ready for 3.10.  Introduction (mostly repeated) follows:


This patch series implements read delegations, which allow NFSv4 clients
to perform read opens without contacting the server, by promising to
call back to clients before modifying the data, metadata, or set of
links pointing to a file.

The main recent change was in response to review from Linus, who didn't
want us to hang under directory i_mutex's on timeouts communicating with
unresponsive clients.

So, this version of the series drops the i_mutex before waiting.  The
logic ends up looking something like:

        acquire locks
        look up inode
        test for delegation; if found:
                take reference on inode
                release locks
                wait for delegation break
                drop reference on inode
                retry


The initial test for a delegation happens after the lock on the
delegated inode is acquired, but additional directory mutexes may have
been acquired further up the call stack.  I therefore add a "struct
inode **" argument to any intervening functions, which we use to pass
the inode back up to the caller in the case it needs to wait for the
delegation to be broken.

I also allow callers to pass in NULL for the "struct inode **" argument
to indicate they'd rather just fail than wait for a delegation.  For
example, as long as ecryptfs isn't exportable I assume they'd rather not
see retry logic there that they won't use.  But I may have misjudged in
some of these cases.

J. Bruce Fields (12):
  vfs: pull ext4's double-i_mutex-locking into common code
  vfs: don't use PARENT/CHILD lock classes for non-directories
  vfs: rename I_MUTEX_QUOTA now that it's not used for quotas
  vfs: take i_mutex on renamed file
  locks: introduce new FL_DELEG lock flag
  locks: implement delegations
  namei: minor vfs_unlink cleanup
  locks: break delegations on unlink
  locks: helper functions for delegation breaking
  locks: break delegations on rename
  locks: break delegations on link
  locks: break delegations on any attribute modification

 Documentation/filesystems/directory-locking |   31 ++++++++---
 drivers/base/devtmpfs.c                     |    6 +-
 fs/attr.c                                   |    5 +-
 fs/cachefiles/interface.c                   |    4 +-
 fs/cachefiles/namei.c                       |    4 +-
 fs/ecryptfs/inode.c                         |    6 +-
 fs/ext4/move_extent.c                       |   40 +-------------
 fs/hpfs/namei.c                             |    2 +-
 fs/inode.c                                  |   35 +++++++++++-
 fs/locks.c                                  |   51 +++++++++++++----
 fs/namei.c                                  |   79 +++++++++++++++++++++------
 fs/nfsd/nfs4state.c                         |    2 +-
 fs/nfsd/vfs.c                               |   14 +++--
 fs/open.c                                   |   21 +++++--
 fs/utimes.c                                 |    9 ++-
 include/linux/fs.h                          |   72 ++++++++++++++++++++----
 ipc/mqueue.c                                |    2 +-
 17 files changed, 271 insertions(+), 112 deletions(-)

-- 
1.7.9.5

