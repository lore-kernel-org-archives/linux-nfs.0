Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758549Ab2AMULO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:14 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 06/44] NFS: Export symbols needed by a v2 module
Date: Fri, 13 Jan 2012 15:10:15 -0500
Message-Id: <1326485453-1350-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These functions need to be available for v2 to work as a module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c    |    2 +
 fs/nfs/dir.c       |   53 +++++++++++++++++++++++++++++----------------------
 fs/nfs/file.c      |   50 ++++++++++++++++++++++++++++++++----------------
 fs/nfs/inode.c     |   13 ++++++++++-
 fs/nfs/namespace.c |    2 +
 5 files changed, 78 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee63d6a..168b469 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -934,6 +934,7 @@ error:
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_init_client);
 
 /*
  * Create a version 2 or 3 client
@@ -2196,6 +2197,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 	dprintk("NFS: Unrecognized nfs status value: %u\n", status);
 	return nfs_errtbl[i].errno;
 }
+EXPORT_SYMBOL_GPL(nfs_stat_to_errno);
 
 module_param(nfs4_disable_idmapping, bool, 0644);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac28990..6b2813b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -17,6 +17,7 @@
  *  6 Jun 1999	Cache readdir lookups in the page cache. -DaveM
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/stat.h>
@@ -40,22 +41,13 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "nfs.h"
 
 /* #define NFS_DEBUG_VERBOSE 1 */
 
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
-		      struct inode *, struct dentry *);
 static int nfs_fsync_dir(struct file *, loff_t, loff_t, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 static void nfs_readdir_clear_array(struct page*);
@@ -1094,7 +1086,7 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
  * If the parent directory is seen to have changed, we throw out the
  * cached dentry and do a new lookup.
  */
-static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
+int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *dir;
 	struct inode *inode;
@@ -1192,11 +1184,12 @@ out_error:
 			dentry->d_name.name, error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup_revalidate);
 
 /*
  * This is called from dput() when d_count is going to 0.
  */
-static int nfs_dentry_delete(const struct dentry *dentry)
+int nfs_dentry_delete(const struct dentry *dentry)
 {
 	dfprintk(VFS, "NFS: dentry_delete(%s/%s, %x)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -1218,6 +1211,7 @@ static int nfs_dentry_delete(const struct dentry *dentry)
 	return 0;
 
 }
+EXPORT_SYMBOL_GPL(nfs_dentry_delete);
 
 static void nfs_drop_nlink(struct inode *inode)
 {
@@ -1231,7 +1225,7 @@ static void nfs_drop_nlink(struct inode *inode)
  * Called when the dentry loses inode.
  * We use it to clean up silly-renamed files.
  */
-static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
+void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 {
 	if (S_ISDIR(inode->i_mode))
 		/* drop any readdir cache as it could easily be old */
@@ -1243,8 +1237,9 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 	}
 	iput(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_dentry_iput);
 
-static void nfs_d_release(struct dentry *dentry)
+void nfs_d_release(struct dentry *dentry)
 {
 	/* free cached devname value, if it survived that far */
 	if (unlikely(dentry->d_fsdata)) {
@@ -1254,6 +1249,7 @@ static void nfs_d_release(struct dentry *dentry)
 			kfree(dentry->d_fsdata);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_d_release);
 
 const struct dentry_operations nfs_dentry_operations = {
 	.d_revalidate	= nfs_lookup_revalidate,
@@ -1263,7 +1259,7 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_release	= nfs_d_release,
 };
 
-static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
+struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
 	struct dentry *parent;
@@ -1326,6 +1322,7 @@ out:
 	nfs_free_fhandle(fhandle);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_lookup);
 
 #ifdef CONFIG_NFS_V4
 static int nfs_open_revalidate(struct dentry *, struct nameidata *);
@@ -1668,6 +1665,7 @@ out_error:
 	dput(parent);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_instantiate);
 
 /*
  * Following a failed create operation, we drop the dentry rather
@@ -1675,7 +1673,7 @@ out_error:
  * that the operation succeeded on the server, but an error in the
  * reply path made it appear to have failed.
  */
-static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
+int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 		struct nameidata *nd)
 {
 	struct iattr attr;
@@ -1699,11 +1697,12 @@ out_err:
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
@@ -1726,11 +1725,12 @@ out_err:
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
@@ -1749,6 +1749,7 @@ out_err:
 	d_drop(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_mkdir);
 
 static void nfs_dentry_handle_enoent(struct dentry *dentry)
 {
@@ -1756,7 +1757,7 @@ static void nfs_dentry_handle_enoent(struct dentry *dentry)
 		d_delete(dentry);
 }
 
-static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
+int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 
@@ -1772,6 +1773,7 @@ static int nfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rmdir);
 
 /*
  * Remove a file after making sure there are no pending writes,
@@ -1815,7 +1817,7 @@ out:
  *
  *  If sillyrename() returns 0, we do nothing, otherwise we unlink.
  */
-static int nfs_unlink(struct inode *dir, struct dentry *dentry)
+int nfs_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int error;
 	int need_rehash = 0;
@@ -1843,6 +1845,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		d_rehash(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_unlink);
 
 /*
  * To create a symbolic link, most file systems instantiate a new inode,
@@ -1859,7 +1862,7 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
  * now have a new file handle and can instantiate an in-core NFS inode
  * and move the raw page into its mapping.
  */
-static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct pagevec lru_pvec;
 	struct page *page;
@@ -1913,8 +1916,9 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_symlink);
 
-static int 
+int
 nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = old_dentry->d_inode;
@@ -1934,6 +1938,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 	}
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_link);
 
 /*
  * RENAME
@@ -1959,7 +1964,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
  * If these conditions are met, we can drop the dentries before doing
  * the rename.
  */
-static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
+int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		      struct inode *new_dir, struct dentry *new_dentry)
 {
 	struct inode *old_inode = old_dentry->d_inode;
@@ -2032,6 +2037,7 @@ out:
 		dput(dentry);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_rename);
 
 static DEFINE_SPINLOCK(nfs_access_lru_lock);
 static LIST_HEAD(nfs_access_lru_list);
@@ -2351,6 +2357,7 @@ out_notsup:
 		res = generic_permission(inode, mask);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_permission);
 
 /*
  * Local variables:
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c43a452..227694e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -16,6 +16,7 @@
  *  nfs regular file handling functions
  */
 
+#include <linux/module.h>
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -37,6 +38,7 @@
 #include "iostat.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
@@ -65,18 +67,19 @@ const struct inode_operations nfs3_file_inode_operations = {
 # define IS_SWAPFILE(inode)	(0)
 #endif
 
-static int nfs_check_flags(int flags)
+int nfs_check_flags(int flags)
 {
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))
 		return -EINVAL;
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_check_flags);
 
 /*
  * Open file
  */
-static int
+int
 nfs_file_open(struct inode *inode, struct file *filp)
 {
 	int res;
@@ -93,8 +96,9 @@ nfs_file_open(struct inode *inode, struct file *filp)
 	res = nfs_open(inode, filp);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_file_open);
 
-static int
+int
 nfs_file_release(struct inode *inode, struct file *filp)
 {
 	dprintk("NFS: release(%s/%s)\n",
@@ -104,6 +108,7 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return nfs_release(inode, filp);
 }
+EXPORT_SYMBOL_GPL(nfs_file_release);
 
 /**
  * nfs_revalidate_size - Revalidate the file size
@@ -136,7 +141,7 @@ force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
 
-static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
+loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 {
 	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
@@ -157,11 +162,12 @@ static loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 
 	return generic_file_llseek(filp, offset, origin);
 }
+EXPORT_SYMBOL_GPL(nfs_file_llseek);
 
 /*
  * Flush all dirty pages, and check for write errors.
  */
-static int
+int
 nfs_file_flush(struct file *file, fl_owner_t id)
 {
 	struct dentry	*dentry = file->f_path.dentry;
@@ -178,8 +184,9 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	/* Flush writes to the server and return any errors */
 	return vfs_fsync(file, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_file_flush);
 
-static ssize_t
+ssize_t
 nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 		unsigned long nr_segs, loff_t pos)
 {
@@ -202,8 +209,9 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	}
 	return result;
 }
+EXPORT_SYMBOL_GPL(nfs_file_read);
 
-static ssize_t
+ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     struct pipe_inode_info *pipe, size_t count,
 		     unsigned int flags)
@@ -224,8 +232,9 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	}
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_file_splice_read);
 
-static int
+int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -245,6 +254,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	}
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_file_mmap);
 
 /*
  * Flush any dirty pages for this process, and check for write errors.
@@ -258,7 +268,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
  * nfs_file_write() that a write error occurred, and hence cause it to
  * fall back to doing a synchronous write.
  */
-static int
+int
 nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct dentry *dentry = file->f_path.dentry;
@@ -290,6 +300,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	mutex_unlock(&inode->i_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_file_fsync);
 
 /*
  * Decide whether a read/modify/write cycle may be more efficient
@@ -563,8 +574,8 @@ static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 	return 0;
 }
 
-static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
+		       unsigned long nr_segs, loff_t pos)
 {
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
@@ -614,10 +625,11 @@ out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_file_write);
 
-static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
-				     struct file *filp, loff_t *ppos,
-				     size_t count, unsigned int flags)
+ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+			      struct file *filp, loff_t *ppos,
+			      size_t count, unsigned int flags)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -645,6 +657,7 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_file_splice_write);
 
 static int
 do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
@@ -769,7 +782,7 @@ out:
 /*
  * Lock a (portion of) a file
  */
-static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int ret = -ENOLCK;
@@ -805,11 +818,12 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 out_err:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_lock);
 
 /*
  * Lock a (portion of) a file
  */
-static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
+int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
 	int is_local = 0;
@@ -834,18 +848,20 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 		return do_unlk(filp, cmd, fl, is_local);
 	return do_setlk(filp, cmd, fl, is_local);
 }
+EXPORT_SYMBOL_GPL(nfs_flock);
 
 /*
  * There is no protocol support for leases, so we have no way to implement
  * them correctly in the face of opens by other clients.
  */
-static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
+int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 {
 	dprintk("NFS: setlease(%s/%s, arg=%ld)\n",
 			file->f_path.dentry->d_parent->d_name.name,
 			file->f_path.dentry->d_name.name, arg);
 	return -EINVAL;
 }
+EXPORT_SYMBOL_GPL(nfs_setlease);
 
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3c81a32..35db7b8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -192,6 +192,7 @@ void nfs_invalidate_atime(struct inode *inode)
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_invalidate_atime);
 
 /*
  * Invalidate, but do not unhash, the inode.
@@ -403,8 +404,7 @@ out_no_inode:
 
 #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE)
 
-int
-nfs_setattr(struct dentry *dentry, struct iattr *attr)
+int nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct nfs_fattr *fattr;
@@ -445,6 +445,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_setattr);
 
 /**
  * nfs_vmtruncate - unmap mappings "freed" by truncate() syscall
@@ -503,6 +504,7 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 		nfs_vmtruncate(inode, attr->ia_size);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
@@ -541,6 +543,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_getattr);
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -629,6 +632,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 		return;
 	nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_close_context);
 
 struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct rpc_cred *cred, fmode_t f_mode)
 {
@@ -1023,6 +1027,7 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->owner_name = NULL;
 	fattr->group_name = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_fattr_init);
 
 struct nfs_fattr *nfs_alloc_fattr(void)
 {
@@ -1033,6 +1038,7 @@ struct nfs_fattr *nfs_alloc_fattr(void)
 		nfs_fattr_init(fattr);
 	return fattr;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fattr);
 
 struct nfs_fh *nfs_alloc_fhandle(void)
 {
@@ -1043,6 +1049,7 @@ struct nfs_fh *nfs_alloc_fhandle(void)
 		fh->size = 0;
 	return fh;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_fhandle);
 
 /**
  * nfs_inode_attrs_need_update - check if the inode attributes need updating
@@ -1102,6 +1109,7 @@ int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_refresh_inode);
 
 static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
@@ -1189,6 +1197,7 @@ out_noforce:
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
 
 /*
  * Many nfs protocol calls return the new file attributes after
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 8102391..18c5e4f 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -7,6 +7,7 @@
  * NFS namespace
  */
 
+#include <linux/module.h>
 #include <linux/dcache.h>
 #include <linux/gfp.h>
 #include <linux/mount.h>
@@ -279,6 +280,7 @@ out_nofree:
 	dprintk("<-- nfs_follow_mountpoint() = %p\n", mnt);
 	return mnt;
 }
+EXPORT_SYMBOL_GPL(nfs_d_automount);
 
 const struct inode_operations nfs_mountpoint_inode_operations = {
 	.getattr	= nfs_getattr,
-- 
1.7.8.3

