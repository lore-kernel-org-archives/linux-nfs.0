From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 048/112] NFS: define a function to update
	nfsi->cache_change_attribute
Date: Fri, 25 Jan 2008 11:37:38 -0500
Message-ID: <20080125163738.31887.79413.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57951 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757018AbYAYRBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:01:49 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Zat020525
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:36 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c           |   15 +++++++++++++++
 fs/nfs/inode.c         |    6 ++++--
 fs/nfs/nfs4proc.c      |    2 +-
 include/linux/nfs_fs.h |    1 +
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f697b5c..410449d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -639,6 +639,21 @@ static int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
 	return 0;
 }
 
+/**
+ * nfs_force_lookup_revalidate - Mark the directory as having changed
+ * @dir - pointer to directory inode
+ *
+ * This forces the revalidation code in nfs_lookup_revalidate() to do a
+ * full lookup on all child dentries of 'dir' whenever a change occurs
+ * on the server that might have invalidated our dcache.
+ *
+ * The caller should be holding dir->i_lock
+ */
+void nfs_force_lookup_revalidate(struct inode *dir)
+{
+	NFS_I(dir)->cache_change_attribute = jiffies;
+}
+
 /*
  * A check for whether or not the parent directory has changed.
  * In the case it has, we assume that the dentries are untrustworthy
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cc3a09d..5747d49 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1029,7 +1029,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			dprintk("NFS: mtime change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
-			nfsi->cache_change_attribute = now;
+			if (S_ISDIR(inode->i_mode))
+				nfs_force_lookup_revalidate(inode);
 		}
 		/* If ctime has changed we should definitely clear access+acl caches */
 		if (!timespec_equal(&inode->i_ctime, &fattr->ctime))
@@ -1038,7 +1039,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		dprintk("NFS: change_attr change on server for file %s/%ld\n",
 				inode->i_sb->s_id, inode->i_ino);
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-		nfsi->cache_change_attribute = now;
+		if (S_ISDIR(inode->i_mode))
+			nfs_force_lookup_revalidate(inode);
 	}
 
 	/* Check if our cached file size is stale */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bda2957..d170f1d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -210,7 +210,7 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	spin_lock(&dir->i_lock);
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
 	if (!cinfo->atomic || cinfo->before != nfsi->change_attr)
-		nfsi->cache_change_attribute = jiffies;
+		nfs_force_lookup_revalidate(dir);
 	nfsi->change_attr = cinfo->after;
 	spin_unlock(&dir->i_lock);
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2d15d4a..7095aaa 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -366,6 +366,7 @@ extern const struct inode_operations nfs3_dir_inode_operations;
 extern const struct file_operations nfs_dir_operations;
 extern struct dentry_operations nfs_dentry_operations;
 
+extern void nfs_force_lookup_revalidate(struct inode *dir);
 extern int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fh, struct nfs_fattr *fattr);
 extern int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags);
 extern void nfs_access_zap_cache(struct inode *inode);
