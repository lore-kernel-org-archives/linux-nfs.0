From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 45/67] nfs41: get_lease_time
Date: Thu,  2 Apr 2009 16:57:12 +0300
Message-ID: <1238680632-14809-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28573 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757452AbZDBN5V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:57:21 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

get_lease_time uses the FSINFO rpc operation to
get the lease time attribute.

nfs4_get_lease_time() is only called from the state manager on session setup
so don't recover from clientid or sequence level errors.

We do need to recover from NFS4ERR_DELAY or NFS4ERR_GRACE.
Use NFS4_POLL_RETRY_MIN - the Linux server returns NFS4ERR_DELAY when an
upcall is needed to resolve an uncached export referenced by a file handle.

[nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove extraneous rpc_clnt pointer]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: have get_lease_time work on nfs_client]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: get_lease_time recover from NFS4ERR_DELAY]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: pass *session in seq_args and seq_res]
[define nfs4_get_lease_time_{args,res}]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   94 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |   51 +++++++++++++++++++++++++
 include/linux/nfs_xdr.h |    9 ++++
 3 files changed, 154 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1391ce1..926a9d6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4192,6 +4192,100 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
+struct nfs4_get_lease_time_data {
+	struct nfs4_get_lease_time_args *args;
+	struct nfs4_get_lease_time_res *res;
+	struct nfs_client *clp;
+};
+
+static void nfs4_get_lease_time_prepare(struct rpc_task *task,
+					void *calldata)
+{
+	int ret;
+	struct nfs4_get_lease_time_data *data =
+			(struct nfs4_get_lease_time_data *)calldata;
+
+	dprintk("--> %s\n", __func__);
+	/* just setup sequence, do not trigger session recovery
+	   since we're invoked within one */
+	ret = nfs41_setup_sequence(data->clp->cl_session,
+					&data->args->la_seq_args,
+					&data->res->lr_seq_res, 0, task);
+
+	BUG_ON(ret == -EAGAIN);
+	rpc_call_start(task);
+	dprintk("<-- %s\n", __func__);
+}
+
+/*
+ * Called from nfs4_state_manager thread for session setup, so don't recover
+ * from sequence operation or clientid errors.
+ */
+static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_get_lease_time_data *data =
+			(struct nfs4_get_lease_time_data *)calldata;
+
+	dprintk("--> %s\n", __func__);
+	nfs41_sequence_done(data->clp, &data->res->lr_seq_res, task->tk_status);
+	switch (task->tk_status) {
+	case -NFS4ERR_DELAY:
+	case -NFS4ERR_GRACE:
+		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
+		rpc_delay(task, NFS4_POLL_RETRY_MIN);
+		task->tk_status = 0;
+		rpc_restart_call(task);
+		return;
+	}
+	nfs41_sequence_free_slot(data->clp, &data->res->lr_seq_res);
+	dprintk("<-- %s\n", __func__);
+}
+
+struct rpc_call_ops nfs4_get_lease_time_ops = {
+	.rpc_call_prepare = nfs4_get_lease_time_prepare,
+	.rpc_call_done = nfs4_get_lease_time_done,
+};
+
+int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
+{
+	struct rpc_task *task;
+	struct nfs4_get_lease_time_args args;
+	struct nfs4_get_lease_time_res res = {
+		.lr_fsinfo = fsinfo,
+	};
+	struct nfs4_get_lease_time_data data = {
+		.args = &args,
+		.res = &res,
+		.clp = clp,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GET_LEASE_TIME],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client = clp->cl_rpcclient,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_get_lease_time_ops,
+		.callback_data = &data
+	};
+	int status;
+
+	res.lr_seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
+	dprintk("--> %s\n", __func__);
+	task = rpc_run_task(&task_setup);
+
+	if (IS_ERR(task))
+		status = PTR_ERR(task);
+	else {
+		status = task->tk_status;
+		rpc_put_task(task);
+	}
+	dprintk("<-- %s return %d\n", __func__, status);
+
+	return status;
+}
+
 /* Destroy the slot table */
 static void nfs4_destroy_slot_table(struct nfs4_session *session)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 31e9998..3f88a20 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -622,6 +622,14 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_exchange_id_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_exchange_id_maxsz)
+#define NFS4_enc_get_lease_time_sz	(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_putrootfh_maxsz + \
+					 encode_fsinfo_maxsz)
+#define NFS4_dec_get_lease_time_sz	(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_putrootfh_maxsz + \
+					 decode_fsinfo_maxsz)
 #endif /* CONFIG_NFS_V4_1 */
 
 static const umode_t nfs_type2fmt[] = {
@@ -2231,6 +2239,27 @@ static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ * a GET_LEASE_TIME request
+ */
+static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
+				       struct nfs4_get_lease_time_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
+	};
+	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->la_seq_args, &hdr);
+	encode_putrootfh(&xdr, &hdr);
+	encode_fsinfo(&xdr, lease_bitmap, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -4910,6 +4939,27 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 		status = decode_exchange_id(&xdr, res);
 	return status;
 }
+
+/*
+ * a GET_LEASE_TIME request
+ */
+static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
+				       struct nfs4_get_lease_time_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_sequence(&xdr, &res->lr_seq_res, rqstp);
+	if (!status)
+		status = decode_putrootfh(&xdr);
+	if (!status)
+		status = decode_fsinfo(&xdr, res->lr_fsinfo);
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -5083,6 +5133,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+  PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1f22fcd..6c75c63 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -174,6 +174,15 @@ struct nfs4_sequence_res {
 	int			sr_status;	/* sequence operation status */
 };
 
+struct nfs4_get_lease_time_args {
+	struct nfs4_sequence_args	la_seq_args;
+};
+
+struct nfs4_get_lease_time_res {
+	struct nfs_fsinfo	       *lr_fsinfo;
+	struct nfs4_sequence_res	lr_seq_res;
+};
+
 /*
  * Arguments to the open call.
  */
-- 
1.6.2.1

