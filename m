From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 07/15] rpc: use count of pipe openers to wait for first open
Date: Fri, 12 Dec 2008 13:20:27 -0500
Message-ID: <1229106035-16102-8-git-send-email-bfields@citi.umich.edu>
References: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-2-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-4-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-5-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-6-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-7-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758481AbYLLSUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:39 -0500
In-Reply-To: <1229106035-16102-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a global variable pipe_version which will eventually be used
to keep track of which version of the upcall gssd is using.

For now, though, it only keeps track of whether any pipe is open or not;
it is negative if not, zero if one is opened.  We use this to wait for
the first gssd to open a pipe.

(Minor digression: note this waits only for the very first open of any
pipe, not for the first open of a pipe for a given auth; thus we still
need the RPC_PIPE_WAIT_FOR_OPEN behavior to wait for gssd to open new
pipes that pop up on subsequent mounts.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   64 ++++++++++++++++++++++++++++++++++++++--
 1 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 45e6728..3046f2b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -75,7 +75,12 @@ struct gss_auth {
 	struct dentry *dentry;
 };
 
+/* pipe_version >= 0 if and only if someone has a pipe open. */
+static int pipe_version = -1;
 static atomic_t pipe_users = ATOMIC_INIT(0);
+static DEFINE_SPINLOCK(pipe_version_lock);
+static struct rpc_wait_queue pipe_version_rpc_waitqueue;
+static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
 
 static void gss_free_ctx(struct gss_cl_ctx *);
 static struct rpc_pipe_ops gss_upcall_ops;
@@ -234,12 +239,34 @@ struct gss_upcall_msg {
 	struct gss_cl_ctx *ctx;
 };
 
+static int get_pipe_version(void)
+{
+	int ret;
+
+	spin_lock(&pipe_version_lock);
+	if (pipe_version >= 0) {
+		atomic_inc(&pipe_users);
+		ret = 0;
+	} else
+		ret = -EAGAIN;
+	spin_unlock(&pipe_version_lock);
+	return ret;
+}
+
+static void put_pipe_version(void)
+{
+	if (atomic_dec_and_lock(&pipe_users, &pipe_version_lock)) {
+		pipe_version = -1;
+		spin_unlock(&pipe_version_lock);
+	}
+}
+
 static void
 gss_release_msg(struct gss_upcall_msg *gss_msg)
 {
 	if (!atomic_dec_and_test(&gss_msg->count))
 		return;
-	atomic_dec(&pipe_users);
+	put_pipe_version();
 	BUG_ON(!list_empty(&gss_msg->list));
 	if (gss_msg->ctx != NULL)
 		gss_put_ctx(gss_msg->ctx);
@@ -330,11 +357,16 @@ static inline struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 {
 	struct gss_upcall_msg *gss_msg;
+	int vers;
 
 	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
 	if (gss_msg == NULL)
 		return ERR_PTR(-ENOMEM);
-	atomic_inc(&pipe_users);
+	vers = get_pipe_version();
+	if (vers < 0) {
+		kfree(gss_msg);
+		return ERR_PTR(vers);
+	}
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
@@ -400,6 +432,14 @@ gss_refresh_upcall(struct rpc_task *task)
 	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid,
 								cred->cr_uid);
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
+	if (IS_ERR(gss_msg) == -EAGAIN) {
+		/* XXX: warning on the first, under the assumption we
+		 * shouldn't normally hit this case on a refresh. */
+		warn_gssd();
+		task->tk_timeout = 15*HZ;
+		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
+		return 0;
+	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
 		goto out;
@@ -437,7 +477,17 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	int err = 0;
 
 	dprintk("RPC:       gss_upcall for uid %u\n", cred->cr_uid);
+retry:
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
+	if (PTR_ERR(gss_msg) == -EAGAIN) {
+		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
+				pipe_version >= 0, 15*HZ);
+		if (err)
+			goto out;
+		if (pipe_version < 0)
+			warn_gssd();
+		goto retry;
+	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
 		goto out;
@@ -562,7 +612,14 @@ out:
 static int
 gss_pipe_open(struct inode *inode)
 {
+	spin_lock(&pipe_version_lock);
+	if (pipe_version < 0) {
+		pipe_version = 0;
+		rpc_wake_up(&pipe_version_rpc_waitqueue);
+		wake_up(&pipe_version_waitqueue);
+	}
 	atomic_inc(&pipe_users);
+	spin_unlock(&pipe_version_lock);
 	return 0;
 }
 
@@ -586,7 +643,7 @@ gss_pipe_release(struct inode *inode)
 	}
 	spin_unlock(&inode->i_lock);
 
-	atomic_dec(&pipe_users);
+	put_pipe_version();
 }
 
 static void
@@ -1372,6 +1429,7 @@ static int __init init_rpcsec_gss(void)
 	err = gss_svc_init();
 	if (err)
 		goto out_unregister;
+	rpc_init_wait_queue(&pipe_version_rpc_waitqueue, "gss pipe version");
 	return 0;
 out_unregister:
 	rpcauth_unregister(&authgss_ops);
-- 
1.5.5.rc1

