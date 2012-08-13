Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41701 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab2HMVVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 17:21:53 -0400
Received: by mail-yx0-f174.google.com with SMTP id l14so2487139yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 14:21:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] SUNRPC: Prepare gss_pipes_dentries_create() for sharing
 pipe data
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Aug 2012 17:21:51 -0400
Message-ID: <20120813212150.1680.96757.stgit@degas.1015granger.net>
In-Reply-To: <20120813210739.1680.53741.stgit@degas.1015granger.net>
References: <20120813210739.1680.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are about to make pipe data shareable. gss_pipes_dentries_create()
and gss_pipes_dentries_destroy() have to be more careful when dealing
with their dentry pointers.  Namely:

  1. When asked to create a dentry, don't write over possibly valid
     pointers, but instead preserve an existing dentry

  2. When unlinking a dentry, make sure the ->dentry pointer is NULL

  3. If creating a dentry fails, don't leak the ERR_PTR value, make
     sure the ->dentry pointer is NULL

2. and 3. are needed so that 1. can recognize when a new dentry
should be created.

This is clean up, mostly.  But it's necessary because unmounting a
pipe FS can cause pipe dentries, but not the pipe data, to be
released (via ->pipes_destroy).

The functions that manage pipe data for gss_create() have to be
prepared for finding an existing shared rpc_pipe_data object that
has a dentry, or doesn't, and then do the correct thing in either
case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   67 +++++++++++++++++++++++++++++-----------
 1 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 909dc0c..947ab01 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -757,42 +757,73 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	}
 }
 
+static void gss_pipe_dentry_destroy(struct rpc_pipe *pipe)
+{
+	if (pipe->dentry != NULL) {
+		rpc_unlink(pipe->dentry);
+		pipe->dentry = NULL;
+	}
+}
+
+/*
+ * Release existing pipe dentries, but leave the rpc_pipe data
+ * ready to receive fresh dentries if subsequently needed.
+ */
 static void gss_pipes_dentries_destroy(struct rpc_auth *auth)
 {
 	struct gss_auth *gss_auth;
 
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
-	if (gss_auth->pipe[0]->dentry)
-		rpc_unlink(gss_auth->pipe[0]->dentry);
-	if (gss_auth->pipe[1]->dentry)
-		rpc_unlink(gss_auth->pipe[1]->dentry);
+
+	dprintk("RPC:       %s auth=%p, clnt=%p\n",
+		__func__, auth, gss_auth->client);
+
+	gss_pipe_dentry_destroy(gss_auth->pipe[0]);
+	gss_pipe_dentry_destroy(gss_auth->pipe[1]);
 }
 
+/*
+ * On success, zero is returned and both elements of the rpc_pipe
+ * array are populated with valid dentries.  Otherwise an error value
+ * is returned, the dentries are freed, and both ->dentry pointers are
+ * set to NULL.
+ */
 static int gss_pipes_dentries_create(struct rpc_auth *auth)
 {
-	int err;
+	int err = 0;
 	struct gss_auth *gss_auth;
 	struct rpc_clnt *clnt;
 
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	clnt = gss_auth->client;
 
-	gss_auth->pipe[1]->dentry = rpc_mkpipe_dentry(clnt->cl_dentry,
-						      "gssd",
-						      clnt, gss_auth->pipe[1]);
-	if (IS_ERR(gss_auth->pipe[1]->dentry))
-		return PTR_ERR(gss_auth->pipe[1]->dentry);
-	gss_auth->pipe[0]->dentry = rpc_mkpipe_dentry(clnt->cl_dentry,
-						      gss_auth->mech->gm_name,
-						      clnt, gss_auth->pipe[0]);
-	if (IS_ERR(gss_auth->pipe[0]->dentry)) {
-		err = PTR_ERR(gss_auth->pipe[0]->dentry);
-		goto err_unlink_pipe_1;
+	if (gss_auth->pipe[1]->dentry == NULL) {
+		gss_auth->pipe[1]->dentry =
+			rpc_mkpipe_dentry(clnt->cl_dentry, "gssd", clnt,
+							gss_auth->pipe[1]);
+		if (IS_ERR(gss_auth->pipe[1]->dentry)) {
+			err = PTR_ERR(gss_auth->pipe[1]->dentry);
+			gss_auth->pipe[1]->dentry = NULL;
+			goto out_err;
+		}
 	}
+
+	if (gss_auth->pipe[0]->dentry == NULL) {
+		gss_auth->pipe[0]->dentry =
+			rpc_mkpipe_dentry(clnt->cl_dentry,
+						gss_auth->mech->gm_name,
+						clnt, gss_auth->pipe[0]);
+		if (IS_ERR(gss_auth->pipe[0]->dentry)) {
+			err = PTR_ERR(gss_auth->pipe[0]->dentry);
+			gss_auth->pipe[0]->dentry = NULL;
+			goto out_err;
+		}
+	}
+
 	return 0;
 
-err_unlink_pipe_1:
-	rpc_unlink(gss_auth->pipe[1]->dentry);
+out_err:
+	gss_pipes_dentries_destroy(auth);
 	return err;
 }
 

