Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:39220 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050Ab3FKOjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 10:39:24 -0400
Subject: [PATCH v2 1/4] SUNRPC: split client creation routine into setup and
	registration
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Tue, 11 Jun 2013 18:39:10 +0400
Message-ID: <20130611143910.16046.83919.stgit@localhost.localdomain>
In-Reply-To: <20130611143725.16046.17279.stgit@localhost.localdomain>
References: <20130611143725.16046.17279.stgit@localhost.localdomain>
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
 net/sunrpc/clnt.c |   48 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5a750b9..4bf2409 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -289,12 +289,39 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
 }
 
+static int rpc_client_register(const struct rpc_create_args *args,
+			       struct rpc_clnt *clnt)
+{
+	const struct rpc_program *program = args->program;
+	struct rpc_auth *auth;
+	int err = 0;
+
+	err = rpc_setup_pipedir(clnt, program->pipe_dir_name);
+	if (err < 0)
+		goto out;
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
+	return err;
+
+err_auth:
+	rpc_clnt_remove_pipedir(clnt);
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
 
 	/* sanity check the name before trying to print it */
@@ -354,25 +381,14 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	atomic_set(&clnt->cl_count, 1);
 
-	err = rpc_setup_pipedir(clnt, program->pipe_dir_name);
-	if (err < 0)
-		goto out_no_path;
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
+
+	err = rpc_client_register(args, clnt);
+	if (err)
+		goto out_no_path;
 	return clnt;
 
-out_no_auth:
-	rpc_clnt_remove_pipedir(clnt);
 out_no_path:
 	kfree(clnt->cl_principal);
 out_no_principal:

