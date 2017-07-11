Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:38055 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934055AbdGKQo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:56 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 35/42] NFSD first draft of async copy
Date: Tue, 11 Jul 2017 12:44:09 -0400
Message-ID: <20170711164416.1982-36-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upong receiving copy request for the inter copy, nfsd will
establish the mount to the source server.

Asynchronous copies are handled by a single threaded workqueue.
If we get asynchronous request, make sure to copy the needed
arguments/state from the stack before starting the copy. Then
queue work and reply back to the client indicating copy is
asynchronous.

nfsd_copy_file_range() will copy in 4MBchunk so do a loop over
the total number of bytes need to copy. In case a failure
happens in the middle, we can return an error as well as how
much we copied so far. Once done creating a workitem for the
callback workqueue and send CB_OFFLOAD with the results.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 224 +++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c |   9 ++-
 fs/nfsd/state.h     |   2 +
 fs/nfsd/xdr4.h      |  11 +++
 4 files changed, 197 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5dd8278..a977142 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -77,6 +77,21 @@
 { }
 #endif
 
+static struct workqueue_struct *copy_wq;
+
+int nfsd4_create_copy_queue(void)
+{
+	copy_wq = create_singlethread_workqueue("nfsd4_copy");
+	if (!copy_wq)
+		return -ENOMEM;
+	return 0;
+}
+
+void nfsd4_destroy_copy_queue(void)
+{
+	destroy_workqueue(copy_wq);
+}
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static u32 nfsd_attrmask[] = {
@@ -1210,21 +1225,17 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 static struct vfsmount *
 nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
 			struct nfsd4_compound_state *cstate,
-			struct nfsd4_copy *copy, struct file **src,
-			struct file **dst)
+			struct nfsd4_copy *copy)
 {
 	struct svc_fh *s_fh = NULL;
 	stateid_t *s_stid = &copy->cp_src_stateid;
-	struct nfs_fh fh;
-	nfs4_stateid stateid;
-	struct file *filp;
 	struct vfsmount *ss_mnt;
 	__be32 status;
 
 	/* Verify the destination stateid and set dst struct file*/
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&copy->cp_dst_stateid,
-					WR_STATE, dst, NULL, NULL);
+					WR_STATE, &copy->fh_dst, NULL, NULL);
 	if (status) {
 		ss_mnt = ERR_PTR(be32_to_cpu(status));
 		goto out;
@@ -1238,19 +1249,11 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 		goto out;
 
 	s_fh = &cstate->save_fh;
-
-	fh.size = s_fh->fh_handle.fh_size;
-	memcpy(fh.data, &s_fh->fh_handle.fh_base, fh.size);
-	stateid.seqid = s_stid->si_generation;
-	memcpy(stateid.other, (void *)&s_stid->si_opaque,
+	copy->c_fh.size = s_fh->fh_handle.fh_size;
+	memcpy(copy->c_fh.data, &s_fh->fh_handle.fh_base, copy->c_fh.size);
+	copy->stateid.seqid = s_stid->si_generation;
+	memcpy(copy->stateid.other, (void *)&s_stid->si_opaque,
 		sizeof(stateid_opaque_t));
-
-	filp =  nfs42_ssc_open(ss_mnt, &fh, &stateid);
-	if (IS_ERR(filp)) {
-		nfsd4_interssc_disconnect(ss_mnt);
-		return ERR_CAST(filp);
-	}
-	*src = filp;
 out:
 	return ss_mnt;
 }
@@ -1272,8 +1275,7 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 static struct vfsmount *
 nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
 			struct nfsd4_compound_state *cstate,
-			struct nfsd4_copy *copy, struct file **src,
-			struct file **dst)
+			struct nfsd4_copy *copy)
 {
 	return ERR_PTR(-EINVAL);
 }
@@ -1289,13 +1291,13 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 static __be32
 nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
 		      struct nfsd4_compound_state *cstate,
-		      struct nfsd4_copy *copy, struct file **src,
-		      struct file **dst)
+		      struct nfsd4_copy *copy)
 {
 	__be32 status;
 
-	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, src,
-				   &copy->cp_dst_stateid, dst);
+	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
+				   &copy->fh_src, &copy->cp_dst_stateid,
+				   &copy->fh_dst);
 	if (status)
 		goto out;
 
@@ -1315,47 +1317,173 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	fput(dst);
 }
 
+static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
+{
+	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
+
+	kfree(copy);
+}
+
+static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
+				 struct rpc_task *task)
+{
+	return 1;
+}
+
+static const struct nfsd4_callback_ops nfsd4_cb_offload_ops = {
+	.release = nfsd4_cb_offload_release,
+	.done = nfsd4_cb_offload_done
+};
+
+static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
+{
+	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
+		sizeof(copy->cp_dst_stateid));
+	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
+	copy->cp_consecutive = 1;
+	copy->cp_synchronous = sync;
+	gen_boot_verifier(&copy->cp_res.wr_verifier, copy->net);
+
+	return nfs_ok;
+}
+
+static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
+{
+	ssize_t bytes_copied = 0;
+	size_t bytes_total = copy->cp_count;
+	size_t bytes_to_copy;
+	u64 src_pos = copy->cp_src_pos;
+	u64 dst_pos = copy->cp_dst_pos;
+
+	do {
+		bytes_to_copy = min_t(u64, bytes_total, MAX_RW_COUNT);
+		bytes_copied = nfsd_copy_file_range(copy->fh_src, src_pos,
+				copy->fh_dst, dst_pos, bytes_to_copy);
+		if (bytes_copied <= 0)
+			break;
+		bytes_total -= bytes_copied;
+		copy->cp_res.wr_bytes_written += bytes_copied;
+		src_pos += bytes_copied;
+		dst_pos += bytes_copied;
+	} while (bytes_total > 0 && !copy->cp_synchronous);
+	return bytes_copied;
+}
+
+static int nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
+{
+	__be32 status;
+	ssize_t bytes;
+
+	bytes = _nfsd_copy_file_range(copy);
+	if (bytes < 0)
+		status = nfserrno(bytes);
+	else
+		status = nfsd4_init_copy_res(copy, sync);
+
+	if (copy->cp_src.nl_nsvr > 0)   /* Inter server SSC */
+		nfsd4_cleanup_inter_ssc(copy->ss_mnt, copy->fh_src,
+				copy->fh_dst);
+	else
+		nfsd4_cleanup_intra_ssc(copy->fh_src, copy->fh_dst);
+
+	return status;
+}
+
+static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
+{
+	memcpy(&dst->cp_src_stateid, &src->cp_src_stateid, sizeof(stateid_t));
+	memcpy(&dst->cp_dst_stateid, &src->cp_dst_stateid, sizeof(stateid_t));
+	dst->cp_src_pos = src->cp_src_pos;
+	dst->cp_dst_pos = src->cp_dst_pos;
+	dst->cp_count = src->cp_count;
+	memcpy(&dst->cp_src, &src->cp_src, sizeof(struct nl4_servers));
+	dst->cp_consecutive = src->cp_consecutive;
+	dst->cp_synchronous = src->cp_synchronous;
+	memcpy(&dst->cp_res, &src->cp_res, sizeof(src->cp_res));
+	memcpy(&dst->stateid, &src->stateid, sizeof(src->stateid));
+	memcpy(&dst->c_fh, &src->c_fh, sizeof(src->c_fh));
+	/* skipping nfsd4_callback */
+	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
+	dst->fh = src->fh;
+	dst->cp_clp = src->cp_clp;
+	dst->fh_src = src->fh_src;
+	dst->fh_dst = src->fh_dst;
+	dst->ss_mnt = src->ss_mnt;
+	dst->net = src->net;
+}
+
+static void nfsd4_do_async_copy(struct work_struct *work)
+{
+	struct nfsd4_copy *copy =
+		container_of(work, struct nfsd4_copy, cp_work);
+	struct nfsd4_copy *cb_copy;
+
+	if (copy->cp_src.nl_nsvr > 0) { /* Inter server SSC */
+		copy->fh_src = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
+						&copy->stateid);
+		if (IS_ERR(copy->fh_src)) {
+			nfsd4_interssc_disconnect(copy->ss_mnt);
+			return;
+		}
+	}
+	copy->nfserr = nfsd4_do_copy(copy, 0);
+	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
+	if (!cb_copy)
+		goto out;
+	memcpy(&cb_copy->cp_res, &copy->cp_res, sizeof(copy->cp_res));
+	cb_copy->cp_clp = copy->cp_clp;
+	cb_copy->nfserr = copy->nfserr;
+	memcpy(&cb_copy->fh, &copy->fh, sizeof(copy->fh));
+	nfsd4_init_cb(&cb_copy->cp_cb, cb_copy->cp_clp,
+			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
+	nfsd4_run_cb(&cb_copy->cp_cb);
+out:
+	kfree(copy);
+}
+
 static __be32
 nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_copy *copy)
 {
-	struct vfsmount *ss_mnt = NULL;
-	struct file *src, *dst;
 	__be32 status;
-	ssize_t bytes;
 
 	if (copy->cp_src.nl_nsvr > 0) { /* Inter server SSC */
-		ss_mnt = nfsd4_setup_inter_ssc(rqstp, cstate, copy, &src, &dst);
-		if (IS_ERR(ss_mnt)) {
-			status = nfserrno(PTR_ERR(ss_mnt));
+		copy->ss_mnt = nfsd4_setup_inter_ssc(rqstp, cstate, copy);
+		if (IS_ERR(copy->ss_mnt)) {
+			status = nfserrno(PTR_ERR(copy->ss_mnt));
 			goto out;
 		}
 	} else {
-		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy, &src, &dst);
+		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy);
 		if (status)
 			goto out;
 	}
 
-	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
-			dst, copy->cp_dst_pos, copy->cp_count);
-
-	if (bytes < 0)
-		status = nfserrno(bytes);
-	else {
-		copy->cp_res.wr_bytes_written = bytes;
-		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
-		copy->cp_consecutive = 1;
-		copy->cp_synchronous = 1;
-		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
-		status = nfs_ok;
+	copy->cp_clp = cstate->clp;
+	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
+		sizeof(struct knfsd_fh));
+	copy->net = SVC_NET(rqstp);
+	if (!copy->cp_synchronous) {
+		struct nfsd4_copy *async_copy;
+
+		status = nfsd4_init_copy_res(copy, 0);
+		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
+		if (!async_copy)
+			goto out_err;
+		dup_copy_fields(copy, async_copy);
+		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
+			sizeof(copy->cp_dst_stateid));
+		INIT_WORK(&async_copy->cp_work, nfsd4_do_async_copy);
+		queue_work(copy_wq, &async_copy->cp_work);
+	} else {
+		status = nfsd4_do_copy(copy, 1);
 	}
-
-	if (copy->cp_src.nl_nsvr > 0)   /* Inter server SSC */
-		nfsd4_cleanup_inter_ssc(ss_mnt, src, dst);
-	else
-		nfsd4_cleanup_intra_ssc(src, dst);
 out:
 	return status;
+out_err:
+	nfsd4_interssc_disconnect(copy->ss_mnt);
+	status = nfserrno(-ENOMEM);
+	goto out;
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b019fc8..d391ce5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7123,8 +7123,14 @@ static int nfs4_state_create_net(struct net *net)
 		goto out_free_laundry;
 
 	set_max_delegations();
-	return 0;
 
+	ret = nfsd4_create_copy_queue();
+	if (ret)
+		goto out_free_callback;
+
+	return 0;
+out_free_callback:
+	nfsd4_destroy_callback_queue();
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_cleanup_cred:
@@ -7187,6 +7193,7 @@ static int nfs4_state_create_net(struct net *net)
 	destroy_workqueue(laundry_wq);
 	nfsd4_destroy_callback_queue();
 	cleanup_callback_cred();
+	nfsd4_destroy_copy_queue();
 }
 
 static void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 3b0da32..2acea23 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -649,6 +649,8 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
+extern int nfsd4_create_copy_queue(void);
+extern void nfsd4_destroy_copy_queue(void);
 
 struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c3e6907..d75e530 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -532,10 +532,21 @@ struct nfsd4_copy {
 	/* response */
 	struct nfsd42_write_res	cp_res;
 
+	struct nfs_fh           c_fh;
+	nfs4_stateid            stateid;
+
 	/* for cb_offload */
 	struct nfsd4_callback	cp_cb;
 	__be32			nfserr;
 	struct knfsd_fh		fh;
+
+	struct work_struct	cp_work;
+	struct nfs4_client	*cp_clp;
+
+	struct file		*fh_src;
+	struct file		*fh_dst;
+	struct vfsmount		*ss_mnt;
+	struct net		*net;
 };
 
 struct nfsd4_seek {
-- 
1.8.3.1

