From: James Morris <jmorris@namei.org>
Subject: [PATCH] nfsv3: convert xattrs to generic xattr API
Date: Tue, 10 Mar 2009 13:11:50 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0903101253190.22273@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond.Myklebust@netapp.com, Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:3426 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017AbZCJCNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Mar 2009 22:13:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, I've been working on an implementation of an xattr protocol for 
NFSv3 (based on the Irix stuff).

The first logical step is to convert the existing xattr use to the generic 
xattr API code.  I figured this might be a useful change in its own right, 
per the patch below.  It seems to work ok with various hand-made tests of 
ACL operations and xattr syscalls.

Please review (and apply if it looks ok).

----

Convert existing use of the extended attribute API (used for ACLs) to the 
kernel's generic xattr API.  This helps unify xattr handling overall in 
the kernel, and clarifies the NFS xattr code.  It will also be useful 
later for the implementation of an xattr protocol for NFSv3.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/dir.c           |    8 +-
 fs/nfs/file.c          |    8 +-
 fs/nfs/internal.h      |    4 +
 fs/nfs/nfs3acl.c       |  163 ++++++++++++++++++++++++++++--------------------
 fs/nfs/super.c         |    3 +
 include/linux/nfs_fs.h |   16 -----
 6 files changed, 111 insertions(+), 91 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e35c819..9aa2e6e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -95,10 +95,10 @@ const struct inode_operations nfs3_dir_inode_operations = {
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
index 90f292b..89f942d 100644
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
index 340ede8..629d817 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -3,6 +3,7 @@
  */
 
 #include <linux/mount.h>
+#include <linux/xattr.h>
 #include <linux/security.h>
 
 struct nfs_string;
@@ -197,6 +198,9 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* nfs3acl.c */
+extern struct xattr_handler *nfs3_xattr_handlers[];
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index cef6255..d0c0fed 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -9,64 +9,57 @@
 
 #define NFSDBG_FACILITY	NFSDBG_PROC
 
-ssize_t nfs3_listxattr(struct dentry *dentry, char *buffer, size_t size)
+static size_t nfs3_acl_xattr_list(struct inode *inode,
+				  char *list, size_t list_len,
+				  const char *name, size_t name_len,
+				  int acl_type, const char *acl_name)
 {
-	struct inode *inode = dentry->d_inode;
 	struct posix_acl *acl;
-	int pos=0, len=0;
+	size_t size = strlen(acl_name) + 1;
 
-#	define output(s) do {						\
-			if (pos + sizeof(s) <= size) {			\
-				memcpy(buffer + pos, s, sizeof(s));	\
-				pos += sizeof(s);			\
-			}						\
-			len += sizeof(s);				\
-		} while(0)
+	acl = nfs3_proc_getacl(inode, acl_type);
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
+	if (list && size <= list_len)
+		memcpy(list, acl_name, size);
+	
+	posix_acl_release(acl);
+	return size;
+}
 
-#	undef output
+static size_t nfs3_acl_access_xattr_list(struct inode *inode, char *list,
+					 size_t list_len, const char *name,
+					 size_t name_len)
+{
+	return nfs3_acl_xattr_list(inode, list, list_len,
+				   name, name_len, ACL_TYPE_ACCESS,
+				   POSIX_ACL_XATTR_ACCESS);
+}
 
-	if (!buffer || len <= size)
-		return len;
-	return -ERANGE;
+static size_t nfs3_acl_default_xattr_list(struct inode *inode, char *list,
+			 		  size_t list_len, const char *name,
+					  size_t name_len)
+{
+	return nfs3_acl_xattr_list(inode, list, list_len,
+				   name, name_len, ACL_TYPE_DEFAULT,
+				   POSIX_ACL_XATTR_DEFAULT);
 }
 
-ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
-		void *buffer, size_t size)
+static ssize_t nfs3_acl_xattr_get(struct inode *inode, void *buffer,
+				  size_t size, int acl_type)
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
+	acl = nfs3_proc_getacl(inode, acl_type);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 	else if (acl) {
-		if (type == ACL_TYPE_ACCESS && acl->a_count == 0)
+		if (acl_type == ACL_TYPE_ACCESS && acl->a_count == 0)
 			error = -ENODATA;
 		else
 			error = posix_acl_to_xattr(acl, buffer, size);
@@ -77,44 +70,80 @@ ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
 	return error;
 }
 
-int nfs3_setxattr(struct dentry *dentry, const char *name,
-	     const void *value, size_t size, int flags)
+static int nfs3_acl_access_xattr_get(struct inode *inode, const char *name,
+				     void *buffer, size_t size)
 {
-	struct inode *inode = dentry->d_inode;
-	struct posix_acl *acl;
-	int type, error;
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
 
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
+	return nfs3_acl_xattr_get(inode, buffer, size, ACL_TYPE_ACCESS);
+}
 
-	acl = posix_acl_from_xattr(value, size);
-	if (IS_ERR(acl))
-		return PTR_ERR(acl);
-	error = nfs3_proc_setacl(inode, type, acl);
+static int nfs3_acl_default_xattr_get(struct inode *inode, const char *name,
+				      void *buffer, size_t size)
+{
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+
+	return nfs3_acl_xattr_get(inode, buffer, size, ACL_TYPE_DEFAULT);
+}
+
+static int nfs3_acl_xattr_set(struct inode *inode, const void *value,
+			      size_t size, int flags, int acl_type)
+{
+	struct posix_acl *acl;
+	int error;
+
+	if (value == NULL && (flags & XATTR_REPLACE))
+		acl = NULL;	/* remove xattr */
+	else {
+		acl = posix_acl_from_xattr(value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+	}
+	
+	error = nfs3_proc_setacl(inode, acl_type, acl);
 	posix_acl_release(acl);
 
 	return error;
 }
 
-int nfs3_removexattr(struct dentry *dentry, const char *name)
+static int nfs3_acl_access_xattr_set(struct inode *inode, const char *name,
+				     const void *value, size_t size, int flags)
 {
-	struct inode *inode = dentry->d_inode;
-	int type;
-
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	return nfs3_acl_xattr_set(inode, value, size, flags, ACL_TYPE_ACCESS);
+}
 
-	return nfs3_proc_setacl(inode, type, NULL);
+static int nfs3_acl_default_xattr_set(struct inode *inode, const char *name,
+				      const void *value, size_t size, int flags)
+{
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	return nfs3_acl_xattr_set(inode, value, size, flags, ACL_TYPE_DEFAULT);
 }
 
+static struct xattr_handler nfs3_xattr_acl_access_handler = {
+	.prefix = POSIX_ACL_XATTR_ACCESS,
+	.list   = nfs3_acl_access_xattr_list,
+	.get    = nfs3_acl_access_xattr_get,
+	.set    = nfs3_acl_access_xattr_set,
+};
+
+static struct xattr_handler nfs3_xattr_acl_default_handler = {
+	.prefix = POSIX_ACL_XATTR_DEFAULT,
+	.list   = nfs3_acl_default_xattr_list,
+	.get    = nfs3_acl_default_xattr_get,
+	.set    = nfs3_acl_default_xattr_set,
+};
+
+struct xattr_handler *nfs3_xattr_handlers[] = {
+	&nfs3_xattr_acl_access_handler,
+	&nfs3_xattr_acl_default_handler,
+	NULL
+};
+
 static void __nfs3_forget_cached_acls(struct nfs_inode *nfsi)
 {
 	if (!IS_ERR(nfsi->acl_access)) {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d6686f4..effe4ae 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1838,6 +1838,9 @@ static void nfs_fill_super(struct super_block *sb,
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
+#ifdef CONFIG_NFS_V3_ACL
+		sb->s_xattr = nfs3_xattr_handlers;
+#endif		
 	}
 
 	sb->s_op = &nfs_sops;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index db867b0..0b45730 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -380,22 +380,6 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
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
1.6.1.3

