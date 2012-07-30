Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656Ab2G3UFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:35 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/10] NFS: Convert v3 into a module
Date: Mon, 30 Jul 2012 16:05:24 -0400
Message-Id: <1343678725-8659-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch exports symbols and moves over the final structures needed by
the v3 module.  In addition, I also switch over to using IS_ENABLED() to
check if CONFIG_NFS_V3 or CONFIG_NFS_V3_MODULE are set.

The module (nfs3.ko) will be created in the same directory as nfs.ko and
will be automatically loaded the first time you try to mount over NFS v3.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Kconfig     |  2 +-
 fs/nfs/Makefile    |  6 ++++--
 fs/nfs/client.c    |  5 -----
 fs/nfs/dir.c       |  1 +
 fs/nfs/direct.c    |  2 +-
 fs/nfs/inode.c     |  3 +++
 fs/nfs/internal.h  |  2 +-
 fs/nfs/nfs.h       | 14 --------------
 fs/nfs/nfs3super.c |  9 +++++++--
 fs/nfs/super.c     |  6 +++---
 fs/nfs/write.c     |  8 ++++----
 11 files changed, 25 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6764dbf..f81a729 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -40,7 +40,7 @@ config NFS_V2
 	  If unsure, say Y.
 
 config NFS_V3
-	bool "NFS client support for NFS version 3"
+	tristate "NFS client support for NFS version 3"
 	depends on NFS_FS
 	default y
 	help
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index df61db4..01846ed 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
-nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o nfs4file.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
@@ -27,6 +25,10 @@ nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 obj-$(CONFIG_NFS_V2) += nfs2.o
 nfs2-y := nfs2super.o proc.o nfs2xdr.o
 
+obj-$(CONFIG_NFS_V3) += nfs3.o
+nfs3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
+nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
+
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index fa8acf5..8687b6b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -149,10 +149,6 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 int __init nfs_register_versions(void)
 {
-	int err = init_nfs_v3();
-	if (err)
-		return err;
-
 	return init_nfs_v4();
 }
 
@@ -161,7 +157,6 @@ int __init nfs_register_versions(void)
  */
 void nfs_unregister_versions(void)
 {
-	exit_nfs_v3();
 	exit_nfs_v4();
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c382a6d..55438c9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1981,6 +1981,7 @@ void nfs_access_zap_cache(struct inode *inode)
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
 }
+EXPORT_SYMBOL_GPL(nfs_access_zap_cache);
 
 static struct nfs_access_entry *nfs_access_search_rbtree(struct inode *inode, struct rpc_cred *cred)
 {
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4825337..a947484 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -460,7 +460,7 @@ static void nfs_inode_dio_write_done(struct inode *inode)
 	inode_dio_done(inode);
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor desc;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f358b97..78dfc3e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -186,6 +186,7 @@ void nfs_zap_acl_cache(struct inode *inode)
 	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_ACL;
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_zap_acl_cache);
 
 void nfs_invalidate_atime(struct inode *inode)
 {
@@ -847,6 +848,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
+EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
@@ -1213,6 +1215,7 @@ int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	spin_unlock(&inode->i_lock);
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
 
 /**
  * nfs_post_op_update_inode_force_wcc - try to update the inode attribute cache
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4174faf..64f0dc4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -224,7 +224,7 @@ int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
 #endif
 
 /* nfs3client.c */
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
 struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
 				     struct nfs_fattr *, rpc_authflavor_t);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index f5d1cf5..3e1b84b 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -24,20 +24,6 @@ struct nfs_subversion {
 int nfs_register_versions(void);
 void nfs_unregister_versions(void);
 
-#ifdef CONFIG_NFS_V3
-int init_nfs_v3(void);
-void exit_nfs_v3(void);
-#else /* CONFIG_NFS_V3 */
-static inline int __init init_nfs_v3(void)
-{
-	return 0;
-}
-
-static inline void exit_nfs_v3(void)
-{
-}
-#endif /* CONFIG_NFS_V3 */
-
 #ifdef CONFIG_NFS_V4
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 8378090..cc471c7 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -14,13 +14,18 @@ static struct nfs_subversion nfs_v3 = {
 	.sops     = &nfs_sops,
 };
 
-int __init init_nfs_v3(void)
+static int __init init_nfs_v3(void)
 {
 	register_nfs_version(&nfs_v3);
 	return 0;
 }
 
-void exit_nfs_v3(void)
+static void __exit exit_nfs_v3(void)
 {
 	unregister_nfs_version(&nfs_v3);
 }
+
+MODULE_LICENSE("GPL");
+
+module_init(init_nfs_v3);
+module_exit(exit_nfs_v3);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 999ce75..558a85c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -69,7 +69,7 @@
 #define NFSDBG_FACILITY		NFSDBG_VFS
 #define NFS_TEXT_DATA		1
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 #define NFS_DEFAULT_VERSION 3
 #else
 #define NFS_DEFAULT_VERSION 2
@@ -1876,7 +1876,7 @@ static int nfs23_validate_mount_data(void *options,
 		return NFS_TEXT_DATA;
 	}
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 	if (args->version == 3)
 		goto out_v3_not_compiled;
 #endif /* !CONFIG_NFS_V3 */
@@ -1896,7 +1896,7 @@ out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
 	return -EINVAL;
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 out_v3_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1e8d4b0..f268fe4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -446,7 +446,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
@@ -636,7 +636,7 @@ out:
 	hdr->release(hdr);
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if  IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static unsigned long
 nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
@@ -1298,7 +1298,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1358,7 +1358,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
-- 
1.7.11.3

