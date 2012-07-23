Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33550 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab2GWPMT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jul 2012 11:12:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] NFS: Convert v4 into a module
Date: Mon, 23 Jul 2012 11:12:09 -0400
Message-Id: <1343056329-24808-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343056329-24808-1-git-send-email-bjschuma@netapp.com>
References: <1343056329-24808-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch exports symbols needed by the v4 module.  In addition, I also
switch over to using IS_ENABLED() to check if CONFIG_NFS_V4 or
CONFIG_NFS_V4_MODULE are set.

The module (nfs4.ko) will be created in the same directory as nfs.ko and
will be automatically loaded the first time you try to mount over NFS v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig            |  2 +-
 fs/nfs/Makefile           | 19 ++++++--------
 fs/nfs/callback.h         |  2 +-
 fs/nfs/client.c           | 34 +++++++++++--------------
 fs/nfs/delegation.h       |  2 +-
 fs/nfs/dir.c              |  6 ++++-
 fs/nfs/direct.c           |  2 +-
 fs/nfs/dns_resolve.c      |  4 +++
 fs/nfs/file.c             | 13 ++++++++++
 fs/nfs/inode.c            | 64 +++++++++++++++++++++++------------------------
 fs/nfs/internal.h         |  8 +++---
 fs/nfs/namespace.c        |  2 ++
 fs/nfs/netns.h            |  2 +-
 fs/nfs/nfs.h              | 17 -------------
 fs/nfs/nfs4_fs.h          |  4 +--
 fs/nfs/nfs4super.c        |  9 +++++--
 fs/nfs/pagelist.c         |  4 +++
 fs/nfs/pnfs.c             |  2 ++
 fs/nfs/read.c             |  4 +++
 fs/nfs/super.c            | 34 ++++++++++++++++++-------
 fs/nfs/write.c            | 13 +++++++---
 include/linux/nfs_fs.h    |  6 ++---
 include/linux/nfs_fs_sb.h |  6 ++---
 include/linux/nfs_idmap.h |  2 +-
 include/linux/nfs_xdr.h   |  2 +-
 25 files changed, 147 insertions(+), 116 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index f81a729..195c1ea 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -72,7 +72,7 @@ config NFS_V3_ACL
 	  If unsure, say N.
 
 config NFS_V4
-	bool "NFS client support for NFS version 4"
+	tristate "NFS client support for NFS version 4"
 	depends on NFS_FS
 	select SUNRPC_GSS
 	select KEYS
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 01846ed..8bf3a3f 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,17 +9,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   nfs4super.o nfs4file.o delegation.o idmap.o \
-			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4getroot.o nfs4client.o
-nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
-
-ifeq ($(CONFIG_SYSCTL), y)
-nfs-y += sysctl.o
-nfs-$(CONFIG_NFS_V4) += nfs4sysctl.o
-endif
-
+nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
 obj-$(CONFIG_NFS_V2) += nfs2.o
@@ -29,6 +19,13 @@ obj-$(CONFIG_NFS_V3) += nfs3.o
 nfs3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
 
+obj-$(CONFIG_NFS_V4) += nfs4.o
+nfs4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
+	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
+	  nfs4namespace.o nfs4getroot.o nfs4client.o
+nfs4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
+nfs4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index a5527c9..b44d7b1 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -192,7 +192,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_process_state *cps);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8687b6b..9fc0d9d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -143,24 +143,6 @@ void unregister_nfs_version(struct nfs_subversion *nfs)
 EXPORT_SYMBOL_GPL(unregister_nfs_version);
 
 /*
- * Preload all configured NFS versions during module init.
- * This function should be edited after each protocol is converted,
- * and eventually removed.
- */
-int __init nfs_register_versions(void)
-{
-	return init_nfs_v4();
-}
-
-/*
- * Remove each pre-loaded NFS version
- */
-void nfs_unregister_versions(void)
-{
-	exit_nfs_v4();
-}
-
-/*
  * Allocate a shared client record
  *
  * Since these are allocated/deallocated very rarely, we don't
@@ -214,7 +196,7 @@ error_0:
 }
 EXPORT_SYMBOL_GPL(nfs_alloc_client);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
@@ -390,6 +372,7 @@ int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_sockaddr_match_ipaddr);
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -456,6 +439,7 @@ int nfs_wait_client_init_complete(const struct nfs_client *clp)
 	return wait_event_killable(nfs_client_active_wq,
 			nfs_client_init_is_complete(clp));
 }
+EXPORT_SYMBOL_GPL(nfs_wait_client_init_complete);
 
 /*
  * Found an existing client.  Make sure it's ready before returning.
@@ -530,6 +514,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		cl_init->hostname ?: "", PTR_ERR(new));
 	return new;
 }
+EXPORT_SYMBOL_GPL(nfs_get_client);
 
 /*
  * Mark a server as ready or failed
@@ -540,6 +525,7 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 	clp->cl_cons_state = state;
 	wake_up_all(&nfs_client_active_wq);
 }
+EXPORT_SYMBOL_GPL(nfs_mark_client_ready);
 
 /*
  * Initialise the timeout values for a connection
@@ -581,6 +567,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 		BUG();
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_init_timeout_values);
 
 /*
  * Create an RPC client handle
@@ -620,6 +607,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 	clp->cl_rpcclient = clnt;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
 
 /*
  * Version 2 or 3 client destruction
@@ -706,6 +694,7 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_init_server_rpcclient);
 
 /**
  * nfs_init_client - Initialise an NFS2 or NFS3 client
@@ -932,6 +921,7 @@ out_error:
 	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_probe_fsinfo);
 
 /*
  * Copy useful information when duplicating a server record
@@ -948,6 +938,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
 	target->caps = source->caps;
 	target->options = source->options;
 }
+EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
 
 void nfs_server_insert_lists(struct nfs_server *server)
 {
@@ -961,6 +952,7 @@ void nfs_server_insert_lists(struct nfs_server *server)
 	spin_unlock(&nn->nfs_client_lock);
 
 }
+EXPORT_SYMBOL_GPL(nfs_server_insert_lists);
 
 static void nfs_server_remove_lists(struct nfs_server *server)
 {
@@ -1020,6 +1012,7 @@ struct nfs_server *nfs_alloc_server(void)
 
 	return server;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_server);
 
 /*
  * Free up a server record
@@ -1048,6 +1041,7 @@ void nfs_free_server(struct nfs_server *server)
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
 }
+EXPORT_SYMBOL_GPL(nfs_free_server);
 
 /*
  * Create a version 2 or 3 volume record
@@ -1193,7 +1187,7 @@ void nfs_clients_init(struct net *net)
 
 	INIT_LIST_HEAD(&nn->nfs_client_list);
 	INIT_LIST_HEAD(&nn->nfs_volume_list);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	idr_init(&nn->cb_ident_idr);
 #endif
 	spin_lock_init(&nn->nfs_client_lock);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 1f3ccd9..bbc6a4d 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -8,7 +8,7 @@
 #ifndef FS_NFS_DELEGATION_H
 #define FS_NFS_DELEGATION_H
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 /*
  * NFSv4 delegation
  */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 55438c9..627f108 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -936,6 +936,7 @@ void nfs_force_lookup_revalidate(struct inode *dir)
 {
 	NFS_I(dir)->cache_change_attribute++;
 }
+EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
 
 /*
  * A check for whether or not the parent directory has changed.
@@ -1267,7 +1268,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_lookup);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static int nfs4_lookup_revalidate(struct dentry *, unsigned int);
 
 const struct dentry_operations nfs4_dentry_operations = {
@@ -1277,6 +1278,7 @@ const struct dentry_operations nfs4_dentry_operations = {
 	.d_automount	= nfs_d_automount,
 	.d_release	= nfs_d_release,
 };
+EXPORT_SYMBOL_GPL(nfs4_dentry_operations);
 
 static fmode_t flags_to_mode(int flags)
 {
@@ -1419,6 +1421,7 @@ no_open:
 
 	return finish_no_open(file, res);
 }
+EXPORT_SYMBOL_GPL(nfs_atomic_open);
 
 static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 {
@@ -2142,6 +2145,7 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 {
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
+EXPORT_SYMBOL_GPL(nfs_may_open);
 
 int nfs_permission(struct inode *inode, int mask)
 {
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a947484..237a33d 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -460,7 +460,7 @@ static void nfs_inode_dio_write_done(struct inode *inode)
 	inode_dio_done(inode);
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor desc;
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index b3924b8..31c26c4 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -8,6 +8,7 @@
 
 #ifdef CONFIG_NFS_USE_KERNEL_DNS
 
+#include <linux/module.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/dns_resolver.h>
 #include "dns_resolve.h"
@@ -27,9 +28,11 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name, size_t namelen,
 	kfree(ip_addr);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
 #else
 
+#include <linux/module.h>
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <linux/kmod.h>
@@ -345,6 +348,7 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name,
 		ret = -ESRCH;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
 
 int nfs_dns_resolver_cache_init(struct net *net)
 {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 130a7bb..3d557057 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -53,6 +53,7 @@ int nfs_check_flags(int flags)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_check_flags);
 
 /*
  * Open file
@@ -85,6 +86,7 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return nfs_release(inode, filp);
 }
+EXPORT_SYMBOL_GPL(nfs_file_release);
 
 /**
  * nfs_revalidate_size - Revalidate the file size
@@ -138,6 +140,7 @@ loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
 
 	return generic_file_llseek(filp, offset, origin);
 }
+EXPORT_SYMBOL_GPL(nfs_file_llseek);
 
 /*
  * Flush all dirty pages, and check for write errors.
@@ -166,6 +169,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	/* Flush writes to the server and return any errors */
 	return vfs_fsync(file, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_file_flush);
 
 ssize_t
 nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
@@ -190,6 +194,7 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	}
 	return result;
 }
+EXPORT_SYMBOL_GPL(nfs_file_read);
 
 ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
@@ -212,6 +217,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	}
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_file_splice_read);
 
 int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
@@ -233,6 +239,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	}
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_file_mmap);
 
 /*
  * Flush any dirty pages for this process, and check for write errors.
@@ -271,6 +278,7 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
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
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 78dfc3e..2ed6138 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -82,6 +82,7 @@ int nfs_wait_bit_killable(void *word)
 	freezable_schedule();
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
 
 /**
  * nfs_compat_user_ino64 - returns the user-visible inode number
@@ -117,6 +118,7 @@ void nfs_clear_inode(struct inode *inode)
 	nfs_access_zap_cache(inode);
 	nfs_fscache_release_inode_cookie(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
 void nfs_evict_inode(struct inode *inode)
 {
@@ -393,6 +395,7 @@ out_no_inode:
 	dprintk("nfs_fhget: iget failed with error %ld\n", PTR_ERR(inode));
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_fhget);
 
 #define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE|ATTR_OPEN)
 
@@ -655,6 +658,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->mdsthreshold = NULL;
 	return ctx;
 }
+EXPORT_SYMBOL_GPL(alloc_nfs_open_context);
 
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
@@ -662,6 +666,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 		atomic_inc(&ctx->lock_context.count);
 	return ctx;
 }
+EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
@@ -689,6 +694,7 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 {
 	__put_nfs_open_context(ctx, 0);
 }
+EXPORT_SYMBOL_GPL(put_nfs_open_context);
 
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
@@ -704,6 +710,7 @@ void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
 	list_add(&ctx->list, &nfsi->open_files);
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_file_set_open_context);
 
 /*
  * Given an inode, search for an open context with the desired characteristics
@@ -1497,11 +1504,12 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);
 #endif
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_inode);
 
 static void nfs_i_callback(struct rcu_head *head)
 {
@@ -1513,10 +1521,11 @@ void nfs_destroy_inode(struct inode *inode)
 {
 	call_rcu(&inode->i_rcu, nfs_i_callback);
 }
+EXPORT_SYMBOL_GPL(nfs_destroy_inode);
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	INIT_LIST_HEAD(&nfsi->open_states);
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
@@ -1562,6 +1571,7 @@ static void nfs_destroy_inodecache(void)
 }
 
 struct workqueue_struct *nfsiod_workqueue;
+EXPORT_SYMBOL_GPL(nfsiod_workqueue);
 
 /*
  * start up the nfsiod workqueue
@@ -1622,90 +1632,80 @@ static int __init init_nfs_fs(void)
 
 	err = nfs_dns_resolver_init();
 	if (err < 0)
-		goto out11;
+		goto out10;;
 
 	err = register_pernet_subsys(&nfs_net_ops);
 	if (err < 0)
-		goto out10;
+		goto out9;
 
 	err = nfs_fscache_register();
 	if (err < 0)
-		goto out9;
+		goto out8;
 
 	err = nfsiod_start();
 	if (err)
-		goto out8;
+		goto out7;
 
 	err = nfs_fs_proc_init();
 	if (err)
-		goto out7;
+		goto out6;
 
 	err = nfs_init_nfspagecache();
 	if (err)
-		goto out6;
+		goto out5;
 
 	err = nfs_init_inodecache();
 	if (err)
-		goto out5;
+		goto out4;
 
 	err = nfs_init_readpagecache();
 	if (err)
-		goto out4;
+		goto out3;
 
 	err = nfs_init_writepagecache();
 	if (err)
-		goto out3;
+		goto out2;
 
 	err = nfs_init_directcache();
 	if (err)
-		goto out2;
+		goto out1;
 
 #ifdef CONFIG_PROC_FS
 	rpc_proc_register(&init_net, &nfs_rpcstat);
 #endif
-
-	err = nfs_register_versions();
-	if (err)
-		goto out1;
-
 	if ((err = register_nfs_fs()) != 0)
 		goto out0;
 
 	return 0;
 out0:
-	nfs_unregister_versions();
-out1:
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
 #endif
 	nfs_destroy_directcache();
-out2:
+out1:
 	nfs_destroy_writepagecache();
-out3:
+out2:
 	nfs_destroy_readpagecache();
-out4:
+out3:
 	nfs_destroy_inodecache();
-out5:
+out4:
 	nfs_destroy_nfspagecache();
-out6:
+out5:
 	nfs_fs_proc_exit();
-out7:
+out6:
 	nfsiod_stop();
-out8:
+out7:
 	nfs_fscache_unregister();
-out9:
+out8:
 	unregister_pernet_subsys(&nfs_net_ops);
-out10:
+out9:
 	nfs_dns_resolver_destroy();
-out11:
+out10:
 	return err;
 }
 
 static void __exit exit_nfs_fs(void)
 {
-#ifdef CONFIG_NFS_V4
-	exit_nfs_v4();
-#endif
 	nfs_destroy_directcache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 64f0dc4..8865538 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -262,7 +262,7 @@ extern int nfs3_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
 /* nfs4xdr.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs4_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 #endif
@@ -272,7 +272,7 @@ extern const u32 nfs41_maxwrite_overhead;
 #endif
 
 /* nfs4proc.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
@@ -328,7 +328,7 @@ extern int nfs_wait_bit_killable(void *word);
 extern const struct super_operations nfs_sops;
 extern struct file_system_type nfs_fs_type;
 extern struct file_system_type nfs_xdev_fs_type;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
@@ -364,7 +364,7 @@ struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
 				   const char *);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
 				    const char *);
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 2a3b170..6559253 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -113,6 +113,7 @@ Elong_unlock:
 Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
+EXPORT_SYMBOL_GPL(nfs_path);
 
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
@@ -241,6 +242,7 @@ out:
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
 }
+EXPORT_SYMBOL_GPL(nfs_do_submount);
 
 struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 			      struct nfs_fh *fh, struct nfs_fattr *fattr)
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index 8a6394e..0539de1 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -20,7 +20,7 @@ struct nfs_net {
 	wait_queue_head_t bl_wq;
 	struct list_head nfs_client_list;
 	struct list_head nfs_volume_list;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
 #endif
 	spinlock_t nfs_client_lock;
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 3e1b84b..43679df 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -21,23 +21,6 @@ struct nfs_subversion {
 	struct list_head list;		/* List of NFS versions */
 };
 
-int nfs_register_versions(void);
-void nfs_unregister_versions(void);
-
-#ifdef CONFIG_NFS_V4
-int init_nfs_v4(void);
-void exit_nfs_v4(void);
-#else /* CONFIG_NFS_V4 */
-static inline int __init init_nfs_v4(void)
-{
-	return 0;
-}
-
-static inline void exit_nfs_v4(void)
-{
-}
-#endif /* CONFIG_NFS_V4 */
-
 struct nfs_subversion *get_nfs_version(unsigned int);
 void put_nfs_version(struct nfs_subversion *);
 void register_nfs_version(struct nfs_subversion *);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af8712d..9b35609 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -9,7 +9,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 struct idmap;
 
@@ -365,8 +365,6 @@ extern const nfs4_stateid zero_stateid;
 struct nfs_mount_info;
 extern struct nfs_subversion nfs_v4;
 struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *, struct nfs_subversion *);
-int init_nfs_v4(void);
-void exit_nfs_v4(void);
 
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 1c825f3..12a31a9 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -332,7 +332,7 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 }
 
 
-int __init init_nfs_v4(void)
+static int __init init_nfs_v4(void)
 {
 	int err;
 
@@ -358,10 +358,15 @@ out:
 	return err;
 }
 
-void exit_nfs_v4(void)
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
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aed913c..1e7d887 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -54,6 +54,7 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	if (hdr->completion_ops->init_hdr)
 		hdr->completion_ops->init_hdr(hdr);
 }
+EXPORT_SYMBOL_GPL(nfs_pgheader_init);
 
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos)
 {
@@ -268,6 +269,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_lseg = NULL;
 	desc->pg_dreq = NULL;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init);
 
 /**
  * nfs_can_coalesce_requests - test two requests for compatibility
@@ -409,6 +411,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	} while (ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
 
 /**
  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
@@ -424,6 +427,7 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 			break;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_complete);
 
 /**
  * nfs_pageio_cond_complete - Conditional I/O completion
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7fbd25a..76875bf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1407,6 +1407,7 @@ static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 	put_lseg(hdr->lseg);
 	nfs_writehdr_free(hdr);
 }
+EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
 
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
@@ -1561,6 +1562,7 @@ static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 	put_lseg(hdr->lseg);
 	nfs_readhdr_free(hdr);
 }
+EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
 
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b000e4c..6935e40 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -48,6 +48,7 @@ struct nfs_read_header *nfs_readhdr_alloc(void)
 	}
 	return rhdr;
 }
+EXPORT_SYMBOL_GPL(nfs_readhdr_alloc);
 
 static struct nfs_read_data *nfs_readdata_alloc(struct nfs_pgio_header *hdr,
 						unsigned int pagecount)
@@ -80,6 +81,7 @@ void nfs_readhdr_free(struct nfs_pgio_header *hdr)
 
 	kmem_cache_free(nfs_rdata_cachep, rhdr);
 }
+EXPORT_SYMBOL_GPL(nfs_readhdr_free);
 
 void nfs_readdata_release(struct nfs_read_data *rdata)
 {
@@ -96,6 +98,7 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 }
+EXPORT_SYMBOL_GPL(nfs_readdata_release);
 
 static
 int nfs_return_empty_page(struct page *page)
@@ -398,6 +401,7 @@ int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 		return nfs_pagein_multi(desc, hdr);
 	return nfs_pagein_one(desc, hdr);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pagein);
 
 static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b94984d..96c91a0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -315,7 +315,7 @@ const struct super_operations nfs_sops = {
 };
 EXPORT_SYMBOL_GPL(nfs_sops);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *);
 static int nfs4_validate_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
@@ -366,6 +366,7 @@ void nfs_sb_active(struct super_block *sb)
 	if (atomic_inc_return(&server->active) == 1)
 		atomic_inc(&sb->s_active);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_active);
 
 void nfs_sb_deactive(struct super_block *sb)
 {
@@ -374,6 +375,7 @@ void nfs_sb_deactive(struct super_block *sb)
 	if (atomic_dec_and_test(&server->active))
 		deactivate_super(sb);
 }
+EXPORT_SYMBOL_GPL(nfs_sb_deactive);
 
 /*
  * Deliver file system statistics to userspace
@@ -439,6 +441,7 @@ int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	dprintk("%s: statfs error = %d\n", __func__, -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_statfs);
 
 /*
  * Map the security flavour number to a name
@@ -544,7 +547,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	nfs_show_mountd_netid(m, nfss, showdefaults);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 				    int showdefaults)
 {
@@ -675,8 +678,9 @@ int nfs_show_options(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_options);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_sessions(struct seq_file *m, struct nfs_server *server)
 {
@@ -709,7 +713,7 @@ static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 	}
 }
 #else
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
 }
@@ -734,12 +738,14 @@ int nfs_show_devname(struct seq_file *m, struct dentry *root)
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
@@ -774,7 +780,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 	seq_printf(m, ",bsize=%u", nfss->bsize);
 	seq_printf(m, ",namlen=%u", nfss->namelen);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	if (nfss->nfs_client->rpc_ops->version == 4) {
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
@@ -832,6 +838,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_stats);
 
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
@@ -851,6 +858,7 @@ void nfs_umount_begin(struct super_block *sb)
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
 }
+EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
 static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 {
@@ -1915,7 +1923,7 @@ out_invalid_fh:
 	return -EINVAL;
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_validate_mount_data(struct file_system_type *fs_type,
 				   void *options,
 				   struct nfs_parsed_mount_data *args,
@@ -1953,7 +1961,7 @@ static int nfs_validate_text_mount_data(void *options,
 		goto out_no_address;
 
 	if (args->version == 4) {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 		port = NFS_PORT;
 		max_namelen = NFS4_MAXNAMLEN;
 		max_pathlen = NFS4_MAXPATHLEN;
@@ -1976,7 +1984,7 @@ static int nfs_validate_text_mount_data(void *options,
 				   &args->nfs_server.export_path,
 				   max_pathlen);
 
-#ifndef CONFIG_NFS_V4
+#if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
@@ -2075,6 +2083,7 @@ out:
 	kfree(data);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_remount);
 
 /*
  * Initialise the common bits of the superblock
@@ -2123,6 +2132,7 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 
  	nfs_initialise_sb(sb);
 }
+EXPORT_SYMBOL_GPL(nfs_fill_super);
 
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
@@ -2292,6 +2302,7 @@ int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
 {
 	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
 }
+EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
 int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 			  struct nfs_mount_info *mount_info)
@@ -2302,6 +2313,7 @@ int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 		return -ESTALE;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
 struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 				   int flags, const char *dev_name,
@@ -2375,6 +2387,7 @@ error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
 
 struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
@@ -2415,6 +2428,7 @@ out:
 	nfs_free_fhandle(mount_info.mntfh);
 	return mntroot;
 }
+EXPORT_SYMBOL_GPL(nfs_fs_mount);
 
 /*
  * Ensure that we unregister the bdi before kill_anon_super
@@ -2426,6 +2440,7 @@ void nfs_put_super(struct super_block *s)
 
 	bdi_unregister(&server->backing_dev_info);
 }
+EXPORT_SYMBOL_GPL(nfs_put_super);
 
 /*
  * Destroy an NFS2/3 superblock
@@ -2438,6 +2453,7 @@ void nfs_kill_super(struct super_block *s)
 	nfs_fscache_release_super_cookie(s);
 	nfs_free_server(server);
 }
+EXPORT_SYMBOL_GPL(nfs_kill_super);
 
 /*
  * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
@@ -2478,7 +2494,7 @@ out_err:
 	goto out;
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f268fe4..e4a2ad2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -84,6 +84,7 @@ struct nfs_write_header *nfs_writehdr_alloc(void)
 	}
 	return p;
 }
+EXPORT_SYMBOL_GPL(nfs_writehdr_alloc);
 
 static struct nfs_write_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
 						  unsigned int pagecount)
@@ -115,6 +116,7 @@ void nfs_writehdr_free(struct nfs_pgio_header *hdr)
 	struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
 	mempool_free(whdr, nfs_wdata_mempool);
 }
+EXPORT_SYMBOL_GPL(nfs_writehdr_free);
 
 void nfs_writedata_release(struct nfs_write_data *wdata)
 {
@@ -131,6 +133,7 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 }
+EXPORT_SYMBOL_GPL(nfs_writedata_release);
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
@@ -446,7 +449,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
@@ -636,7 +639,7 @@ out:
 	hdr->release(hdr);
 }
 
-#if  IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if  IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static unsigned long
 nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
@@ -1173,6 +1176,7 @@ int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 		return nfs_flush_multi(desc, hdr);
 	return nfs_flush_one(desc, hdr);
 }
+EXPORT_SYMBOL_GPL(nfs_generic_flush);
 
 static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
@@ -1298,7 +1302,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1358,7 +1362,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
@@ -1674,6 +1678,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	return nfs_commit_unstable_pages(inode, wbc);
 }
+EXPORT_SYMBOL_GPL(nfs_write_inode);
 
 /*
  * flush the inode to disk.
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4b6043c..2889877 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,7 +191,7 @@ struct nfs_inode {
 	struct hlist_head	silly_list;
 	wait_queue_head_t	waitqueue;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
 	struct list_head	open_states;
@@ -428,7 +428,7 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
  * linux/fs/nfs/file.c
  */
 extern const struct file_operations nfs_file_operations;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern const struct file_operations nfs4_file_operations;
 #endif /* CONFIG_NFS_V4 */
 extern const struct address_space_operations nfs_file_aops;
@@ -538,7 +538,7 @@ extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_commit_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_commit_data *data);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6039297..310c63c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -53,7 +53,7 @@ struct nfs_client {
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
@@ -138,7 +138,7 @@ struct nfs_server {
 #endif
 
 	u32			pnfs_blksize;	/* layout_blksize attr */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
@@ -201,7 +201,7 @@ struct nfs_server {
 #define NFS4_MAX_SLOT_TABLE (256U)
 #define NFS4_NO_SLOT ((u32)-1)
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 /* Sessions */
 #define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 7eed201..ece91c5 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -69,7 +69,7 @@ struct nfs_server;
 struct nfs_fattr;
 struct nfs4_string;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 int nfs_idmap_init(void);
 void nfs_idmap_quit(void);
 #else
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6311820..00485e0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -824,7 +824,7 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 typedef u64 clientid4;
 
-- 
1.7.11.2

