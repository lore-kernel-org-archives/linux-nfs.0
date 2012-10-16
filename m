Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36008 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754580Ab2JPWBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 18:01:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 00/12] Implement NFSv4 delegations, take 5
Date: Tue, 16 Oct 2012 18:01:25 -0400
Message-Id: <1350424897-26894-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Previous posting:

	http://mid.gmane.org/<1346878524-10585-1-git-send-email-bfields@redhat.com>

This is just a rebase to 3.7-rc1.  Jeff Layton's audit patches fixed the
last problem I know of with this patchset, so as far as I'm concerned
it's ready.  But it needs review.

Summary, as before:

NFSv3 clients can only find out about changes to a file by polling.
NFSv4 instead allows a client to get a "delegation" on a file and then
operate on a file without talking to the server.  Consistency is
maintained by requiring the server to recall the delegation before
allowing any conflicting operation.

But our kfsd doesn't always recall delegations on conflicting operations
from local (non-NFS) users of an exported filesystem.

This patch series fixes that by defining a new lock type to represent a
delegation.  This new lock type isn't available to userspace for
now--nfsd is the only user.

Delegations come in both "read" and "write" flavors, but I'm only
implementing read delegations for now.

Delegations are similar to leases.  The main difference is that
delegations need to be broken on any operation that changes a file's
attributes or the set of links pointing to it (like link, unlink, and
rename).

Such operations take several locks (including at least one i_mutex on a
directory).  Delegations can take a long time (about a minute) to recall
when NFS clients are unresponsive.  To avoid blocking a lot of unrelated
operations, this version of the patches drops all of those locks before
waiting.

To that end, I'm passing an extra inode ** to functions like vfs_unlink.
When vfs_unlink finds a delegation it can then pass back the offending
inode so that the caller can wait for the delegation recall.  If the
caller passes in NULL, then it instead gets -EWOULDBLOCK on encountering
a delegation.

In fact, callers outside the vfs are mostly passing in NULL:

	- nfsd wants to imediately return NFS4ERR_DELAY to callers on
	  encountering a delegation, instead of waiting.
	- I assume that anyone exporting the fileystem underlying an
	  ecryptfs mount is making a mistake, and that it's better to
	  return an error than to wait.
	- Ditto for fscache.

But those other callers could be taught to wait as well if necessary.

--b.

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

 Documentation/filesystems/directory-locking |   31 +++++++---
 drivers/base/devtmpfs.c                     |    6 +-
 fs/attr.c                                   |    5 +-
 fs/cachefiles/interface.c                   |    4 +-
 fs/cachefiles/namei.c                       |    4 +-
 fs/ecryptfs/inode.c                         |    6 +-
 fs/ext4/move_extent.c                       |   40 +------------
 fs/hpfs/namei.c                             |    2 +-
 fs/inode.c                                  |   35 ++++++++++-
 fs/locks.c                                  |   51 ++++++++++++----
 fs/namei.c                                  |   83 +++++++++++++++++++++------
 fs/nfsd/nfs4state.c                         |    2 +-
 fs/nfsd/vfs.c                               |   14 +++--
 fs/open.c                                   |   21 +++++--
 fs/utimes.c                                 |    9 ++-
 include/linux/fs.h                          |   72 +++++++++++++++++++----
 ipc/mqueue.c                                |    2 +-
 17 files changed, 273 insertions(+), 114 deletions(-)

-- 
1.7.9.5

