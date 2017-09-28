Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40248 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752470AbdI1RaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:12 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 07/10] NFSD create new stateid for async copy
Date: Thu, 28 Sep 2017 13:29:42 -0400
Message-ID: <20170928172945.50780-8-kolga@netapp.com>
In-Reply-To: <20170928172945.50780-1-kolga@netapp.com>
References: <20170928172945.50780-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Generate a new stateid to be used for reply to the asynchronous
COPY (this would also be used later by COPY_NOTIFY as well).
Associate the stateid with the parent OPEN/LOCK/DELEG stateid
that can be freed during the free of the parent stateid. However,
right now deciding to bind the lifetime to when the vfs copy
is done. This way don't need to keep the nfsd_net structure for
the callback. The drawback is that time copy state information
is available for query by OFFLOAD_STATUS is slightly less.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/netns.h     |  8 +++++++
 fs/nfsd/nfs4proc.c  | 31 ++++++++++++++++++-------
 fs/nfsd/nfs4state.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c    |  1 +
 fs/nfsd/state.h     | 14 ++++++++++++
 fs/nfsd/xdr4.h      |  2 ++
 6 files changed, 114 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 3714231..2c88a95 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -119,6 +119,14 @@ struct nfsd_net {
 	u32 clverifier_counter;
 
 	struct svc_serv *nfsd_serv;
+
+	/*
+	 * clientid and stateid data for construction of net unique COPY
+	 * stateids.
+	 */
+	u32		s2s_cp_cl_id;
+	struct idr	s2s_cp_stateids;
+	spinlock_t	s2s_cp_lock;
 };
 
 /* Simple check to find out if a given net was properly initialized */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 044af6b..3cddebb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1046,7 +1046,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 static __be32
 nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  stateid_t *src_stateid, struct file **src,
-		  stateid_t *dst_stateid, struct file **dst)
+		  stateid_t *dst_stateid, struct file **dst,
+		  struct nfs4_stid **stid)
 {
 	__be32 status;
 
@@ -1060,7 +1061,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    dst_stateid, WR_STATE, dst, NULL,
-					    NULL);
+					    stid);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
@@ -1091,7 +1092,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	__be32 status;
 
 	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
-				   &clone->cl_dst_stateid, &dst);
+				   &clone->cl_dst_stateid, &dst, NULL);
 	if (status)
 		goto out;
 
@@ -1123,8 +1124,6 @@ static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
 
 static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
 {
-	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-		sizeof(copy->cp_dst_stateid));
 	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
 	copy->cp_consecutive = 1;
 	copy->cp_synchronous = sync;
@@ -1188,6 +1187,8 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 	dst->fh_src = src->fh_src;
 	dst->fh_dst = src->fh_dst;
 	dst->net = src->net;
+	dst->stid = src->stid;
+	dst->cps = src->cps;
 }
 
 static void nfsd4_do_async_copy(struct work_struct *work)
@@ -1208,6 +1209,9 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
 	nfsd4_run_cb(&cb_copy->cp_cb);
 out:
+	list_del(&copy->cps->cp_list);
+	nfs4_free_cp_state(copy->cps);
+	nfs4_put_stid(copy->stid);
 	kfree(copy);
 }
 
@@ -1220,7 +1224,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 
 	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
 				   &copy->fh_src, &copy->cp_dst_stateid,
-				   &copy->fh_dst);
+				   &copy->fh_dst, &copy->stid);
 	if (status)
 		goto out;
 
@@ -1229,6 +1233,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		sizeof(struct knfsd_fh));
 	copy->net = SVC_NET(rqstp);
 	if (!copy->cp_synchronous) {
+		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 		struct nfsd4_copy *async_copy;
 
 		status = nfsd4_init_copy_res(copy, 0);
@@ -1237,9 +1242,19 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			status = nfserrno(-ENOMEM);
 			goto out;
 		}
+		copy->cps = nfs4_alloc_init_cp_state(nn, copy->stid);
+		if (!copy->cps) {
+			status = nfserrno(-ENOMEM);
+			kfree(async_copy);
+			goto out;
+		}
+		/* take a reference on the parent stateid so it's not
+		 * not freed by the copy compound
+		 */
+		atomic_inc(&copy->stid->sc_count);
+		memcpy(&copy->cp_res.cb_stateid, &copy->cps->cp_stateid,
+			sizeof(copy->cps->cp_stateid));
 		dup_copy_fields(copy, async_copy);
-		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-			sizeof(copy->cp_dst_stateid));
 		INIT_WORK(&async_copy->cp_work, nfsd4_do_async_copy);
 		queue_work(copy_wq, &async_copy->cp_work);
 	} else {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c89dae..be59baf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -658,6 +658,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	/* Will be incremented before return to client: */
 	atomic_set(&stid->sc_count, 1);
 	spin_lock_init(&stid->sc_lock);
+	INIT_LIST_HEAD(&stid->sc_cp_list);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -674,6 +675,66 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	return NULL;
 }
 
+/*
+ * Create a unique stateid_t to represent each COPY. Hang the copy
+ * stateids off the OPEN/LOCK/DELEG stateid from the client open
+ * the source file.
+ */
+struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
+					       struct nfs4_stid *p_stid)
+{
+	struct nfs4_cp_state *cps;
+	int new_id;
+
+	cps = kzalloc(sizeof(struct nfs4_cp_state), GFP_KERNEL);
+	if (!cps)
+		return NULL;
+	idr_preload(GFP_KERNEL);
+	spin_lock(&nn->s2s_cp_lock);
+	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, cps, 0, 0, GFP_NOWAIT);
+	spin_unlock(&nn->s2s_cp_lock);
+	idr_preload_end();
+	if (new_id < 0)
+		goto out_free;
+	cps->cp_stateid.si_opaque.so_id = new_id;
+	cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
+	cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
+	cps->cp_p_stid = p_stid;
+	INIT_LIST_HEAD(&cps->cp_list);
+	list_add(&cps->cp_list, &p_stid->sc_cp_list);
+
+	return cps;
+out_free:
+	kfree(cps);
+	return NULL;
+}
+
+void nfs4_free_cp_state(struct nfs4_cp_state *cps)
+{
+	struct nfsd_net *nn;
+
+	nn = net_generic(cps->cp_p_stid->sc_client->net, nfsd_net_id);
+	spin_lock(&nn->s2s_cp_lock);
+	idr_remove(&nn->s2s_cp_stateids, cps->cp_stateid.si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+
+	kfree(cps);
+}
+
+static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
+{
+	struct nfs4_cp_state *cps;
+
+	might_sleep();
+
+	while (!list_empty(&stid->sc_cp_list)) {
+		cps = list_first_entry(&stid->sc_cp_list, struct nfs4_cp_state,
+				       cp_list);
+		list_del(&cps->cp_list);
+		nfs4_free_cp_state(cps);
+	}
+}
+
 static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
@@ -819,6 +880,9 @@ static void block_delegations(struct knfsd_fh *fh)
 	}
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
 	spin_unlock(&clp->cl_lock);
+
+	nfs4_free_cp_statelist(s);
+
 	s->sc_free(s);
 	if (fp)
 		put_nfs4_file(fp);
@@ -6952,6 +7016,8 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
 	spin_lock_init(&nn->client_lock);
+	spin_lock_init(&nn->s2s_cp_lock);
+	idr_init(&nn->s2s_cp_stateids);
 
 	spin_lock_init(&nn->blocked_locks_lock);
 	INIT_LIST_HEAD(&nn->blocked_locks_lru);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6493df6..232270d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1241,6 +1241,7 @@ static __net_init int nfsd_init_net(struct net *net)
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
+	nn->s2s_cp_cl_id = nn->clientid_counter++;
 	return 0;
 
 out_idmap_error:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cfd13f0..8724955 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -93,6 +93,7 @@ struct nfs4_stid {
 #define NFS4_REVOKED_DELEG_STID 16
 #define NFS4_CLOSED_DELEG_STID 32
 #define NFS4_LAYOUT_STID 64
+	struct list_head	sc_cp_list;
 	unsigned char		sc_type;
 	stateid_t		sc_stateid;
 	spinlock_t		sc_lock;
@@ -102,6 +103,17 @@ struct nfs4_stid {
 };
 
 /*
+ * Keep a list of stateids issued by the COPY, associate it with the
+ * parent OPEN/LOCK/DELEG stateid. Used for lookup by
+ * OFFLOAD_CANCEL and OFFLOAD_STATUS (as well as COPY_NOTIFY)
+ */
+struct nfs4_cp_state {
+	stateid_t		cp_stateid;
+	struct list_head	cp_list;	/* per parent nfs4_stid */
+	struct nfs4_stid        *cp_p_stid;     /* pointer to parent */
+};
+
+/*
  * Represents a delegation stateid. The nfs4_client holds references to these
  * and they are put when it is being destroyed or when the delegation is
  * returned by the client:
@@ -607,6 +619,8 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
+struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn, struct nfs4_stid *p_stid);
+void nfs4_free_cp_state(struct nfs4_cp_state *cps);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index f7a94d3..4ccd43b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -536,6 +536,8 @@ struct nfsd4_copy {
 	struct file             *fh_src;
 	struct file             *fh_dst;
 	struct net              *net;
+	struct nfs4_stid        *stid;
+	struct nfs4_cp_state	*cps;
 };
 
 struct nfsd4_seek {
-- 
1.8.3.1

