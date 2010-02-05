From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 3/5] nfs41: renewd sequence operations should take/put client reference
Date: Fri,  5 Feb 2010 03:32:32 -0800
Message-ID: <1265369554-2105-4-git-send-email-batsakis@netapp.com>
References: <1265369554-2105-1-git-send-email-batsakis@netapp.com>
 <1265369554-2105-2-git-send-email-batsakis@netapp.com>
 <1265369554-2105-3-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, root <vadmin.root@vadmin (none) >,
	Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757051Ab0BKUl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 15:41:27 -0500
In-Reply-To: <1265369554-2105-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root <root@vadmin.(none)>

renewd sends SEQUENCE requests to the NFS server in order to renew state.
As the request is asynchronous, renewd should take a reference to the
nfs_client to prevent concurrent umounts from freeing the session/client

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ce44b5a..87fd43a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -419,7 +419,8 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 			clp->cl_last_renewal = timestamp;
 		spin_unlock(&clp->cl_lock);
 		/* Check sequence flags */
-		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
+		if (atomic_read(&clp->cl_count) > 1)
+			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
 	}
 out:
 	/* The session may be reset by one of the error handlers. */
@@ -5032,6 +5033,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
+		if (atomic_read(&clp->cl_count) == 1)
+			goto out;
 
 		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
 								== -EAGAIN) {
@@ -5041,8 +5044,9 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	}
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
-	nfs4_schedule_state_renewal(clp);
-
+	if (atomic_read(&clp->cl_count) > 1)
+		nfs4_schedule_state_renewal(clp);
+out:
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
 
@@ -5064,9 +5068,15 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	rpc_call_start(task);
 }
 
+static void nfs41_sequence_release(void *calldata)
+{
+	nfs_put_client((struct nfs_client *) calldata);
+}
+
 static const struct rpc_call_ops nfs41_sequence_ops = {
 	.rpc_call_done = nfs41_sequence_call_done,
 	.rpc_call_prepare = nfs41_sequence_prepare,
+	.rpc_release = nfs41_sequence_release,
 };
 
 static int nfs41_proc_async_sequence(struct nfs_client *clp,
@@ -5079,11 +5089,16 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 		.rpc_cred = cred,
 	};
 
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		return -EIO;
 	args = kzalloc(sizeof(*args), GFP_KERNEL);
-	if (!args)
+	if (!args) {
+		nfs_put_client(clp);
 		return -ENOMEM;
+	}
 	res = kzalloc(sizeof(*res), GFP_KERNEL);
 	if (!res) {
+		nfs_put_client(clp);
 		kfree(args);
 		return -ENOMEM;
 	}
-- 
1.6.2.5

