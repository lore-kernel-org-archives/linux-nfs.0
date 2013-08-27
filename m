Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099Ab3H0U67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:58:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>,
        Trond Myklebust <netapp.com.Trond.Myklebust@netapp.com>
Subject: [PATCH 04/15] RPCSEC_GSS: Clean up upcall message allocation
Date: Tue, 27 Aug 2013 16:58:41 -0400
Message-ID: <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Optimise away gss_encode_msg: we don't need to look up the pipe
version a second time.

Save the gss target name in struct gss_auth. It is a property of the
auth cache itself, and doesn't really belong in the rpc_client.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com.
---
 net/sunrpc/auth_gss/auth_gss.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index fc2f78d..b62812a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -84,6 +84,7 @@ struct gss_auth {
 	 * backwards-compatibility with older gssd's.
 	 */
 	struct rpc_pipe *pipe[2];
+	const char *target_name;
 };
 
 /* pipe_version >= 0 if and only if someone has a pipe open. */
@@ -406,8 +407,8 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt,
-				const char *service_name)
+				const char *service_name,
+				const char *target_name)
 {
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
@@ -417,8 +418,8 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				   mech->gm_name,
 				   from_kuid(&init_user_ns, gss_msg->uid));
 	p += gss_msg->msg.len;
-	if (clnt->cl_principal) {
-		len = sprintf(p, "target=%s ", clnt->cl_principal);
+	if (target_name) {
+		len = sprintf(p, "target=%s ", target_name);
 		p += len;
 		gss_msg->msg.len += len;
 	}
@@ -439,19 +440,6 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
 }
 
-static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
-				struct rpc_clnt *clnt,
-				const char *service_name)
-{
-	struct net *net = rpc_net_ns(clnt);
-	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
-
-	if (sn->pipe_version == 0)
-		gss_encode_v0_msg(gss_msg);
-	else /* pipe_version == 1 */
-		gss_encode_v1_msg(gss_msg, clnt, service_name);
-}
-
 static struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
 		kuid_t uid, const char *service_name)
@@ -474,7 +462,12 @@ gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
 	atomic_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
-	gss_encode_msg(gss_msg, clnt, service_name);
+	switch (vers) {
+	case 0:
+		gss_encode_v0_msg(gss_msg);
+	default:
+		gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
+	};
 	return gss_msg;
 }
 
@@ -883,6 +876,12 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 		return ERR_PTR(err);
 	if (!(gss_auth = kmalloc(sizeof(*gss_auth), GFP_KERNEL)))
 		goto out_dec;
+	gss_auth->target_name = NULL;
+	if (clnt->cl_principal) {
+		gss_auth->target_name = kstrdup(clnt->cl_principal, GFP_KERNEL);
+		if (gss_auth->target_name == NULL)
+			goto err_free;
+	}
 	gss_auth->client = clnt;
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
@@ -937,6 +936,7 @@ err_destroy_pipe_1:
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
 err_free:
+	kfree(gss_auth->target_name);
 	kfree(gss_auth);
 out_dec:
 	module_put(THIS_MODULE);
@@ -950,6 +950,7 @@ gss_free(struct gss_auth *gss_auth)
 	rpc_destroy_pipe_data(gss_auth->pipe[0]);
 	rpc_destroy_pipe_data(gss_auth->pipe[1]);
 	gss_mech_put(gss_auth->mech);
+	kfree(gss_auth->target_name);
 
 	kfree(gss_auth);
 	module_put(THIS_MODULE);
-- 
1.8.3.1

