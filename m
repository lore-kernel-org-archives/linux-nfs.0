From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 62/69] rpc: store pointer to pipe inode in gss upcall
 message
Date: Tue, 23 Dec 2008 18:02:24 -0500
Message-ID: <20081223230224.13743.56073.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbYLWXYp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:45 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcm7006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

Keep a pointer to the inode that the message is queued on in the struct
gss_upcall_msg.  This will be convenient, especially after we have a
choice of two pipes that an upcall could be queued on.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e451d10..fe06acd 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -234,6 +234,7 @@ struct gss_upcall_msg {
 	struct rpc_pipe_msg msg;
 	struct list_head list;
 	struct gss_auth *auth;
+	struct rpc_inode *inode;
 	struct rpc_wait_queue rpc_waitqueue;
 	wait_queue_head_t waitqueue;
 	struct gss_cl_ctx *ctx;
@@ -296,8 +297,8 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
 static inline struct gss_upcall_msg *
 gss_add_msg(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
 {
-	struct inode *inode = gss_auth->dentry->d_inode;
-	struct rpc_inode *rpci = RPC_I(inode);
+	struct rpc_inode *rpci = gss_msg->inode;
+	struct inode *inode = &rpci->vfs_inode;
 	struct gss_upcall_msg *old;
 
 	spin_lock(&inode->i_lock);
@@ -323,8 +324,7 @@ __gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 static void
 gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 {
-	struct gss_auth *gss_auth = gss_msg->auth;
-	struct inode *inode = gss_auth->dentry->d_inode;
+	struct inode *inode = &gss_msg->inode->vfs_inode;
 
 	if (list_empty(&gss_msg->list))
 		return;
@@ -340,7 +340,7 @@ gss_upcall_callback(struct rpc_task *task)
 	struct gss_cred *gss_cred = container_of(task->tk_msg.rpc_cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_msg = gss_cred->gc_upcall;
-	struct inode *inode = gss_msg->auth->dentry->d_inode;
+	struct inode *inode = &gss_msg->inode->vfs_inode;
 
 	spin_lock(&inode->i_lock);
 	if (gss_msg->ctx)
@@ -367,6 +367,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 		kfree(gss_msg);
 		return ERR_PTR(vers);
 	}
+	gss_msg->inode = RPC_I(gss_auth->dentry->d_inode);
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
@@ -395,7 +396,8 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 		return gss_new;
 	gss_msg = gss_add_msg(gss_auth, gss_new);
 	if (gss_msg == gss_new) {
-		int res = rpc_queue_upcall(gss_auth->dentry->d_inode, &gss_new->msg);
+		struct inode *inode = &gss_new->inode->vfs_inode;
+		int res = rpc_queue_upcall(inode, &gss_new->msg);
 		if (res) {
 			gss_unhash_msg(gss_new);
 			gss_msg = ERR_PTR(res);
@@ -426,7 +428,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_msg;
-	struct inode *inode = gss_auth->dentry->d_inode;
+	struct inode *inode;
 	int err = 0;
 
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
@@ -444,6 +446,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		err = PTR_ERR(gss_msg);
 		goto out;
 	}
+	inode = &gss_msg->inode->vfs_inode;
 	spin_lock(&inode->i_lock);
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
@@ -470,7 +473,7 @@ out:
 static inline int
 gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 {
-	struct inode *inode = gss_auth->dentry->d_inode;
+	struct inode *inode;
 	struct rpc_cred *cred = &gss_cred->gc_base;
 	struct gss_upcall_msg *gss_msg;
 	DEFINE_WAIT(wait);
@@ -492,6 +495,7 @@ retry:
 		err = PTR_ERR(gss_msg);
 		goto out;
 	}
+	inode = &gss_msg->inode->vfs_inode;
 	for (;;) {
 		prepare_to_wait(&gss_msg->waitqueue, &wait, TASK_INTERRUPTIBLE);
 		spin_lock(&inode->i_lock);

