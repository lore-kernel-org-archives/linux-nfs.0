Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59549 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770Ab3LANUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 08:20:21 -0500
Message-Id: <20131201132010.737752728@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 05:14:47 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org
Subject: [PATCH 06/11] sunrpc: clean up rpc_pipefs client dir creation
References: <20131201131441.790963326@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove redundant wrappers, take it out of clnt.c and into rpc_pipe.c.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +-
 net/sunrpc/clnt.c                  |   78 +++---------------------------------
 net/sunrpc/rpc_pipe.c              |   54 +++++++++++++++++--------
 3 files changed, 44 insertions(+), 90 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 0e1cfb7..fefbfa3 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -79,7 +79,7 @@ extern ssize_t rpc_pipe_generic_upcall(struct file *, struct rpc_pipe_msg *,
 extern int rpc_queue_upcall(struct rpc_pipe *, struct rpc_pipe_msg *);
 
 struct rpc_clnt;
-extern struct dentry *rpc_create_client_dir(struct dentry *, const char *, struct rpc_clnt *);
+extern int rpc_create_client_dir(struct rpc_clnt *);
 extern int rpc_remove_client_dir(struct rpc_clnt *);
 
 extern void rpc_init_pipe_dir_head(struct rpc_pipe_dir_head *pdh);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ec059c2..ae57193 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -100,66 +100,6 @@ static void rpc_unregister_client(struct rpc_clnt *clnt)
 	spin_unlock(&sn->rpc_client_lock);
 }
 
-static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
-{
-	rpc_remove_client_dir(clnt);
-}
-
-static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
-{
-	struct net *net = rpc_net_ns(clnt);
-	struct super_block *pipefs_sb;
-
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		__rpc_clnt_remove_pipedir(clnt);
-		rpc_put_sb_net(net);
-	}
-}
-
-static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
-				    struct rpc_clnt *clnt)
-{
-	static uint32_t clntid;
-	const char *dir_name = clnt->cl_program->pipe_dir_name;
-	char name[15];
-	struct dentry *dir, *dentry;
-
-	dir = rpc_d_lookup_sb(sb, dir_name);
-	if (dir == NULL) {
-		pr_info("RPC: pipefs directory doesn't exist: %s\n", dir_name);
-		return dir;
-	}
-	for (;;) {
-		snprintf(name, sizeof(name), "clnt%x", (unsigned int)clntid++);
-		name[sizeof(name) - 1] = '\0';
-		dentry = rpc_create_client_dir(dir, name, clnt);
-		if (!IS_ERR(dentry))
-			break;
-		if (dentry == ERR_PTR(-EEXIST))
-			continue;
-		printk(KERN_INFO "RPC: Couldn't create pipefs entry"
-				" %s/%s, error %ld\n",
-				dir_name, name, PTR_ERR(dentry));
-		break;
-	}
-	dput(dir);
-	return dentry;
-}
-
-static int
-rpc_setup_pipedir(struct super_block *pipefs_sb, struct rpc_clnt *clnt)
-{
-	struct dentry *dentry;
-
-	if (clnt->cl_program->pipe_dir_name != NULL) {
-		dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt);
-		if (IS_ERR(dentry))
-			return PTR_ERR(dentry);
-	}
-	return 0;
-}
-
 static struct rpc_xprt *rpc_clnt_set_transport(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt,
 		const struct rpc_timeout *timeout)
@@ -197,20 +137,15 @@ static int rpc_client_register(struct rpc_clnt *clnt,
 		.target_name = client_name,
 	};
 	struct rpc_auth *auth;
-	struct net *net = rpc_net_ns(clnt);
-	struct super_block *pipefs_sb;
 	int err;
 
-	pipefs_sb = rpc_get_sb_net(net);
-	if (pipefs_sb) {
-		err = rpc_setup_pipedir(pipefs_sb, clnt);
+	if (clnt->cl_program->pipe_dir_name) {
+		err = rpc_create_client_dir(clnt);
 		if (err)
 			goto out;
 	}
 
 	rpc_register_client(clnt);
-	if (pipefs_sb)
-		rpc_put_sb_net(net);
 
 	auth = rpcauth_create(&auth_args, clnt);
 	if (IS_ERR(auth)) {
@@ -221,12 +156,9 @@ static int rpc_client_register(struct rpc_clnt *clnt,
 	}
 	return 0;
 err_auth:
-	pipefs_sb = rpc_get_sb_net(net);
 	rpc_unregister_client(clnt);
-	__rpc_clnt_remove_pipedir(clnt);
+	rpc_remove_client_dir(clnt);
 out:
-	if (pipefs_sb)
-		rpc_put_sb_net(net);
 	return err;
 }
 
@@ -554,7 +486,7 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 	old = rpc_clnt_set_transport(clnt, xprt, timeout);
 
 	rpc_unregister_client(clnt);
-	__rpc_clnt_remove_pipedir(clnt);
+	rpc_remove_client_dir(clnt);
 
 	/*
 	 * A new transport was created.  "clnt" therefore
@@ -656,7 +588,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		parent = clnt->cl_parent;
-	rpc_clnt_remove_pipedir(clnt);
+	rpc_remove_client_dir(clnt);
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
 	clnt->cl_metrics = NULL;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index dea4008..751aba5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1093,27 +1093,49 @@ static void rpc_clntdir_depopulate(struct dentry *dentry)
 
 /**
  * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
- * @dentry: the parent of new directory
- * @name: the name of new directory
- * @rpc_client: rpc client to associate with this directory
+ * @clnt: rpc client to associate with this directory
  *
- * This creates a directory at the given @path associated with
- * @rpc_clnt, which will contain a file named "info" with some basic
- * information about the client, together with any "pipes" that may
- * later be created using rpc_mkpipe().
+ * This creates a directory associated with @clnt, which will contain a file
+ * named "info" with some basic information about the client, together with
+ * any "pipes" that may later be created using rpc_mkpipe().
  */
-struct dentry *rpc_create_client_dir(struct dentry *dentry,
-				   const char *name,
-				   struct rpc_clnt *rpc_client)
+int rpc_create_client_dir(struct rpc_clnt *clnt)
 {
-	struct dentry *ret;
+	static uint32_t clntid;
+	struct net *net = rpc_net_ns(clnt);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+	const char *dir_name = clnt->cl_program->pipe_dir_name;
+	struct dentry *dir, *dentry;
+	char name[15];
+	int ret = 0;
 
-	ret = rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, NULL,
-			rpc_clntdir_populate, rpc_client);
-	if (!IS_ERR(ret)) {
-		rpc_client->cl_pipedir_objects.pdh_dentry = ret;
-		rpc_create_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
+	dir = rpc_d_lookup_sb(sn->pipefs_sb, dir_name);
+	if (dir == NULL) {
+		pr_info("RPC: pipefs directory doesn't exist: %s\n", dir_name);
+		return -ENOENT;
+	}
+
+retry:
+	snprintf(name, sizeof(name), "clnt%x", (unsigned int)clntid++);
+	name[sizeof(name) - 1] = '\0';
+
+	dentry = rpc_mkdir_populate(dir, name, S_IRUGO | S_IXUGO, NULL,
+			rpc_clntdir_populate, clnt);
+	if (IS_ERR(dentry)) {
+		if (dentry == ERR_PTR(-EEXIST))
+			goto retry;
+		printk(KERN_INFO "RPC: Couldn't create pipefs entry"
+				" %s/%s, error %ld\n",
+				dir_name, name, PTR_ERR(dentry));
+		ret = PTR_ERR(dentry);
+		goto out;
 	}
+
+	clnt->cl_pipedir_objects.pdh_dentry = dentry;
+	rpc_create_pipe_dir_objects(&clnt->cl_pipedir_objects);
+
+out:
+	dput(dir);
 	return ret;
 }
 
-- 
1.7.10.4


