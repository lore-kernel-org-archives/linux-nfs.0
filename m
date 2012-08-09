Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34705 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab2HIVb3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 17:31:29 -0400
Received: by yenl2 with SMTP id l2so1002187yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 14:31:28 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Insert a shim under gss_create()
To: linux-nfs@vger.kernel.org
Cc: skinsbursky@parallels.com
Date: Thu, 09 Aug 2012 17:31:26 -0400
Message-ID: <20120809213126.12984.25414.stgit@degas.1015granger.net>
In-Reply-To: <20120809205748.12984.88991.stgit@degas.1015granger.net>
References: <20120809205748.12984.88991.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to share rpc_pipe data between GSS-flavored rpc_auth objects.
To do this, create a shim in gss_create() and gss_free() where the
pipe data will be looked up, created, and destroyed.  The unused
arguments anticipate a per-RPC client cache of pipes.

This is a refactoring change which shouldn't have a functional
effect.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index dfe7825..2264776 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -857,6 +857,18 @@ static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 	return err;
 }
 
+static struct rpc_pipe *gss_mkpipe_data(struct rpc_clnt *clnt,
+					const struct rpc_pipe_ops *ops,
+					char *name)
+{
+	return rpc_mkpipe_data(ops, RPC_PIPE_WAIT_FOR_OPEN);
+}
+
+static void gss_destroy_pipe_data(struct rpc_clnt *clnt, struct rpc_pipe *pipe)
+{
+	rpc_destroy_pipe_data(pipe);
+}
+
 /*
  * NOTE: we have the opportunity to use different
  * parameters based on the input flavor (which must be a pseudoflavor)
@@ -899,15 +911,13 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	 * that we supported only the old pipe.  So we instead create
 	 * the new pipe first.
 	 */
-	gss_auth->pipe[1] = rpc_mkpipe_data(&gss_upcall_ops_v1,
-					    RPC_PIPE_WAIT_FOR_OPEN);
+	gss_auth->pipe[1] = gss_mkpipe_data(clnt, &gss_upcall_ops_v1, "gssd");
 	if (IS_ERR(gss_auth->pipe[1])) {
 		err = PTR_ERR(gss_auth->pipe[1]);
 		goto err_put_mech;
 	}
-
-	gss_auth->pipe[0] = rpc_mkpipe_data(&gss_upcall_ops_v0,
-					    RPC_PIPE_WAIT_FOR_OPEN);
+	gss_auth->pipe[0] = gss_mkpipe_data(clnt, &gss_upcall_ops_v0,
+						gss_auth->mech->gm_name);
 	if (IS_ERR(gss_auth->pipe[0])) {
 		err = PTR_ERR(gss_auth->pipe[0]);
 		goto err_destroy_pipe_1;
@@ -923,9 +933,9 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 err_unlink_pipes:
 	gss_pipes_dentries_destroy_net(clnt, auth);
 err_destroy_pipe_0:
-	rpc_destroy_pipe_data(gss_auth->pipe[0]);
+	gss_destroy_pipe_data(clnt, gss_auth->pipe[0]);
 err_destroy_pipe_1:
-	rpc_destroy_pipe_data(gss_auth->pipe[1]);
+	gss_destroy_pipe_data(clnt, gss_auth->pipe[1]);
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
 err_free:
@@ -939,8 +949,8 @@ static void
 gss_free(struct gss_auth *gss_auth)
 {
 	gss_pipes_dentries_destroy_net(gss_auth->client, &gss_auth->rpc_auth);
-	rpc_destroy_pipe_data(gss_auth->pipe[0]);
-	rpc_destroy_pipe_data(gss_auth->pipe[1]);
+	gss_destroy_pipe_data(gss_auth->client, gss_auth->pipe[0]);
+	gss_destroy_pipe_data(gss_auth->client, gss_auth->pipe[1]);
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);

