Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996Ab3H0U7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:59:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 07/15] RPCSEC_GSS: Fix an Oopsable condition when creating/destroying pipefs objects
Date: Tue, 27 Aug 2013 16:58:44 -0400
Message-ID: <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an error condition occurs on rpc_pipefs creation, or the user mounts
rpc_pipefs and then unmounts it, then the dentries in struct gss_auth
need to be reset to NULL so that a second call to gss_pipes_dentries_destroy
doesn't try to free them again.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6323803..c0d36bb 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -796,10 +796,14 @@ static void gss_pipes_dentries_destroy(struct rpc_auth *auth)
 	struct gss_auth *gss_auth;
 
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
-	if (gss_auth->pipe[0]->dentry)
+	if (gss_auth->pipe[0]->dentry) {
 		rpc_unlink(gss_auth->pipe[0]->dentry);
-	if (gss_auth->pipe[1]->dentry)
+		gss_auth->pipe[0]->dentry = NULL;
+	}
+	if (gss_auth->pipe[1]->dentry) {
 		rpc_unlink(gss_auth->pipe[1]->dentry);
+		gss_auth->pipe[1]->dentry = NULL;
+	}
 }
 
 static int gss_pipes_dentries_create(struct rpc_auth *auth)
@@ -807,26 +811,30 @@ static int gss_pipes_dentries_create(struct rpc_auth *auth)
 	int err;
 	struct gss_auth *gss_auth;
 	struct rpc_clnt *clnt;
+	struct dentry *dentry;
 
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
+	dentry = rpc_mkpipe_dentry(clnt->cl_dentry, "gssd",
+			clnt, gss_auth->pipe[1]);
+	if (IS_ERR(dentry)) {
+		err = PTR_ERR(dentry);
+		goto err;
+	}
+	gss_auth->pipe[1]->dentry = dentry;
+	dentry = rpc_mkpipe_dentry(clnt->cl_dentry, gss_auth->mech->gm_name,
+			clnt, gss_auth->pipe[0]);
+	if (IS_ERR(dentry)) {
+		err = PTR_ERR(dentry);
 		goto err_unlink_pipe_1;
 	}
 	return 0;
 
 err_unlink_pipe_1:
 	rpc_unlink(gss_auth->pipe[1]->dentry);
+	gss_auth->pipe[1]->dentry = NULL;
+err:
 	return err;
 }
 
-- 
1.8.3.1

