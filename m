Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:31185 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933238AbdGKQo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:56 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 38/42] NFSD create new stateid for async copy
Date: Tue, 11 Jul 2017 12:44:12 -0400
Message-ID: <20170711164416.1982-39-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Previously dst copy stateid was used as reply to the asynchronous
copy. Instead, generate a new stateid and the destination server
will keep a list of the stateids. If it receives a cancel, it can
decide to forego sending the CB_OFFLOAD.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 56 +++++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/state.h    |  3 +++
 fs/nfsd/xdr4.h     |  2 ++
 3 files changed, 50 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b93713d..c411887 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1039,7 +1039,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 static __be32
 nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  stateid_t *src_stateid, struct file **src,
-		  stateid_t *dst_stateid, struct file **dst)
+		  stateid_t *dst_stateid, struct file **dst,
+		  struct nfs4_stid **stid)
 {
 	__be32 status;
 
@@ -1053,7 +1054,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    dst_stateid, WR_STATE, dst, NULL,
-					    NULL);
+					    stid);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
@@ -1083,7 +1084,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	__be32 status;
 
 	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
-				   &clone->cl_dst_stateid, &dst);
+				   &clone->cl_dst_stateid, &dst, NULL);
 	if (status)
 		goto out;
 
@@ -1241,7 +1242,8 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	/* Verify the destination stateid and set dst struct file*/
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&copy->cp_dst_stateid,
-					WR_STATE, &copy->fh_dst, NULL, NULL);
+					WR_STATE, &copy->fh_dst, NULL,
+					&copy->stid);
 	if (status) {
 		ss_mnt = ERR_PTR(be32_to_cpu(status));
 		goto out;
@@ -1303,7 +1305,7 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 
 	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
 				   &copy->fh_src, &copy->cp_dst_stateid,
-				   &copy->fh_dst);
+				   &copy->fh_dst, &copy->stid);
 	if (status)
 		goto out;
 
@@ -1343,8 +1345,6 @@ static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
 
 static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
 {
-	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-		sizeof(copy->cp_dst_stateid));
 	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
 	copy->cp_consecutive = 1;
 	copy->cp_synchronous = sync;
@@ -1360,6 +1360,7 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 	size_t bytes_to_copy;
 	u64 src_pos = copy->cp_src_pos;
 	u64 dst_pos = copy->cp_dst_pos;
+	bool cancelled = false;
 
 	do {
 		bytes_to_copy = min_t(u64, bytes_total, MAX_RW_COUNT);
@@ -1371,7 +1372,12 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 		copy->cp_res.wr_bytes_written += bytes_copied;
 		src_pos += bytes_copied;
 		dst_pos += bytes_copied;
-	} while (bytes_total > 0 && !copy->cp_synchronous);
+		if (!copy->cp_synchronous) {
+			spin_lock(&copy->cps->cp_lock);
+			cancelled = copy->cps->cp_cancelled;
+			spin_unlock(&copy->cps->cp_lock);
+		}
+	} while (bytes_total > 0 && !copy->cp_synchronous && !cancelled);
 	return bytes_copied;
 }
 
@@ -1416,6 +1422,8 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 	dst->fh_dst = src->fh_dst;
 	dst->ss_mnt = src->ss_mnt;
 	dst->net = src->net;
+	dst->stid = src->stid;
+	dst->cps = src->cps;
 }
 
 static void nfsd4_do_async_copy(struct work_struct *work)
@@ -1434,6 +1442,10 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			goto out_err;
 	}
 	copy->nfserr = nfsd4_do_copy(copy, 0);
+
+	if (copy->cps->cp_cancelled)
+		goto out;
+
 	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 	if (!cb_copy)
 		goto out;
@@ -1445,6 +1457,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
 	nfsd4_run_cb(&cb_copy->cp_cb);
 out:
+	nfs4_put_stid(copy->stid);
 	kfree(copy);
 	return;
 out_err:
@@ -1475,15 +1488,26 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		sizeof(struct knfsd_fh));
 	copy->net = SVC_NET(rqstp);
 	if (!copy->cp_synchronous) {
+		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 		struct nfsd4_copy *async_copy;
 
 		status = nfsd4_init_copy_res(copy, 0);
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 		if (!async_copy)
 			goto out_err;
+		copy->cps = nfs4_alloc_init_cp_state(nn, nn->nfsd4_lease,
+				copy->stid);
+		if (!copy->cps)
+			goto out_err;
+		/* take a reference on the parent stateid so it's not
+		 * not freed by the copy compound
+		 */
+		atomic_inc(&copy->stid->sc_count);
+		copy->cps->cp_dst_async = true;
+		spin_lock_init(&copy->cps->cp_lock);
+		memcpy(&copy->cp_res.cb_stateid, &copy->cps->cp_stateid,
+			sizeof(copy->cps->cp_stateid));
 		dup_copy_fields(copy, async_copy);
-		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
-			sizeof(copy->cp_dst_stateid));
 		INIT_WORK(&async_copy->cp_work, nfsd4_do_async_copy);
 		queue_work(copy_wq, &async_copy->cp_work);
 	} else {
@@ -1596,7 +1620,17 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	struct nfs4_cp_state *state = NULL;
 
 	status = find_cp_state(nn, &os->stateid, &state);
-	if (!status) {
+	/* on the source server, remove stateid from list of acceptable
+	 * stateid to force reads to fail. on the destination server,
+	 * callback offload stateids shouldn't be removed and instead
+	 * mark the offload copy state to be cancelled.
+	 */
+	if (state) {
+		spin_lock(&state->cp_lock);
+		state->cp_cancelled = true;
+		spin_unlock(&state->cp_lock);
+	}
+	if (!status && !state->cp_dst_async) {
 		list_del(&state->cp_list);
 		nfs4_free_cp_state(state);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fa749763..70ee3fe 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -114,6 +114,9 @@ struct nfs4_cp_state {
 	struct nfs4_stid	*cp_p_stid;	/* pointer to parent */
 	bool			cp_active;	/* has the copy started */
 	unsigned long		cp_timeout;	/* copy timeout */
+	bool			cp_dst_async;	/* async copy on dst server */
+	bool			cp_cancelled;	/* copy cancelled */
+	spinlock_t		cp_lock;
 };
 
 /*
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d75e530..ae5c6e3 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -547,6 +547,8 @@ struct nfsd4_copy {
 	struct file		*fh_dst;
 	struct vfsmount		*ss_mnt;
 	struct net		*net;
+	struct nfs4_stid	*stid;
+	struct nfs4_cp_state	*cps;
 };
 
 struct nfsd4_seek {
-- 
1.8.3.1

