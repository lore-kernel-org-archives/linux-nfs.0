Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59547 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132010.551867308@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:46 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 05/11] sunprc: add sensible pipe creation and removal helpers
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add rpc_mkpipe, rpc_mkpipe_clnt and rpc_rmpipe that allow creating
and removing pipes without having to write enormous amounts of
boilerplate code.  Use them in the trivially to convert consumers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c   |   43 +++-----------------------
 fs/nfsd/nfs4recover.c              |   60 +++++++-----------------------------
 include/linux/sunrpc/rpc_pipe_fs.h |    5 +++
 net/sunrpc/rpc_pipe.c              |   57 ++++++++++++++++++++++++++++++++++
 4 files changed, 77 insertions(+), 88 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d5950aa..c879a39 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1295,48 +1295,16 @@ static const struct rpc_pipe_ops bl_upcall_ops = {
 	.destroy_msg	= bl_pipe_destroy_msg,
 };
 
-static struct dentry *nfs4blocklayout_register_sb(struct super_block *sb,
-					    struct rpc_pipe *pipe)
-{
-	struct dentry *dir, *dentry;
-
-	dir = rpc_d_lookup_sb(sb, NFS_PIPE_DIRNAME);
-	if (dir == NULL)
-		return ERR_PTR(-ENOENT);
-	dentry = rpc_mkpipe_dentry(dir, "blocklayout", NULL, pipe);
-	dput(dir);
-	return dentry;
-}
-
-static struct dentry *nfs4blocklayout_register_net(struct net *net,
-						   struct rpc_pipe *pipe)
-{
-	struct super_block *pipefs_sb;
-	struct dentry *dentry;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (!pipefs_sb)
-		return NULL;
-	dentry = nfs4blocklayout_register_sb(pipefs_sb, pipe);
-	rpc_put_sb_net(net);
-	return dentry;
-}
-
 static int nfs4blocklayout_net_init(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct dentry *dentry;
 
 	init_waitqueue_head(&nn->bl_wq);
-	nn->bl_device_pipe = rpc_mkpipe_data(&bl_upcall_ops, 0);
+
+	nn->bl_device_pipe = rpc_mkpipe(net, NFS_PIPE_DIRNAME, "blocklayout",
+				       &bl_upcall_ops, NULL, 0);
 	if (IS_ERR(nn->bl_device_pipe))
 		return PTR_ERR(nn->bl_device_pipe);
-	dentry = nfs4blocklayout_register_net(net, nn->bl_device_pipe);
-	if (IS_ERR(dentry)) {
-		rpc_destroy_pipe_data(nn->bl_device_pipe);
-		return PTR_ERR(dentry);
-	}
-	nn->bl_device_pipe->dentry = dentry;
 	return 0;
 }
 
@@ -1344,10 +1312,7 @@ static void nfs4blocklayout_net_exit(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
-	if (nn->bl_device_pipe->dentry)
-		rpc_unlink(nn->bl_device_pipe->dentry);
-	rpc_destroy_pipe_data(nn->bl_device_pipe);
-	nn->bl_device_pipe = NULL;
+	rpc_rmpipe(nn->bl_device_pipe);
 }
 
 static struct pernet_operations nfs4blocklayout_net_ops = {
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index f4fe7d6..cda82b7 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -761,73 +761,37 @@ static const struct rpc_pipe_ops cld_upcall_ops = {
 	.destroy_msg	= cld_pipe_destroy_msg,
 };
 
-static struct dentry *
-nfsd4_cld_register_sb(struct super_block *sb, struct rpc_pipe *pipe)
-{
-	struct dentry *dir, *dentry;
-
-	dir = rpc_d_lookup_sb(sb, NFSD_PIPE_DIR);
-	if (dir == NULL)
-		return ERR_PTR(-ENOENT);
-	dentry = rpc_mkpipe_dentry(dir, NFSD_CLD_PIPE, NULL, pipe);
-	dput(dir);
-	return dentry;
-}
-
-static struct dentry *
-nfsd4_cld_register_net(struct net *net, struct rpc_pipe *pipe)
-{
-	struct super_block *sb;
-	struct dentry *dentry;
-
-	sb = rpc_get_sb_net(net);
-	if (!sb)
-		return NULL;
-	dentry = nfsd4_cld_register_sb(sb, pipe);
-	rpc_put_sb_net(net);
-	return dentry;
-}
-
 /* Initialize rpc_pipefs pipe for communication with client tracking daemon */
 static int
 nfsd4_init_cld_pipe(struct net *net)
 {
-	int ret;
-	struct dentry *dentry;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct cld_net *cn;
+	int ret = -ENOMEM;
 
 	if (nn->cld_net)
 		return 0;
 
 	cn = kzalloc(sizeof(*cn), GFP_KERNEL);
-	if (!cn) {
-		ret = -ENOMEM;
+	if (!cn)
 		goto err;
-	}
-
-	cn->cn_pipe = rpc_mkpipe_data(&cld_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(cn->cn_pipe)) {
-		ret = PTR_ERR(cn->cn_pipe);
-		goto err;
-	}
 	spin_lock_init(&cn->cn_lock);
 	INIT_LIST_HEAD(&cn->cn_list);
 
-	dentry = nfsd4_cld_register_net(net, cn->cn_pipe);
-	if (IS_ERR(dentry)) {
-		ret = PTR_ERR(dentry);
-		goto err_destroy_data;
+	cn->cn_pipe = rpc_mkpipe(net, NFSD_PIPE_DIR, NFSD_CLD_PIPE,
+					&cld_upcall_ops, NULL,
+					RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(cn->cn_pipe)) {
+		ret = PTR_ERR(cn->cn_pipe);
+		goto err_kfree;
 	}
 
-	cn->cn_pipe->dentry = dentry;
 	nn->cld_net = cn;
 	return 0;
 
-err_destroy_data:
-	rpc_destroy_pipe_data(cn->cn_pipe);
-err:
+err_kfree:
 	kfree(cn);
+err:
 	printk(KERN_ERR "NFSD: unable to create nfsdcld upcall pipe (%d)\n",
 			ret);
 	return ret;
@@ -839,9 +803,7 @@ nfsd4_remove_cld_pipe(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
-	if (cn->cn_pipe->dentry)
-		rpc_unlink(cn->cn_pipe->dentry);
-	rpc_destroy_pipe_data(cn->cn_pipe);
+	rpc_rmpipe(cn->cn_pipe);
 	kfree(nn->cld_net);
 	nn->cld_net = NULL;
 }
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index b9f3805..0e1cfb7 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -112,6 +112,11 @@ struct rpc_pipe *rpc_mkpipe_data(const struct rpc_pipe_ops *ops, int flags);
 void rpc_destroy_pipe_data(struct rpc_pipe *pipe);
 extern struct dentry *rpc_mkpipe_dentry(struct dentry *, const char *, void *,
 					struct rpc_pipe *);
+extern struct rpc_pipe *rpc_mkpipe(struct net *, const char *, const char *,
+	const struct rpc_pipe_ops *, void *private, int);
+extern struct rpc_pipe *rpc_mkpipe_clnt(struct rpc_clnt *, const char *,
+		const struct rpc_pipe_ops *, void *, int);
+extern void rpc_rmpipe(struct rpc_pipe *);
 extern int rpc_unlink(struct dentry *);
 extern int register_rpc_pipefs(void);
 extern void unregister_rpc_pipefs(void);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 73e7963..dea4008 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -831,6 +831,55 @@ out_err:
 }
 EXPORT_SYMBOL_GPL(rpc_mkpipe_dentry);
 
+struct rpc_pipe *
+__rpc_mkpipe(struct dentry *dir, const char *name,
+		const struct rpc_pipe_ops *ops, void *private, int flags)
+{
+	struct rpc_pipe *pipe;
+	int err = -ENOENT;
+
+	pipe = rpc_mkpipe_data(ops, flags);
+	if (IS_ERR(pipe))
+		return pipe;
+
+	pipe->dentry = rpc_mkpipe_dentry(dir, name, private, pipe);
+	if (IS_ERR(pipe->dentry)) {
+		err = PTR_ERR(pipe->dentry);
+		goto out_destroy_pipe;
+	}
+	return pipe;
+out_destroy_pipe:
+	rpc_destroy_pipe_data(pipe);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(__rpc_mkpipe);
+
+struct rpc_pipe *
+rpc_mkpipe(struct net *net, const char *dirname, const char *name,
+		const struct rpc_pipe_ops *ops, void *private, int flags)
+{
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	struct rpc_pipe *pipe;
+	struct dentry *dir;
+
+	dir = rpc_d_lookup_sb(sn->pipefs_sb, dirname);
+	if (dir == NULL)
+		return ERR_PTR(-ENOENT);
+	pipe = __rpc_mkpipe(dir, name, ops, private, flags);
+	dput(dir);
+	return pipe;
+}
+EXPORT_SYMBOL_GPL(rpc_mkpipe);
+
+struct rpc_pipe *
+rpc_mkpipe_clnt(struct rpc_clnt *clnt, const char *name,
+		const struct rpc_pipe_ops *ops, void *private, int flags)
+{
+	return __rpc_mkpipe(clnt->cl_pipedir_objects.pdh_dentry, name,
+			    ops, private, flags);
+}
+EXPORT_SYMBOL_GPL(rpc_mkpipe_clnt);
+
 /**
  * rpc_unlink - remove a pipe
  * @dentry: dentry for the pipe, as returned from rpc_mkpipe
@@ -856,6 +905,14 @@ rpc_unlink(struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(rpc_unlink);
 
+void rpc_rmpipe(struct rpc_pipe *pipe)
+{
+	if (pipe->dentry)
+		rpc_unlink(pipe->dentry);
+	rpc_destroy_pipe_data(pipe);
+}
+EXPORT_SYMBOL_GPL(rpc_rmpipe);
+
 /**
  * rpc_init_pipe_dir_head - initialise a struct rpc_pipe_dir_head
  * @pdh: pointer to struct rpc_pipe_dir_head
-- 
1.7.10.4


