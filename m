Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753480AbcIPU1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:27:12 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 0/9] nfs: add CB_NOTIFY_LOCK support to nfs client
Date: Fri, 16 Sep 2016 16:27:02 -0400
Message-Id: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- add NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK in a separate patch
- a little cleanup and patch squashing
- changelog cleanups

v2:
- don't use *_unsafe sleep in setlk retry code
- better encapsulate retry logic into helper functions
- don't bother with waitqueue handling if we aren't expecting callback
- fix build when CONFIG_NFS_V4_1 is not set
- address several other style comments

This is the third posting of this patchset. The only real change is a
separate patch to add the NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant.

This patchset adds support for CB_NOTIFY_LOCK callbacks to the NFS
client. The basic idea is to add a waitqueue to the nfs_client and then
have blocking lock waiters wait on that queue for callbacks.

When a callback comes in, we use a keyed wakeup to wake any waiters. The
waitqueue handling is necessarily more "manual" than I would like, but I
don't see a real alternative there given that we need to insert the
waiters onto the waitqueue prior to sending the lock request, and
sending a lock request can involve blocking operations.

Tested in conjunction with the corresponding knfsd server-side patchset.

Jeff Layton (9):
  nfs: eliminate pointless and confusing do_vfs_lock wrappers
  nfs: check for POSIX lock capability on server even for flock locks
  nfs: use safe, interruptible sleeps when waiting to retry LOCK
  nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
  nfs: track whether server sets MAY_NOTIFY_LOCK flag
  nfs: add handling for CB_NOTIFY_LOCK in client
  nfs: move nfs4_set_lock_state call into caller
  nfs: move nfs4 lock retry attempt loop to a separate function
  nfs: add code to allow client to wait on lock callbacks

 fs/nfs/callback.h         |   8 +++
 fs/nfs/callback_proc.c    |  18 +++++
 fs/nfs/callback_xdr.c     |  49 ++++++++++++-
 fs/nfs/file.c             |   9 +--
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4client.c       |   3 +
 fs/nfs/nfs4proc.c         | 179 ++++++++++++++++++++++++++++++++++------------
 include/linux/nfs_fs_sb.h |   3 +
 include/uapi/linux/nfs4.h |   5 +-
 9 files changed, 220 insertions(+), 55 deletions(-)

-- 
2.7.4

