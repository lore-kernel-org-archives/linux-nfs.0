Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753226AbcIISrw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:47:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/10] nfs: add CB_NOTIFY_LOCK support to nfs client
Date: Fri,  9 Sep 2016 14:47:41 -0400
Message-Id: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- don't use *_unsafe sleep in setlk retry code
- better encapsulate retry logic into helper functions
- don't bother with waitqueue handling if we aren't expecting callback
- fix build when CONFIG_NFS_V4_1 is not set
- address several other style comments

This is the second posting of this patchset. Most of the changes from
the v1 set are to address Anna's review comments. Original cover letter
text follows.

This patchset adds support for CB_NOTIFY_LOCK callbacks to the NFS
client. The basic idea is to add a waitqueue to the nfs_client and then
have blocking lock waiters wait on that queue for callbacks.

When a callback comes in, we use a keyed wakeup to wake any waiters. The
waitqueue handling is necessarily more "manual" than I would like, but I
don't see a real alternative there given that we need to insert the
waiters onto the waitqueue prior to sending the lock request, and
sending a lock request can involve blocking operations.

Tested in conjunction with the corresponding knfsd server-side patchset.

Jeff Layton (10):
  nfs: the length argument to read_buf should be unsigned
  nfs: eliminate pointless and confusing do_vfs_lock wrappers
  nfs: check for POSIX lock capability on server even for flock locks
  nfs: use safe, interruptible sleeps when waiting to retry LOCK
  nfs: track whether server sets MAY_NOTIFY_LOCK flag
  nfs: add handling for CB_NOTIFY_LOCK in client
  nfs: move nfs4_set_lock_state call into caller
  nfs: move nfs4 lock retry attempt loop to a separate function
  nfs: add code to allow client to wait on lock callbacks
  nfs: ensure that the filehandle in CB_NOTIFY_LOCK request matches the
    inode

 fs/nfs/callback.h         |   8 +++
 fs/nfs/callback_proc.c    |  18 +++++
 fs/nfs/callback_xdr.c     |  51 ++++++++++++-
 fs/nfs/file.c             |   9 +--
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4client.c       |   3 +
 fs/nfs/nfs4proc.c         | 179 ++++++++++++++++++++++++++++++++++------------
 include/linux/nfs_fs_sb.h |   3 +
 8 files changed, 218 insertions(+), 54 deletions(-)

-- 
2.7.4

