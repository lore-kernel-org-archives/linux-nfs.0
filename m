Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932737AbbLGQ0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:26:11 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, hch@infradead.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/10] NFS: Move the flock open mode check into nfs_flock()
Date: Mon,  7 Dec 2015 11:26:01 -0500
Message-Id: <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
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
index 93e2364..ec16abc 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -893,6 +893,21 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
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

