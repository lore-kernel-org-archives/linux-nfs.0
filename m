From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 44/51] nfsd41: slab cache for current session
Date: Mon, 10 Nov 2008 22:55:48 +0200
Message-ID: <1226350548-11768-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57458 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbYKJU4B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:56:01 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use a separate slab cache for the current session so that an NFSv4.1 server
responding to NFSv4.0 requests uses only the compound state slab.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   36 +++++++++++++++++-------------------
 fs/nfsd/nfs4state.c       |   28 ++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |    2 ++
 3 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index deefba1..eaebe5b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -942,9 +942,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	struct nfsd4_compound_state *cstate = NULL;
 	int		slack_bytes;
 	__be32		status = nfs_ok;
-#if defined(CONFIG_NFSD_V4_1)
-	struct current_session *current_ses = NULL;
-#endif /* CONFIG_NFSD_V4_1 */
 
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
@@ -970,6 +967,19 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (cstate == NULL)
 		goto out;
 
+#ifdef CONFIG_NFSD_V4_1
+	/* cstate->current_ses could be set revisiting a deferal */
+	if (args->minorversion == 1 && !cstate->current_ses) {
+		cstate->current_ses = nfsd41_current_session_alloc();
+		if (cstate->current_ses == NULL) {
+			/* still nfserr_resource */
+			nfsd4_cstate_free(cstate, rqstp->rq_deferred);
+			goto out;
+		}
+		cstate->current_ses->cs_slot = NULL;
+	}
+#endif /* CONFIG_NFSD_V4_1 */
+
 	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
 		dprintk("%s Resuming deferred processing\n", __func__);
 		resp->opcnt = cstate->last_op_cnt;
@@ -985,17 +995,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	rqstp->rq_defer_data = cstate;
 	rqstp->rq_save_state = nfsd4_save_deferred_state;
 
-#if defined(CONFIG_NFSD_V4_1)
-	if (args->minorversion == 1) {
-		/* FIXME: use kmem_cache */
-		current_ses = kzalloc(sizeof(*current_ses), GFP_KERNEL);
-		if (current_ses == NULL)
-			goto out_free;
-	}
-	/* DM: current_ses must be NULL for minorversion 0 */
-	cstate->current_ses = current_ses;
-#endif /* CONFIG_NFSD_V4_1 */
-
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		cstate->last_op_p = resp->p;
@@ -1081,12 +1080,11 @@ encode_op:
 		return status;
 	}
 
-out_free:
 #if defined(CONFIG_NFSD_V4_1)
-	if (current_ses) {
-		struct nfs41_slot *cs_slot = current_ses->cs_slot;
+	if (cstate->current_ses) {
+		struct nfs41_slot *cs_slot = cstate->current_ses->cs_slot;
 		if (cs_slot) {
-			if (op && op->status != nfserr_dropit) {
+			if (status != nfserr_dropit) {
 				dprintk("%s: SET SLOT STATE TO AVAILABLE\n",
 					__func__);
 				nfs41_set_slot_state(cs_slot,
@@ -1094,7 +1092,7 @@ out_free:
 			}
 			nfs41_put_session(cs_slot->sl_session);
 		}
-		kfree(current_ses);
+		nfsd41_current_session_free(cstate->current_ses);
 	}
 #endif /* CONFIG_NFSD_V4_1 */
 	nfsd4_cstate_free(cstate, rqstp->rq_deferred);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8fd7704..ba6ab19 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -102,6 +102,9 @@ static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
 static struct kmem_cache *cstate_slab;
+#ifdef CONFIG_NFSD_V4_1
+static struct kmem_cache *current_session_slab;
+#endif /* CONFIG_NFSD_V4_1 */
 
 #define BUG_ON_UNLOCKED_STATE() BUG_ON(mutex_trylock(&client_mutex))
 
@@ -479,6 +482,19 @@ free_session(struct kref *kref)
 	kfree(ses->se_slots);
 	kfree(ses);
 }
+
+void
+nfsd41_current_session_free(struct current_session *cses)
+{
+	kmem_cache_free(current_session_slab, cses);
+}
+
+struct current_session *
+nfsd41_current_session_alloc(void)
+{
+	return kmem_cache_alloc(current_session_slab, GFP_KERNEL);
+}
+
 #endif /* CONFIG_NFSD_V4_1 */
 
 void
@@ -511,6 +527,9 @@ nfsd4_cstate_alloc(struct svc_rqst *rqstp)
 	fh_init(&cstate->current_fh, NFS4_FHSIZE);
 	fh_init(&cstate->save_fh, NFS4_FHSIZE);
 	cstate->replay_owner = NULL;
+#ifdef CONFIG_NFSD_V4_1
+	cstate->current_ses = NULL;
+#endif /* CONFIG_NFSD_V4_1 */
 out:
 	return cstate;
 }
@@ -1565,6 +1584,9 @@ nfsd4_free_slabs(void)
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
 	nfsd4_free_slab(&cstate_slab);
+#ifdef CONFIG_NFSD_V4_1
+	nfsd4_free_slab(&current_session_slab);
+#endif /* CONFIG_NFSD_V4_1 */
 }
 
 static int
@@ -1590,6 +1612,12 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfsd4_compound_state), 0, 0, NULL);
 	if (cstate_slab == NULL)
 		goto out_nomem;
+#ifdef CONFIG_NFSD_V4_1
+	current_session_slab = kmem_cache_create("nfsd4_current_sessions",
+			sizeof(struct current_session), 0, 0, NULL);
+	if (current_session_slab == NULL)
+		goto out_nomem;
+#endif /* CONFIG_NFSD_V4_1 */
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index a0b4f00..fc42fba 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -532,6 +532,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
 #if defined(CONFIG_NFSD_V4_1)
+extern void nfsd41_current_session_free(struct current_session *cses);
+extern struct current_session *nfsd41_current_session_alloc(void);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_exchange_id *);
-- 
1.6.0.2

