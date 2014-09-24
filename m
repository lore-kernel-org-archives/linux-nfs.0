Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:39526 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686AbaIXKQ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 06:16:59 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] nfsd: introduce a generic nfsd4_cb
Date: Wed, 24 Sep 2014 12:19:17 +0200
Message-Id: <1411553959-5280-3-git-send-email-hch@lst.de>
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper to queue up a callback.  CB_NULL has a bit of special casing
because it is special in the specification, but all other new callback
operations will be able to share code with this and a few more changes
to refactor the callback code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 47 ++++++++++++-----------------------------------
 fs/nfsd/nfs4state.c    |  4 +++-
 fs/nfsd/state.h        | 10 +++++++++-
 3 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 06e07e1..022edcf 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -49,12 +49,6 @@ static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
 
 /* Index of predefined Linux callback client operations */
 
-enum {
-	NFSPROC4_CLNT_CB_NULL = 0,
-	NFSPROC4_CLNT_CB_RECALL,
-	NFSPROC4_CLNT_CB_SEQUENCE,
-};
-
 #define to_delegation(cb) \
 	container_of(cb, struct nfs4_delegation, dl_recall)
 
@@ -749,24 +743,9 @@ static const struct rpc_call_ops nfsd4_cb_probe_ops = {
 
 static struct workqueue_struct *callback_wq;
 
-static void run_nfsd4_cb(struct nfsd4_callback *cb)
-{
-	queue_work(callback_wq, &cb->cb_work);
-}
-
 static void do_probe_callback(struct nfs4_client *clp)
 {
-	struct nfsd4_callback *cb = &clp->cl_cb_null;
-
-	cb->cb_clp = clp;
-
-	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL];
-	cb->cb_msg.rpc_argp = NULL;
-	cb->cb_msg.rpc_resp = NULL;
-
-	cb->cb_ops = &nfsd4_cb_probe_ops;
-
-	run_nfsd4_cb(cb);
+	return nfsd4_cb(&clp->cl_cb_null, clp, NFSPROC4_CLNT_CB_NULL);
 }
 
 /*
@@ -1005,7 +984,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	}
 	/* Yay, the callback channel's back! Restart any callbacks: */
 	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
-		run_nfsd4_cb(cb);
+		queue_work(callback_wq, &cb->cb_work);
 }
 
 static void
@@ -1046,21 +1025,19 @@ nfsd4_run_cb_recall(struct work_struct *w)
 	nfsd4_run_callback_rpc(cb);
 }
 
-void nfsd4_cb_recall(struct nfs4_delegation *dp)
+void nfsd4_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
+		enum nfsd4_cb_op op)
 {
-	struct nfsd4_callback *cb = &dp->dl_recall;
-	struct nfs4_client *clp = dp->dl_stid.sc_client;
-
-	dp->dl_retries = 1;
 	cb->cb_clp = clp;
-	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL];
+	cb->cb_msg.rpc_proc = &nfs4_cb_procedures[op];
 	cb->cb_msg.rpc_argp = cb;
 	cb->cb_msg.rpc_resp = cb;
+	if (op == NFSPROC4_CLNT_CB_NULL)
+		cb->cb_ops = &nfsd4_cb_probe_ops;
+	else
+		cb->cb_ops = &nfsd4_cb_recall_ops;
+ 	INIT_LIST_HEAD(&cb->cb_per_client);
+ 	cb->cb_done = true;
 
-	cb->cb_ops = &nfsd4_cb_recall_ops;
-
-	INIT_LIST_HEAD(&cb->cb_per_client);
-	cb->cb_done = true;
-
-	run_nfsd4_cb(&dp->dl_recall);
+	queue_work(callback_wq, &cb->cb_work);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8597fbe..90b909e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3383,7 +3383,9 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * it's safe to take a reference.
 	 */
 	atomic_inc(&dp->dl_stid.sc_count);
-	nfsd4_cb_recall(dp);
+	dp->dl_retries = 1;
+	nfsd4_cb(&dp->dl_recall, dp->dl_stid.sc_client,
+		 NFSPROC4_CLNT_CB_RECALL);
 }
 
 /* Called from break_lease() with i_lock held. */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 74b0700..515408b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -515,6 +515,13 @@ static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
 
+enum nfsd4_cb_op {
+	NFSPROC4_CLNT_CB_NULL = 0,
+	NFSPROC4_CLNT_CB_RECALL,
+	NFSPROC4_CLNT_CB_SEQUENCE,
+};
+
+
 struct nfsd4_compound_state;
 struct nfsd_net;
 
@@ -534,7 +541,8 @@ void nfsd4_run_cb_recall(struct work_struct *w);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern void nfsd4_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
+		enum nfsd4_cb_op op);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
-- 
1.9.1

