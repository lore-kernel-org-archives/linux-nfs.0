From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/8] nfsv4: Switch to generic xattr handling code
Date: Wed,  2 Sep 2009 17:54:22 +0530
Message-ID: <1251894268-1555-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:48510 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbZIBMY6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:24:58 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82COtvn000476
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:55 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82COtY02195690
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82COslv001333
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:24:55 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch make nfsv4 use the generic xattr handling code
to get the nfsv4 acl. This will help us to add posix acl
support to nfsv4 in later patches

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/dir.c      |    9 +++++--
 fs/nfs/nfs4_fs.h  |    6 -----
 fs/nfs/nfs4proc.c |   57 ++++++++++++++++++++++++++++++----------------------
 fs/nfs/super.c    |    3 ++
 4 files changed, 42 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32062c3..f9278a2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -33,6 +33,8 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/sched.h>
+#include <linux/xattr.h>
+
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -117,9 +119,10 @@ const struct inode_operations nfs4_dir_inode_operations = {
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
index 6ea07a3..c9869f5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -191,12 +191,6 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
-/* inode.c */
-extern ssize_t nfs4_getxattr(struct dentry *, const char *, void *, size_t);
-extern int nfs4_setxattr(struct dentry *, const char *, const void *, size_t, int);
-extern ssize_t nfs4_listxattr(struct dentry *, char *, size_t);
-
-
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6917311..fa60261 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -49,6 +49,7 @@
 #include <linux/mount.h>
 #include <linux/module.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/xattr.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -4172,42 +4173,37 @@ out:
 
 #define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
 
-int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
-		size_t buflen, int flags)
+static int nfs4_xattr_set_nfs4_acl(struct inode *inode, const char *key,
+			const void *buf, size_t buflen, int flags)
 {
-	struct inode *inode = dentry->d_inode;
-
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
+	if (strcmp(key, "") != 0)
+		return -EINVAL;
 
 	return nfs4_proc_set_acl(inode, buf, buflen);
 }
 
-/* The getxattr man page suggests returning -ENODATA for unknown attributes,
- * and that's what we'll do for e.g. user attributes that haven't been set.
- * But we'll follow ext2/ext3's lead by returning -EOPNOTSUPP for unsupported
- * attributes in kernel-managed attribute namespaces. */
-ssize_t nfs4_getxattr(struct dentry *dentry, const char *key, void *buf,
-		size_t buflen)
+static int nfs4_xattr_get_nfs4_acl(struct inode *inode, const char *key,
+				void *buf, size_t buflen)
 {
-	struct inode *inode = dentry->d_inode;
-
-	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
-		return -EOPNOTSUPP;
+	if (strcmp(key, "") != 0)
+		return -EINVAL;
 
 	return nfs4_proc_get_acl(inode, buf, buflen);
 }
 
-ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
+static size_t nfs4_xattr_list_nfs4_acl(struct inode *inode, char *list,
+				size_t list_len, const char *name,
+				size_t name_len)
 {
 	size_t len = strlen(XATTR_NAME_NFSV4_ACL) + 1;
 
-	if (!nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
+	if (!nfs4_server_supports_acls(NFS_SERVER(inode)))
 		return 0;
-	if (buf && buflen < len)
+
+	if (list && len <= list_len)
+		memcpy(list, XATTR_NAME_NFSV4_ACL, len);
+	else
 		return -ERANGE;
-	if (buf)
-		memcpy(buf, XATTR_NAME_NFSV4_ACL, len);
 	return len;
 }
 
@@ -4988,9 +4984,10 @@ static const struct inode_operations nfs4_file_inode_operations = {
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
@@ -5032,6 +5029,18 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 };
 
+struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
+	.prefix	= XATTR_NAME_NFSV4_ACL,
+	.list	= nfs4_xattr_list_nfs4_acl,
+	.get	= nfs4_xattr_get_nfs4_acl,
+	.set	= nfs4_xattr_set_nfs4_acl,
+};
+
+struct xattr_handler *nfs4_xattr_handlers[] = {
+	&nfs4_xattr_nfs4_acl_handler,
+	NULL
+};
+
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0b4cbdc..2f2a5bd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -242,6 +242,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
+extern struct xattr_handler *nfs4_xattr_handlers[];
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -2299,6 +2300,7 @@ static void nfs4_clone_super(struct super_block *sb,
 	sb->s_maxbytes = old_sb->s_maxbytes;
 	sb->s_time_gran = 1;
 	sb->s_op = old_sb->s_op;
+	sb->s_xattr  = old_sb->s_xattr;
  	nfs_initialise_sb(sb);
 }
 
@@ -2309,6 +2311,7 @@ static void nfs4_fill_super(struct super_block *sb)
 {
 	sb->s_time_gran = 1;
 	sb->s_op = &nfs4_sops;
+	sb->s_xattr = nfs4_xattr_handlers;
 	nfs_initialise_sb(sb);
 }
 
-- 
1.6.4.2.253.g0b1fac

