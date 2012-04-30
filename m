Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44256 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab2D3QN6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 12:13:58 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] SUNRPC: RPC client must use the current utsname hostname string
Date: Mon, 30 Apr 2012 12:13:47 -0400
Message-Id: <1335802428-8132-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the rpc client is namespace aware, it needs to use the
utsname of the process that created it instead of using the
init_utsname. Both rpc_new_client and rpc_clone_client need to
be fixed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/clnt.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d127bd7..adf2990 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -279,6 +279,14 @@ void rpc_clients_notifier_unregister(void)
 	return rpc_pipefs_notifier_unregister(&rpc_clients_block);
 }
 
+static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
+{
+	clnt->cl_nodelen = strlen(nodename);
+	if (clnt->cl_nodelen > UNX_MAXNODENAME)
+		clnt->cl_nodelen = UNX_MAXNODENAME;
+	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
+}
+
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
 {
 	const struct rpc_program *program = args->program;
@@ -359,10 +367,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	}
 
 	/* save the nodename */
-	clnt->cl_nodelen = strlen(init_utsname()->nodename);
-	if (clnt->cl_nodelen > UNX_MAXNODENAME)
-		clnt->cl_nodelen = UNX_MAXNODENAME;
-	memcpy(clnt->cl_nodename, init_utsname()->nodename, clnt->cl_nodelen);
+	rpc_clnt_set_nodename(clnt, utsname()->nodename);
 	rpc_register_client(clnt);
 	return clnt;
 
@@ -521,6 +526,7 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
 	if (err != 0)
 		goto out_no_path;
+	rpc_clnt_set_nodename(new, utsname()->nodename);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
 	atomic_inc(&clnt->cl_count);
-- 
1.7.7.6

