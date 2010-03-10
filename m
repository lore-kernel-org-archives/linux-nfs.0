From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 04/11] nfsd4: preallocate nfs4_rpc_args
Date: Tue,  9 Mar 2010 19:28:09 -0500
Message-ID: <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755349Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of allocating this small structure, just include it in the
delegation.

The nfsd4_callback structure isn't really necessary yet, but we plan to
add to it all the information necessary to perform a callback.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   18 +++---------------
 fs/nfsd/state.h        |   10 ++++++++++
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 17cd439..40a9c20 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -78,11 +78,6 @@ enum nfs_cb_opnum4 {
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
-struct nfs4_rpc_args {
-	void				*args_op;
-	struct nfsd4_cb_sequence	args_seq;
-};
-
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
@@ -676,7 +671,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		break;
 	default:
 		/* success, or error we can't handle */
-		goto done;
+		return;
 	}
 	if (dp->dl_retries--) {
 		rpc_delay(task, 2*HZ);
@@ -687,8 +682,6 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		atomic_set(&clp->cl_cb_conn.cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
 	}
-done:
-	kfree(task->tk_msg.rpc_argp);
 }
 
 static void nfsd4_cb_recall_release(void *calldata)
@@ -714,24 +707,19 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
-	struct nfs4_rpc_args *args;
+	struct nfs4_rpc_args *args = &dp->dl_recall.cb_args;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_cred = callback_cred
 	};
-	int status = -ENOMEM;
+	int status;
 
-	args = kzalloc(sizeof(*args), GFP_KERNEL);
-	if (!args)
-		goto out;
 	args->args_op = dp;
 	msg.rpc_argp = args;
 	dp->dl_retries = 1;
 	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
 				&nfsd4_cb_recall_ops, dp);
-out:
 	if (status) {
-		kfree(args);
 		put_nfs4_client(clp);
 		nfs4_put_delegation(dp);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b09943a..6e5b005 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -70,6 +70,15 @@ struct nfsd4_cb_sequence {
 	struct nfs4_client	*cbs_clp;
 };
 
+struct nfs4_rpc_args {
+	void				*args_op;
+	struct nfsd4_cb_sequence	args_seq;
+};
+
+struct nfsd4_callback {
+	struct nfs4_rpc_args cb_args;
+};
+
 struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
@@ -86,6 +95,7 @@ struct nfs4_delegation {
 	stateid_t		dl_stateid;
 	struct knfsd_fh		dl_fh;
 	int			dl_retries;
+	struct nfsd4_callback	dl_recall;
 };
 
 /* client delegation callback info */
-- 
1.6.3.3

