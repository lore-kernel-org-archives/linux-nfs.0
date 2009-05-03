From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: create rpc callback client from server thread
Date: Sun,  3 May 2009 14:16:32 -0400
Message-ID: <1241374599-20348-7-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58605 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-6-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The code is a little simpler, and it should be easier to avoid races, if
we just do all rpc client creation/destruction from nfsd or laundromat
threads and do only the rpc calls themselves asynchronously.  The rpc
creation doesn't involve any significant waiting (it doesn't call the
client, for example), so there's no reason not to do this.

Also don't bother destroying the client on failure of the rpc null
probe.  We may want to retry the probe later anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4788d09..711c628 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -409,6 +409,12 @@ int setup_callback_client(struct nfs4_client *clp)
 
 }
 
+static void warn_no_callback_path(struct nfs4_client *clp, int reason)
+{
+	dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
+		(int)clp->cl_name.len, clp->cl_name.data, reason);
+}
+
 static int do_probe_callback(void *data)
 {
 	struct nfs4_client *clp = data;
@@ -419,24 +425,12 @@ static int do_probe_callback(void *data)
 	};
 	int status;
 
-	status = setup_callback_client(clp);
-	if (status)
-		goto out_err;
-
 	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
-
 	if (status)
-		goto out_release_client;
+		warn_no_callback_path(clp, status);
+	else
+		atomic_set(&cb->cb_set, 1);
 
-	atomic_set(&cb->cb_set, 1);
-	put_nfs4_client(clp);
-	return 0;
-out_release_client:
-	rpc_shutdown_client(cb->cb_client);
-	cb->cb_client = NULL;
-out_err:
-	dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
-		(int)clp->cl_name.len, clp->cl_name.data, status);
 	put_nfs4_client(clp);
 	return 0;
 }
@@ -448,9 +442,16 @@ void
 nfsd4_probe_callback(struct nfs4_client *clp)
 {
 	struct task_struct *t;
+	int status;
 
 	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
 
+	status = setup_callback_client(clp);
+	if (status) {
+		warn_no_callback_path(clp, status);
+		return;
+	}
+
 	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
 
-- 
1.6.0.4

