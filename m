Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738Ab2AMULS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:18 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 11/44] NFS: Switch to using the IS_ENABLED macro for CONFIG_NFS_V3
Date: Fri, 13 Jan 2012 15:10:20 -0500
Message-Id: <1326485453-1350-12-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Just checking if CONFIG_NFS_V3 is defined will check if v3 is built in
to the kernel.  Instead, we'll want to check if it is either built in OR
a module (CONFIG_NFS_V3_MODULE).  This macro will do both.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c        |    6 +++---
 fs/nfs/dir.c           |    2 +-
 fs/nfs/direct.c        |    2 +-
 fs/nfs/file.c          |    2 +-
 fs/nfs/super.c         |    6 +++---
 fs/nfs/write.c         |    8 ++++----
 include/linux/nfs_fs.h |    6 +++---
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 3f36e6e..20cfc99 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -123,13 +123,13 @@ struct rpc_stat nfs_rpcstat = {
  * Once everything has been converted this function will
  * be removed.
  */
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_module_null_function(void)
 {
 }
 #endif
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 static struct nfs_subversion nfs_v3_mod = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -238,7 +238,7 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  */
 void __init nfs_register_versions(void)
 {
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 	register_nfs_version(&nfs_v3_mod);
 #endif
 #ifdef CONFIG_NFS_V4
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a5e3a36..96bcfa3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -80,7 +80,7 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 const struct inode_operations nfs3_dir_inode_operations = {
 	.create		= nfs_create,
 	.lookup		= nfs_lookup,
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..7aa353c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -460,7 +460,7 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 	}
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4ac4dae..d11bb90 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -44,7 +44,7 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index aee7b00..2889a70 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -68,7 +68,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
-#ifdef CONFIG_NFS_V3
+#if IS_ENABLED(CONFIG_NFS_V3)
 #define NFS_DEFAULT_VERSION 3
 #else
 #define NFS_DEFAULT_VERSION 2
@@ -1908,7 +1908,7 @@ static int nfs_validate_mount_data(void *options,
 		}
 	}
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 	if (args->version == 3)
 		goto out_v3_not_compiled;
 #endif /* !CONFIG_NFS_V3 */
@@ -1928,7 +1928,7 @@ out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
 	return -EINVAL;
 
-#ifndef CONFIG_NFS_V3
+#if !IS_ENABLED(CONFIG_NFS_V3)
 out_v3_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0c38852..1e92376 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -431,7 +431,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
  */
@@ -516,7 +516,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 }
 #endif
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
 {
@@ -1238,7 +1238,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1297,7 +1297,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 92ecf55..666ebea 100644
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
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-- 
1.7.8.3

