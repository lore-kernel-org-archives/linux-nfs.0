Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37826 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647Ab3FXHxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 03:53:03 -0400
Subject: [PATCH v3 3/4] SUNRPC: split client creation routine into setup and
	registration
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 24 Jun 2013 11:52:52 +0400
Message-ID: <20130624075252.17104.41933.stgit@localhost.localdomain>
In-Reply-To: <20130624075131.17104.55399.stgit@localhost.localdomain>
References: <20130624075131.17104.55399.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This helper moves all "registration" code to the new rpc_client_register()
helper.
This helper will be used later in the series to synchronize against PipeFS
MOUNT/UMOUNT events.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/clnt.c |   64 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 41f180c..b4f1711 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -281,14 +281,47 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
 }
 
+static int rpc_client_register(const struct rpc_create_args *args,
+			       struct rpc_clnt *clnt)
+{
+	const struct rpc_program *program = args->program;
+	struct rpc_auth *auth;
+	struct net *net = rpc_net_ns(clnt);
+	struct super_block *pipefs_sb;
+	int err = 0;
+
+	pipefs_sb = rpc_get_sb_net(net);
+	if (pipefs_sb) {
+		err = rpc_setup_pipedir(clnt, program->pipe_dir_name, pipefs_sb);
+		if (err)
+			goto out;
+	}
+
+	auth = rpcauth_create(args->authflavor, clnt);
+	if (IS_ERR(auth)) {
+		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
+				args->authflavor);
+		err = PTR_ERR(auth);
+		goto err_auth;
+	}
+
+	rpc_register_client(clnt);
+out:
+	if (pipefs_sb)
+		rpc_put_sb_net(net);
+	return err;
+
+err_auth:
+	__rpc_clnt_remove_pipedir(clnt);
+	goto out;
+}
+
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
 {
 	const struct rpc_program *program = args->program;
 	const struct rpc_version *version;
 	struct rpc_clnt		*clnt = NULL;
-	struct rpc_auth		*auth;
 	int err;
-	struct super_block *pipefs_sb;
 
 	/* sanity check the name before trying to print it */
 	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
@@ -347,34 +380,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	atomic_set(&clnt->cl_count, 1);
 
-	pipefs_sb = rpc_get_sb_net(rpc_net_ns(clnt));
-	if (pipefs_sb) {
-		err = rpc_setup_pipedir(clnt, program->pipe_dir_name, pipefs_sb);
-		if (err)
-			goto out_no_path;
-	}
-
-	auth = rpcauth_create(args->authflavor, clnt);
-	if (IS_ERR(auth)) {
-		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
-				args->authflavor);
-		err = PTR_ERR(auth);
-		goto out_no_auth;
-	}
-
 	/* save the nodename */
 	rpc_clnt_set_nodename(clnt, utsname()->nodename);
-	rpc_register_client(clnt);
-	if (pipefs_sb)
-		rpc_put_sb_net(rpc_net_ns(clnt));
+
+	err = rpc_client_register(args, clnt);
+	if (err)
+		goto out_no_path;
 	return clnt;
 
-out_no_auth:
-	if (pipefs_sb)
-		__rpc_clnt_remove_pipedir(clnt);
 out_no_path:
-	if (pipefs_sb)
-		rpc_put_sb_net(rpc_net_ns(clnt));
 	kfree(clnt->cl_principal);
 out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);

