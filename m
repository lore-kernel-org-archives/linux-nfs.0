Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2BJWCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:18 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 09/21] NFS: Convert v3 into a module
Date: Fri, 10 Feb 2012 17:01:53 -0500
Message-Id: <1328911325-1566-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch exports symbols and moves over the final structures needed by
the v3 module.  In addition, I also switch over to using IS_ENABLED() to
check if CONFIG_NFS_V3 or CONFIG_NFS_V3_MODULE are set.

The module will be created in the same directory as nfs.ko.  You need to
run `modprobe nfs3` before you can use it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig         |    2 +-
 fs/nfs/Makefile        |    6 +++-
 fs/nfs/client.c        |   18 -------------
 fs/nfs/dir.c           |   65 ++++++++++++++++-------------------------------
 fs/nfs/direct.c        |    2 +-
 fs/nfs/file.c          |   12 ---------
 fs/nfs/inode.c         |    5 +++
 fs/nfs/nfs.h           |   12 ++++++++-
 fs/nfs/nfs3client.c    |   15 ++++++++++-
 fs/nfs/nfs3super.c     |   39 ++++++++++++++++++++++++++++
 fs/nfs/super.c         |    6 ++--
 fs/nfs/write.c         |    8 +++---
 include/linux/nfs_fs.h |    6 ++--
 13 files changed, 107 insertions(+), 89 deletions(-)
 create mode 100644 fs/nfs/dangling.txt

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b28e56f..57c4b19 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -39,7 +39,7 @@ config NFS_V2
 	  If unsure, say Y.
 
 config NFS_V3
-	bool "NFS client support for NFS version 3"
+	tristate "NFS client support for NFS version 3"
 	depends on NFS_FS
 	help
 	  This option enables support for version 3 of the NFS protocol
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 6764e66..938db05 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
@@ -22,6 +20,10 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 obj-$(CONFIG_NFS_V2) += nfs2.o
 nfs2-y += nfs2super.o proc.o nfs2xdr.o
 
+obj-$(CONFIG_NFS_V3) += nfs3.o
+nfs3-y += nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
+nfs3-y += nfs3acl.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ca3a408..75fe112 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -111,21 +111,6 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-#ifdef CONFIG_NFS_V3_ACL
-static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static struct rpc_version *nfsacl_version[] = {
-	[3]			= &nfsacl_version3,
-};
-
-const struct rpc_program nfsacl_program = {
-	.name			= "nfsacl",
-	.number			= NFS_ACL_PROGRAM,
-	.nrvers			= ARRAY_SIZE(nfsacl_version),
-	.version		= nfsacl_version,
-	.stats			= &nfsacl_rpcstat,
-};
-#endif  /* CONFIG_NFS_V3_ACL */
-
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
@@ -197,9 +182,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 void __init nfs_register_versions(void)
 {
-#ifdef CONFIG_NFS_V3
-	init_nfs_v3();
-#endif
 #ifdef CONFIG_NFS_V4
 	init_nfs_v4();
 #endif
diff --git a/fs/nfs/dangling.txt b/fs/nfs/dangling.txt
new file mode 100644
index 0000000..e69de29
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0a2bf0e..07ed31d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -41,22 +41,13 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "nfs.h"
 
 /* #define NFS_DEBUG_VERBOSE 1 */
 
 static int nfs_opendir(struct inode *, struct file *);
 static int nfs_closedir(struct inode *, struct file *);
 static int nfs_readdir(struct file *, void *, filldir_t);
-static struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
-static int nfs_create(struct inode *, struct dentry *, umode_t, struct nameidata *);
-static int nfs_mkdir(struct inode *, struct dentry *, umode_t);
-static int nfs_rmdir(struct inode *, struct dentry *);
-static int nfs_unlink(struct inode *, struct dentry *);
-static int nfs_symlink(struct inode *, struct dentry *, const char *);
-static int nfs_link(struct dentry *, struct inode *, struct dentry *);
-static int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
-static int nfs_rename(struct inode *, struct dentry *,
-		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, loff_t, loff_t, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static void nfs_readdir_clear_array(struct page*);
@@ -90,27 +81,6 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V3
-const struct inode_operations nfs3_dir_inode_operations = {
-	.create		= nfs_create,
-	.lookup		= nfs_lookup,
-	.link		= nfs_link,
-	.unlink		= nfs_unlink,
-	.symlink	= nfs_symlink,
-	.mkdir		= nfs_mkdir,
-	.rmdir		= nfs_rmdir,
-	.mknod		= nfs_mknod,
-	.rename		= nfs_rename,
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_V3 */
-
 #ifdef CONFIG_NFS_V4
 
 static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
@@ -1266,7 +1236,7 @@ const struct dentry_operations nfs_dentry_operations = {
 };
 EXPORT_SYMBOL_GPL(nfs_dentry_operations);
 
-static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
+struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
 	struct dentry *parent;
@@ -1329,6 +1299,7 @@ out:
 	nfs_free_fhandle(fhandle);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup);
 
 #ifdef CONFIG_NFS_V4
 static int nfs_open_revalidate(struct dentry *, struct nameidata *);
@@ -1681,7 +1652,7 @@ EXPORT_SYMBOL_GPL(nfs_instantiate);
  * that the operation succeeded on the server, but an error in the
  * reply path made it appear to have failed.
  */
-static int nfs_create(struct inode *dir, struct dentry *dentry,
+int nfs_create(struct inode *dir, struct dentry *dentry,
 		umode_t mode, struct nameidata *nd)
 {
 	struct iattr attr;
@@ -1705,12 +1676,12 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_create);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int
-nfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t rdev)
+int nfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t rdev)
 {
 	struct iattr attr;
 	int status;
@@ -1732,11 +1703,12 @@ out_err:
 	d_drop(dentry);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_mknod);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int nfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
+int nfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	struct iattr attr;
 	int error;
@@ -1755,6 +1727,7 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_mkdir);
 
 static void nfs_dentry_handle_enoent(struct dentry *dentry)
 {
@@ -1762,7 +1735,7 @@ static void nfs_dentry_handle_enoent(struct dentry *dentry)
 		d_delete(dentry);
 }
 
-static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
+int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 
@@ -1778,6 +1751,7 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rmdir);
 
 /*
  * Remove a file after making sure there are no pending writes,
@@ -1821,7 +1795,7 @@ out:
  *
  *  If sillyrename() returns 0, we do nothing, otherwise we unlink.
  */
-static int nfs_unlink(struct inode *dir, struct dentry *dentry)
+int nfs_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 	int need_rehash = 0;
@@ -1849,6 +1823,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		d_rehash(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_unlink);
 
 /*
  * To create a symbolic link, most file systems instantiate a new inode,
@@ -1865,7 +1840,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
  * now have a new file handle and can instantiate an in-core NFS inode
  * and move the raw page into its mapping.
  */
-static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct pagevec lru_pvec;
 	struct page *page;
@@ -1919,9 +1894,9 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_symlink);
 
-static int 
-nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
+int nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = old_dentry->d_inode;
 	int error;
@@ -1940,6 +1915,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 	}
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_link);
 
 /*
  * RENAME
@@ -1965,8 +1941,8 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
  * If these conditions are met, we can drop the dentries before doing
  * the rename.
  */
-static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
-		      struct inode *new_dir, struct dentry *new_dentry)
+int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
+	       struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
@@ -2038,6 +2014,7 @@ out:
 		dput(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rename);
 
 static DEFINE_SPINLOCK(nfs_access_lru_lock);
 static LIST_HEAD(nfs_access_lru_list);
@@ -2138,6 +2115,7 @@ void nfs_access_zap_cache(struct inode *inode)
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
 }
+EXPORT_SYMBOL_GPL(nfs_access_zap_cache);
 
 static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
 {
@@ -2357,6 +2335,7 @@ out_notsup:
 		res = generic_permission(inode, mask);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_permission);
 
 /*
  * Local variables:
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..185e177 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -460,7 +460,7 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 	}
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 94af2db..c678c00 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -50,18 +50,6 @@ const struct inode_operations nfs_file_inode_operations = {
 };
 EXPORT_SYMBOL_GPL(nfs_file_inode_operations);
 
-#ifdef CONFIG_NFS_V3
-const struct inode_operations nfs3_file_inode_operations = {
-	.permission	= nfs_permission,
-	.getattr	= nfs_getattr,
-	.setattr	= nfs_setattr,
-	.listxattr	= nfs3_listxattr,
-	.getxattr	= nfs3_getxattr,
-	.setxattr	= nfs3_setxattr,
-	.removexattr	= nfs3_removexattr,
-};
-#endif  /* CONFIG_NFS_v3 */
-
 /* Hack for future NFS swap support */
 #ifndef IS_SWAPFILE
 # define IS_SWAPFILE(inode)	(0)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 773dfb9..a78d701 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -187,6 +187,7 @@ void nfs_zap_acl_cache(struct inode *inode)
 	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_ACL;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_zap_acl_cache);
 
 void nfs_invalidate_atime(struct inode *inode)
 {
@@ -448,6 +449,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_setattr);
 
 /**
  * nfs_vmtruncate - unmap mappings "freed" by truncate() syscall
@@ -545,6 +547,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -851,6 +854,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
@@ -1147,6 +1151,7 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
 
 /**
  * nfs_post_op_update_inode_force_wcc - try to update the inode attribute cache
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 921e8c8..dccbcfc 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -30,7 +30,6 @@ struct nfs_subversion {
 };
 
 void nfs_register_versions(void);
-int init_nfs_v3(void);
 int init_nfs_v4(void);
 
 struct nfs_subversion *get_nfs_version(unsigned int);
@@ -42,6 +41,17 @@ void unregister_nfs_version(struct nfs_subversion *);
 /* Exported in client.c */
 struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
 
+/* Exported in dir.c */
+struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_create(struct inode *, struct dentry *, umode_t, struct nameidata *);
+int nfs_mkdir(struct inode *, struct dentry *, umode_t);
+int nfs_rmdir(struct inode *, struct dentry *);
+int nfs_unlink(struct inode *, struct dentry *);
+int nfs_symlink(struct inode *, struct dentry *, const char *);
+int nfs_link(struct dentry *, struct inode *, struct dentry *);
+int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
+int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+
 /* Exported in super.c */
 extern struct file_system_type nfs_fs_type;
 struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index f23fc46..f246cbd 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -12,10 +12,23 @@
 #include "internal.h"
 #include "nfs.h"
 
+#ifdef CONFIG_NFS_V3_ACL
+static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
+static struct rpc_version *nfsacl_version[] = {
+	[3]			= &nfsacl_version3,
+};
+
+const struct rpc_program nfsacl_program = {
+	.name			= "nfsacl",
+	.number			= NFS_ACL_PROGRAM,
+	.nrvers			= ARRAY_SIZE(nfsacl_version),
+	.version		= nfsacl_version,
+	.stats			= &nfsacl_rpcstat,
+};
+
 /*
  * Initialise an NFSv3 ACL client connection
  */
-#ifdef CONFIG_NFS_V3_ACL
 static void nfs_init_server_aclclient(struct nfs_server *server)
 {
 	if (server->flags & NFS_MOUNT_NOACL)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 5702895..474840f 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -41,6 +41,35 @@ static struct dentry *nfs3_xdev_mount(int flags, const char *dev_name,
 	return _nfs_xdev_mount(&nfs_fs_type, server, flags, dev_name, data, NFS_MOUNT_UNSHARED);
 }
 
+const struct inode_operations nfs3_file_inode_operations = {
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
+const struct inode_operations nfs3_dir_inode_operations = {
+	.create		= nfs_create,
+	.lookup		= nfs_lookup,
+	.link		= nfs_link,
+	.unlink		= nfs_unlink,
+	.symlink	= nfs_symlink,
+	.mkdir		= nfs_mkdir,
+	.rmdir		= nfs_rmdir,
+	.mknod		= nfs_mknod,
+	.rename		= nfs_rename,
+	.permission	= nfs_permission,
+	.getattr	= nfs_getattr,
+	.setattr	= nfs_setattr,
+	.listxattr	= nfs3_listxattr,
+	.getxattr	= nfs3_getxattr,
+	.setxattr	= nfs3_setxattr,
+	.removexattr	= nfs3_removexattr,
+};
+
 static struct nfs_subversion nfs_v3 = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -57,3 +86,13 @@ int __init init_nfs_v3(void)
 	register_nfs_version(&nfs_v3);
 	return 0;
 }
+
+static void __exit exit_nfs_v3(void)
+{
+	unregister_nfs_version(&nfs_v3);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v3);
+module_exit(exit_nfs_v3);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ec5287d..88bbebe 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -68,7 +68,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 #define NFS_DEFAULT_VERSION 3
 #else
 #define NFS_DEFAULT_VERSION 2
@@ -1910,7 +1910,7 @@ static int nfs_validate_mount_data(void *options,
 		}
 	}
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 	if (args->version == 3)
 		goto out_v3_not_compiled;
 #endif /* !CONFIG_NFS_V3 */
@@ -1930,7 +1930,7 @@ out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
 	return -EINVAL;
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 out_v3_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b1831d..b8111cb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -431,7 +431,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
  */
@@ -516,7 +516,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 }
 #endif
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
 {
@@ -1238,7 +1238,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1297,7 +1297,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8c29950..766ea02 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -406,7 +406,7 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
  * linux/fs/nfs/file.c
  */
 extern const struct inode_operations nfs_file_inode_operations;
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
@@ -464,7 +464,7 @@ extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
  * linux/fs/nfs/dir.c
  */
 extern const struct inode_operations nfs_dir_inode_operations;
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 extern const struct inode_operations nfs3_dir_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_dir_operations;
@@ -524,7 +524,7 @@ extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-- 
1.7.9

