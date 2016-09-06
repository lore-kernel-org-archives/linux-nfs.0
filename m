Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933689AbcIFPMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:12:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] nfs: add CB_NOTIFY_LOCK support to nfs client
Date: Tue,  6 Sep 2016 11:12:31 -0400
Message-Id: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
  nfs: check for POSIX lock capability on server even for flock locks
  nfs: add a freezable_schedule_timeout_unsafe() and use it when waiting
    to retry LOCK
  nfs: add handling for CB_NOTIFY_LOCK in client
  nfs: move nfs4_set_lock_state call into caller
  nfs: add code to allow client to wait on lock callbacks
  nfs: ensure that the filehandle in CB_NOTIFY_LOCK request matches the
    inode
  nfs: track whether server sets MAY_NOTIFY_LOCK flag

 fs/nfs/callback.h         |   8 ++++
 fs/nfs/callback_proc.c    |  20 ++++++++
 fs/nfs/callback_xdr.c     |  51 +++++++++++++++++++-
 fs/nfs/file.c             |   9 +---
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4client.c       |   1 +
 fs/nfs/nfs4proc.c         | 118 +++++++++++++++++++++++++++++++++++++---------
 include/linux/freezer.h   |  13 +++++
 include/linux/nfs_fs_sb.h |   1 +
 9 files changed, 190 insertions(+), 32 deletions(-)

-- 
2.7.4

