From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 43/51] nfsd: deferral processing
Date: Mon, 10 Nov 2008 22:55:27 +0200
Message-ID: <1226350527-11731-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57454 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbYKJUzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:55:40 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Save the struct nfsd4_compound_state and set the save_state callback for
each request for potential deferral handling.

If an NFSv4 operation causes a deferral, the save_state callback is called
by svc_defer which saves the defer_data with the deferral, and sets the
restore_state deferral callback.

fh_put is called so that the deferral is not referencing the file handles,
allowing umount of the file system.

Use a slab cache for nfsd4_compound_state allocation.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   63 ++++++++++++++++++++++++--------------------
 fs/nfsd/nfs4state.c       |   40 ++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |    5 +++
 3 files changed, 79 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 72fd645..deefba1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -860,29 +860,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 		nfsdstats.nfs4_opcount[opnum]++;
 }
 
-static void cstate_free(struct nfsd4_compound_state *cstate)
-{
-	if (cstate == NULL)
-		return;
-	fh_put(&cstate->current_fh);
-	fh_put(&cstate->save_fh);
-	BUG_ON(cstate->replay_owner);
-	kfree(cstate);
-}
-
-static struct nfsd4_compound_state *cstate_alloc(void)
-{
-	struct nfsd4_compound_state *cstate;
-
-	cstate = kmalloc(sizeof(struct nfsd4_compound_state), GFP_KERNEL);
-	if (cstate == NULL)
-		return NULL;
-	fh_init(&cstate->current_fh, NFS4_FHSIZE);
-	fh_init(&cstate->save_fh, NFS4_FHSIZE);
-	cstate->replay_owner = NULL;
-	return cstate;
-}
-
 /*
  * RPC restore deferral state callback
  */
@@ -891,8 +868,7 @@ nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
 {
 	dprintk("--> %s dreq %p\n", __func__, dreq);
 
-	nfsd4_clear_respages(dreq->respages, dreq->resused);
-	cstate_free(dreq->defer_data); /* kfree the cstate */
+	nfsd4_cstate_free(dreq->defer_data, dreq); /* kfree the cstate */
 }
 
 /*
@@ -961,11 +937,11 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		    struct nfsd4_compoundargs *args,
 		    struct nfsd4_compoundres *resp)
 {
-	struct nfsd4_op	*op = NULL;
+	struct nfsd4_op	*op;
 	struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = NULL;
 	int		slack_bytes;
-	__be32		status;
+	__be32		status = nfs_ok;
 #if defined(CONFIG_NFSD_V4_1)
 	struct current_session *current_ses = NULL;
 #endif /* CONFIG_NFSD_V4_1 */
@@ -990,10 +966,25 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		goto out;
 
 	status = nfserr_resource;
-	cstate = cstate_alloc();
+	cstate = nfsd4_cstate_alloc(rqstp);
 	if (cstate == NULL)
 		goto out;
 
+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
+		dprintk("%s Resuming deferred processing\n", __func__);
+		resp->opcnt = cstate->last_op_cnt;
+		resp->p = cstate->last_op_p;
+
+		/* verify the current and save file handles that were
+		 * fh_put at deferral. */
+		fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
+		fh_verify(rqstp, &cstate->save_fh, 0, NFSD_MAY_NOP);
+	}
+
+	/* set for potential deferral */
+	rqstp->rq_defer_data = cstate;
+	rqstp->rq_save_state = nfsd4_save_deferred_state;
+
 #if defined(CONFIG_NFSD_V4_1)
 	if (args->minorversion == 1) {
 		/* FIXME: use kmem_cache */
@@ -1007,6 +998,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
+		cstate->last_op_p = resp->p;
 		op = &args->ops[resp->opcnt++];
 
 		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
@@ -1076,6 +1068,19 @@ encode_op:
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
+	/* Done with any potential deferral */
+	rqstp->rq_defer_data = cstate;
+	rqstp->rq_save_state = NULL;
+
+	if (status == nfserr_dropit) {
+		dprintk("%s Drop it!\n", __func__);
+
+		/* svc_defer() has called the rq_save_state() callback
+		 * to cache the partially processed compound. */
+		cstate->last_op_cnt = resp->opcnt - 1;
+		return status;
+	}
+
 out_free:
 #if defined(CONFIG_NFSD_V4_1)
 	if (current_ses) {
@@ -1092,7 +1097,7 @@ out_free:
 		kfree(current_ses);
 	}
 #endif /* CONFIG_NFSD_V4_1 */
-	cstate_free(cstate);
+	nfsd4_cstate_free(cstate, rqstp->rq_deferred);
 out:
 	nfsd4_release_compoundargs(args);
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ae6de38..8fd7704 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -101,6 +101,7 @@ static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
+static struct kmem_cache *cstate_slab;
 
 #define BUG_ON_UNLOCKED_STATE() BUG_ON(mutex_trylock(&client_mutex))
 
@@ -480,6 +481,40 @@ free_session(struct kref *kref)
 }
 #endif /* CONFIG_NFSD_V4_1 */
 
+void
+nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
+		  struct svc_deferred_req *dreq)
+{
+	if (dreq && dreq->release_state)
+		nfsd4_clear_respages(dreq->respages, dreq->resused);
+	if (cstate == NULL)
+		return;
+	fh_put(&cstate->current_fh);
+	fh_put(&cstate->save_fh);
+	BUG_ON(cstate->replay_owner);
+	kmem_cache_free(cstate_slab, cstate);
+}
+
+struct nfsd4_compound_state *
+nfsd4_cstate_alloc(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compound_state *cstate;
+
+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
+		dprintk("%s Revisit deferred request\n", __func__);
+		cstate = rqstp->rq_deferred->defer_data;
+		goto out;
+	}
+	cstate = kmem_cache_alloc(cstate_slab, GFP_KERNEL);
+	if (cstate == NULL)
+		return NULL;
+	fh_init(&cstate->current_fh, NFS4_FHSIZE);
+	fh_init(&cstate->save_fh, NFS4_FHSIZE);
+	cstate->replay_owner = NULL;
+out:
+	return cstate;
+}
+
 static inline void
 renew_client(struct nfs4_client *clp)
 {
@@ -1529,6 +1564,7 @@ nfsd4_free_slabs(void)
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
+	nfsd4_free_slab(&cstate_slab);
 }
 
 static int
@@ -1550,6 +1586,10 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_delegation), 0, 0, NULL);
 	if (deleg_slab == NULL)
 		goto out_nomem;
+	cstate_slab = kmem_cache_create("nfsd4_compound_states",
+			sizeof(struct nfsd4_compound_state), 0, 0, NULL);
+	if (cstate_slab == NULL)
+		goto out_nomem;
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 01fb139..a0b4f00 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -48,6 +48,8 @@ struct nfsd4_compound_state {
 	struct svc_fh current_fh;
 	struct svc_fh save_fh;
 	struct nfs4_stateowner *replay_owner;
+	__be32 *last_op_p;
+	u32 last_op_cnt;
 #if defined(CONFIG_NFSD_V4_1)
 	struct current_session *current_ses;
 #endif /* CONFIG_NFSD_V4_1 */
@@ -520,6 +522,9 @@ extern void nfsd4_cache_rqst_pages(struct svc_rqst *rqstp,
 		struct page **respages, short *resused);
 extern void nfsd4_restore_rqst_pages(struct svc_rqst *rqstp,
 		struct page **respages, short resused);
+extern struct nfsd4_compound_state *nfsd4_cstate_alloc(struct svc_rqst *rqstp);
+extern void nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
+		struct svc_deferred_req *dreq);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.6.0.2

