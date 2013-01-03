Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17637 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab3ACVmb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2013 16:42:31 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: Fix access to suid/sgid executables
Date: Thu,  3 Jan 2013 16:42:29 -0500
Message-Id: <1357249349-12074-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_open_permission_mask() should only check MAY_EXEC for files that
are opened with __FMODE_EXEC.

Also fix NFSv4 access-in-open path in a similar way -- openflags must be
used because fmode will not always have FMODE_EXEC set.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

This patch fixes https://bugzilla.kernel.org/show_bug.cgi?id=49101

Patch v2 - apply Trond's comment: only check MAY_EXEC when openflags has 
__FMODE_EXEC.

 fs/nfs/dir.c      |   16 ++++++++++------
 fs/nfs/nfs4proc.c |   18 ++++++++++++------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32e6c53..1b2d7eb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2153,12 +2153,16 @@ static int nfs_open_permission_mask(int openflags)
 {
 	int mask = 0;
 
-	if ((openflags & O_ACCMODE) != O_WRONLY)
-		mask |= MAY_READ;
-	if ((openflags & O_ACCMODE) != O_RDONLY)
-		mask |= MAY_WRITE;
-	if (openflags & __FMODE_EXEC)
-		mask |= MAY_EXEC;
+	if (openflags & __FMODE_EXEC) {
+		/* ONLY check exec rights */
+		mask = MAY_EXEC;
+	} else {
+		if ((openflags & O_ACCMODE) != O_WRONLY)
+			mask |= MAY_READ;
+		if ((openflags & O_ACCMODE) != O_RDONLY)
+			mask |= MAY_WRITE;
+	}
+
 	return mask;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d864fb..3b70588 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1626,7 +1626,8 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 
 static int nfs4_opendata_access(struct rpc_cred *cred,
 				struct nfs4_opendata *opendata,
-				struct nfs4_state *state, fmode_t fmode)
+				struct nfs4_state *state, fmode_t fmode,
+				int openflags)
 {
 	struct nfs_access_entry cache;
 	u32 mask;
@@ -1637,12 +1638,17 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 		return 0;
 
 	mask = 0;
+
+	/* use openflags to check for exec, because fmode won't
+	 * always have FMODE_EXEC set when file open for exec. */
+	if (openflags & __FMODE_EXEC)
+		/* ONLY check for exec rights */
+		mask = MAY_EXEC;
+
 	/* don't check MAY_WRITE - a newly created file may not have
 	 * write mode bits, but POSIX allows the creating process to write */
-	if (fmode & FMODE_READ)
-		mask |= MAY_READ;
-	if (fmode & FMODE_EXEC)
-		mask |= MAY_EXEC;
+	else if (fmode & FMODE_READ)
+		mask = MAY_READ;
 
 	cache.cred = cred;
 	cache.jiffies = jiffies;
@@ -1896,7 +1902,7 @@ static int _nfs4_do_open(struct inode *dir,
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 
-	status = nfs4_opendata_access(cred, opendata, state, fmode);
+	status = nfs4_opendata_access(cred, opendata, state, fmode, flags);
 	if (status != 0)
 		goto err_opendata_put;
 
-- 
1.7.9.6 (Apple Git-31.1)

