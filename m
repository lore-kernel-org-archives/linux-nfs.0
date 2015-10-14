Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 03/10] NFS: Move the flock open mode check into nfs_flock()
Date: Wed, 14 Oct 2015 14:23:30 -0400
Message-Id: <c94a6b0c0e48aef6e4fbec83dd509a1f6fae757a.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only need to check lock exclusive/shared types against open mode when
flock() is used on NFS, so move it into the flock-specific path instead of
checking it for all locks.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c     |   15 +++++++++++++++
 fs/nfs/nfs4proc.c |   13 -------------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c0f9b1e..57fefd2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -904,6 +904,21 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 	/* We're simulating flock() locks using posix locks on the server */
 	if (fl->fl_type == F_UNLCK)
 		return do_unlk(filp, cmd, fl, is_local);
+
+	/*
+	 * Don't rely on the VFS having checked the file open mode,
+	 * since it won't do this for flock() locks.
+	 */
+	switch (fl->fl_type) {
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
index 75223d2..28b771c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6137,19 +6137,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 
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

