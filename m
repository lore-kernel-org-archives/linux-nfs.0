From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/5] rpc: add new gssd upcall pipe
Date: Fri, 13 Jun 2008 18:50:42 -0400
Message-ID: <1213397442-15611-6-git-send-email-bfields@citi.umich.edu>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-5-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43965 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935AbYFMWuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:44 -0400
In-Reply-To: <1213397442-15611-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This adds the new text-based gss upcall.  We only allow an open from
either the new pipe or the old one, and use the pipe_open method to
enforce this.

If no pipes are open, we provisionally queue messages for the new pipe;
a subsequent open of the old pipe will cause all those messages to be
purged.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 +
 net/sunrpc/auth_gss/auth_gss.c     |  144 ++++++++++++++++++++++++++++++++---
 net/sunrpc/rpc_pipe.c              |   27 +++++--
 3 files changed, 153 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 439bef3..4c0f4a0 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -42,6 +42,7 @@ RPC_I(struct inode *inode)
 }
 
 extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
+void rpc_pipe_cancel_all(struct inode *inode, int errno);
 
 extern struct dentry *rpc_mkdir(char *, struct rpc_clnt *);
 extern int rpc_rmdir(struct dentry *);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5e82a69..a5a56e8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -87,7 +87,19 @@ struct gss_auth {
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
 	struct rpc_clnt *client;
-	struct dentry *dentry;
+	/*
+	 * There are two upcall pipes; dentry[1], named "gssd", is used
+	 * for the new text-based upcall; dentry[0] is named after the
+	 * mechanism ("krb5") and exists for backwards-compatibility
+	 * with older gssd's.
+	 */
+	struct dentry *dentry[2];
+	/*
+	 * The upcall_version tracks which of the above upcalls we're
+	 * using, 0 (old) or 1 (new).  While userland has neither pipe
+	 * open, upcall_version is set to -1:
+	 */
+	int upcall_version;
 };
 
 static void gss_free_ctx(struct gss_cl_ctx *);
@@ -235,6 +247,7 @@ err:
 	return p;
 }
 
+#define UPCALL_BUF_LEN 128
 
 struct gss_upcall_msg {
 	atomic_t count;
@@ -245,6 +258,7 @@ struct gss_upcall_msg {
 	struct rpc_wait_queue rpc_waitqueue;
 	wait_queue_head_t waitqueue;
 	struct gss_cl_ctx *ctx;
+	char databuf[UPCALL_BUF_LEN];
 };
 
 static void
@@ -347,14 +361,52 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 		rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 		init_waitqueue_head(&gss_msg->waitqueue);
 		atomic_set(&gss_msg->count, 1);
-		gss_msg->msg.data = &gss_msg->uid;
-		gss_msg->msg.len = sizeof(gss_msg->uid);
 		gss_msg->uid = uid;
 		gss_msg->auth = gss_auth;
 	}
 	return gss_msg;
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
+static void gss_encode_msg(struct gss_upcall_msg *gss_msg, int vers)
+{
+	if (vers == 0)
+		gss_encode_v0_msg(gss_msg);
+	else
+		gss_encode_v1_msg(gss_msg);
+}
+
+static int gss_queue_upcall(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
+{
+	int res;
+	int vers;
+
+	spin_lock(&gss_auth->lock);
+	vers = gss_auth->upcall_version;
+	if (vers == -1) {
+		/* Neither pipe opened yet; default to the new one: */
+		vers = 1;
+	}
+	gss_encode_msg(gss_msg, vers);
+	res = rpc_queue_upcall(gss_auth->dentry[vers]->d_inode, &gss_msg->msg);
+	spin_unlock(&gss_auth->lock);
+	return res;
+}
+
 static struct gss_upcall_msg *
 gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cred *cred)
 {
@@ -372,7 +424,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 		return ERR_PTR(-ENOMEM);
 	gss_msg = gss_add_msg(gss_auth, gss_new);
 	if (gss_msg == gss_new) {
-		int res = rpc_queue_upcall(gss_auth->dentry->d_inode, &gss_new->msg);
+		int res = gss_queue_upcall(gss_auth, gss_msg);
 		if (res) {
 			gss_unhash_msg(gss_new);
 			gss_msg = ERR_PTR(res);
@@ -562,6 +614,55 @@ out:
 	return err;
 }
 
+static int gss_pipe_version(struct gss_auth *gss_auth, struct inode *inode)
+{
+	if (gss_auth->dentry[0]->d_inode == inode)
+		return 0;
+	if (gss_auth->dentry[1]->d_inode == inode)
+		return 1;
+	BUG();
+}
+
+static int
+gss_pipe_open(struct inode *inode)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	struct rpc_clnt *clnt = rpci->private;
+	struct gss_auth *gss_auth = container_of(clnt->cl_auth,
+						 struct gss_auth, rpc_auth);
+	int vers = gss_pipe_version(gss_auth, inode);
+	int ret;
+
+	spin_lock(&gss_auth->lock);
+	if (gss_auth->upcall_version >= 0) {
+		/*
+		 * If pipe is already opened, permit only opens of the same
+		 * version:
+		 */
+		if (vers == gss_auth->upcall_version)
+			ret = 0;
+		else
+			ret = -EBUSY;
+		spin_unlock(&gss_auth->lock);
+		return ret;
+	}
+
+	/*
+	 * Neither pipe was opened previously, so this open is the first
+	 * hint we've gotten as to which upcall gssd intends to use:
+	 */
+	gss_auth->upcall_version = vers;
+	spin_unlock(&gss_auth->lock);
+	if (vers == 0) {
+		/*
+		 * We default to trying the new upcall, so may have
+		 * already attempted some upcalls there; cancel them:
+		 */
+		rpc_pipe_cancel_all(gss_auth->dentry[1]->d_inode, -EAGAIN);
+	}
+	return 0;
+}
+
 static void
 gss_pipe_release(struct inode *inode)
 {
@@ -572,6 +673,8 @@ gss_pipe_release(struct inode *inode)
 	struct gss_upcall_msg *gss_msg;
 
 	spin_lock(&gss_auth->lock);
+	if (rpci->nreaders == 0)
+		gss_auth->upcall_version = -1;
 	while (!list_empty(&gss_auth->in_downcall)) {
 
 		gss_msg = list_entry(gss_auth->in_downcall.next,
@@ -646,21 +749,34 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	auth->au_flavor = flavor;
 	atomic_set(&auth->au_count, 1);
 	kref_init(&gss_auth->kref);
-
-	gss_auth->dentry = rpc_mkpipe(clnt->cl_dentry, gss_auth->mech->gm_name,
-			clnt, &gss_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(gss_auth->dentry)) {
-		err = PTR_ERR(gss_auth->dentry);
+	gss_auth->upcall_version = -1;
+
+	gss_auth->dentry[0] = rpc_mkpipe(clnt->cl_dentry,
+					 gss_auth->mech->gm_name,
+					 clnt, &gss_upcall_ops,
+					 RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(gss_auth->dentry[0])) {
+		err = PTR_ERR(gss_auth->dentry[0]);
 		goto err_put_mech;
 	}
+	gss_auth->dentry[1] = rpc_mkpipe(clnt->cl_dentry,
+					 "gssd",
+					 clnt, &gss_upcall_ops,
+					 RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(gss_auth->dentry[1])) {
+		err = PTR_ERR(gss_auth->dentry[1]);
+		goto err_unlink_pipe_0;
+	}
 
 	err = rpcauth_init_credcache(auth);
 	if (err)
-		goto err_unlink_pipe;
+		goto err_unlink_pipe_1;
 
 	return auth;
-err_unlink_pipe:
-	rpc_unlink(gss_auth->dentry);
+err_unlink_pipe_1:
+	rpc_unlink(gss_auth->dentry[1]);
+err_unlink_pipe_0:
+	rpc_unlink(gss_auth->dentry[0]);
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
 err_free:
@@ -673,7 +789,8 @@ out_dec:
 static void
 gss_free(struct gss_auth *gss_auth)
 {
-	rpc_unlink(gss_auth->dentry);
+	rpc_unlink(gss_auth->dentry[1]);
+	rpc_unlink(gss_auth->dentry[0]);
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);
@@ -1362,6 +1479,7 @@ static struct rpc_pipe_ops gss_upcall_ops = {
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
 	.release_pipe	= gss_pipe_release,
+	.open_pipe	= gss_pipe_open,
 };
 
 /*
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index f7781fc..bbefc3a 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -53,13 +53,18 @@ static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
 	wake_up(&rpci->waitq);
 }
 
-static void
-rpc_timeout_upcall_queue(struct work_struct *work)
+/**
+ * rpc_pipe_cancel_all
+ * @inode: inode of upcall pipe to cancel all upcalls on
+ * @errno: errno (as a negative integer) to return on all pending upcalls
+ *
+ * Call with an inode created by rpc_mkpipe() to remove all queued
+ * upcalls.  Allowed only on pipes not yet opened for read.
+ */
+void rpc_pipe_cancel_all(struct inode *inode, int errno)
 {
 	LIST_HEAD(free_list);
-	struct rpc_inode *rpci =
-		container_of(work, struct rpc_inode, queue_timeout.work);
-	struct inode *inode = &rpci->vfs_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
 	void (*destroy_msg)(struct rpc_pipe_msg *);
 
 	spin_lock(&inode->i_lock);
@@ -73,7 +78,17 @@ rpc_timeout_upcall_queue(struct work_struct *work)
 		rpci->pipelen = 0;
 	}
 	spin_unlock(&inode->i_lock);
-	rpc_purge_list(rpci, &free_list, destroy_msg, -ETIMEDOUT);
+	rpc_purge_list(rpci, &free_list, destroy_msg, errno);
+}
+
+static void
+rpc_timeout_upcall_queue(struct work_struct *work)
+{
+	struct rpc_inode *rpci =
+		container_of(work, struct rpc_inode, queue_timeout.work);
+	struct inode *inode = &rpci->vfs_inode;
+
+	rpc_pipe_cancel_all(inode, -ETIMEDOUT);
 }
 
 /**
-- 
1.5.5.rc1

