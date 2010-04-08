From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/8] nfsd4: remove probe task's reference on client
Date: Thu,  8 Apr 2010 11:59:18 -0400
Message-ID: <1270742362-9375-5-git-send-email-bfields@citi.umich.edu>
References: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932695Ab0DHP4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:55 -0400
In-Reply-To: <1270742362-9375-4-git-send-email-bfields@citi.umich.edu>
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
index b99c3f0..91eb2ea 100644
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
@@ -563,10 +560,6 @@ nfsd4_probe_callback(struct nfs4_client *clp)
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

