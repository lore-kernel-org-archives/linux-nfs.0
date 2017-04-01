Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54980 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdDADQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 23:16:07 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 2/6] NFS: Move the flock open mode check into nfs_flock()
Date: Fri, 31 Mar 2017 23:15:59 -0400
Message-Id: <fe45f49878bdbe361bfeb99cbd92401fccbdb2f6.1491015671.git.bcodding@redhat.com>
In-Reply-To: <cover.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
In-Reply-To: <cover.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only need to check lock exclusive/shared types against open mode when
flock() is used on NFS, so move it into the flock-specific path instead of
checking it for all locks.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c     | 18 ++++++++++++++++--
 fs/nfs/nfs4proc.c | 14 --------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 26dbe8b0c10d..a490f45df4db 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -820,9 +820,23 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
 		is_local = 1;
 
-	/* We're simulating flock() locks using posix locks on the server */
-	if (fl->fl_type == F_UNLCK)
+	/*
+	 * VFS doesn't require the open mode to match a flock() lock's type.
+	 * NFS, however, may simulate flock() locking with posix locking which
+	 * requires the open mode to match the lock type.
+	 */
+	switch (fl->fl_type) {
+	case F_UNLCK:
 		return do_unlk(filp, cmd, fl, is_local);
+	case F_RDLCK:
+		if (!(filp->f_mode & FMODE_READ))
+			return -EBADF;
+		break;
+	case F_WRLCK:
+		if (!(filp->f_mode & FMODE_WRITE))
+			return -EBADF;
+	}
+
 	return do_setlk(filp, cmd, fl, is_local);
 }
 EXPORT_SYMBOL_GPL(nfs_flock);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9388899e4050..91f88bfbbe79 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6592,20 +6592,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	    !test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
 		return -ENOLCK;
 
-	/*
-	 * Don't rely on the VFS having checked the file open mode,
-	 * since it won't do this for flock() locks.
-	 */
-	switch (request->fl_type) {
-	case F_RDLCK:
-		if (!(filp->f_mode & FMODE_READ))
-			return -EBADF;
-		break;
-	case F_WRLCK:
-		if (!(filp->f_mode & FMODE_WRITE))
-			return -EBADF;
-	}
-
 	status = nfs4_set_lock_state(state, request);
 	if (status != 0)
 		return status;
-- 
2.9.3

