Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab3H0U7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:59:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 12/15] NFSv4: Convert idmapper to use the new framework for pipefs dentries
Date: Tue, 27 Aug 2013 16:58:49 -0400
Message-ID: <1377637132-53318-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-11-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c | 184 +++++++++++----------------------------------------------
 1 file changed, 34 insertions(+), 150 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 8b7e94a..567983d 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -64,6 +64,7 @@ struct idmap_legacy_upcalldata {
 };
 
 struct idmap {
+	struct rpc_pipe_dir_object idmap_pdo;
 	struct rpc_pipe		*idmap_pipe;
 	struct idmap_legacy_upcalldata *idmap_upcall_data;
 	struct mutex		idmap_mutex;
@@ -402,18 +403,23 @@ static struct key_type key_type_id_resolver_legacy = {
 	.request_key	= nfs_idmap_legacy_upcall,
 };
 
-static void __nfs_idmap_unregister(struct rpc_pipe *pipe)
+static void nfs_idmap_pipe_destroy(struct dentry *dir,
+		struct rpc_pipe_dir_object *pdo)
 {
+	struct idmap *idmap = pdo->pdo_data;
+	struct rpc_pipe *pipe = idmap->idmap_pipe;
+
 	if (pipe->dentry) {
 		rpc_unlink(pipe->dentry);
 		pipe->dentry = NULL;
 	}
 }
 
-static int __nfs_idmap_register(struct dentry *dir,
-				     struct idmap *idmap,
-				     struct rpc_pipe *pipe)
+static int nfs_idmap_pipe_create(struct dentry *dir,
+		struct rpc_pipe_dir_object *pdo)
 {
+	struct idmap *idmap = pdo->pdo_data;
+	struct rpc_pipe *pipe = idmap->idmap_pipe;
 	struct dentry *dentry;
 
 	dentry = rpc_mkpipe_dentry(dir, "idmap", idmap, pipe);
@@ -423,36 +429,10 @@ static int __nfs_idmap_register(struct dentry *dir,
 	return 0;
 }
 
-static void nfs_idmap_unregister(struct nfs_client *clp,
-				      struct rpc_pipe *pipe)
-{
-	struct net *net = clp->cl_net;
-	struct super_block *pipefs_sb;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		__nfs_idmap_unregister(pipe);
-		rpc_put_sb_net(net);
-	}
-}
-
-static int nfs_idmap_register(struct nfs_client *clp,
-				   struct idmap *idmap,
-				   struct rpc_pipe *pipe)
-{
-	struct net *net = clp->cl_net;
-	struct super_block *pipefs_sb;
-	int err = 0;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		if (clp->cl_rpcclient->cl_dentry)
-			err = __nfs_idmap_register(clp->cl_rpcclient->cl_dentry,
-						   idmap, pipe);
-		rpc_put_sb_net(net);
-	}
-	return err;
-}
+static const struct rpc_pipe_dir_object_ops nfs_idmap_pipe_dir_object_ops = {
+	.create = nfs_idmap_pipe_create,
+	.destroy = nfs_idmap_pipe_destroy,
+};
 
 int
 nfs_idmap_new(struct nfs_client *clp)
@@ -465,23 +445,31 @@ nfs_idmap_new(struct nfs_client *clp)
 	if (idmap == NULL)
 		return -ENOMEM;
 
+	rpc_init_pipe_dir_object(&idmap->idmap_pdo,
+			&nfs_idmap_pipe_dir_object_ops,
+			idmap);
+
 	pipe = rpc_mkpipe_data(&idmap_upcall_ops, 0);
 	if (IS_ERR(pipe)) {
 		error = PTR_ERR(pipe);
-		kfree(idmap);
-		return error;
-	}
-	error = nfs_idmap_register(clp, idmap, pipe);
-	if (error) {
-		rpc_destroy_pipe_data(pipe);
-		kfree(idmap);
-		return error;
+		goto err;
 	}
 	idmap->idmap_pipe = pipe;
 	mutex_init(&idmap->idmap_mutex);
 
+	error = rpc_add_pipe_dir_object(clp->cl_net,
+			&clp->cl_rpcclient->cl_pipedir_objects,
+			&idmap->idmap_pdo);
+	if (error)
+		goto err_destroy_pipe;
+
 	clp->cl_idmap = idmap;
 	return 0;
+err_destroy_pipe:
+	rpc_destroy_pipe_data(idmap->idmap_pipe);
+err:
+	kfree(idmap);
+	return error;
 }
 
 void
@@ -491,130 +479,26 @@ nfs_idmap_delete(struct nfs_client *clp)
 
 	if (!idmap)
 		return;
-	nfs_idmap_unregister(clp, idmap->idmap_pipe);
-	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	clp->cl_idmap = NULL;
+	rpc_remove_pipe_dir_object(clp->cl_net,
+			&clp->cl_rpcclient->cl_pipedir_objects,
+			&idmap->idmap_pdo);
+	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	kfree(idmap);
 }
 
-static int __rpc_pipefs_event(struct nfs_client *clp, unsigned long event,
-			      struct super_block *sb)
-{
-	int err = 0;
-
-	switch (event) {
-	case RPC_PIPEFS_MOUNT:
-		err = __nfs_idmap_register(clp->cl_rpcclient->cl_dentry,
-						clp->cl_idmap,
-						clp->cl_idmap->idmap_pipe);
-		break;
-	case RPC_PIPEFS_UMOUNT:
-		if (clp->cl_idmap->idmap_pipe) {
-			struct dentry *parent;
-
-			parent = clp->cl_idmap->idmap_pipe->dentry->d_parent;
-			__nfs_idmap_unregister(clp->cl_idmap->idmap_pipe);
-			/*
-			 * Note: This is a dirty hack. SUNRPC hook has been
-			 * called already but simple_rmdir() call for the
-			 * directory returned with error because of idmap pipe
-			 * inside. Thus now we have to remove this directory
-			 * here.
-			 */
-			if (rpc_rmdir(parent))
-				printk(KERN_ERR "NFS: %s: failed to remove "
-					"clnt dir!\n", __func__);
-		}
-		break;
-	default:
-		printk(KERN_ERR "NFS: %s: unknown event: %ld\n", __func__,
-			event);
-		return -ENOTSUPP;
-	}
-	return err;
-}
-
-static struct nfs_client *nfs_get_client_for_event(struct net *net, int event)
-{
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-	struct dentry *cl_dentry;
-	struct nfs_client *clp;
-	int err;
-
-restart:
-	spin_lock(&nn->nfs_client_lock);
-	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
-		/* Wait for initialisation to finish */
-		if (clp->cl_cons_state == NFS_CS_INITING) {
-			atomic_inc(&clp->cl_count);
-			spin_unlock(&nn->nfs_client_lock);
-			err = nfs_wait_client_init_complete(clp);
-			nfs_put_client(clp);
-			if (err)
-				return NULL;
-			goto restart;
-		}
-		/* Skip nfs_clients that failed to initialise */
-		if (clp->cl_cons_state < 0)
-			continue;
-		smp_rmb();
-		if (clp->rpc_ops != &nfs_v4_clientops)
-			continue;
-		cl_dentry = clp->cl_idmap->idmap_pipe->dentry;
-		if (((event == RPC_PIPEFS_MOUNT) && cl_dentry) ||
-		    ((event == RPC_PIPEFS_UMOUNT) && !cl_dentry))
-			continue;
-		atomic_inc(&clp->cl_count);
-		spin_unlock(&nn->nfs_client_lock);
-		return clp;
-	}
-	spin_unlock(&nn->nfs_client_lock);
-	return NULL;
-}
-
-static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
-			    void *ptr)
-{
-	struct super_block *sb = ptr;
-	struct nfs_client *clp;
-	int error = 0;
-
-	if (!try_module_get(THIS_MODULE))
-		return 0;
-
-	while ((clp = nfs_get_client_for_event(sb->s_fs_info, event))) {
-		error = __rpc_pipefs_event(clp, event, sb);
-		nfs_put_client(clp);
-		if (error)
-			break;
-	}
-	module_put(THIS_MODULE);
-	return error;
-}
-
-#define PIPEFS_NFS_PRIO		1
-
-static struct notifier_block nfs_idmap_block = {
-	.notifier_call	= rpc_pipefs_event,
-	.priority	= SUNRPC_PIPEFS_NFS_PRIO,
-};
-
 int nfs_idmap_init(void)
 {
 	int ret;
 	ret = nfs_idmap_init_keyring();
 	if (ret != 0)
 		goto out;
-	ret = rpc_pipefs_notifier_register(&nfs_idmap_block);
-	if (ret != 0)
-		nfs_idmap_quit_keyring();
 out:
 	return ret;
 }
 
 void nfs_idmap_quit(void)
 {
-	rpc_pipefs_notifier_unregister(&nfs_idmap_block);
 	nfs_idmap_quit_keyring();
 }
 
-- 
1.8.3.1

