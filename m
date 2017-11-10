Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48841 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750835AbdKJL1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Nov 2017 06:27:50 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Revert "NFS: Move the flock open mode check into nfs_flock()"
Date: Fri, 10 Nov 2017 06:27:49 -0500
Message-Id: <83ce85f94c31a311075f45540ca157ac43a3e91c.1510313041.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit e12937279c8b "NFS: Move the flock open mode check into nfs_flock()"
changed NFSv3 behavior for flock() such that the open mode must match the
lock type, however that requirement shouldn't be enforced for flock().

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c     | 18 ++----------------
 fs/nfs/nfs4proc.c | 14 ++++++++++++++
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..1ef3a1307aad 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -822,23 +822,9 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
 		is_local = 1;
 
-	/*
-	 * VFS doesn't require the open mode to match a flock() lock's type.
-	 * NFS, however, may simulate flock() locking with posix locking which
-	 * requires the open mode to match the lock type.
-	 */
-	switch (fl->fl_type) {
-	case F_UNLCK:
+	/* We're simulating flock() locks using posix locks on the server */
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
-
 	return do_setlk(filp, cmd, fl, is_local);
 }
 EXPORT_SYMBOL_GPL(nfs_flock);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d90132642340..f40c32b14ef5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6542,6 +6542,20 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	    !test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
 		return -ENOLCK;
 
+	/*
+	 * Don't rely on the VFS having checked the file open mode,
+	 * since it won't do this for flock() locks.
+	 */
+	switch (request->fl_type) {
+	case F_RDLCK:
+		if (!(filp->f_mode & FMODE_READ))
+			return -EBADF;
+		break;
+	case F_WRLCK:
+		if (!(filp->f_mode & FMODE_WRITE))
+			return -EBADF;
+	}
+
 	status = nfs4_set_lock_state(state, request);
 	if (status != 0)
 		return status;
-- 
2.9.3

