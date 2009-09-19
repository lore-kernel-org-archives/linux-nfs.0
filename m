From: James Morris <jmorris@namei.org>
Subject: [PATCH 1/4] NFSv3: convert client to generic xattr API
Date: Sun, 20 Sep 2009 01:11:42 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0909200110590.31880@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert existing NFSv3 client use (i.e. ACLs) of the xattrs to
the kernel's generic xattr API.

This helps simplify the code, and prepare for the subsequent
NFSv3 xattr protocol patches, which will also utilize the
generic xattr API.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/nfs/dir.c           |    8 +-
 fs/nfs/file.c          |    8 +-
 fs/nfs/internal.h      |    4 +
 fs/nfs/nfs3acl.c       |  161 ++++++++++++++++++++++++++++--------------------
 fs/nfs/super.c         |    3 +
 include/linux/nfs_fs.h |   16 -----
 6 files changed, 110 insertions(+), 90 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32062c3..104fae5 100644
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
index 5021b75..22c4ce1 100644
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
index e21b1bb..964170d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -4,6 +4,7 @@
 
 #include "nfs4_fs.h"
 #include <linux/mount.h>
+#include <linux/xattr.h>
 #include <linux/security.h>
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
@@ -287,6 +288,9 @@ static inline void nfs4_sequence_free_slot(const struct nfs_client *clp,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+/* nfs3acl.c */
+extern struct xattr_handler *nfs3_xattr_handlers[];
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index bac6051..4e15d1a 100644
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
 
-#	undef output
+	posix_acl_release(acl);
+	return size;
+}
 
-	if (!buffer || len <= size)
-		return len;
-	return -ERANGE;
+static size_t nfs3_acl_access_xattr_list(struct inode *inode, char *list,
+					 size_t list_len, const char *name,
+					 size_t name_len)
+{
+	return nfs3_acl_xattr_list(inode, list, list_len,
+				   name, name_len, ACL_TYPE_ACCESS,
+				   POSIX_ACL_XATTR_ACCESS);
 }
 
-ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
-		void *buffer, size_t size)
+static size_t nfs3_acl_default_xattr_list(struct inode *inode, char *list,
+					  size_t list_len, const char *name,
+					  size_t name_len)
 {
-	struct inode *inode = dentry->d_inode;
-	struct posix_acl *acl;
-	int type, error = 0;
+	return nfs3_acl_xattr_list(inode, list, list_len,
+				   name, name_len, ACL_TYPE_DEFAULT,
+				   POSIX_ACL_XATTR_DEFAULT);
+}
 
-	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
-		type = ACL_TYPE_ACCESS;
-	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
-		type = ACL_TYPE_DEFAULT;
-	else
-		return -EOPNOTSUPP;
+static ssize_t nfs3_acl_xattr_get(struct inode *inode, void *buffer,
+				  size_t size, int acl_type)
+{
+	struct posix_acl *acl;
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
+{
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+
+	return nfs3_acl_xattr_get(inode, buffer, size, ACL_TYPE_ACCESS);
+}
+
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
index 867f705..c94fa3f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1940,6 +1940,9 @@ static void nfs_fill_super(struct super_block *sb,
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
+#ifdef CONFIG_NFS_V3_ACL
+		sb->s_xattr = nfs3_xattr_handlers;
+#endif
 	}
 
 	sb->s_op = &nfs_sops;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f6b9024..04c4f80 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -390,22 +390,6 @@ static inline struct rpc_cred *nfs_file_cred(struct file *file)
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
1.6.2.5


-- 
James Morris
<jmorris@namei.org>
