Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59555 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132011.305242374@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:50 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 09/11] nfs: convert idmapper to rpc_mkpipe_clnt
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/idmap.c |   74 +++++++-------------------------------------------------
 1 file changed, 9 insertions(+), 65 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 567983d..91459b0 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -64,7 +64,6 @@ struct idmap_legacy_upcalldata {
 };
 
 struct idmap {
-	struct rpc_pipe_dir_object idmap_pdo;
 	struct rpc_pipe		*idmap_pipe;
 	struct idmap_legacy_upcalldata *idmap_upcall_data;
 	struct mutex		idmap_mutex;
@@ -403,73 +402,25 @@ static struct key_type key_type_id_resolver_legacy = {
 	.request_key	= nfs_idmap_legacy_upcall,
 };
 
-static void nfs_idmap_pipe_destroy(struct dentry *dir,
-		struct rpc_pipe_dir_object *pdo)
-{
-	struct idmap *idmap = pdo->pdo_data;
-	struct rpc_pipe *pipe = idmap->idmap_pipe;
-
-	if (pipe->dentry) {
-		rpc_unlink(pipe->dentry);
-		pipe->dentry = NULL;
-	}
-}
-
-static int nfs_idmap_pipe_create(struct dentry *dir,
-		struct rpc_pipe_dir_object *pdo)
-{
-	struct idmap *idmap = pdo->pdo_data;
-	struct rpc_pipe *pipe = idmap->idmap_pipe;
-	struct dentry *dentry;
-
-	dentry = rpc_mkpipe_dentry(dir, "idmap", idmap, pipe);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-	pipe->dentry = dentry;
-	return 0;
-}
-
-static const struct rpc_pipe_dir_object_ops nfs_idmap_pipe_dir_object_ops = {
-	.create = nfs_idmap_pipe_create,
-	.destroy = nfs_idmap_pipe_destroy,
-};
-
 int
 nfs_idmap_new(struct nfs_client *clp)
 {
 	struct idmap *idmap;
-	struct rpc_pipe *pipe;
-	int error;
 
 	idmap = kzalloc(sizeof(*idmap), GFP_KERNEL);
 	if (idmap == NULL)
 		return -ENOMEM;
-
-	rpc_init_pipe_dir_object(&idmap->idmap_pdo,
-			&nfs_idmap_pipe_dir_object_ops,
-			idmap);
-
-	pipe = rpc_mkpipe_data(&idmap_upcall_ops, 0);
-	if (IS_ERR(pipe)) {
-		error = PTR_ERR(pipe);
-		goto err;
-	}
-	idmap->idmap_pipe = pipe;
 	mutex_init(&idmap->idmap_mutex);
 
-	error = rpc_add_pipe_dir_object(clp->cl_net,
-			&clp->cl_rpcclient->cl_pipedir_objects,
-			&idmap->idmap_pdo);
-	if (error)
-		goto err_destroy_pipe;
+	idmap->idmap_pipe = rpc_mkpipe_clnt(clp->cl_rpcclient, "idmap",
+				&idmap_upcall_ops, idmap, 0);
+	if (IS_ERR(idmap->idmap_pipe)) {
+		kfree(idmap);
+		return PTR_ERR(idmap->idmap_pipe);
+	}
 
 	clp->cl_idmap = idmap;
 	return 0;
-err_destroy_pipe:
-	rpc_destroy_pipe_data(idmap->idmap_pipe);
-err:
-	kfree(idmap);
-	return error;
 }
 
 void
@@ -479,22 +430,15 @@ nfs_idmap_delete(struct nfs_client *clp)
 
 	if (!idmap)
 		return;
+
+	rpc_rmpipe(idmap->idmap_pipe);
 	clp->cl_idmap = NULL;
-	rpc_remove_pipe_dir_object(clp->cl_net,
-			&clp->cl_rpcclient->cl_pipedir_objects,
-			&idmap->idmap_pdo);
-	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	kfree(idmap);
 }
 
 int nfs_idmap_init(void)
 {
-	int ret;
-	ret = nfs_idmap_init_keyring();
-	if (ret != 0)
-		goto out;
-out:
-	return ret;
+	return nfs_idmap_init_keyring();
 }
 
 void nfs_idmap_quit(void)
-- 
1.7.10.4


