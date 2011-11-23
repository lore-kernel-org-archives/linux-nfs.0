Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38993 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900Ab1KWKx3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 05:53:29 -0500
Subject: [PATCH 6/6] SUNRPC: remove RPC PipeFS mount point reference from RPC
	client
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Date: Wed, 23 Nov 2011 14:52:04 +0300
Message-ID: <20111123105204.11077.54113.stgit@localhost6.localdomain6>
In-Reply-To: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch. We don't need this reference anymore.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/idmap.c                 |    4 ++--
 include/linux/sunrpc/clnt.h    |    2 +-
 net/sunrpc/auth_gss/auth_gss.c |    8 ++++----
 net/sunrpc/clnt.c              |   21 ++++++++++-----------
 4 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b09a7f1..60698a1 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -370,8 +370,8 @@ nfs_idmap_new(struct nfs_client *clp)
 		return error;
 	}
 
-	if (clp->cl_rpcclient->cl_path.dentry)
-		pipe->dentry = rpc_mkpipe_dentry(clp->cl_rpcclient->cl_path.dentry,
+	if (clp->cl_rpcclient->cl_dentry)
+		pipe->dentry = rpc_mkpipe_dentry(clp->cl_rpcclient->cl_dentry,
 				"idmap", idmap, pipe);
 	if (IS_ERR(pipe->dentry)) {
 		error = PTR_ERR(pipe->dentry);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index db7bcaf..9fe39bc 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -56,7 +56,7 @@ struct rpc_clnt {
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
-	struct path		cl_path;
+	struct dentry *		cl_dentry;
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 66293dc..8673220 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -799,12 +799,12 @@ static int gss_pipes_dentries_create(struct rpc_auth *auth)
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	clnt = gss_auth->client;
 
-	gss_auth->pipe[1]->dentry = rpc_mkpipe_dentry(clnt->cl_path.dentry,
+	gss_auth->pipe[1]->dentry = rpc_mkpipe_dentry(clnt->cl_dentry,
 						      "gssd",
 						      clnt, gss_auth->pipe[1]);
 	if (IS_ERR(gss_auth->pipe[1]->dentry))
 		return PTR_ERR(gss_auth->pipe[1]->dentry);
-	gss_auth->pipe[0]->dentry = rpc_mkpipe_dentry(clnt->cl_path.dentry,
+	gss_auth->pipe[0]->dentry = rpc_mkpipe_dentry(clnt->cl_dentry,
 						      gss_auth->mech->gm_name,
 						      clnt, gss_auth->pipe[0]);
 	if (IS_ERR(gss_auth->pipe[0]->dentry)) {
@@ -826,7 +826,7 @@ static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
 
 	sb = rpc_get_sb_net(net);
 	if (sb) {
-		if (clnt->cl_path.dentry)
+		if (clnt->cl_dentry)
 			gss_pipes_dentries_destroy(auth);
 		rpc_put_sb_net(net);
 	}
@@ -841,7 +841,7 @@ static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 
 	sb = rpc_get_sb_net(net);
 	if (sb) {
-		if (clnt->cl_path.dentry)
+		if (clnt->cl_dentry)
 			err = gss_pipes_dentries_create(auth);
 		rpc_put_sb_net(net);
 	}
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index eb2595f..3971aaa 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -95,12 +95,12 @@ static void rpc_unregister_client(struct rpc_clnt *clnt)
 
 static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 {
-	if (clnt->cl_path.dentry) {
+	if (clnt->cl_dentry) {
 		if (clnt->cl_auth && clnt->cl_auth->au_ops->pipes_destroy)
 			clnt->cl_auth->au_ops->pipes_destroy(clnt->cl_auth);
-		rpc_remove_client_dir(clnt->cl_path.dentry);
+		rpc_remove_client_dir(clnt->cl_dentry);
 	}
-	clnt->cl_path.dentry = NULL;
+	clnt->cl_dentry = NULL;
 }
 
 static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
@@ -151,20 +151,19 @@ static int
 rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 {
 	struct super_block *pipefs_sb;
-	struct path path;
+	struct dentry *dentry;
 
-	clnt->cl_path.mnt = ERR_PTR(-ENOENT);
-	clnt->cl_path.dentry = NULL;
+	clnt->cl_dentry = NULL;
 	if (dir_name == NULL)
 		return 0;
 	pipefs_sb = rpc_get_sb_net(clnt->cl_xprt->xprt_net);
 	if (!pipefs_sb)
 		return 0;
-	path.dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
+	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
 	rpc_put_sb_net(clnt->cl_xprt->xprt_net);
-	if (IS_ERR(path.dentry))
-		return PTR_ERR(path.dentry);
-	clnt->cl_path = path;
+	if (IS_ERR(dentry))
+		return PTR_ERR(dentry);
+	clnt->cl_dentry = dentry;
 	return 0;
 }
 
@@ -183,7 +182,7 @@ static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
 		BUG_ON(dentry == NULL);
 		if (IS_ERR(dentry))
 			return PTR_ERR(dentry);
-		clnt->cl_path.dentry = dentry;
+		clnt->cl_dentry = dentry;
 		if (clnt->cl_auth->au_ops->pipes_create) {
 			err = clnt->cl_auth->au_ops->pipes_create(clnt->cl_auth);
 			if (err)

