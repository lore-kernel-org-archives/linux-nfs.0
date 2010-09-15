Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753946Ab0IONY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:24:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/8] nfs: move nfs_sillyrename to unlink.c
Date: Wed, 15 Sep 2010 09:23:58 -0400
Message-Id: <1284557041-4375-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...since that's where most of the sillyrenaming code lives. Also, make
nfs_async_unlink static as nfs_sillyrename is the only caller.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c           |   70 ---------------------------------------
 fs/nfs/unlink.c        |   85 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs.h |    2 +-
 3 files changed, 85 insertions(+), 72 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e257172..d15ebc9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1351,76 +1351,6 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 	return error;
 }
 
-static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
-{
-	static unsigned int sillycounter;
-	const int      fileidsize  = sizeof(NFS_FILEID(dentry->d_inode))*2;
-	const int      countersize = sizeof(sillycounter)*2;
-	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
-	char           silly[slen+1];
-	struct qstr    qsilly;
-	struct dentry *sdentry;
-	int            error = -EIO;
-
-	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
-		dentry->d_parent->d_name.name, dentry->d_name.name, 
-		atomic_read(&dentry->d_count));
-	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
-
-	/*
-	 * We don't allow a dentry to be silly-renamed twice.
-	 */
-	error = -EBUSY;
-	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
-		goto out;
-
-	sprintf(silly, ".nfs%*.*Lx",
-		fileidsize, fileidsize,
-		(unsigned long long)NFS_FILEID(dentry->d_inode));
-
-	/* Return delegation in anticipation of the rename */
-	nfs_inode_return_delegation(dentry->d_inode);
-
-	sdentry = NULL;
-	do {
-		char *suffix = silly + slen - countersize;
-
-		dput(sdentry);
-		sillycounter++;
-		sprintf(suffix, "%*.*x", countersize, countersize, sillycounter);
-
-		dfprintk(VFS, "NFS: trying to rename %s to %s\n",
-				dentry->d_name.name, silly);
-		
-		sdentry = lookup_one_len(silly, dentry->d_parent, slen);
-		/*
-		 * N.B. Better to return EBUSY here ... it could be
-		 * dangerous to delete the file while it's in use.
-		 */
-		if (IS_ERR(sdentry))
-			goto out;
-	} while(sdentry->d_inode != NULL); /* need negative lookup */
-
-	qsilly.name = silly;
-	qsilly.len  = strlen(silly);
-	if (dentry->d_inode) {
-		error = NFS_PROTO(dir)->rename(dir, &dentry->d_name,
-				dir, &qsilly);
-		nfs_mark_for_revalidate(dentry->d_inode);
-	} else
-		error = NFS_PROTO(dir)->rename(dir, &dentry->d_name,
-				dir, &qsilly);
-	if (!error) {
-		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-		d_move(dentry, sdentry);
-		error = nfs_async_unlink(dir, dentry);
- 		/* If we return 0 we don't unlink */
-	}
-	dput(sdentry);
-out:
-	return error;
-}
-
 /*
  * Remove a file after making sure there are no pending writes,
  * and after checking that the file has only one user. 
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 2f84ada..42cadd1 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -13,9 +13,12 @@
 #include <linux/nfs_fs.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
+#include <linux/namei.h>
 
 #include "internal.h"
 #include "nfs4_fs.h"
+#include "iostat.h"
+#include "delegation.h"
 
 struct nfs_unlinkdata {
 	struct hlist_node list;
@@ -244,7 +247,7 @@ void nfs_unblock_sillyrename(struct dentry *dentry)
  * @dir: parent directory of dentry
  * @dentry: dentry to unlink
  */
-int
+static int
 nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct nfs_unlinkdata *data;
@@ -303,3 +306,83 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 	if (data != NULL && (NFS_STALE(inode) || !nfs_call_unlink(dentry, data)))
 		nfs_free_unlinkdata(data);
 }
+
+/**
+ * nfs_sillyrename - Perform a silly-rename of a dentry
+ * @dir: inode of directory that contains dentry
+ * @dentry: dentry to be sillyrenamed
+ *
+ * NFSv2/3 is stateless, so the server doesn't know when the client is
+ * holding a file open. To prevent problems when a file is unlinked while
+ * it's still open, we perform a "silly-rename" -- that is, we rename the
+ * file to a hidden file in the same directory, and only actually perform
+ * the unlink once the last reference to it is put.
+ *
+ * The final cleanup is done via nfs_dentry_iput.
+ */
+int
+nfs_sillyrename(struct inode *dir, struct dentry *dentry)
+{
+	static unsigned int sillycounter;
+	const int      fileidsize  = sizeof(NFS_FILEID(dentry->d_inode))*2;
+	const int      countersize = sizeof(sillycounter)*2;
+	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
+	char           silly[slen+1];
+	struct qstr    qsilly;
+	struct dentry *sdentry;
+	int            error = -EIO;
+
+	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		atomic_read(&dentry->d_count));
+	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
+
+	/*
+	 * We don't allow a dentry to be silly-renamed twice.
+	 */
+	error = -EBUSY;
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
+		goto out;
+
+	sprintf(silly, ".nfs%*.*Lx",
+		fileidsize, fileidsize,
+		(unsigned long long)NFS_FILEID(dentry->d_inode));
+
+	/* Return delegation in anticipation of the rename */
+	nfs_inode_return_delegation(dentry->d_inode);
+
+	sdentry = NULL;
+	do {
+		char *suffix = silly + slen - countersize;
+
+		dput(sdentry);
+		sillycounter++;
+		sprintf(suffix, "%*.*x", countersize, countersize, sillycounter);
+
+		dfprintk(VFS, "NFS: trying to rename %s to %s\n",
+				dentry->d_name.name, silly);
+
+		sdentry = lookup_one_len(silly, dentry->d_parent, slen);
+		/*
+		 * N.B. Better to return EBUSY here ... it could be
+		 * dangerous to delete the file while it's in use.
+		 */
+		if (IS_ERR(sdentry))
+			goto out;
+	} while(sdentry->d_inode != NULL); /* need negative lookup */
+
+	qsilly.name = silly;
+	qsilly.len  = strlen(silly);
+	error = NFS_PROTO(dir)->rename(dir, &dentry->d_name, dir, &qsilly);
+	if (dentry->d_inode)
+		nfs_mark_for_revalidate(dentry->d_inode);
+	if (!error) {
+		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+		d_move(dentry, sdentry);
+		error = nfs_async_unlink(dir, dentry);
+		/* If we return 0 we don't unlink */
+	}
+	dput(sdentry);
+out:
+	return error;
+}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 508f8cf..6cdf0d6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -479,10 +479,10 @@ extern void nfs_release_automount_timer(void);
 /*
  * linux/fs/nfs/unlink.c
  */
-extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
 extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
 extern void nfs_block_sillyrename(struct dentry *dentry);
 extern void nfs_unblock_sillyrename(struct dentry *dentry);
+extern int  nfs_sillyrename(struct inode *dir, struct dentry *dentry);
 
 /*
  * linux/fs/nfs/write.c
-- 
1.7.1

