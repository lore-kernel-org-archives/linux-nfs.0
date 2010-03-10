From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 07/11] nfsd4: remove probe task's reference on client
Date: Tue,  9 Mar 2010 19:28:12 -0500
Message-ID: <1268180896-30921-8-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-6-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-7-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42169 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755563Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any null probe rpc will be synchronously destroyed by the
rpc_shutdown_client() in expire_client(), so the rpc task cannot outlast
the nfs4 client.  Therefore there's no need for that task to hold a
reference on the client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 40a9c20..7f84686 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -509,7 +509,6 @@ static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 		warn_no_callback_path(clp, task->tk_status);
 	else
 		atomic_set(&clp->cl_cb_conn.cb_set, 1);
-	put_nfs4_client(clp);
 }
 
 static const struct rpc_call_ops nfsd4_cb_probe_ops = {
@@ -542,10 +541,8 @@ void do_probe_callback(struct nfs4_client *clp)
 	status = rpc_call_async(cb->cb_client, &msg,
 				RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 				&nfsd4_cb_probe_ops, (void *)clp);
-	if (status) {
+	if (status)
 		warn_no_callback_path(clp, status);
-		put_nfs4_client(clp);
-	}
 }
 
 /*
@@ -563,10 +560,6 @@ nfsd4_probe_callback(struct nfs4_client *clp, struct svc_xprt *cb_xprt)
 		warn_no_callback_path(clp, status);
 		return;
 	}
-
-	/* the task holds a reference to the nfs4_client struct */
-	atomic_inc(&clp->cl_count);
-
 	do_probe_callback(clp);
 }
 
-- 
1.6.3.3

