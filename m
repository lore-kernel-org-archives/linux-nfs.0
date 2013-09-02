Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:37320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681Ab3IBSRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 06/17] RPCSEC_GSS: Further cleanups
Date: Mon, 2 Sep 2013 14:16:49 -0400
Message-ID: <1378145820-29990-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't pass the rpc_client as a parameter, when what we really want is
the net namespace.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 672a67f..6323803 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -77,6 +77,7 @@ struct gss_auth {
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
 	struct rpc_clnt *client;
+	struct net *net;
 	/*
 	 * There are two upcall pipes; dentry[1], named "gssd", is used
 	 * for the new text-based upcall; dentry[0] is named after the
@@ -295,7 +296,7 @@ static void put_pipe_version(struct net *net)
 static void
 gss_release_msg(struct gss_upcall_msg *gss_msg)
 {
-	struct net *net = rpc_net_ns(gss_msg->auth->client);
+	struct net *net = gss_msg->auth->net;
 	if (!atomic_dec_and_test(&gss_msg->count))
 		return;
 	put_pipe_version(net);
@@ -441,7 +442,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 }
 
 static struct gss_upcall_msg *
-gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
+gss_alloc_msg(struct gss_auth *gss_auth,
 		kuid_t uid, const char *service_name)
 {
 	struct gss_upcall_msg *gss_msg;
@@ -450,7 +451,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
 	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
 	if (gss_msg == NULL)
 		return ERR_PTR(-ENOMEM);
-	vers = get_pipe_version(rpc_net_ns(clnt));
+	vers = get_pipe_version(gss_auth->net);
 	if (vers < 0) {
 		kfree(gss_msg);
 		return ERR_PTR(vers);
@@ -472,14 +473,14 @@ gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
 }
 
 static struct gss_upcall_msg *
-gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cred *cred)
+gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 {
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
 	kuid_t uid = cred->cr_uid;
 
-	gss_new = gss_alloc_msg(gss_auth, clnt, uid, gss_cred->gc_principal);
+	gss_new = gss_alloc_msg(gss_auth, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
 		return gss_new;
 	gss_msg = gss_add_msg(gss_new);
@@ -520,7 +521,7 @@ gss_refresh_upcall(struct rpc_task *task)
 
 	dprintk("RPC: %5u %s for uid %u\n",
 		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
-	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
+	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
 		 * shouldn't normally hit this case on a refresh. */
@@ -559,7 +560,7 @@ out:
 static inline int
 gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 {
-	struct net *net = rpc_net_ns(gss_auth->client);
+	struct net *net = gss_auth->net;
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct rpc_pipe *pipe;
 	struct rpc_cred *cred = &gss_cred->gc_base;
@@ -576,7 +577,7 @@ retry:
 	timeout = 15 * HZ;
 	if (!sn->gssd_running)
 		timeout = HZ >> 2;
-	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
+	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
 				sn->pipe_version >= 0, timeout);
@@ -832,7 +833,9 @@ err_unlink_pipe_1:
 static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
 					   struct rpc_auth *auth)
 {
-	struct net *net = rpc_net_ns(clnt);
+	struct gss_auth *gss_auth = container_of(auth, struct gss_auth,
+			rpc_auth);
+	struct net *net = gss_auth->net;
 	struct super_block *sb;
 
 	sb = rpc_get_sb_net(net);
@@ -846,7 +849,9 @@ static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
 static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 					 struct rpc_auth *auth)
 {
-	struct net *net = rpc_net_ns(clnt);
+	struct gss_auth *gss_auth = container_of(auth, struct gss_auth,
+			rpc_auth);
+	struct net *net = gss_auth->net;
 	struct super_block *sb;
 	int err = 0;
 
@@ -884,11 +889,12 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 			goto err_free;
 	}
 	gss_auth->client = clnt;
+	gss_auth->net = get_net(rpc_net_ns(clnt));
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
 	if (!gss_auth->mech) {
 		dprintk("RPC:       Pseudoflavor %d not found!\n", flavor);
-		goto err_free;
+		goto err_put_net;
 	}
 	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
 	if (gss_auth->service == 0)
@@ -936,6 +942,8 @@ err_destroy_pipe_1:
 	rpc_destroy_pipe_data(gss_auth->pipe[1]);
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
+err_put_net:
+	put_net(gss_auth->net);
 err_free:
 	kfree(gss_auth->target_name);
 	kfree(gss_auth);
@@ -951,6 +959,7 @@ gss_free(struct gss_auth *gss_auth)
 	rpc_destroy_pipe_data(gss_auth->pipe[0]);
 	rpc_destroy_pipe_data(gss_auth->pipe[1]);
 	gss_mech_put(gss_auth->mech);
+	put_net(gss_auth->net);
 	kfree(gss_auth->target_name);
 
 	kfree(gss_auth);
-- 
1.8.3.1

