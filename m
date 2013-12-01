Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59559 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab3LANUW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:22 -0500
Message-Id: <20131201132011.734298838@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:52 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 11/11] sunrpc: rpc_pipefs cleanup
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove or fold now unused pipe creation and removal functions.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    8 +---
 net/sunrpc/rpc_pipe.c              |   87 ++++++++----------------------------
 2 files changed, 19 insertions(+), 76 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index d37a1e2..bed3845 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -62,18 +62,12 @@ extern struct dentry *rpc_create_cache_dir(struct net *n, const char *,
 		const char *, umode_t umode, struct cache_detail *);
 extern void rpc_remove_cache_dir(struct dentry *);
 
-extern int rpc_rmdir(struct dentry *dentry);
-
-struct rpc_pipe *rpc_mkpipe_data(const struct rpc_pipe_ops *ops, int flags);
-void rpc_destroy_pipe_data(struct rpc_pipe *pipe);
-extern struct dentry *rpc_mkpipe_dentry(struct dentry *, const char *, void *,
-					struct rpc_pipe *);
 extern struct rpc_pipe *rpc_mkpipe(struct net *, const char *, const char *,
 	const struct rpc_pipe_ops *, void *private, int);
 extern struct rpc_pipe *rpc_mkpipe_clnt(struct rpc_clnt *, const char *,
 		const struct rpc_pipe_ops *, void *, int);
 extern void rpc_rmpipe(struct rpc_pipe *);
-extern int rpc_unlink(struct dentry *);
+
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 6bce5f6..f70eec9 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -526,42 +526,6 @@ static int __rpc_mkdir(struct inode *dir, struct dentry *dentry,
 	return 0;
 }
 
-static void
-init_pipe(struct rpc_pipe *pipe)
-{
-	pipe->nreaders = 0;
-	pipe->nwriters = 0;
-	INIT_LIST_HEAD(&pipe->in_upcall);
-	INIT_LIST_HEAD(&pipe->in_downcall);
-	INIT_LIST_HEAD(&pipe->pipe);
-	pipe->pipelen = 0;
-	INIT_DELAYED_WORK(&pipe->queue_timeout,
-			    rpc_timeout_upcall_queue);
-	pipe->ops = NULL;
-	spin_lock_init(&pipe->lock);
-	pipe->dentry = NULL;
-}
-
-void rpc_destroy_pipe_data(struct rpc_pipe *pipe)
-{
-	kfree(pipe);
-}
-EXPORT_SYMBOL_GPL(rpc_destroy_pipe_data);
-
-struct rpc_pipe *rpc_mkpipe_data(const struct rpc_pipe_ops *ops, int flags)
-{
-	struct rpc_pipe *pipe;
-
-	pipe = kzalloc(sizeof(struct rpc_pipe), GFP_KERNEL);
-	if (!pipe)
-		return ERR_PTR(-ENOMEM);
-	init_pipe(pipe);
-	pipe->ops = ops;
-	pipe->flags = flags;
-	return pipe;
-}
-EXPORT_SYMBOL_GPL(rpc_mkpipe_data);
-
 static int __rpc_mkpipe_dentry(struct inode *dir, struct dentry *dentry,
 			       umode_t mode,
 			       const struct file_operations *i_fop,
@@ -592,22 +556,6 @@ static int __rpc_rmdir(struct inode *dir, struct dentry *dentry)
 	return ret;
 }
 
-int rpc_rmdir(struct dentry *dentry)
-{
-	struct dentry *parent;
-	struct inode *dir;
-	int error;
-
-	parent = dget_parent(dentry);
-	dir = parent->d_inode;
-	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	error = __rpc_rmdir(dir, dentry);
-	mutex_unlock(&dir->i_mutex);
-	dput(parent);
-	return error;
-}
-EXPORT_SYMBOL_GPL(rpc_rmdir);
-
 static int __rpc_unlink(struct inode *dir, struct dentry *dentry)
 {
 	int ret;
@@ -812,7 +760,7 @@ static int rpc_rmdir_depopulate(struct dentry *dentry,
  * The @private argument passed here will be available to all these methods
  * from the file pointer, via RPC_I(file_inode(file))->private.
  */
-struct dentry *rpc_mkpipe_dentry(struct dentry *parent, const char *name,
+static struct dentry *rpc_mkpipe_dentry(struct dentry *parent, const char *name,
 				 void *private, struct rpc_pipe *pipe)
 {
 	struct dentry *dentry;
@@ -843,7 +791,6 @@ out_err:
 			err);
 	goto out;
 }
-EXPORT_SYMBOL_GPL(rpc_mkpipe_dentry);
 
 struct rpc_pipe *
 __rpc_mkpipe(struct dentry *dir, const char *name,
@@ -852,10 +799,21 @@ __rpc_mkpipe(struct dentry *dir, const char *name,
 	struct rpc_pipe *pipe;
 	int err = -ENOENT;
 
-	pipe = rpc_mkpipe_data(ops, flags);
-	if (IS_ERR(pipe))
-		return pipe;
+	pipe = kzalloc(sizeof(struct rpc_pipe), GFP_KERNEL);
+	if (!pipe)
+		return ERR_PTR(-ENOMEM);
+
+	pipe->nreaders = 0;
+	pipe->nwriters = 0;
+	INIT_LIST_HEAD(&pipe->in_upcall);
+	INIT_LIST_HEAD(&pipe->in_downcall);
+	INIT_LIST_HEAD(&pipe->pipe);
+	pipe->pipelen = 0;
+	INIT_DELAYED_WORK(&pipe->queue_timeout, rpc_timeout_upcall_queue);
+	spin_lock_init(&pipe->lock);
 
+	pipe->ops = ops;
+	pipe->flags = flags;
 	pipe->dentry = rpc_mkpipe_dentry(dir, name, private, pipe);
 	if (IS_ERR(pipe->dentry)) {
 		err = PTR_ERR(pipe->dentry);
@@ -863,7 +821,7 @@ __rpc_mkpipe(struct dentry *dir, const char *name,
 	}
 	return pipe;
 out_destroy_pipe:
-	rpc_destroy_pipe_data(pipe);
+	kfree(pipe);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(__rpc_mkpipe);
@@ -893,15 +851,7 @@ rpc_mkpipe_clnt(struct rpc_clnt *clnt, const char *name,
 }
 EXPORT_SYMBOL_GPL(rpc_mkpipe_clnt);
 
-/**
- * rpc_unlink - remove a pipe
- * @dentry: dentry for the pipe, as returned from rpc_mkpipe
- *
- * After this call, lookups will no longer find the pipe, and any
- * attempts to read or write using preexisting opens of the pipe will
- * return -EPIPE.
- */
-int
+static int
 rpc_unlink(struct dentry *dentry)
 {
 	struct dentry *parent;
@@ -916,13 +866,12 @@ rpc_unlink(struct dentry *dentry)
 	dput(parent);
 	return error;
 }
-EXPORT_SYMBOL_GPL(rpc_unlink);
 
 void rpc_rmpipe(struct rpc_pipe *pipe)
 {
 	if (pipe->dentry)
 		rpc_unlink(pipe->dentry);
-	rpc_destroy_pipe_data(pipe);
+	kfree(pipe);
 }
 EXPORT_SYMBOL_GPL(rpc_rmpipe);
 
-- 
1.7.10.4


