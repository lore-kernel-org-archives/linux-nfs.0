Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab3ISUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:50:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 00/13] Implement NFSv4 delegations, take 12
Date: Thu, 19 Sep 2013 16:50:24 -0400
Message-Id: <1379623837-30798-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Al, if you don't see any objections, could you queue this up for 3.13?

Changes since version 11:
	- rebase to 3.12-rc1
	- fix to lock class in single-lock case of
	  lock_two_nondirectories

Changes since version 10:
	- appended Jeff's fix for a setlease/open race (otherwise
	  unrelated to this series, but there are some minor conficts to
	  resolve).

Changes since version 9:
	- just a rebase to 3.11-rc6

Changes since version 8:
	- additional warnings in lock_two_nondirectories
	- lock_two_nondirectories handles NULL second argument,
	  simplifying vfs_rename_other
	- kerneldoc comments on notify_change, vfs_link, vfs_rename,
	  vfs_unlink, to explain delegated_inode argument.
	- make clear non-support of write delegations in
	  generic_add_lease
	- rebase to 3.11-rc1

Introduction copied from previous posting:

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

Jeff Layton (1):
  locks: close potential race between setlease and open

 Documentation/filesystems/directory-locking |   31 ++++--
 drivers/base/devtmpfs.c                     |    6 +-
 fs/attr.c                                   |   25 ++++-
 fs/cachefiles/interface.c                   |    4 +-
 fs/cachefiles/namei.c                       |    4 +-
 fs/ecryptfs/inode.c                         |    6 +-
 fs/ext4/ext4.h                              |    2 -
 fs/ext4/ioctl.c                             |    4 +-
 fs/ext4/move_extent.c                       |   40 +-------
 fs/hpfs/namei.c                             |    2 +-
 fs/inode.c                                  |   42 ++++++++-
 fs/locks.c                                  |  130 +++++++++++++++++++++-----
 fs/namei.c                                  |  135 +++++++++++++++++++++++----
 fs/nfsd/nfs4state.c                         |    2 +-
 fs/nfsd/vfs.c                               |   14 ++-
 fs/open.c                                   |   22 ++++-
 fs/utimes.c                                 |    9 +-
 include/linux/fs.h                          |   78 +++++++++++++---
 ipc/mqueue.c                                |    2 +-
 19 files changed, 428 insertions(+), 130 deletions(-)

-- 
1.7.9.5

