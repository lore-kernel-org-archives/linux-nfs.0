Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760244Ab2BJWCO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:14 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 04/21] NFS: Convert v2 into a module
Date: Fri, 10 Feb 2012 17:01:48 -0500
Message-Id: <1328911325-1566-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The module will be created in the same subdirectory as nfs.ko.  You need
to run `modprobe nfs2` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig     |    2 +-
 fs/nfs/Makefile    |    4 +++-
 fs/nfs/client.c    |    5 ++---
 fs/nfs/dir.c       |    4 ++++
 fs/nfs/file.c      |    3 +++
 fs/nfs/inode.c     |    8 ++++++++
 fs/nfs/nfs.h       |    3 ++-
 fs/nfs/nfs2super.c |   14 +++++++++++++-
 8 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 5419166..b28e56f 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -30,7 +30,7 @@ config NFS_FS
 	  If unsure, say N.
 
 config NFS_V2
-	bool "NFS client support for NFS version 2"
+	tristate "NFS client support for NFS version 2"
 	depends on NFS_FS
 	help
 	  This option enables support for version 2 of the NFS protocol
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index c6e7844..bc2ba86 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= nfs2super.o proc.o nfs2xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
@@ -20,6 +19,9 @@ nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
+obj-$(CONFIG_NFS_V2) += nfs2.o
+nfs2-y += nfs2super.o proc.o nfs2xdr.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 59bf964..4312a51 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -197,9 +197,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 void __init nfs_register_versions(void)
 {
-#ifdef CONFIG_NFS_V2
-	init_nfs_v2();
-#endif
 #ifdef CONFIG_NFS_V3
 	init_nfs_v3();
 #endif
@@ -893,6 +890,7 @@ error:
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_init_client);
 
 /*
  * Create a version 2 or 3 client
@@ -2137,6 +2135,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
 	return nfs_errtbl[i].errno;
 }
+EXPORT_SYMBOL_GPL(nfs_stat_to_errno);
 
 module_param(nfs4_disable_idmapping, bool, 0644);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index bb132a8..0a2bf0e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -17,6 +17,7 @@
  *  6 Jun 1999	Cache readdir lookups in the page cache. -DaveM
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/stat.h>
@@ -83,6 +84,7 @@ const struct inode_operations nfs_dir_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 };
+EXPORT_SYMBOL_GPL(nfs_dir_inode_operations);
 
 const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
@@ -1262,6 +1264,7 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs_dentry_operations);
 
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
@@ -1670,6 +1673,7 @@ out_error:
 	dput(parent);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_instantiate);
 
 /*
  * Following a failed create operation, we drop the dentry rather
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4fdaaa6..94af2db 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -16,6 +16,7 @@
  *  nfs regular file handling functions
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -47,6 +48,7 @@ const struct inode_operations nfs_file_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 };
+EXPORT_SYMBOL_GPL(nfs_file_inode_operations);
 
 #ifdef CONFIG_NFS_V3
 const struct inode_operations nfs3_file_inode_operations = {
@@ -867,6 +869,7 @@ const struct file_operations nfs_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
+EXPORT_SYMBOL_GPL(nfs_file_operations);
 
 #ifdef CONFIG_NFS_V4
 static int
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e30d6d3..773dfb9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -194,6 +194,7 @@ void nfs_invalidate_atime(struct inode *inode)
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_invalidate_atime);
 
 /*
  * Invalidate, but do not unhash, the inode.
@@ -505,6 +506,7 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
@@ -631,6 +633,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 		return;
 	nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_close_context);
 
 struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
 {
@@ -1025,6 +1028,7 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->owner_name = NULL;
 	fattr->group_name = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_fattr_init);
 
 struct nfs_fattr *nfs_alloc_fattr(void)
 {
@@ -1035,6 +1039,7 @@ struct nfs_fattr *nfs_alloc_fattr(void)
 		nfs_fattr_init(fattr);
 	return fattr;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fattr);
 
 struct nfs_fh *nfs_alloc_fhandle(void)
 {
@@ -1045,6 +1050,7 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 		fh->size = 0;
 	return fh;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fhandle);
 
 /**
  * nfs_inode_attrs_need_update - check if the inode attributes need updating
@@ -1104,6 +1110,7 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
 static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
@@ -1191,6 +1198,7 @@ out_noforce:
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
 
 /*
  * Many nfs protocol calls return the new file attributes after
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 05f6849..4e4802e 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -9,6 +9,8 @@
 
 #include <linux/fs.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
 
 struct nfs_subversion {
@@ -22,7 +24,6 @@ struct nfs_subversion {
 };
 
 void nfs_register_versions(void);
-int init_nfs_v2(void);
 int init_nfs_v3(void);
 int init_nfs_v4(void);
 
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index 12fa906..773342d 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -1,5 +1,7 @@
 /*
  * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ *
+ * Initialize the NFS v2 module
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
@@ -24,8 +26,18 @@ static struct nfs_subversion nfs_v2 = {
 	.unreference = nfs2_unreference,
 };
 
-int __init init_nfs_v2(void)
+static int __init init_nfs_v2(void)
 {
 	register_nfs_version(&nfs_v2);
 	return 0;
 }
+
+static void __exit exit_nfs_v2(void)
+{
+	unregister_nfs_version(&nfs_v2);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v2);
+module_exit(exit_nfs_v2);
-- 
1.7.9

