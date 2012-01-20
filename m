Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3888 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753609Ab2ATUMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 15:12:25 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: constify rpc_clnt fields cl_server and cl_protname
Date: Fri, 20 Jan 2012 15:12:16 -0500
Message-Id: <1327090338-6496-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and get rid of the superfluous cl_inline_name.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/clnt.h |    9 ++++-----
 net/sunrpc/clnt.c           |   29 ++++++++++++-----------------
 net/sunrpc/rpcb_clnt.c      |    2 +-
 3 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9e754e3..db6970c 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -41,8 +41,8 @@ struct rpc_clnt {
 				cl_vers,	/* RPC version number */
 				cl_maxproc;	/* max procedure number */
 
-	char *			cl_server;	/* server machine name */
-	char *			cl_protname;	/* protocol name */
+	const char *		cl_server;	/* server machine name */
+	const char *		cl_protname;	/* protocol name */
 	struct rpc_auth *	cl_auth;	/* authenticator */
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
@@ -62,7 +62,6 @@ struct rpc_clnt {
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
 	struct rpc_program *	cl_program;
-	char			cl_inline_name[32];
 	char			*cl_principal;	/* target to authenticate to */
 };
 
@@ -97,7 +96,7 @@ struct rpc_procinfo {
 	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
 	u32			p_statidx;	/* Which procedure to account */
-	char *			p_name;		/* name of procedure */
+	const char *		p_name;		/* name of procedure */
 };
 
 #ifdef __KERNEL__
@@ -109,7 +108,7 @@ struct rpc_create_args {
 	size_t			addrsize;
 	struct sockaddr		*saddress;
 	const struct rpc_timeout *timeout;
-	char			*servername;
+	const char		*servername;
 	struct rpc_program	*program;
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4c68480..e9b22e8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -273,15 +273,9 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	clnt->cl_server = clnt->cl_inline_name;
-	if (len > sizeof(clnt->cl_inline_name)) {
-		char *buf = kmalloc(len, GFP_KERNEL);
-		if (buf != NULL)
-			clnt->cl_server = buf;
-		else
-			len = sizeof(clnt->cl_inline_name);
-	}
-	strlcpy(clnt->cl_server, args->servername, len);
+	clnt->cl_server = kstrdup(args->servername, GFP_KERNEL);
+	if (clnt->cl_server == NULL)
+		goto out_no_server;
 
 	clnt->cl_xprt     = xprt;
 	clnt->cl_procinfo = version->procs;
@@ -346,8 +340,8 @@ out_no_path:
 out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
-	if (clnt->cl_server != clnt->cl_inline_name)
-		kfree(clnt->cl_server);
+	kfree(clnt->cl_server);
+out_no_server:
 	kfree(clnt);
 out_err:
 	xprt_put(xprt);
@@ -470,6 +464,9 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_no_clnt;
+	new->cl_server = kstrdup(clnt->cl_server, GFP_KERNEL);
+	if (new->cl_server == NULL)
+		goto out_no_server;
 	new->cl_parent = clnt;
 	/* Turn off autobind on clones */
 	new->cl_autobind = 0;
@@ -500,6 +497,8 @@ out_no_path:
 out_no_principal:
 	rpc_free_iostats(new->cl_metrics);
 out_no_stats:
+	kfree(new->cl_server);
+out_no_server:
 	kfree(new);
 out_no_clnt:
 	dprintk("RPC:       %s: returned error %d\n", __func__, err);
@@ -565,13 +564,9 @@ rpc_free_client(struct rpc_clnt *clnt)
 {
 	dprintk("RPC:       destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
-	if (clnt->cl_parent != clnt) {
+	if (clnt->cl_parent != clnt)
 		rpc_release_client(clnt->cl_parent);
-		goto out_free;
-	}
-	if (clnt->cl_server != clnt->cl_inline_name)
-		kfree(clnt->cl_server);
-out_free:
+	kfree(clnt->cl_server);
 	rpc_unregister_client(clnt);
 	rpc_clnt_remove_pipedir(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4ce3a8e..d397801 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -343,7 +343,7 @@ out:
 	return result;
 }
 
-static struct rpc_clnt *rpcb_create(struct net *net, char *hostname,
+static struct rpc_clnt *rpcb_create(struct net *net, const char *hostname,
 				    struct sockaddr *srvaddr, size_t salen,
 				    int proto, u32 version)
 {
-- 
1.7.7.5

