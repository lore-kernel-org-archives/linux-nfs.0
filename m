From: andros@netapp.com
Subject: [PATCH 3/3] NFSD deferral processing
Date: Wed, 22 Oct 2008 14:12:06 -0400
Message-ID: <1224699126-3762-4-git-send-email-andros@netapp.com>
References: <>
 <1224699126-3762-1-git-send-email-andros@netapp.com>
 <1224699126-3762-2-git-send-email-andros@netapp.com>
 <1224699126-3762-3-git-send-email-andros@netapp.com>
Cc: androsadamson@gmail.com, Andy Adamson <andros@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61319 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757481AbYJVSMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:12:30 -0400
In-Reply-To: <1224699126-3762-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use a slab cache for nfsd4_compound_state allocation

Save the struct nfsd4_compound_state and set the save_state callback for
each request for potential deferral handling.

If an NFSv4 operation causes a deferral, the save_state callback is called
by svc_defer which saves the defer_data with the deferral, and sets the
restore_state deferral callback.

fh_put is called so that the deferral is not referencing the file handles,
allowing umount of the file system.

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 fs/nfsd/nfs4proc.c        |   45 ++++++++++++++++++---------------------------
 fs/nfsd/nfs4state.c       |   37 +++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h |    6 ++++++
 3 files changed, 61 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 97f2d25..c556e77 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -813,29 +813,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
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
  * RPC deferral callbacks
  */
@@ -925,8 +902,7 @@ nfsd4_return_deferred_respages(struct svc_deferred_req *dreq)
 static void
 nfsd4_release_deferred_state(struct svc_deferred_req *dreq)
 {
-	nfsd4_return_deferred_respages(dreq);
-	cstate_free(dreq->defer_data);
+	nfsd4_cstate_free(dreq->defer_data, dreq);
 }
 
 static void
@@ -1015,12 +991,23 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		goto out;
 
 	status = nfserr_resource;
-	cstate = cstate_alloc();
+	cstate = nfsd4_cstate_alloc(rqstp);
 	if (cstate == NULL)
 		goto out;
 
+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
+		resp->opcnt = cstate->last_op_cnt;
+		resp->p = cstate->last_op_p;
+		fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
+		fh_verify(rqstp, &cstate->save_fh, 0, NFSD_MAY_NOP);
+	}
+	/* Reset to NULL in svc_process */
+	rqstp->rq_defer_data = cstate;
+	rqstp->rq_save_state = nfsd4_save_deferred_state;
+
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
+		cstate->last_op_p = resp->p;
 		op = &args->ops[resp->opcnt++];
 
 		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
@@ -1085,8 +1072,12 @@ encode_op:
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
+	if (status == nfserr_dropit) {
+		cstate->last_op_cnt = resp->opcnt - 1;
+		return status;
+	}
 
-	cstate_free(cstate);
+	nfsd4_cstate_free(cstate, rqstp->rq_deferred);
 out:
 	nfsd4_release_compoundargs(args);
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0cc7ff5..6ab67fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -90,6 +90,7 @@ static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
+static struct kmem_cache *cstate_slab;
 
 void
 nfs4_lock_state(void)
@@ -441,6 +442,37 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	return clp;
 }
 
+void nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
+		       struct svc_deferred_req *dreq)
+{
+	if (dreq && dreq->release_state)
+		nfsd4_return_deferred_respages(dreq);
+	if (cstate == NULL)
+		return;
+	fh_put(&cstate->current_fh);
+	fh_put(&cstate->save_fh);
+	BUG_ON(cstate->replay_owner);
+	kmem_cache_free(cstate_slab, cstate);
+}
+
+struct nfsd4_compound_state *nfsd4_cstate_alloc(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compound_state *cstate;
+
+	if (rqstp->rq_deferred && rqstp->rq_deferred->defer_data) {
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
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 {
 	memcpy(target->cl_verifier.data, source->data,
@@ -940,6 +972,7 @@ nfsd4_free_slabs(void)
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
+	nfsd4_free_slab(&cstate_slab);
 }
 
 static int
@@ -961,6 +994,10 @@ nfsd4_init_slabs(void)
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
index 27bd3e3..ced602c 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -48,6 +48,8 @@ struct nfsd4_compound_state {
 	struct svc_fh current_fh;
 	struct svc_fh save_fh;
 	struct nfs4_stateowner *replay_owner;
+	__be32 *last_op_p;
+	u32 last_op_cnt;
 };
 
 struct nfsd4_change_info {
@@ -442,6 +444,10 @@ void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, __be32 *buffer, int *countp,
 		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
+extern void nfsd4_return_deferred_respages(struct svc_deferred_req *dreq);
+extern struct nfsd4_compound_state *nfsd4_cstate_alloc(struct svc_rqst *rqstp);
+extern void nfsd4_cstate_free(struct nfsd4_compound_state *cstate,
+		struct svc_deferred_req *dreq);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.5.4.3

