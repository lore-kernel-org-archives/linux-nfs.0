Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39409 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800Ab1KVW6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 17:58:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 1/4] NFS: Export symbols needed by an NFS v3 module
Date: Tue, 22 Nov 2011 17:58:00 -0500
Message-Id: <1322002684-20436-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
References: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These are functions and structures used by the NFS v3 code that needs to
be available once it has been moved to its own module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c  |    1 +
 fs/nfs/dir.c     |   50 ++++++++++++++++++++++++++++++++------------------
 fs/nfs/inode.c   |   12 ++++++++++++
 fs/nfs/nfs2xdr.c |    2 ++
 4 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 873bf00..c32a21f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -813,6 +813,7 @@ error:
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_init_client);
 
 /*
  * Create a version 2 or 3 client
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac28990..f7cb6b6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -19,6 +19,7 @@
 
 #include <linux/time.h>
 #include <linux/errno.h>
+#include <linux/export.h>
 #include <linux/stat.h>
 #include <linux/fcntl.h>
 #include <linux/string.h>
@@ -46,15 +47,15 @@
 static int nfs_opendir(struct inode *, struct file *);
 static int nfs_closedir(struct inode *, struct file *);
 static int nfs_readdir(struct file *, void *, filldir_t);
-static struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
-static int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
-static int nfs_mkdir(struct inode *, struct dentry *, int);
-static int nfs_rmdir(struct inode *, struct dentry *);
-static int nfs_unlink(struct inode *, struct dentry *);
-static int nfs_symlink(struct inode *, struct dentry *, const char *);
-static int nfs_link(struct dentry *, struct inode *, struct dentry *);
-static int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
-static int nfs_rename(struct inode *, struct dentry *,
+struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
+int nfs_mkdir(struct inode *, struct dentry *, int);
+int nfs_rmdir(struct inode *, struct dentry *);
+int nfs_unlink(struct inode *, struct dentry *);
+int nfs_symlink(struct inode *, struct dentry *, const char *);
+int nfs_link(struct dentry *, struct inode *, struct dentry *);
+int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
+int nfs_rename(struct inode *, struct dentry *,
 		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, loff_t, loff_t, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
@@ -1262,8 +1263,9 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs_dentry_operations);
 
-static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
+struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
 	struct dentry *parent;
@@ -1326,6 +1328,7 @@ out:
 	nfs_free_fhandle(fhandle);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup);
 
 #ifdef CONFIG_NFS_V4
 static int nfs_open_revalidate(struct dentry *, struct nameidata *);
@@ -1668,6 +1671,7 @@ out_error:
 	dput(parent);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_instantiate);
 
 /*
  * Following a failed create operation, we drop the dentry rather
@@ -1675,7 +1679,7 @@ out_error:
  * that the operation succeeded on the server, but an error in the
  * reply path made it appear to have failed.
  */
-static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
+int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 		struct nameidata *nd)
 {
 	struct iattr attr;
@@ -1699,11 +1703,12 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_create);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int
+int
 nfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t rdev)
 {
 	struct iattr attr;
@@ -1726,11 +1731,12 @@ out_err:
 	d_drop(dentry);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_mknod);
 
 /*
  * See comments for nfs_proc_create regarding failed operations.
  */
-static int nfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
+int nfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 {
 	struct iattr attr;
 	int error;
@@ -1749,6 +1755,7 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_mkdir);
 
 static void nfs_dentry_handle_enoent(struct dentry *dentry)
 {
@@ -1756,7 +1763,7 @@ static void nfs_dentry_handle_enoent(struct dentry *dentry)
 		d_delete(dentry);
 }
 
-static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
+int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 
@@ -1772,6 +1779,7 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rmdir);
 
 /*
  * Remove a file after making sure there are no pending writes,
@@ -1815,7 +1823,7 @@ out:
  *
  *  If sillyrename() returns 0, we do nothing, otherwise we unlink.
  */
-static int nfs_unlink(struct inode *dir, struct dentry *dentry)
+int nfs_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 	int need_rehash = 0;
@@ -1843,6 +1851,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		d_rehash(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_unlink);
 
 /*
  * To create a symbolic link, most file systems instantiate a new inode,
@@ -1859,7 +1868,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
  * now have a new file handle and can instantiate an in-core NFS inode
  * and move the raw page into its mapping.
  */
-static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct pagevec lru_pvec;
 	struct page *page;
@@ -1913,8 +1922,9 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_symlink);
 
-static int 
+int
 nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = old_dentry->d_inode;
@@ -1934,6 +1944,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 	}
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_link);
 
 /*
  * RENAME
@@ -1959,7 +1970,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
  * If these conditions are met, we can drop the dentries before doing
  * the rename.
  */
-static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
+int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		      struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *old_inode = old_dentry->d_inode;
@@ -2032,6 +2043,7 @@ out:
 		dput(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rename);
 
 static DEFINE_SPINLOCK(nfs_access_lru_lock);
 static LIST_HEAD(nfs_access_lru_list);
@@ -2132,6 +2144,7 @@ void nfs_access_zap_cache(struct inode *inode)
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
 }
+EXPORT_SYMBOL_GPL(nfs_access_zap_cache);
 
 static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
 {
@@ -2351,6 +2364,7 @@ out_notsup:
 		res = generic_permission(inode, mask);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_permission);
 
 /*
  * Local variables:
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a15fa..2a4f55d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -184,6 +184,7 @@ void nfs_zap_acl_cache(struct inode *inode)
 	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_ACL;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_zap_acl_cache);
 
 void nfs_invalidate_atime(struct inode *inode)
 {
@@ -191,6 +192,7 @@ void nfs_invalidate_atime(struct inode *inode)
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_invalidate_atime);
 
 /*
  * Invalidate, but do not unhash, the inode.
@@ -444,6 +446,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_setattr);
 
 /**
  * nfs_vmtruncate - unmap mappings "freed" by truncate() syscall
@@ -502,6 +505,7 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
@@ -540,6 +544,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -628,6 +633,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 		return;
 	nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_close_context);
 
 struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct rpc_cred *cred, fmode_t f_mode)
 {
@@ -845,6 +851,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
@@ -1020,6 +1027,7 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->time_start = jiffies;
 	fattr->gencount = nfs_inc_attr_generation_counter();
 }
+EXPORT_SYMBOL_GPL(nfs_fattr_init);
 
 struct nfs_fattr *nfs_alloc_fattr(void)
 {
@@ -1030,6 +1038,7 @@ struct nfs_fattr *nfs_alloc_fattr(void)
 		nfs_fattr_init(fattr);
 	return fattr;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fattr);
 
 struct nfs_fh *nfs_alloc_fhandle(void)
 {
@@ -1099,6 +1108,7 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
 static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
@@ -1135,6 +1145,7 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
 
 /**
  * nfs_post_op_update_inode_force_wcc - try to update the inode attribute cache
@@ -1186,6 +1197,7 @@ out_noforce:
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
 
 /*
  * Many nfs protocol calls return the new file attributes after
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 792cb13..ce8d6c4 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -13,6 +13,7 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/errno.h>
+#include <linux/export.h>
 #include <linux/string.h>
 #include <linux/in.h>
 #include <linux/pagemap.h>
@@ -1120,6 +1121,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
 	return nfs_errtbl[i].errno;
 }
+EXPORT_SYMBOL_GPL(nfs_stat_to_errno);
 
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
-- 
1.7.7.4

