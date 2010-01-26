From: James Morris <jmorris@namei.org>
Subject: [PATCH 1/4] NFSv3: convert client to generic xattr API
Date: Wed, 27 Jan 2010 10:07:50 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1001271007040.15158@tundra.namei.org>
References: <alpine.LRH.2.00.1001270952420.15158@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:45609 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892Ab0AZXH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:07:56 -0500
In-Reply-To: <alpine.LRH.2.00.1001270952420.15158-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert existing NFSv3 client use (i.e. ACLs) of the xattrs to
the kernel's generic xattr API.

This helps simplify the code, and prepare for the subsequent
NFSv3 xattr protocol patches, which will also utilize the
generic xattr API.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/dir.c           |    8 ++--
 fs/nfs/file.c          |    8 ++--
 fs/nfs/internal.h      |    4 ++
 fs/nfs/nfs3acl.c       |  122 ++++++++++++++++++++---------------------------
 fs/nfs/super.c         |    3 +
 include/linux/nfs_fs.h |   16 ------
 6 files changed, 67 insertions(+), 94 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3c7f03b..b1cb729 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -94,10 +94,10 @@ const struct inode_operations nfs3_dir_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
+	.listxattr	= generic_listxattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.removexattr	= generic_removexattr,
 };
 #endif  /* CONFIG_NFS_V3 */
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..1e3114c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -91,10 +91,10 @@ const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
+	.listxattr	= generic_listxattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.removexattr	= generic_removexattr,
 };
 #endif  /* CONFIG_NFS_v3 */
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 29e464d..9bb918a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -4,6 +4,7 @@
 
 #include "nfs4_fs.h"
 #include <linux/mount.h>
+#include <linux/xattr.h>
 #include <linux/security.h>
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
@@ -284,6 +285,9 @@ static inline char *nfs_devname(const struct vfsmount *mnt_parent,
 			dentry, buffer, buflen);
 }
 
+/* nfs3acl.c */
+extern struct xattr_handler *nfs3_xattr_handlers[];
+
 /*
  * Determine the actual block size (and log2 thereof)
  */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index bac6051..c03f8e0 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -9,64 +9,41 @@
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
-ssize_t nfs3_listxattr(struct dentry *dentry, char *buffer, size_t size)
+static size_t nfs3_acl_xattr_list(struct dentry *dentry,
+				  char *list, size_t list_len,
+				  const char *name, size_t name_len,
+				  int acl_type)
 {
-	struct inode *inode = dentry->d_inode;
 	struct posix_acl *acl;
-	int pos=0, len=0;
+	char *acl_name = ACL_TYPE_ACCESS ?
+		POSIX_ACL_XATTR_ACCESS : POSIX_ACL_XATTR_DEFAULT;
+	size_t size = strlen(acl_name) + 1;
 
-#	define output(s) do {						\
-			if (pos + sizeof(s) <= size) {			\
-				memcpy(buffer + pos, s, sizeof(s));	\
-				pos += sizeof(s);			\
-			}						\
-			len += sizeof(s);				\
-		} while(0)
+	acl = nfs3_proc_getacl(dentry->d_inode, acl_type);
+	if (!acl)
+		return 0;
 
-	acl = nfs3_proc_getacl(inode, ACL_TYPE_ACCESS);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
-	if (acl) {
-		output("system.posix_acl_access");
-		posix_acl_release(acl);
-	}
 
-	if (S_ISDIR(inode->i_mode)) {
-		acl = nfs3_proc_getacl(inode, ACL_TYPE_DEFAULT);
-		if (IS_ERR(acl))
-			return PTR_ERR(acl);
-		if (acl) {
-			output("system.posix_acl_default");
-			posix_acl_release(acl);
-		}
-	}
-
-#	undef output
+	if (list && size <= list_len)
+		memcpy(list, acl_name, size);
 
-	if (!buffer || len <= size)
-		return len;
-	return -ERANGE;
+	posix_acl_release(acl);
+	return size;
 }
 
-ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
-		void *buffer, size_t size)
+static int nfs3_acl_xattr_get(struct dentry *dentry, const char *name,
+			      void *buffer, size_t size, int acl_type)
 {
-	struct inode *inode = dentry->d_inode;
 	struct posix_acl *acl;
-	int type, error = 0;
-
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
+	int error = 0;
 
-	acl = nfs3_proc_getacl(inode, type);
+	acl = nfs3_proc_getacl(dentry->d_inode, acl_type);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 	else if (acl) {
-		if (type == ACL_TYPE_ACCESS && acl->a_count == 0)
+		if (acl_type == ACL_TYPE_ACCESS && acl->a_count == 0)
 			error = -ENODATA;
 		else
 			error = posix_acl_to_xattr(acl, buffer, size);
@@ -77,43 +54,48 @@ ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
 	return error;
 }
 
-int nfs3_setxattr(struct dentry *dentry, const char *name,
-	     const void *value, size_t size, int flags)
+static int nfs3_acl_xattr_set(struct dentry *dentry, const char *name,
+			      const void *value, size_t size, int flags,
+			      int acl_type)
 {
-	struct inode *inode = dentry->d_inode;
 	struct posix_acl *acl;
-	int type, error;
+	int error;
 
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
+	if (value == NULL && (flags & XATTR_REPLACE))
+		acl = NULL;	/* remove xattr */
+	else {
+		acl = posix_acl_from_xattr(value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+	}
 
-	acl = posix_acl_from_xattr(value, size);
-	if (IS_ERR(acl))
-		return PTR_ERR(acl);
-	error = nfs3_proc_setacl(inode, type, acl);
+	error = nfs3_proc_setacl(dentry->d_inode, acl_type, acl);
 	posix_acl_release(acl);
 
 	return error;
 }
 
-int nfs3_removexattr(struct dentry *dentry, const char *name)
-{
-	struct inode *inode = dentry->d_inode;
-	int type;
-
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
-
-	return nfs3_proc_setacl(inode, type, NULL);
-}
+static struct xattr_handler nfs3_xattr_acl_access_handler = {
+	.prefix = POSIX_ACL_XATTR_ACCESS,
+	.flags	= ACL_TYPE_ACCESS,
+	.list   = nfs3_acl_xattr_list,
+	.get    = nfs3_acl_xattr_get,
+	.set    = nfs3_acl_xattr_set,
+};
+
+static struct xattr_handler nfs3_xattr_acl_default_handler = {
+	.prefix = POSIX_ACL_XATTR_DEFAULT,
+	.flags	= ACL_TYPE_DEFAULT,
+	.list   = nfs3_acl_xattr_list,
+	.get    = nfs3_acl_xattr_get,
+	.set    = nfs3_acl_xattr_set,
+};
+
+struct xattr_handler *nfs3_xattr_handlers[] = {
+	&nfs3_xattr_acl_access_handler,
+	&nfs3_xattr_acl_default_handler,
+	NULL
+};
 
 static void __nfs3_forget_cached_acls(struct nfs_inode *nfsi)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ce907ef..b89bbac 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2015,6 +2015,9 @@ static void nfs_fill_super(struct super_block *sb,
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
+#ifdef CONFIG_NFS_V3_ACL
+		sb->s_xattr = nfs3_xattr_handlers;
+#endif
 	}
 
 	sb->s_op = &nfs_sops;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d09db1b..34848b8 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -389,22 +389,6 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
 }
 
 /*
- * linux/fs/nfs/xattr.c
- */
-#ifdef CONFIG_NFS_V3_ACL
-extern ssize_t nfs3_listxattr(struct dentry *, char *, size_t);
-extern ssize_t nfs3_getxattr(struct dentry *, const char *, void *, size_t);
-extern int nfs3_setxattr(struct dentry *, const char *,
-			const void *, size_t, int);
-extern int nfs3_removexattr (struct dentry *, const char *name);
-#else
-# define nfs3_listxattr NULL
-# define nfs3_getxattr NULL
-# define nfs3_setxattr NULL
-# define nfs3_removexattr NULL
-#endif
-
-/*
  * linux/fs/nfs/direct.c
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, const struct iovec *, loff_t,
-- 
1.6.3.3


-- 
James Morris
<jmorris@namei.org>
