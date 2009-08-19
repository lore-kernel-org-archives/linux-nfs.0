From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/32] SUNRPC: Constify rpc_pipe_ops...
Date: Wed, 19 Aug 2009 19:38:30 -0400
Message-ID: <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012AbZHSXkw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:52 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNdxnC001600
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:39 -0700 (PDT)
In-Reply-To: <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c                     |    2 +-
 include/linux/sunrpc/rpc_pipe_fs.h |    5 +++--
 net/sunrpc/auth_gss/auth_gss.c     |    8 ++++----
 net/sunrpc/rpc_pipe.c              |    7 ++++---
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 86147b0..fae0d3e 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -101,7 +101,7 @@ static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 
 static unsigned int fnvhash32(const void *, size_t);
 
-static struct rpc_pipe_ops idmap_upcall_ops = {
+static const struct rpc_pipe_ops idmap_upcall_ops = {
 	.upcall		= idmap_pipe_upcall,
 	.downcall	= idmap_pipe_downcall,
 	.destroy_msg	= idmap_pipe_destroy_msg,
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index cea764c..91f5b13 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -32,8 +32,8 @@ struct rpc_inode {
 	wait_queue_head_t waitq;
 #define RPC_PIPE_WAIT_FOR_OPEN	1
 	int flags;
-	struct rpc_pipe_ops *ops;
 	struct delayed_work queue_timeout;
+	const struct rpc_pipe_ops *ops;
 };
 
 static inline struct rpc_inode *
@@ -46,7 +46,8 @@ extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 
 extern struct dentry *rpc_mkdir(char *, struct rpc_clnt *);
 extern int rpc_rmdir(struct dentry *);
-extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *, struct rpc_pipe_ops *, int flags);
+extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
+				 const struct rpc_pipe_ops *, int flags);
 extern int rpc_unlink(struct dentry *);
 extern struct vfsmount *rpc_get_mount(void);
 extern void rpc_put_mount(void);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 66d458f..23eb386 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -89,8 +89,8 @@ static struct rpc_wait_queue pipe_version_rpc_waitqueue;
 static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
 
 static void gss_free_ctx(struct gss_cl_ctx *);
-static struct rpc_pipe_ops gss_upcall_ops_v0;
-static struct rpc_pipe_ops gss_upcall_ops_v1;
+static const struct rpc_pipe_ops gss_upcall_ops_v0;
+static const struct rpc_pipe_ops gss_upcall_ops_v1;
 
 static inline struct gss_cl_ctx *
 gss_get_ctx(struct gss_cl_ctx *ctx)
@@ -1507,7 +1507,7 @@ static const struct rpc_credops gss_nullops = {
 	.crunwrap_resp	= gss_unwrap_resp,
 };
 
-static struct rpc_pipe_ops gss_upcall_ops_v0 = {
+static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
 	.upcall		= gss_pipe_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
@@ -1515,7 +1515,7 @@ static struct rpc_pipe_ops gss_upcall_ops_v0 = {
 	.release_pipe	= gss_pipe_release,
 };
 
-static struct rpc_pipe_ops gss_upcall_ops_v1 = {
+static const struct rpc_pipe_ops gss_upcall_ops_v1 = {
 	.upcall		= gss_pipe_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9ced062..f6f60f6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -125,7 +125,7 @@ static void
 rpc_close_pipes(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
-	struct rpc_pipe_ops *ops;
+	const struct rpc_pipe_ops *ops;
 	int need_release;
 
 	mutex_lock(&inode->i_mutex);
@@ -776,8 +776,9 @@ rpc_rmdir(struct dentry *dentry)
  * The @private argument passed here will be available to all these methods
  * from the file pointer, via RPC_I(file->f_dentry->d_inode)->private.
  */
-struct dentry *
-rpc_mkpipe(struct dentry *parent, const char *name, void *private, struct rpc_pipe_ops *ops, int flags)
+struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
+			  void *private, const struct rpc_pipe_ops *ops,
+			  int flags)
 {
 	struct dentry *dentry;
 	struct inode *dir, *inode;
-- 
1.6.0.4
