Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754719AbcIQWRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 18:17:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v4 0/9] nfs: add CB_NOTIFY_LOCK support to nfs client
Date: Sat, 17 Sep 2016 18:17:30 -0400
Message-Id: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- reinstate patch to fix read_buf args
- drop patch to check NFS_STATE_POSIX_LOCKS on FL_FLOCK locks
- clean up retry loops. Use while loops instead of do..while
  and use !signalled() as the condition.
- add a cbnl_valid flag to cb_notify_lock_args to indicate whether
  decoding worked. s_dev and id could legitimately both be zero.

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
  nfs: the length argument to read_buf should be unsigned
  nfs: eliminate pointless and confusing do_vfs_lock wrappers
  nfs: use safe, interruptible sleeps when waiting to retry LOCK
  nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
  nfs: track whether server sets MAY_NOTIFY_LOCK flag
  nfs: add handling for CB_NOTIFY_LOCK in client
  nfs: move nfs4_set_lock_state call into caller
  nfs: move nfs4 lock retry attempt loop to a separate function
  nfs: allow blocking locks to be awoken by lock callbacks

 fs/nfs/callback.h         |   9 +++
 fs/nfs/callback_proc.c    |  16 +++++
 fs/nfs/callback_xdr.c     |  53 +++++++++++++-
 fs/nfs/file.c             |   9 +--
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4client.c       |   3 +
 fs/nfs/nfs4proc.c         | 176 ++++++++++++++++++++++++++++++++++------------
 include/linux/nfs_fs_sb.h |   3 +
 include/uapi/linux/nfs4.h |   5 +-
 9 files changed, 219 insertions(+), 56 deletions(-)

-- 
2.7.4

