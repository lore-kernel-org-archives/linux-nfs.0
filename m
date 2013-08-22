Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:39950 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab3HVAYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 06/21] NFS: Add tracepoints for debugging directory changes
Date: Wed, 21 Aug 2013 20:24:04 -0400
Message-ID: <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints for mknod, mkdir, rmdir, remove (unlink) and symlink.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      | 15 +++++++++-
 fs/nfs/nfstrace.h | 90 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9c07812..e41dec5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1642,7 +1642,9 @@ nfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t rdev)
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
+	trace_nfs_mknod_enter(dir, dentry);
 	status = NFS_PROTO(dir)->mknod(dir, dentry, &attr, rdev);
+	trace_nfs_mknod_exit(dir, dentry, status);
 	if (status != 0)
 		goto out_err;
 	return 0;
@@ -1666,7 +1668,9 @@ int nfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	attr.ia_valid = ATTR_MODE;
 	attr.ia_mode = mode | S_IFDIR;
 
+	trace_nfs_mkdir_enter(dir, dentry);
 	error = NFS_PROTO(dir)->mkdir(dir, dentry, &attr);
+	trace_nfs_mkdir_exit(dir, dentry, error);
 	if (error != 0)
 		goto out_err;
 	return 0;
@@ -1689,12 +1693,14 @@ int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: rmdir(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
+	trace_nfs_rmdir_enter(dir, dentry);
 	error = NFS_PROTO(dir)->rmdir(dir, &dentry->d_name);
 	/* Ensure the VFS deletes this inode */
 	if (error == 0 && dentry->d_inode != NULL)
 		clear_nlink(dentry->d_inode);
 	else if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
+	trace_nfs_rmdir_exit(dir, dentry, error);
 
 	return error;
 }
@@ -1722,6 +1728,7 @@ static int nfs_safe_remove(struct dentry *dentry)
 		goto out;
 	}
 
+	trace_nfs_remove_enter(dir, dentry);
 	if (inode != NULL) {
 		NFS_PROTO(inode)->return_delegation(inode);
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
@@ -1731,6 +1738,7 @@ static int nfs_safe_remove(struct dentry *dentry)
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
 	if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
+	trace_nfs_remove_exit(dir, dentry, error);
 out:
 	return error;
 }
@@ -1748,13 +1756,14 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	dfprintk(VFS, "NFS: unlink(%s/%ld, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name);
 
+	trace_nfs_unlink_enter(dir, dentry);
 	spin_lock(&dentry->d_lock);
 	if (d_count(dentry) > 1) {
 		spin_unlock(&dentry->d_lock);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
 		error = nfs_sillyrename(dir, dentry);
-		return error;
+		goto out;
 	}
 	if (!d_unhashed(dentry)) {
 		__d_drop(dentry);
@@ -1766,6 +1775,8 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	} else if (need_rehash)
 		d_rehash(dentry);
+out:
+	trace_nfs_unlink_exit(dir, dentry, error);
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_unlink);
@@ -1812,7 +1823,9 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 		memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
 	kunmap_atomic(kaddr);
 
+	trace_nfs_symlink_enter(dir, dentry);
 	error = NFS_PROTO(dir)->symlink(dir, dentry, page, pathlen, &attr);
+	trace_nfs_symlink_exit(dir, dentry, error);
 	if (error != 0) {
 		dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s) error %d\n",
 			dir->i_sb->s_id, dir->i_ino,
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 2963a05..5827906 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -422,6 +422,96 @@ TRACE_EVENT(nfs_create_exit,
 		)
 );
 
+DECLARE_EVENT_CLASS(nfs_directory_event,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct dentry *dentry
+		),
+
+		TP_ARGS(dir, dentry),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"name=%02x:%02x:%llu/%s",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+#define DEFINE_NFS_DIRECTORY_EVENT(name) \
+	DEFINE_EVENT(nfs_directory_event, name, \
+			TP_PROTO( \
+				const struct inode *dir, \
+				const struct dentry *dentry \
+			), \
+			TP_ARGS(dir, dentry))
+
+DECLARE_EVENT_CLASS(nfs_directory_event_done,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct dentry *dentry,
+			int error
+		),
+
+		TP_ARGS(dir, dentry, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->error = error;
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d name=%02x:%02x:%llu/%s",
+			__entry->error,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+#define DEFINE_NFS_DIRECTORY_EVENT_DONE(name) \
+	DEFINE_EVENT(nfs_directory_event_done, name, \
+			TP_PROTO( \
+				const struct inode *dir, \
+				const struct dentry *dentry, \
+				int error \
+			), \
+			TP_ARGS(dir, dentry, error))
+
+DEFINE_NFS_DIRECTORY_EVENT(nfs_mknod_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_mknod_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_mkdir_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_mkdir_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_rmdir_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_rmdir_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_remove_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_remove_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_unlink_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_unlink_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_symlink_enter);
+DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_symlink_exit);
+
 #endif /* _TRACE_NFS_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

