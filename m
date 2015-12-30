Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754749AbbL3NOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2015 08:14:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 02/10] NFS: Move the flock open mode check into nfs_flock()
Date: Wed, 30 Dec 2015 08:13:58 -0500
Message-Id: <7c9912459f09f3393a768870ad4d5f21215549f9.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only need to check lock exclusive/shared types against open mode when
flock() is used on NFS, so move it into the flock-specific path instead of
checking it for all locks.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c     |   20 +++++++++++++++++---
 fs/nfs/nfs4proc.c |   13 -------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 93e2364..8b16a08 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -890,9 +890,23 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
 		is_local = 1;
 
-	/* We're simulating flock() locks using posix locks on the server */
-	if (fl->fl_type == F_UNLCK)
-		return do_unlk(filp, cmd, fl, is_local);
+	/*
+	 * VFS doesn't require the open mode to match a flock() lock's type.
+	 * NFS, however, may simulate flock() locking with posix locking which
+	 * requires the open mode to match the lock type.
+	 */
+	switch (fl->fl_type) {
+		case F_UNLCK:
+			return do_unlk(filp, cmd, fl, is_local);
+		case F_RDLCK:
+			if (!(filp->f_mode & FMODE_READ))
+				return -EBADF;
+			break;
+		case F_WRLCK:
+			if (!(filp->f_mode & FMODE_WRITE))
+				return -EBADF;
+	}
+
 	return do_setlk(filp, cmd, fl, is_local);
 }
 EXPORT_SYMBOL_GPL(nfs_flock);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2231d7d..05ea1e1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6125,19 +6125,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 
 	if (state == NULL)
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
 
 	do {
 		status = nfs4_proc_setlk(state, cmd, request);
-- 
1.7.1

