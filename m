Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48660 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdJROo6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Oct 2017 10:44:58 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Remove the flock check for matching open mode
Date: Wed, 18 Oct 2017 10:44:57 -0400
Message-Id: <1c7f83fe32ca8699c745629a3ad0581c7f75b1ee.1508337840.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit e12937279c8b "NFS: Move the flock open mode check into nfs_flock()"
changed NFSv3 behavior for flock() such that the open mode must match the
lock type, however this requirement shouldn't be enforced for flock().

Since FL_POSIX locks are already checked in fs/locks.c, remove this check
in NFS altogether.  For NFSv4, allow the server to determine whether or not
the mode should match the lock type for flock().

Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..ca7e737810e4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -822,22 +822,8 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
 		is_local = 1;
 
-	/*
-	 * VFS doesn't require the open mode to match a flock() lock's type.
-	 * NFS, however, may simulate flock() locking with posix locking which
-	 * requires the open mode to match the lock type.
-	 */
-	switch (fl->fl_type) {
-	case F_UNLCK:
+	if (fl->fl_type == F_UNLCK)
 		return do_unlk(filp, cmd, fl, is_local);
-	case F_RDLCK:
-		if (!(filp->f_mode & FMODE_READ))
-			return -EBADF;
-		break;
-	case F_WRLCK:
-		if (!(filp->f_mode & FMODE_WRITE))
-			return -EBADF;
-	}
 
 	return do_setlk(filp, cmd, fl, is_local);
 }
-- 
2.9.3

