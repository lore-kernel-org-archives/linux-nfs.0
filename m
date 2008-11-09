From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 8/9] rpc: store pointer to pipe inode in gss upcall message
Date: Sun,  9 Nov 2008 16:04:42 -0500
Message-ID: <1226264683-28650-9-git-send-email-bfields@citi.umich.edu>
References: <20081109204621.GD27376@fieldses.org>
 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-7-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-8-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34909 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842AbYKIVEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 16:04:47 -0500
In-Reply-To: <1226264683-28650-8-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep a pointer to the inode that the message is queued on in the struct
gss_upcall_msg.  This will be convenient, especially after we have a
choice of two pipes that an upcall could be queued on.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3046f2b..96c1bab 100644
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
-- 
1.5.5.rc1

