Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:63444 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751002AbeDMRCh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:02:37 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 6/9] NFSD create new stateid for async copy
Date: Fri, 13 Apr 2018 13:01:55 -0400
Message-ID: <20180413170158.17589-7-kolga@netapp.com>
In-Reply-To: <20180413170158.17589-1-kolga@netapp.com>
References: <20180413170158.17589-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Generate a new stateid to be used for reply to the asynchronous
COPY. Right now deciding to bind the lifetime to when the vfs copy
is done. This way don't need to keep the nfsd_net structure for
the callback. The drawback is that time copy state information
is available for query by OFFLOAD_STATUS is slightly less.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/netns.h     |  8 ++++++++
 fs/nfsd/nfs4proc.c  | 14 ++++++++------
 fs/nfsd/nfs4state.c | 32 ++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c    |  1 +
 fs/nfsd/state.h     |  3 +++
 fs/nfsd/xdr4.h      |  2 ++
 6 files changed, 54 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 36358d4..e83cf6e 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -122,6 +122,14 @@ struct nfsd_net {
 
 	wait_queue_head_t ntf_wq;
 	atomic_t ntf_refcnt;
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
index 0650271..9d5f0d0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1120,8 +1120,6 @@ static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
 
 static __be32 nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
 {
-	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-		sizeof(copy->cp_dst_stateid));
 	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
 	copy->cp_synchronous = sync;
 	gen_boot_verifier(&copy->cp_res.wr_verifier, copy->cp_clp->net);
@@ -1179,10 +1177,12 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 	dst->cp_clp = src->cp_clp;
 	dst->file_dst = get_file(src->file_dst);
 	dst->file_src = get_file(src->file_src);
+	memcpy(&dst->cp_stateid, &src->cp_stateid, sizeof(src->cp_stateid));
 }
 
 static void cleanup_async_copy(struct nfsd4_copy *copy)
 {
+	nfs4_free_cp_state(copy);
 	fput(copy->file_dst);
 	fput(copy->file_src);
 	spin_lock(&copy->cp_clp->async_lock);
@@ -1229,16 +1229,18 @@ static int nfsd4_do_async_copy(void *data)
 	copy->cp_clp = cstate->clp;
 	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
 		sizeof(struct knfsd_fh));
-	/* for now disable asynchronous copy feature */
-	copy->cp_synchronous = 1;
 	if (!copy->cp_synchronous) {
+		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 		status = nfserrno(-ENOMEM);
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 		if (!async_copy)
 			goto out;
+		if (!nfs4_init_cp_state(nn, copy))
+			goto out;
+		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
+			sizeof(copy->cp_stateid));
 		dup_copy_fields(copy, async_copy);
-		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-			sizeof(copy->cp_dst_stateid));
 		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
 				async_copy, "%s", "copy thread");
 		if (IS_ERR(async_copy->copy_task))
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1094ade..3416d29 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -713,6 +713,36 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	return NULL;
 }
 
+/*
+ * Create a unique stateid_t to represent each COPY.
+ */
+int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
+{
+	int new_id;
+
+	idr_preload(GFP_KERNEL);
+	spin_lock(&nn->s2s_cp_lock);
+	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, copy, 0, 0, GFP_NOWAIT);
+	spin_unlock(&nn->s2s_cp_lock);
+	idr_preload_end();
+	if (new_id < 0)
+		return 0;
+	copy->cp_stateid.si_opaque.so_id = new_id;
+	copy->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
+	copy->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
+	return 1;
+}
+
+void nfs4_free_cp_state(struct nfsd4_copy *copy)
+{
+	struct nfsd_net *nn;
+
+	nn = net_generic(copy->cp_clp->net, nfsd_net_id);
+	spin_lock(&nn->s2s_cp_lock);
+	idr_remove(&nn->s2s_cp_stateids, copy->cp_stateid.si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+}
+
 static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
@@ -7124,6 +7154,8 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
 	spin_lock_init(&nn->client_lock);
+	spin_lock_init(&nn->s2s_cp_lock);
+	idr_init(&nn->s2s_cp_stateids);
 
 	spin_lock_init(&nn->blocked_locks_lock);
 	INIT_LIST_HEAD(&nn->blocked_locks_lru);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b44..63edf68 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1241,6 +1241,7 @@ static __net_init int nfsd_init_net(struct net *net)
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
+	nn->s2s_cp_cl_id = nn->clientid_counter++;
 
 	atomic_set(&nn->ntf_refcnt, 0);
 	init_waitqueue_head(&nn->ntf_wq);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 491030e..d8893427 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -602,6 +602,7 @@ struct nfsd4_blocked_lock {
 
 struct nfsd4_compound_state;
 struct nfsd_net;
+struct nfsd4_copy;
 
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
@@ -611,6 +612,8 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
+int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy);
+void nfs4_free_cp_state(struct nfsd4_copy *copy);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ed49646..5af9eae 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -538,6 +538,8 @@ struct nfsd4_copy {
 	struct file             *file_src;
 	struct file             *file_dst;
 
+	stateid_t		cp_stateid;
+
 	struct list_head	copies;
 	struct task_struct	*copy_task;
 };
-- 
1.8.3.1

