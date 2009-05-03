From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: lookup up callback cred only once
Date: Sun,  3 May 2009 14:16:33 -0400
Message-ID: <1241374599-20348-8-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58607 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-7-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Lookup the callback cred once and then use it for all subsequent
callbacks.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |   26 ++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c        |    4 ++++
 include/linux/nfsd/state.h |    1 +
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 711c628..cc10ed3 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -415,6 +415,22 @@ static void warn_no_callback_path(struct nfs4_client *clp, int reason)
 		(int)clp->cl_name.len, clp->cl_name.data, reason);
 }
 
+static struct rpc_cred *lookup_cb_cred(struct nfs4_callback *cb)
+{
+	struct auth_cred acred = {
+		.machine_cred = 1
+	};
+
+	/*
+	 * Note in the gss case this doesn't actually have to wait for a
+	 * gss upcall (or any calls to the client); this just creates a
+	 * non-uptodate cred which the rpc state machine will fill in with
+	 * a refresh_upcall later.
+	 */
+	return rpcauth_lookup_credcache(cb->cb_client->cl_auth, &acred,
+							RPCAUTH_LOOKUP_NEW);
+}
+
 static int do_probe_callback(void *data)
 {
 	struct nfs4_client *clp = data;
@@ -423,9 +439,18 @@ static int do_probe_callback(void *data)
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
 	};
+	struct rpc_cred *cred;
 	int status;
 
+	cred = lookup_cb_cred(cb);
+	if (IS_ERR(cred)) {
+		status = PTR_ERR(cred);
+		goto out;
+	}
+	cb->cb_cred = cred;
+	msg.rpc_cred = cb->cb_cred;
 	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
+out:
 	if (status)
 		warn_no_callback_path(clp, status);
 	else
@@ -475,6 +500,7 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_argp = cbr,
+		.rpc_cred = clp->cl_callback.cb_cred
 	};
 	int retries = 1;
 	int status = 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7e1fcc3..b205c7d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -643,6 +643,10 @@ shutdown_callback_client(struct nfs4_client *clp)
 		clp->cl_callback.cb_client = NULL;
 		rpc_shutdown_client(clnt);
 	}
+	if (clp->cl_callback.cb_cred) {
+		put_rpccred(clp->cl_callback.cb_cred);
+		clp->cl_callback.cb_cred = NULL;
+	}
 }
 
 static inline void
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 4d61c87..8d882a3 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -97,6 +97,7 @@ struct nfs4_callback {
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
 	struct rpc_clnt *       cb_client;
+	struct rpc_cred	*	cb_cred;
 };
 
 /* Maximum number of slots per session. 128 is useful for long haul TCP */
-- 
1.6.0.4

