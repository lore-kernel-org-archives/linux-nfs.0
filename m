Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50437 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602Ab3JBV2l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 17:28:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] vfs: split out vfs_getattr_nosec
Date: Wed,  2 Oct 2013 17:28:13 -0400
Message-Id: <1380749295-20854-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20131002210736.GA20598@fieldses.org>
References: <20131002210736.GA20598@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The filehandle lookup code wants this version of getattr.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/stat.c          |   31 +++++++++++++++++++++++++------
 include/linux/fs.h |    1 +
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index 04ce1ac..71a39e8 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -37,14 +37,21 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
 
 EXPORT_SYMBOL(generic_fillattr);
 
-int vfs_getattr(struct path *path, struct kstat *stat)
+/**
+ * vfs_getattr_nosec - getattr without security checks
+ * @path: file to get attributes from
+ * @stat: structure to return attributes in
+ *
+ * Get attributes without calling security_inode_getattr.
+ *
+ * Currently the only caller other than vfs_getattr is internal to the
+ * filehandle lookup code, which uses only the inode number and returns
+ * no attributes to any user.  Any other code probably wants
+ * vfs_getattr.
+ */
+int vfs_getattr_nosec(struct path *path, struct kstat *stat)
 {
 	struct inode *inode = path->dentry->d_inode;
-	int retval;
-
-	retval = security_inode_getattr(path->mnt, path->dentry);
-	if (retval)
-		return retval;
 
 	if (inode->i_op->getattr)
 		return inode->i_op->getattr(path->mnt, path->dentry, stat);
@@ -53,6 +60,18 @@ int vfs_getattr(struct path *path, struct kstat *stat)
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(vfs_getattr_nosec);
+
+int vfs_getattr(struct path *path, struct kstat *stat)
+{
+	int retval;
+
+	retval = security_inode_getattr(path->mnt, path->dentry);
+	if (retval)
+		return retval;
+	return vfs_getattr_nosec(path, stat);
+}
+
 EXPORT_SYMBOL(vfs_getattr);
 
 int vfs_fstat(unsigned int fd, struct kstat *stat)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9818747..5a51faa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2500,6 +2500,7 @@ extern int page_symlink(struct inode *inode, const char *symname, int len);
 extern const struct inode_operations page_symlink_inode_operations;
 extern int generic_readlink(struct dentry *, char __user *, int);
 extern void generic_fillattr(struct inode *, struct kstat *);
+int vfs_getattr_nosec(struct path *path, struct kstat *stat);
 extern int vfs_getattr(struct path *, struct kstat *);
 void __inode_add_bytes(struct inode *inode, loff_t bytes);
 void inode_add_bytes(struct inode *inode, loff_t bytes);
-- 
1.7.9.5

