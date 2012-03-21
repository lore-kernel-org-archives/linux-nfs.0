Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759087Ab2CUPV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:28 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 23/23] NFS: Convert v4 into a module
Date: Wed, 21 Mar 2012 11:20:53 -0400
Message-Id: <1332343253-24970-24-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch exports all the symbols needed by the v4 module in addition
to creating the module itself.

The module (nfs4.ko) will be created in the same directory as nfs.ko and
will be automatically loaded the first time you try to mount over NFS v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig       |    2 +-
 fs/nfs/Makefile      |   13 +++++++------
 fs/nfs/client.c      |   16 +++++++++++++++-
 fs/nfs/dir.c         |    4 ++++
 fs/nfs/dns_resolve.c |    3 +++
 fs/nfs/file.c        |   13 +++++++++++++
 fs/nfs/fscache.c     |    3 +++
 fs/nfs/getroot.c     |    1 +
 fs/nfs/inode.c       |   14 ++++++++------
 fs/nfs/namespace.c   |    2 ++
 fs/nfs/nfs.h         |    3 ---
 fs/nfs/nfs4super.c   |    9 +++++++--
 fs/nfs/nfs4sysctl.c  |    4 ----
 fs/nfs/pagelist.c    |    3 +++
 fs/nfs/read.c        |    2 ++
 fs/nfs/super.c       |   22 ++++++++++++++++++++++
 fs/nfs/write.c       |    4 ++++
 17 files changed, 95 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 1e11b08..dee5cf1 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -70,7 +70,7 @@ config NFS_V3_ACL
 	  If unsure, say N.
 
 config NFS_V4
-	bool "NFS client support for NFS version 4"
+	tristate "NFS client support for NFS version 4"
 	depends on NFS_FS
 	select SUNRPC_GSS
 	select KEYS
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 85aafee..3f7e686 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,12 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   nfs4super.o delegation.o idmap.o \
-			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4sysctl.o nfs4client.o \
-			   nfs4getroot.o nfs4file.o
-nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
@@ -25,6 +19,13 @@ obj-$(CONFIG_NFS_V3) += nfs3.o
 nfs3-y += nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
 
+obj-$(CONFIG_NFS_V4) += nfs4.o
+nfs4-y +=  nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o \
+	   delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
+	   nfs4namespace.o nfs4client.o nfs4getroot.o nfs4file.o
+nfs4-$(CONFIG_SYSCTL) += nfs4sysctl.o
+nfs4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 45f3a21..1aa7190 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -76,6 +76,7 @@ retry:
 		goto retry;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_get_cb_ident_idr);
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -555,6 +556,7 @@ found_client:
 	dprintk("--> nfs_get_client() = %p [share]\n", clp);
 	return clp;
 }
+EXPORT_SYMBOL_GPL(nfs_get_client);
 
 /*
  * Mark a server as ready or failed
@@ -564,6 +566,7 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 	clp->cl_cons_state = state;
 	wake_up_all(&nfs_client_active_wq);
 }
+EXPORT_SYMBOL_GPL(nfs_mark_client_ready);
 
 /*
  * With sessions, the client is not marked ready until after a
@@ -580,6 +583,7 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 		return -EPROTONOSUPPORT;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs4_check_client_ready);
 
 /*
  * Initialise the timeout values for a connection
@@ -621,6 +625,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 		BUG();
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_init_timeout_values);
 
 /*
  * Create an RPC client handle
@@ -661,6 +666,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 	clp->cl_rpcclient = clnt;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
 
 /*
  * Version 2 or 3 client destruction
@@ -747,6 +753,7 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_init_server_rpcclient);
 
 /*
  * Initialise an NFS2 or NFS3 client
@@ -972,6 +979,7 @@ out_error:
 	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_probe_fsinfo);
 
 /*
  * Copy useful information when duplicating a server record
@@ -988,6 +996,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
 	target->caps = source->caps;
 	target->options = source->options;
 }
+EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
 
 void nfs_server_insert_lists(struct nfs_server *server)
 {
@@ -1001,6 +1010,7 @@ void nfs_server_insert_lists(struct nfs_server *server)
 	spin_unlock(&nn->nfs_client_lock);
 
 }
+EXPORT_SYMBOL_GPL(nfs_server_insert_lists);
 
 static void nfs_server_remove_lists(struct nfs_server *server)
 {
@@ -1060,6 +1070,7 @@ struct nfs_server *nfs_alloc_server(void)
 
 	return server;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_server);
 
 /*
  * Free up a server record
@@ -1090,6 +1101,7 @@ void nfs_free_server(struct nfs_server *server)
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
 }
+EXPORT_SYMBOL_GPL(nfs_free_server);
 
 /*
  * Create a version 2 or 3 volume record
@@ -1178,6 +1190,7 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
 	spin_unlock(&nn->nfs_client_lock);
 	return clp;
 }
+EXPORT_SYMBOL_GPL(nfs4_find_client_ident);
 
 #if defined(CONFIG_NFS_V4_1)
 /*
@@ -1214,7 +1227,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 	spin_unlock(&nn->nfs_client_lock);
 	return NULL;
 }
-
+EXPORT_SYMBOL_GPL(nfs4_find_client_sessionid);
 #else /* CONFIG_NFS_V4_1 */
 
 struct nfs_client *
@@ -1223,6 +1236,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 {
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(nfs4_find_client_sessionid);
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 10c7275..f8914c5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -103,6 +103,7 @@ const struct inode_operations nfs4_dir_inode_operations = {
 	.listxattr	= generic_listxattr,
 	.removexattr	= generic_removexattr,
 };
+EXPORT_SYMBOL_GPL(nfs4_dir_inode_operations);
 
 #endif /* CONFIG_NFS_V4 */
 
@@ -958,6 +959,7 @@ void nfs_force_lookup_revalidate(struct inode *dir)
 {
 	NFS_I(dir)->cache_change_attribute++;
 }
+EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
 
 /*
  * A check for whether or not the parent directory has changed.
@@ -1311,6 +1313,7 @@ const struct dentry_operations nfs4_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs4_dentry_operations);
 
 /*
  * Use intent information to determine whether we need to substitute
@@ -2276,6 +2279,7 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 {
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
+EXPORT_SYMBOL_GPL(nfs_may_open);
 
 int nfs_permission(struct inode *inode, int mask)
 {
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index b3924b8..eae00d4 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -8,6 +8,7 @@
 
 #ifdef CONFIG_NFS_USE_KERNEL_DNS
 
+#include <linux/module.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/dns_resolver.h>
 #include "dns_resolve.h"
@@ -27,6 +28,7 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name, size_t namelen,
 	kfree(ip_addr);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
 #else
 
@@ -345,6 +347,7 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name,
 		ret = -ESRCH;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
 int nfs_dns_resolver_cache_init(struct net *net)
 {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d169c2b..81e84ca 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -61,6 +61,7 @@ int nfs_check_flags(int flags)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_check_flags);
 
 /*
  * Open file
@@ -93,6 +94,7 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return nfs_release(inode, filp);
 }
+EXPORT_SYMBOL_GPL(nfs_file_release);
 
 /**
  * nfs_revalidate_size - Revalidate the file size
@@ -146,6 +148,7 @@ loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 
 	return generic_file_llseek(filp, offset, origin);
 }
+EXPORT_SYMBOL_GPL(nfs_file_llseek);
 
 /*
  * Flush all dirty pages, and check for write errors.
@@ -167,6 +170,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	/* Flush writes to the server and return any errors */
 	return vfs_fsync(file, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_file_flush);
 
 ssize_t
 nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
@@ -191,6 +195,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	}
 	return result;
 }
+EXPORT_SYMBOL_GPL(nfs_file_read);
 
 ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
@@ -213,6 +218,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	}
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_file_splice_read);
 
 int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
@@ -234,6 +240,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	}
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_file_mmap);
 
 /*
  * Flush any dirty pages for this process, and check for write errors.
@@ -272,6 +279,7 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 		ret = status;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_file_fsync_commit);
 
 static int
 nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
@@ -612,6 +620,7 @@ out_swapfile:
 	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_file_write);
 
 ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 			      struct file *filp, loff_t *ppos,
@@ -643,6 +652,7 @@ ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_file_splice_write);
 
 static int
 do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
@@ -803,6 +813,7 @@ int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 out_err:
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_lock);
 
 /*
  * Lock a (portion of) a file
@@ -832,6 +843,7 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 		return do_unlk(filp, cmd, fl, is_local);
 	return do_setlk(filp, cmd, fl, is_local);
 }
+EXPORT_SYMBOL_GPL(nfs_flock);
 
 /*
  * There is no protocol support for leases, so we have no way to implement
@@ -844,6 +856,7 @@ int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 			file->f_path.dentry->d_name.name, arg);
 	return -EINVAL;
 }
+EXPORT_SYMBOL_GPL(nfs_setlease);
 
 const struct file_operations nfs_file_operations = {
 	.llseek		= nfs_file_llseek,
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index ae65c16..4947f88 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -11,6 +11,7 @@
 
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/nfs_fs.h>
@@ -163,6 +164,7 @@ non_unique:
 	printk(KERN_WARNING "NFS:"
 	       " Cache request denied due to non-unique superblock keys\n");
 }
+EXPORT_SYMBOL_GPL(nfs_fscache_get_super_cookie);
 
 /*
  * release a per-superblock cookie
@@ -185,6 +187,7 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 		nfss->fscache_key = NULL;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_fscache_release_super_cookie);
 
 /*
  * Initialise the per-inode cache cookie pointer for an NFS inode.
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index f6a14a6..0a77a74 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -65,6 +65,7 @@ int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_superblock_set_dummy_root);
 
 /*
  * get an NFS2/NFS3 root dentry from the root filehandle
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e1e0568..04820e4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -84,6 +84,7 @@ int nfs_wait_bit_killable(void *word)
 	freezable_schedule();
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
 
 /**
  * nfs_compat_user_ino64 - returns the user-visible inode number
@@ -119,6 +120,7 @@ void nfs_clear_inode(struct inode *inode)
 	nfs_access_zap_cache(inode);
 	nfs_fscache_release_inode_cookie(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
 void nfs_evict_inode(struct inode *inode)
 {
@@ -422,6 +424,7 @@ out_no_inode:
 	dprintk("nfs_fhget: iget failed with error %ld\n", PTR_ERR(inode));
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_fhget);
 
 #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE|ATTR_OPEN)
 
@@ -687,6 +690,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 		atomic_inc(&ctx->lock_context.count);
 	return ctx;
 }
+EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
@@ -713,6 +717,7 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 {
 	__put_nfs_open_context(ctx, 0);
 }
+EXPORT_SYMBOL_GPL(put_nfs_open_context);
 
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
@@ -1537,6 +1542,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_inode);
 
 static void nfs_i_callback(struct rcu_head *head)
 {
@@ -1548,6 +1554,7 @@ void nfs_destroy_inode(struct inode *inode)
 {
 	call_rcu(&inode->i_rcu, nfs_i_callback);
 }
+EXPORT_SYMBOL_GPL(nfs_destroy_inode);
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
@@ -1597,6 +1604,7 @@ static void nfs_destroy_inodecache(void)
 }
 
 struct workqueue_struct *nfsiod_workqueue;
+EXPORT_SYMBOL_GPL(nfsiod_workqueue);
 
 /*
  * start up the nfsiod workqueue
@@ -1700,9 +1708,6 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-#if IS_ENABLED(CONFIG_NFS_V4)
-	init_nfs_v4();
-#endif
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
@@ -1733,9 +1738,6 @@ out9:
 
 static void __exit exit_nfs_fs(void)
 {
-#if IS_ENABLED(CONFIG_NFS_V4)
-	exit_nfs_v4();
-#endif
 	nfs_destroy_directcache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index aa8e6db..d25c8b5 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -120,6 +120,7 @@ Elong_unlock:
 Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
+EXPORT_SYMBOL_GPL(nfs_path);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
@@ -150,6 +151,7 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 
 	return pseudoflavor;
 }
+EXPORT_SYMBOL_GPL(nfs_find_best_sec);
 
 static int nfs_negotiate_security(const struct dentry *parent,
 				  const struct dentry *dentry,
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index fe8152f..53bcf99 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -52,9 +52,6 @@ struct nfs_sb_mountdata {
 	int mntflags;
 };
 
-int init_nfs_v4(void);
-void exit_nfs_v4(void);
-
 struct nfs_subversion *get_nfs_version(unsigned int);
 struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
 struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 7b8e79b..6d0415a 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -662,7 +662,7 @@ static struct nfs_subversion nfs_v4 = {
 	.unset_layoutdriver = unset_pnfs_layoutdriver,
 };
 
-int __init init_nfs_v4(void)
+static int __init init_nfs_v4(void)
 {
 	int err;
 
@@ -689,10 +689,15 @@ out_2:
 	return err;
 }
 
-void __exit exit_nfs_v4(void)
+static void __exit exit_nfs_v4(void)
 {
 	unregister_nfs_version(&nfs_v4);
 	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v4);
+module_exit(exit_nfs_v4);
diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index 07b67bb..6ebdef7 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -4,8 +4,6 @@
  * Sysctl interface to NFS parameters
  */
 
-#ifdef CONFIG_SYSCTL
-
 #include <linux/types.h>
 #include <linux/linkage.h>
 #include <linux/ctype.h>
@@ -73,5 +71,3 @@ void nfs4_unregister_sysctl(void)
 	unregister_sysctl_table(nfs4_callback_sysctl_table);
 	nfs4_callback_sysctl_table = NULL;
 }
-
-#endif /* CONFIG_SYSCTL */
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d21fcea..0792dcf 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -219,6 +219,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init);
 
 /**
  * nfs_can_coalesce_requests - test two requests for compatibility
@@ -360,6 +361,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	} while (ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
 
 /**
  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
@@ -375,6 +377,7 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 			break;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_complete);
 
 /**
  * nfs_pageio_cond_complete - Conditional I/O completion
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 667f32e..d908b23 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -70,6 +70,7 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 	put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
+EXPORT_SYMBOL_GPL(nfs_readdata_release);
 
 static
 int nfs_return_empty_page(struct page *page)
@@ -369,6 +370,7 @@ int nfs_generic_pagein(struct nfs_pageio_descriptor *desc, struct list_head *hea
 		return nfs_pagein_multi(desc, head);
 	return nfs_pagein_one(desc, head);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pagein);
 
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b214f44..d657b51 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -356,6 +356,7 @@ void nfs_sb_active(struct super_block *sb)
 	if (atomic_inc_return(&server->active) == 1)
 		atomic_inc(&sb->s_active);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_active);
 
 void nfs_sb_deactive(struct super_block *sb)
 {
@@ -364,6 +365,7 @@ void nfs_sb_deactive(struct super_block *sb)
 	if (atomic_dec_and_test(&server->active))
 		deactivate_super(sb);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_deactive);
 
 /*
  * Deliver file system statistics to userspace
@@ -429,6 +431,7 @@ int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	dprintk("%s: statfs error = %d\n", __func__, -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_statfs);
 
 /*
  * Map the security flavour number to a name
@@ -665,6 +668,7 @@ int nfs_show_options(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_options);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
@@ -724,12 +728,14 @@ int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	free_page((unsigned long)page);
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_show_devname);
 
 int nfs_show_path(struct seq_file *m, struct dentry *dentry)
 {
 	seq_puts(m, "/");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_path);
 
 /*
  * Present statistical information for this VFS mountpoint
@@ -822,6 +828,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_stats);
 
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
@@ -841,6 +848,7 @@ void nfs_umount_begin(struct super_block *sb)
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
 }
+EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
 struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
@@ -864,6 +872,7 @@ struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 	}
 	return data;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_parsed_mount_data);
 
 void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 {
@@ -877,6 +886,7 @@ void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 		kfree(data);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_free_parsed_mount_data);
 
 /*
  * Sanity-check a server address provided by the mount command.
@@ -900,6 +910,7 @@ int nfs_verify_server_address(struct sockaddr *addr)
 	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_verify_server_address);
 
 /*
  * Select between a default port value and a user-specified port value.
@@ -929,6 +940,7 @@ void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_validate_transport_protocol);
 
 /*
  * For text based NFSv2/v3 mounts, the mount protocol transport default
@@ -1526,6 +1538,7 @@ out_security_failure:
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_parse_mount_options);
 
 /*
  * Match the requested auth flavors with the list returned by
@@ -2005,6 +2018,7 @@ out:
 	kfree(data);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_remount);
 
 /*
  * Initialise the common bits of the superblock
@@ -2027,6 +2041,7 @@ inline void nfs_initialise_sb(struct super_block *sb)
 
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
 }
+EXPORT_SYMBOL_GPL(nfs_initialise_sb);
 
 /*
  * Finish setting up an NFS2/3 superblock
@@ -2123,6 +2138,7 @@ int nfs_set_super(struct super_block *s, void *data)
 		server->s_dev = s->s_dev;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_set_super);
 
 static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
@@ -2176,6 +2192,7 @@ int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
+EXPORT_SYMBOL_GPL(nfs_compare_super);
 
 static int nfs_bdi_register(struct nfs_server *server)
 {
@@ -2190,6 +2207,7 @@ int nfs_register(struct nfs_server *server)
 		nfs_mod->reference();
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_register);
 
 void nfs_unregister(struct nfs_server *server)
 {
@@ -2197,6 +2215,7 @@ void nfs_unregister(struct nfs_server *server)
 	bdi_unregister(&server->backing_dev_info);
 	nfs_mod->unreference();
 }
+EXPORT_SYMBOL_GPL(nfs_unregister);
 
 struct dentry *_nfs_fs_mount(struct file_system_type *fs_type,
 			     struct nfs_server *server,
@@ -2317,6 +2336,7 @@ void nfs_put_super(struct super_block *s)
 {
 	nfs_unregister(NFS_SB(s));
 }
+EXPORT_SYMBOL_GPL(nfs_put_super);
 
 /*
  * Destroy an NFS2/3 superblock
@@ -2421,6 +2441,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SB(data->sb));
 	return nfs_mod->xdev_mount(flags, dev_name, data);
 }
+EXPORT_SYMBOL_GPL(nfs_xdev_mount);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 
@@ -2460,5 +2481,6 @@ int nfs4_validate_text_mount_data(void *options,
 				   &args->nfs_server.export_path,
 				   NFS4_MAXPATHLEN);
 }
+EXPORT_SYMBOL_GPL(nfs4_validate_text_mount_data);
 
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d8e9ef7..9e7cd89 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -102,6 +102,7 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 	put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
+EXPORT_SYMBOL_GPL(nfs_writedata_release);
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
@@ -1077,6 +1078,7 @@ int nfs_generic_flush(struct nfs_pageio_descriptor *desc, struct list_head *head
 		return nfs_flush_multi(desc, head);
 	return nfs_flush_one(desc, head);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_flush);
 
 static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
@@ -1623,6 +1625,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	return nfs_commit_unstable_pages(inode, wbc);
 }
+EXPORT_SYMBOL_GPL(nfs_write_inode);
 
 /*
  * flush the inode to disk.
@@ -1638,6 +1641,7 @@ int nfs_wb_all(struct inode *inode)
 
 	return sync_inode(inode, &wbc);
 }
+EXPORT_SYMBOL_GPL(nfs_wb_all);
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 {
-- 
1.7.9.4

