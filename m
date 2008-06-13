From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/5] rpc: Use separate spinlock for cred locking in auth_gss.c
Date: Fri, 13 Jun 2008 18:50:39 -0400
Message-ID: <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755780AbYFMWuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:44 -0400
In-Reply-To: <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The i_lock uses in auth_gss.c are to protect the gc_upcall and gc_ctx
fields of the gss cred; so we can use a separate per-auth spinlock for
those instead of the i_lock.  This simplifies the locking in the case
where we have two different pipes (one the current pipe, one the pipe
for a new more flexible upcall), either of which might be used for gss
upcalls.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   56 +++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b42ec85..28ca1c9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -82,6 +82,7 @@ static const struct rpc_credops gss_nullops;
 struct gss_auth {
 	struct kref kref;
 	struct rpc_auth rpc_auth;
+	spinlock_t lock;
 	struct gss_api_mech *mech;
 	enum rpc_gss_svc service;
 	struct rpc_clnt *client;
@@ -108,7 +109,7 @@ gss_put_ctx(struct gss_cl_ctx *ctx)
 /* gss_cred_set_ctx:
  * called by gss_upcall_callback and gss_create_upcall in order
  * to set the gss context. The actual exchange of an old context
- * and a new one is protected by the inode->i_lock.
+ * and a new one is protected by the gss_auth->lock.
  */
 static void
 gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
@@ -283,14 +284,14 @@ gss_add_msg(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct gss_upcall_msg *old;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	old = __gss_find_upcall(rpci, gss_msg->uid);
 	if (old == NULL) {
 		atomic_inc(&gss_msg->count);
 		list_add(&gss_msg->list, &rpci->in_downcall);
 	} else
 		gss_msg = old;
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 	return gss_msg;
 }
 
@@ -307,14 +308,13 @@ static void
 gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 {
 	struct gss_auth *gss_auth = gss_msg->auth;
-	struct inode *inode = gss_auth->dentry->d_inode;
 
 	if (list_empty(&gss_msg->list))
 		return;
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	if (!list_empty(&gss_msg->list))
 		__gss_unhash_msg(gss_msg);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 }
 
 static void
@@ -323,16 +323,16 @@ gss_upcall_callback(struct rpc_task *task)
 	struct gss_cred *gss_cred = container_of(task->tk_msg.rpc_cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_msg = gss_cred->gc_upcall;
-	struct inode *inode = gss_msg->auth->dentry->d_inode;
+	struct gss_auth *gss_auth = gss_msg->auth;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	if (gss_msg->ctx)
 		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
 	else
 		task->tk_status = gss_msg->msg.errno;
 	gss_cred->gc_upcall = NULL;
 	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 	gss_release_msg(gss_msg);
 }
 
@@ -391,7 +391,6 @@ gss_refresh_upcall(struct rpc_task *task)
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_msg;
-	struct inode *inode = gss_auth->dentry->d_inode;
 	int err = 0;
 
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
@@ -401,7 +400,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		err = PTR_ERR(gss_msg);
 		goto out;
 	}
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
 	else if (gss_msg->ctx != NULL) {
@@ -416,7 +415,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback);
 	} else
 		err = gss_msg->msg.errno;
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u result %d\n",
@@ -427,7 +426,6 @@ out:
 static inline int
 gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 {
-	struct inode *inode = gss_auth->dentry->d_inode;
 	struct rpc_cred *cred = &gss_cred->gc_base;
 	struct gss_upcall_msg *gss_msg;
 	DEFINE_WAIT(wait);
@@ -441,11 +439,11 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	}
 	for (;;) {
 		prepare_to_wait(&gss_msg->waitqueue, &wait, TASK_INTERRUPTIBLE);
-		spin_lock(&inode->i_lock);
+		spin_lock(&gss_auth->lock);
 		if (gss_msg->ctx != NULL || gss_msg->msg.errno < 0) {
 			break;
 		}
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&gss_auth->lock);
 		if (signalled()) {
 			err = -ERESTARTSYS;
 			goto out_intr;
@@ -456,7 +454,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 		gss_cred_set_ctx(cred, gss_msg->ctx);
 	else
 		err = gss_msg->msg.errno;
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 out_intr:
 	finish_wait(&gss_msg->waitqueue, &wait);
 	gss_release_msg(gss_msg);
@@ -493,9 +491,11 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
 	const void *p, *end;
 	void *buf;
-	struct rpc_clnt *clnt;
 	struct gss_upcall_msg *gss_msg;
 	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct rpc_clnt *clnt = RPC_I(inode)->private;
+	struct gss_auth *gss_auth = container_of(clnt->cl_auth,
+						 struct gss_auth, rpc_auth);
 	struct gss_cl_ctx *ctx;
 	uid_t uid;
 	ssize_t err = -EFBIG;
@@ -526,14 +526,14 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 
 	err = -ENOENT;
 	/* Find a matching upcall */
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	gss_msg = __gss_find_upcall(RPC_I(inode), uid);
 	if (gss_msg == NULL) {
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&gss_auth->lock);
 		goto err_put_ctx;
 	}
 	list_del_init(&gss_msg->list);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 
 	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
 	if (IS_ERR(p)) {
@@ -545,9 +545,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	err = mlen;
 
 err_release_msg:
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	__gss_unhash_msg(gss_msg);
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 	gss_release_msg(gss_msg);
 err_put_ctx:
 	gss_put_ctx(ctx);
@@ -562,9 +562,12 @@ static void
 gss_pipe_release(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
+	struct rpc_clnt *clnt = rpci->private;
+	struct gss_auth *gss_auth = container_of(clnt->cl_auth,
+						 struct gss_auth, rpc_auth);
 	struct gss_upcall_msg *gss_msg;
 
-	spin_lock(&inode->i_lock);
+	spin_lock(&gss_auth->lock);
 	while (!list_empty(&rpci->in_downcall)) {
 
 		gss_msg = list_entry(rpci->in_downcall.next,
@@ -572,11 +575,11 @@ gss_pipe_release(struct inode *inode)
 		gss_msg->msg.errno = -EPIPE;
 		atomic_inc(&gss_msg->count);
 		__gss_unhash_msg(gss_msg);
-		spin_unlock(&inode->i_lock);
+		spin_unlock(&gss_auth->lock);
 		gss_release_msg(gss_msg);
-		spin_lock(&inode->i_lock);
+		spin_lock(&gss_auth->lock);
 	}
-	spin_unlock(&inode->i_lock);
+	spin_unlock(&gss_auth->lock);
 }
 
 static void
@@ -631,6 +634,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	if (gss_auth->service == 0)
 		goto err_put_mech;
 	auth = &gss_auth->rpc_auth;
+	spin_lock_init(&gss_auth->lock);
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
 	auth->au_ops = &authgss_ops;
-- 
1.5.5.rc1

