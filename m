From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 14/14] nfsd4: move rpc_client setup to a separate function
Date: Tue, 10 Mar 2009 20:27:02 -0400
Message-ID: <1236731222-3294-15-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
 <1236731222-3294-10-git-send-email-bfields@fieldses.org>
 <1236731222-3294-11-git-send-email-bfields@fieldses.org>
 <1236731222-3294-12-git-send-email-bfields@fieldses.org>
 <1236731222-3294-13-git-send-email-bfields@fieldses.org>
 <1236731222-3294-14-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44056 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-14-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c979af7..1d58ac7 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -361,9 +361,8 @@ static struct rpc_program cb_program = {
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
-static int do_probe_callback(void *data)
+static struct rpc_clnt *setup_callback_client(struct nfs4_client *clp)
 {
-	struct nfs4_client *clp = data;
 	struct sockaddr_in	addr;
 	struct nfs4_callback    *cb = &clp->cl_callback;
 	struct rpc_timeout	timeparms = {
@@ -384,15 +383,10 @@ static int do_probe_callback(void *data)
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
 	};
-	struct rpc_message msg = {
-		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
-		.rpc_argp       = clp,
-	};
 	struct rpc_clnt *client;
-	int status = -EINVAL;
 
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
-		goto out_err;
+		return ERR_PTR(-EINVAL);
 
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
@@ -402,9 +396,26 @@ static int do_probe_callback(void *data)
 
 	/* Create RPC client */
 	client = rpc_create(&args);
-	if (IS_ERR(client)) {
-		dprintk("NFSD: couldn't create callback client: %d\n",
+	if (IS_ERR(client))
+		dprintk("NFSD: couldn't create callback client: %ld\n",
 			PTR_ERR(client));
+	return client;
+
+}
+
+static int do_probe_callback(void *data)
+{
+	struct nfs4_client *clp = data;
+	struct nfs4_callback    *cb = &clp->cl_callback;
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
+		.rpc_argp       = clp,
+	};
+	struct rpc_clnt *client;
+	int status;
+
+	client = setup_callback_client(clp);
+	if (IS_ERR(client)) {
 		status = PTR_ERR(client);
 		goto out_err;
 	}
@@ -421,7 +432,7 @@ static int do_probe_callback(void *data)
 out_release_client:
 	rpc_shutdown_client(client);
 out_err:
-	dprintk("NFSD: warning: no callback path to client %.*: error %ds\n",
+	dprintk("NFSD: warning: no callback path to client %.*s: error %ds\n",
 		(int)clp->cl_name.len, clp->cl_name.data, status);
 	put_nfs4_client(clp);
 	return 0;
-- 
1.6.0.4

