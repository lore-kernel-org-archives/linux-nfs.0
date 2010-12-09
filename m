Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:43752 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab0LILfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 06:35:30 -0500
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB9BUO3G015663
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:30:24 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB9BZSpf1916960
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:35:28 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB9BZSqM011800
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:35:28 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: trond.myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] nfsv4: Switch to generic xattr handling code
Date: Thu,  9 Dec 2010 17:05:25 +0530
Message-Id: <1291894525-6559-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch make nfsv4 use the generic xattr handling code
to get the nfsv4 acl. This will help us to add richacl
support to nfsv4 in later patches

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/dir.c      |    8 ++++--
 fs/nfs/nfs4_fs.h  |    7 +-----
 fs/nfs/nfs4proc.c |   62 +++++++++++++++++++++++++++++-----------------------
 fs/nfs/super.c    |    4 ++-
 4 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 070f368..7e0c0be 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -35,6 +35,7 @@
 #include <linux/sched.h>
 #include <linux/vmalloc.h>
 #include <linux/kmemleak.h>
+#include <linux/xattr.h>
 
 #include "delegation.h"
 #include "iostat.h"
@@ -125,9 +126,10 @@ const struct inode_operations nfs4_dir_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
-	.getxattr       = nfs4_getxattr,
-	.setxattr       = nfs4_setxattr,
-	.listxattr      = nfs4_listxattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.listxattr	= generic_listxattr,
+	.removexattr	= generic_removexattr,
 };
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9fa4963..441fbcd 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -227,12 +227,6 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
-/* inode.c */
-extern ssize_t nfs4_getxattr(struct dentry *, const char *, void *, size_t);
-extern int nfs4_setxattr(struct dentry *, const char *, const void *, size_t, int);
-extern ssize_t nfs4_listxattr(struct dentry *, char *, size_t);
-
-
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
@@ -246,6 +240,7 @@ extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fh
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
+extern const struct xattr_handler *nfs4_xattr_handlers[];
 
 #if defined(CONFIG_NFS_V4_1)
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c57b4e0..9d4839b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -49,6 +49,7 @@
 #include <linux/mount.h>
 #include <linux/module.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/xattr.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -4394,42 +4395,36 @@ void nfs4_release_lockowner(const struct nfs4_lock_state *lsp)
 
 #define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
 
-int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
-		size_t buflen, int flags)
+static int nfs4_xattr_set_nfs4_acl(struct dentry *dentry, const char *key,
+				   const void *buf, size_t buflen,
+				   int flags, int type)
 {
-	struct inode *inode = dentry->d_inode;
-
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
+	if (strcmp(key, "") != 0)
+		return -EINVAL;
 
-	return nfs4_proc_set_acl(inode, buf, buflen);
+	return nfs4_proc_set_acl(dentry->d_inode, buf, buflen);
 }
 
-/* The getxattr man page suggests returning -ENODATA for unknown attributes,
- * and that's what we'll do for e.g. user attributes that haven't been set.
- * But we'll follow ext2/ext3's lead by returning -EOPNOTSUPP for unsupported
- * attributes in kernel-managed attribute namespaces. */
-ssize_t nfs4_getxattr(struct dentry *dentry, const char *key, void *buf,
-		size_t buflen)
+static int nfs4_xattr_get_nfs4_acl(struct dentry *dentry, const char *key,
+				   void *buf, size_t buflen, int type)
 {
-	struct inode *inode = dentry->d_inode;
-
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
+	if (strcmp(key, "") != 0)
+		return -EINVAL;
 
-	return nfs4_proc_get_acl(inode, buf, buflen);
+	return nfs4_proc_get_acl(dentry->d_inode, buf, buflen);
 }
 
-ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
+static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
+				       size_t list_len, const char *name,
+				       size_t name_len, int type)
 {
-	size_t len = strlen(XATTR_NAME_NFSV4_ACL) + 1;
+	size_t len = sizeof(XATTR_NAME_NFSV4_ACL);
 
 	if (!nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
 		return 0;
-	if (buf && buflen < len)
-		return -ERANGE;
-	if (buf)
-		memcpy(buf, XATTR_NAME_NFSV4_ACL, len);
+
+	if (list && len <= list_len)
+		memcpy(list, XATTR_NAME_NFSV4_ACL, len);
 	return len;
 }
 
@@ -5500,9 +5495,10 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
-	.getxattr	= nfs4_getxattr,
-	.setxattr	= nfs4_setxattr,
-	.listxattr	= nfs4_listxattr,
+	.getxattr	= generic_getxattr,
+	.setxattr	= generic_setxattr,
+	.listxattr	= generic_listxattr,
+	.removexattr	= generic_removexattr,
 };
 
 const struct nfs_rpc_ops nfs_v4_clientops = {
@@ -5547,6 +5543,18 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.open_context	= nfs4_atomic_open,
 };
 
+static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
+	.prefix	= XATTR_NAME_NFSV4_ACL,
+	.list	= nfs4_xattr_list_nfs4_acl,
+	.get	= nfs4_xattr_get_nfs4_acl,
+	.set	= nfs4_xattr_set_nfs4_acl,
+};
+
+const struct xattr_handler *nfs4_xattr_handlers[] = {
+	&nfs4_xattr_nfs4_acl_handler,
+	NULL
+};
+
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e57e670..e0f4a9e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2503,7 +2503,8 @@ static void nfs4_clone_super(struct super_block *sb,
 	 * so ourselves when necessary.
 	 */
 	sb->s_flags  |= MS_POSIXACL;
- 	nfs_initialise_sb(sb);
+	sb->s_xattr  = old_sb->s_xattr;
+	nfs_initialise_sb(sb);
 }
 
 /*
@@ -2518,6 +2519,7 @@ static void nfs4_fill_super(struct super_block *sb)
 	 * so ourselves when necessary.
 	 */
 	sb->s_flags  |= MS_POSIXACL;
+	sb->s_xattr = nfs4_xattr_handlers;
 	nfs_initialise_sb(sb);
 }
 
-- 
1.7.1

