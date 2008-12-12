From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 09/15] rpc: implement new upcall
Date: Fri, 12 Dec 2008 13:20:29 -0500
Message-ID: <1229106035-16102-10-git-send-email-bfields@citi.umich.edu>
References: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-2-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-4-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-5-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-6-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-7-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-8-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-9-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33994 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758605AbYLLSUk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:40 -0500
In-Reply-To: <1229106035-16102-9-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the new upcall.  We decide which version of the upcall gssd
will use (new or old), by creating both pipes (the new one named "gssd",
the old one named after the mechanism (e.g., "krb5")), and then waiting
to see which version gssd actually opens.

We don't permit pipes of the two different types to be opened at once.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |  116 +++++++++++++++++++++++++++++++++-------
 1 files changed, 96 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 96c1bab..55f922f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -72,7 +72,13 @@ struct gss_auth {
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
 	struct rpc_clnt *client;
-	struct dentry *dentry;
+	/*
+	 * There are two upcall pipes; dentry[1], named "gssd", is used
+	 * for the new text-based upcall; dentry[0] is named after the
+	 * mechanism (for example, "krb5") and exists for
+	 * backwards-compatibility with older gssd's.
+	 */
+	struct dentry *dentry[2];
 };
 
 /* pipe_version >= 0 if and only if someone has a pipe open. */
@@ -83,7 +89,8 @@ static struct rpc_wait_queue pipe_version_rpc_waitqueue;
 static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
 
 static void gss_free_ctx(struct gss_cl_ctx *);
-static struct rpc_pipe_ops gss_upcall_ops;
+static struct rpc_pipe_ops gss_upcall_ops_v0;
+static struct rpc_pipe_ops gss_upcall_ops_v1;
 
 static inline struct gss_cl_ctx *
 gss_get_ctx(struct gss_cl_ctx *ctx)
@@ -227,6 +234,7 @@ err:
 	return p;
 }
 
+#define UPCALL_BUF_LEN 128
 
 struct gss_upcall_msg {
 	atomic_t count;
@@ -238,6 +246,7 @@ struct gss_upcall_msg {
 	struct rpc_wait_queue rpc_waitqueue;
 	wait_queue_head_t waitqueue;
 	struct gss_cl_ctx *ctx;
+	char databuf[UPCALL_BUF_LEN];
 };
 
 static int get_pipe_version(void)
@@ -247,7 +256,7 @@ static int get_pipe_version(void)
 	spin_lock(&pipe_version_lock);
 	if (pipe_version >= 0) {
 		atomic_inc(&pipe_users);
-		ret = 0;
+		ret = pipe_version;
 	} else
 		ret = -EAGAIN;
 	spin_unlock(&pipe_version_lock);
@@ -353,6 +362,29 @@ gss_upcall_callback(struct rpc_task *task)
 	gss_release_msg(gss_msg);
 }
 
+static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
+{
+	gss_msg->msg.data = &gss_msg->uid;
+	gss_msg->msg.len = sizeof(gss_msg->uid);
+}
+
+static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg)
+{
+	gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d\n",
+				   gss_msg->auth->mech->gm_name,
+				   gss_msg->uid);
+	gss_msg->msg.data = gss_msg->databuf;
+	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
+}
+
+static void gss_encode_msg(struct gss_upcall_msg *gss_msg)
+{
+	if (pipe_version == 0)
+		gss_encode_v0_msg(gss_msg);
+	else /* pipe_version == 1 */
+		gss_encode_v1_msg(gss_msg);
+}
+
 static inline struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 {
@@ -367,15 +399,14 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 		kfree(gss_msg);
 		return ERR_PTR(vers);
 	}
-	gss_msg->inode = RPC_I(gss_auth->dentry->d_inode);
+	gss_msg->inode = RPC_I(gss_auth->dentry[vers]->d_inode);
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
 	atomic_set(&gss_msg->count, 1);
-	gss_msg->msg.data = &gss_msg->uid;
-	gss_msg->msg.len = sizeof(gss_msg->uid);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
+	gss_encode_msg(gss_msg);
 	return gss_msg;
 }
 
@@ -613,18 +644,36 @@ out:
 	return err;
 }
 
-static int
-gss_pipe_open(struct inode *inode)
+static int gss_pipe_open(struct inode *inode, int new_version)
 {
+	int ret = 0;
+
 	spin_lock(&pipe_version_lock);
 	if (pipe_version < 0) {
-		pipe_version = 0;
+		/* First open of any gss pipe determines the version: */
+		pipe_version = new_version;
 		rpc_wake_up(&pipe_version_rpc_waitqueue);
 		wake_up(&pipe_version_waitqueue);
+	} else if (pipe_version != new_version) {
+		/* Trying to open a pipe of a different version */
+		ret = -EBUSY;
+		goto out;
 	}
 	atomic_inc(&pipe_users);
+out:
 	spin_unlock(&pipe_version_lock);
-	return 0;
+	return ret;
+
+}
+
+static int gss_pipe_open_v0(struct inode *inode)
+{
+	return gss_pipe_open(inode, 0);
+}
+
+static int gss_pipe_open_v1(struct inode *inode)
+{
+	return gss_pipe_open(inode, 1);
 }
 
 static void
@@ -702,20 +751,38 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	atomic_set(&auth->au_count, 1);
 	kref_init(&gss_auth->kref);
 
-	gss_auth->dentry = rpc_mkpipe(clnt->cl_dentry, gss_auth->mech->gm_name,
-			clnt, &gss_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(gss_auth->dentry)) {
-		err = PTR_ERR(gss_auth->dentry);
+	/*
+	 * Note: if we created the old pipe first, then someone who
+	 * examined the directory at the right moment might conclude
+	 * that we supported only the old pipe.  So we instead create
+	 * the new pipe first.
+	 */
+	gss_auth->dentry[1] = rpc_mkpipe(clnt->cl_dentry,
+					 "gssd",
+					 clnt, &gss_upcall_ops_v1,
+					 RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(gss_auth->dentry[1])) {
+		err = PTR_ERR(gss_auth->dentry[1]);
 		goto err_put_mech;
 	}
 
+	gss_auth->dentry[0] = rpc_mkpipe(clnt->cl_dentry,
+					 gss_auth->mech->gm_name,
+					 clnt, &gss_upcall_ops_v0,
+					 RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(gss_auth->dentry[0])) {
+		err = PTR_ERR(gss_auth->dentry[0]);
+		goto err_unlink_pipe_1;
+	}
 	err = rpcauth_init_credcache(auth);
 	if (err)
-		goto err_unlink_pipe;
+		goto err_unlink_pipe_0;
 
 	return auth;
-err_unlink_pipe:
-	rpc_unlink(gss_auth->dentry);
+err_unlink_pipe_0:
+	rpc_unlink(gss_auth->dentry[0]);
+err_unlink_pipe_1:
+	rpc_unlink(gss_auth->dentry[1]);
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
 err_free:
@@ -728,7 +795,8 @@ out_dec:
 static void
 gss_free(struct gss_auth *gss_auth)
 {
-	rpc_unlink(gss_auth->dentry);
+	rpc_unlink(gss_auth->dentry[1]);
+	rpc_unlink(gss_auth->dentry[0]);
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);
@@ -1412,11 +1480,19 @@ static const struct rpc_credops gss_nullops = {
 	.crunwrap_resp	= gss_unwrap_resp,
 };
 
-static struct rpc_pipe_ops gss_upcall_ops = {
+static struct rpc_pipe_ops gss_upcall_ops_v0 = {
+	.upcall		= gss_pipe_upcall,
+	.downcall	= gss_pipe_downcall,
+	.destroy_msg	= gss_pipe_destroy_msg,
+	.open_pipe	= gss_pipe_open_v0,
+	.release_pipe	= gss_pipe_release,
+};
+
+static struct rpc_pipe_ops gss_upcall_ops_v1 = {
 	.upcall		= gss_pipe_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
-	.open_pipe	= gss_pipe_open,
+	.open_pipe	= gss_pipe_open_v1,
 	.release_pipe	= gss_pipe_release,
 };
 
-- 
1.5.5.rc1

