Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33550 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120Ab2GWPMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jul 2012 11:12:18 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] NFS: Convert v2 into a module
Date: Mon, 23 Jul 2012 11:12:07 -0400
Message-Id: <1343056329-24808-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343056329-24808-1-git-send-email-bjschuma@netapp.com>
References: <1343056329-24808-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The module (nfs2.ko) will be created in the same directory as nfs.ko and
will be automatically loaded the first time you try to mount over NFS v2.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig     |  2 +-
 fs/nfs/Makefile    |  4 +++-
 fs/nfs/client.c    | 12 ++++++------
 fs/nfs/dir.c       | 13 +++++++++++++
 fs/nfs/file.c      |  2 ++
 fs/nfs/inode.c     | 10 ++++++++++
 fs/nfs/namespace.c |  2 ++
 fs/nfs/nfs.h       | 14 --------------
 fs/nfs/nfs2super.c |  9 +++++++--
 fs/nfs/read.c      |  1 +
 fs/nfs/super.c     |  3 +++
 fs/nfs/write.c     |  2 ++
 12 files changed, 50 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 404c6a8..6764dbf 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -30,7 +30,7 @@ config NFS_FS
 	  If unsure, say N.
 
 config NFS_V2
-	bool "NFS client support for NFS version 2"
+	tristate "NFS client support for NFS version 2"
 	depends on NFS_FS
 	default y
 	help
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7ca0125..df61db4 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= nfs2super.o proc.o nfs2xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
@@ -25,6 +24,9 @@ endif
 
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
+obj-$(CONFIG_NFS_V2) += nfs2.o
+nfs2-y := nfs2super.o proc.o nfs2xdr.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1f29082..fa8acf5 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -149,11 +149,7 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 int __init nfs_register_versions(void)
 {
-	int err = init_nfs_v2();
-	if (err)
-		return err;
-
-	err = init_nfs_v3();
+	int err = init_nfs_v3();
 	if (err)
 		return err;
 
@@ -165,7 +161,6 @@ int __init nfs_register_versions(void)
  */
 void nfs_unregister_versions(void)
 {
-	exit_nfs_v2();
 	exit_nfs_v3();
 	exit_nfs_v4();
 }
@@ -222,6 +217,7 @@ error_cleanup:
 error_0:
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_client);
 
 #ifdef CONFIG_NFS_V4
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
@@ -284,6 +280,7 @@ void nfs_free_client(struct nfs_client *clp)
 
 	dprintk("<-- nfs_free_client()\n");
 }
+EXPORT_SYMBOL_GPL(nfs_free_client);
 
 /*
  * Release a reference to a shared client record
@@ -753,6 +750,7 @@ error:
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(nfs_init_client);
 
 /*
  * Create a version 2 or 3 client
@@ -1122,6 +1120,7 @@ error:
 	nfs_free_server(server);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(nfs_create_server);
 
 /*
  * Clone an NFS2, NFS3 or NFS4 server record
@@ -1191,6 +1190,7 @@ out_free_server:
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(nfs_clone_server);
 
 void nfs_clients_init(struct net *net)
 {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d49f1b9..c382a6d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -17,6 +17,7 @@
  *  6 Jun 1999	Cache readdir lookups in the page cache. -DaveM
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/stat.h>
@@ -1196,6 +1197,7 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs_dentry_operations);
 
 struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned int flags)
 {
@@ -1263,6 +1265,7 @@ out:
 	nfs_free_fhandle(fhandle);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup);
 
 #ifdef CONFIG_NFS_V4
 static int nfs4_lookup_revalidate(struct dentry *, unsigned int);
@@ -1508,6 +1511,7 @@ out_error:
 	dput(parent);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_instantiate);
 
 /*
  * Following a failed create operation, we drop the dentry rather
@@ -1536,6 +1540,7 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_create);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
@@ -1563,6 +1568,7 @@ out_err:
 	d_drop(dentry);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_mknod);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
@@ -1586,6 +1592,7 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_mkdir);
 
 static void nfs_dentry_handle_enoent(struct dentry *dentry)
 {
@@ -1609,6 +1616,7 @@ int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rmdir);
 
 /*
  * Remove a file after making sure there are no pending writes,
@@ -1680,6 +1688,7 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		d_rehash(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_unlink);
 
 /*
  * To create a symbolic link, most file systems instantiate a new inode,
@@ -1750,6 +1759,7 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_symlink);
 
 int
 nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
@@ -1771,6 +1781,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 	}
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_link);
 
 /*
  * RENAME
@@ -1869,6 +1880,7 @@ out:
 		dput(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rename);
 
 static DEFINE_SPINLOCK(nfs_access_lru_lock);
 static LIST_HEAD(nfs_access_lru_list);
@@ -2188,6 +2200,7 @@ out_notsup:
 		res = generic_permission(inode, mask);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_permission);
 
 /*
  * Local variables:
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 70d124a..130a7bb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -16,6 +16,7 @@
  *  nfs regular file handling functions
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -862,3 +863,4 @@ const struct file_operations nfs_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
+EXPORT_SYMBOL_GPL(nfs_file_operations);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a6ffa4b..f358b97 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -193,6 +193,7 @@ void nfs_invalidate_atime(struct inode *inode)
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_invalidate_atime);
 
 /*
  * Invalidate, but do not unhash, the inode.
@@ -438,6 +439,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_setattr);
 
 /**
  * nfs_vmtruncate - unmap mappings "freed" by truncate() syscall
@@ -496,6 +498,7 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
@@ -535,6 +538,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -623,6 +627,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 		return;
 	nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_close_context);
 
 struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
 {
@@ -1028,6 +1033,7 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->owner_name = NULL;
 	fattr->group_name = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_fattr_init);
 
 struct nfs_fattr *nfs_alloc_fattr(void)
 {
@@ -1038,6 +1044,7 @@ struct nfs_fattr *nfs_alloc_fattr(void)
 		nfs_fattr_init(fattr);
 	return fattr;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fattr);
 
 struct nfs_fh *nfs_alloc_fhandle(void)
 {
@@ -1048,6 +1055,7 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 		fh->size = 0;
 	return fh;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fhandle);
 
 #ifdef NFS_DEBUG
 /*
@@ -1168,6 +1176,7 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
 static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
@@ -1255,6 +1264,7 @@ out_noforce:
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
 
 /*
  * Many nfs protocol calls return the new file attributes after
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 0f699fe..2a3b170 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -7,6 +7,7 @@
  * NFS namespace
  */
 
+#include <linux/module.h>
 #include <linux/dcache.h>
 #include <linux/gfp.h>
 #include <linux/mount.h>
@@ -255,3 +256,4 @@ struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 
 	return nfs_do_submount(dentry, fh, fattr, server->client->cl_auth->au_flavor);
 }
+EXPORT_SYMBOL_GPL(nfs_submount);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 9f502a0..f5d1cf5 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -24,20 +24,6 @@ struct nfs_subversion {
 int nfs_register_versions(void);
 void nfs_unregister_versions(void);
 
-#ifdef CONFIG_NFS_V2
-int init_nfs_v2(void);
-void exit_nfs_v2(void);
-#else /* CONFIG_NFS_V2 */
-static inline int __init init_nfs_v2(void)
-{
-	return 0;
-}
-
-static inline void exit_nfs_v2(void)
-{
-}
-#endif /* CONFIG_NFS_V2 */
-
 #ifdef CONFIG_NFS_V3
 int init_nfs_v3(void);
 void exit_nfs_v3(void);
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index a9fb69d..0a9782c 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -14,13 +14,18 @@ static struct nfs_subversion nfs_v2 = {
 	.sops     = &nfs_sops,
 };
 
-int __init init_nfs_v2(void)
+static int __init init_nfs_v2(void)
 {
 	register_nfs_version(&nfs_v2);
 	return 0;
 }
 
-void exit_nfs_v2(void)
+static void __exit exit_nfs_v2(void)
 {
 	unregister_nfs_version(&nfs_v2);
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v2);
+module_exit(exit_nfs_v2);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6267b87..b000e4c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -113,6 +113,7 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops, compl_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a275d19..56f3af8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -289,6 +289,7 @@ struct file_system_type nfs_fs_type = {
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
+EXPORT_SYMBOL_GPL(nfs_fs_type);
 
 struct file_system_type nfs_xdev_fs_type = {
 	.owner		= THIS_MODULE,
@@ -312,6 +313,7 @@ const struct super_operations nfs_sops = {
 	.show_stats	= nfs_show_stats,
 	.remount_fs	= nfs_remount,
 };
+EXPORT_SYMBOL_GPL(nfs_sops);
 
 #ifdef CONFIG_NFS_V4
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
@@ -1670,6 +1672,7 @@ struct dentry *nfs_try_mount(int flags, const char *dev_name,
 
 	return nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
 }
+EXPORT_SYMBOL_GPL(nfs_try_mount);
 
 /*
  * Split "dev_name" into "hostname:export_path".
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6ddac54..1e8d4b0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1210,6 +1210,7 @@ void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, compl_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -1688,6 +1689,7 @@ int nfs_wb_all(struct inode *inode)
 
 	return sync_inode(inode, &wbc);
 }
+EXPORT_SYMBOL_GPL(nfs_wb_all);
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
-- 
1.7.11.2

