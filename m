From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 002/100] nfsd: move callback rpc_client creation into separate thread
Date: Fri, 25 Jan 2008 18:15:42 -0500
Message-ID: <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47307 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761990AbYAYXRW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:22 -0500
In-Reply-To: <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The whole reason to move this callback-channel probe into a separate
thread was because (for now) we don't have an easy way to create the
rpc_client asynchronously.  But I forgot to move the rpc_create() to the
spawned thread.  Doh!  Fix that.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   78 ++++++++++++++++++++++++------------------------
 1 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a9735a6..6eb5cd2 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -350,30 +350,6 @@ static struct rpc_version *	nfs_cb_version[] = {
 static int do_probe_callback(void *data)
 {
 	struct nfs4_client *clp = data;
-	struct nfs4_callback *cb = &clp->cl_callback;
-	struct rpc_message msg = {
-		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
-		.rpc_argp       = clp,
-	};
-	int status;
-
-	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
-
-	if (status) {
-		rpc_shutdown_client(cb->cb_client);
-		cb->cb_client = NULL;
-	} else
-		atomic_set(&cb->cb_set, 1);
-	put_nfs4_client(clp);
-	return 0;
-}
-
-/*
- * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
- */
-void
-nfsd4_probe_callback(struct nfs4_client *clp)
-{
 	struct sockaddr_in	addr;
 	struct nfs4_callback    *cb = &clp->cl_callback;
 	struct rpc_timeout	timeparms = {
@@ -390,12 +366,15 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 		.timeout	= &timeparms,
 		.program	= program,
 		.version	= nfs_cb_version[1]->number,
-		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
+		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
 		.flags		= (RPC_CLNT_CREATE_NOPING),
 	};
-	struct task_struct *t;
-
-	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
+		.rpc_argp       = clp,
+	};
+	struct rpc_clnt *client;
+	int status;
 
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
@@ -415,29 +394,50 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	program->stats->program = program;
 
 	/* Create RPC client */
-	cb->cb_client = rpc_create(&args);
-	if (IS_ERR(cb->cb_client)) {
+	client = rpc_create(&args);
+	if (IS_ERR(client)) {
 		dprintk("NFSD: couldn't create callback client\n");
+		status = PTR_ERR(client);
 		goto out_err;
 	}
 
+	status = rpc_call_sync(client, &msg, RPC_TASK_SOFT);
+
+	if (status)
+		goto out_release_client;
+
+	cb->cb_client = client;
+	atomic_set(&cb->cb_set, 1);
+	put_nfs4_client(clp);
+	return 0;
+out_release_client:
+	rpc_shutdown_client(client);
+out_err:
+	put_nfs4_client(clp);
+	dprintk("NFSD: warning: no callback path to client %.*s\n",
+		(int)clp->cl_name.len, clp->cl_name.data);
+	return status;
+}
+
+/*
+ * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
+ */
+void
+nfsd4_probe_callback(struct nfs4_client *clp)
+{
+	struct task_struct *t;
+
+	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
+
 	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
 
 	t = kthread_run(do_probe_callback, clp, "nfs4_cb_probe");
 
 	if (IS_ERR(t))
-		goto out_release_clp;
+		atomic_dec(&clp->cl_count);
 
 	return;
-
-out_release_clp:
-	atomic_dec(&clp->cl_count);
-	rpc_shutdown_client(cb->cb_client);
-out_err:
-	cb->cb_client = NULL;
-	dprintk("NFSD: warning: no callback path to client %.*s\n",
-		(int)clp->cl_name.len, clp->cl_name.data);
 }
 
 /*
-- 
1.5.4.rc2.60.gb2e62

