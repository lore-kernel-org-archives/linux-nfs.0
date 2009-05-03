From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: set cb_client inside setup_callback_client
Date: Sun,  3 May 2009 14:16:31 -0400
Message-ID: <1241374599-20348-6-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58599 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-5-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This is just a minor code simplification.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 049f052..4788d09 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -366,7 +366,7 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
-static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
+int setup_callback_client(struct nfs4_client *clp)
 {
 	struct sockaddr_in	addr;
 	struct nfs4_callback    *cb = &clp->cl_callback;
@@ -389,7 +389,7 @@ static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
 	struct rpc_clnt *client;
 
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
@@ -399,10 +399,13 @@ static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
 
 	/* Create RPC client */
 	client = rpc_create(&args);
-	if (IS_ERR(client))
+	if (IS_ERR(client)) {
 		dprintk("NFSD: couldn't create callback client: %ld\n",
 			PTR_ERR(client));
-	return client;
+		return PTR_ERR(client);
+	}
+	cb->cb_client = client;
+	return 0;
 
 }
 
@@ -414,28 +417,23 @@ static int do_probe_callback(void *data)
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
 	};
-	struct rpc_clnt *client;
 	int status;
 
-	client = setup_callback_client(clp);
-	if (IS_ERR(client)) {
-		status = PTR_ERR(client);
-		dprintk("NFSD: couldn't create callback client: %d\n",
-								status);
+	status = setup_callback_client(clp);
+	if (status)
 		goto out_err;
-	}
 
-	status = rpc_call_sync(client, &msg, RPC_TASK_SOFT);
+	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
 
 	if (status)
 		goto out_release_client;
 
-	cb->cb_client = client;
 	atomic_set(&cb->cb_set, 1);
 	put_nfs4_client(clp);
 	return 0;
 out_release_client:
-	rpc_shutdown_client(client);
+	rpc_shutdown_client(cb->cb_client);
+	cb->cb_client = NULL;
 out_err:
 	dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
 		(int)clp->cl_name.len, clp->cl_name.data, status);
-- 
1.6.0.4

