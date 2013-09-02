Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:24296 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681Ab3IBSR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:56 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to complete
Date: Mon, 2 Sep 2013 14:17:51 -0400
Message-ID: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an NFS client does

	mkdir("dir");
	fd = open("dir/file");
	unlink("dir/file");
	close(fd);
	rmdir("dir");

then the asynchronous nature of the sillyrename operation means that
we can end up getting EBUSY for the rmdir() in the above test. Fix
that by ensuring that we wait for any in-progress sillyrenames
before sending the rmdir() to the server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c           | 19 +++++++++++++------
 fs/nfs/unlink.c        |  7 +++++++
 include/linux/nfs_fs.h |  1 +
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d8149e9..187caa4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1694,12 +1694,19 @@ int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
 	trace_nfs_rmdir_enter(dir, dentry);
-	error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
-	/* Ensure the VFS deletes this inode */
-	if (error == 0 && dentry->d_inode != NULL)
-		clear_nlink(dentry->d_inode);
-	else if (error == -ENOENT)
-		nfs_dentry_handle_enoent(dentry);
+	if (dentry->d_inode) {
+		nfs_wait_on_sillyrename(dentry);
+		error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
+		/* Ensure the VFS deletes this inode */
+		switch (error) {
+		case 0:
+			clear_nlink(dentry->d_inode);
+			break;
+		case -ENOENT:
+			nfs_dentry_handle_enoent(dentry);
+		}
+	} else
+		error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
 	trace_nfs_rmdir_exit(dir, dentry, error);
 
 	return error;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 2c1485d..0c6dfe0 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -207,6 +207,13 @@ out_free:
 	return ret;
 }
 
+void nfs_wait_on_sillyrename(struct dentry *dentry)
+{
+	struct nfs_inode *nfsi = NFS_I(dentry->d_inode);
+
+	wait_event(nfsi->waitqueue, atomic_read(&nfsi->silly_count) == 1);
+}
+
 void nfs_block_sillyrename(struct dentry *dentry)
 {
 	struct nfs_inode *nfsi = NFS_I(dentry->d_inode);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7125cef..3ea4cde 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -524,6 +524,7 @@ static inline void nfs4_label_free(void *label) {}
  * linux/fs/nfs/unlink.c
  */
 extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
+extern void nfs_wait_on_sillyrename(struct dentry *dentry);
 extern void nfs_block_sillyrename(struct dentry *dentry);
 extern void nfs_unblock_sillyrename(struct dentry *dentry);
 extern int  nfs_sillyrename(struct inode *dir, struct dentry *dentry);
-- 
1.8.3.1

