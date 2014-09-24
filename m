Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:39528 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbaIXKRA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 06:17:00 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] nfsd: split nfsd4_callback initialization and use
Date: Wed, 24 Sep 2014 12:19:18 +0200
Message-Id: <1411553959-5280-4-git-send-email-hch@lst.de>
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split out initializing the nfs4_callback structure from using it.  For
the NULL callback this gets rid of tons of pointless re-initializations.

Note that I don't quite understand what protects us from running multiple
NULL callbacks at the same time, but at least this chance doesn't make
it worse..

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4callback.c | 14 ++++++--------
 fs/nfsd/nfs4state.c    |  8 +++++---
 fs/nfsd/state.h        |  3 ++-
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 022edcf..6d9d947 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -743,11 +743,6 @@ static const struct rpc_call_ops nfsd4_cb_probe_ops = {
 
 static struct workqueue_struct *callback_wq;
 
-static void do_probe_callback(struct nfs4_client *clp)
-{
-	return nfsd4_cb(&clp->cl_cb_null, clp, NFSPROC4_CLNT_CB_NULL);
-}
-
 /*
  * Poke the callback thread to process any updates to the callback
  * parameters, and send a null probe.
@@ -756,7 +751,7 @@ void nfsd4_probe_callback(struct nfs4_client *clp)
 {
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
-	do_probe_callback(clp);
+	nfsd4_run_cb(&clp->cl_cb_null);
 }
 
 void nfsd4_probe_callback_sync(struct nfs4_client *clp)
@@ -912,7 +907,7 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
 	 * instead, nfsd4_run_cb_null() will detect the killed
 	 * client, destroy the rpc client, and stop:
 	 */
-	do_probe_callback(clp);
+	nfsd4_run_cb(&clp->cl_cb_null);
 	flush_workqueue(callback_wq);
 }
 
@@ -1025,7 +1020,7 @@ nfsd4_run_cb_recall(struct work_struct *w)
 	nfsd4_run_callback_rpc(cb);
 }
 
-void nfsd4_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
+void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 		enum nfsd4_cb_op op)
 {
 	cb->cb_clp = clp;
@@ -1038,6 +1033,9 @@ void nfsd4_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 		cb->cb_ops = &nfsd4_cb_recall_ops;
  	INIT_LIST_HEAD(&cb->cb_per_client);
  	cb->cb_done = true;
+}
 
+void nfsd4_run_cb(struct nfsd4_callback *cb)
+{
 	queue_work(callback_wq, &cb->cb_work);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 90b909e..5e5012f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -650,6 +650,9 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
+	dp->dl_retries = 1;
+	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
+		 NFSPROC4_CLNT_CB_RECALL);
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
 	return dp;
 out_dec:
@@ -1866,6 +1869,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 		free_client(clp);
 		return NULL;
 	}
+	nfsd4_init_cb(&clp->cl_cb_null, clp, NFSPROC4_CLNT_CB_NULL);
 	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_run_cb_null);
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
@@ -3383,9 +3387,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * it's safe to take a reference.
 	 */
 	atomic_inc(&dp->dl_stid.sc_count);
-	dp->dl_retries = 1;
-	nfsd4_cb(&dp->dl_recall, dp->dl_stid.sc_client,
-		 NFSPROC4_CLNT_CB_RECALL);
+	nfsd4_run_cb(&dp->dl_recall);
 }
 
 /* Called from break_lease() with i_lock held. */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 515408b..4d10e1d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -541,8 +541,9 @@ void nfsd4_run_cb_recall(struct work_struct *w);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-extern void nfsd4_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
+extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 		enum nfsd4_cb_op op);
+extern void nfsd4_run_cb(struct nfsd4_callback *cb);
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
-- 
1.9.1

