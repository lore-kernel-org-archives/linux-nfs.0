From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 35/85] nfs41: get_lease_time
Date: Mon, 10 Nov 2008 22:24:20 +0200
Message-ID: <1226348660-8389-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48808 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbYKJUY1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:27 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

get_lease_time uses the FSINFO rpc operation to
get the lease time attribute.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   84 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c  |   56 +++++++++++++++++++++++++++++++++++
 2 files changed, 140 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2e11c3..f1918fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4241,6 +4241,90 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
+struct nfs4_get_lease_time_data {
+	struct nfs4_get_lease_time_args *args;
+	struct nfs4_get_lease_time_res *res;
+	struct nfs_client *clp;
+	struct nfs4_session *session;
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
+	ret = nfs41_setup_sequence(data->session,
+					&data->args->la_seq_args,
+					&data->res->lr_seq_res, 0, task);
+
+	BUG_ON(ret == -EAGAIN);
+	rpc_call_start(task);
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs4_get_lease_time_done(struct rpc_task *task,
+					void *calldata)
+{
+	struct nfs4_get_lease_time_data *data =
+			(struct nfs4_get_lease_time_data *)calldata;
+
+	dprintk("--> %s\n", __func__);
+	nfs41_sequence_done(data->clp, &data->res->lr_seq_res, task->tk_status);
+	nfs41_sequence_free_slot(&data->res->lr_seq_res);
+	dprintk("<-- %s\n", __func__);
+}
+
+struct rpc_call_ops nfs4_get_lease_time_ops = {
+	.rpc_call_prepare = nfs4_get_lease_time_prepare,
+	.rpc_call_done = nfs4_get_lease_time_done,
+};
+
+int nfs4_proc_get_lease_time(struct nfs_client *clp,
+		struct nfs4_session *session, struct nfs_fsinfo *fsinfo)
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
+		.session = session,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_GET_LEASE_TIME),
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client = session->clnt,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_get_lease_time_ops,
+		.callback_data = &data
+	};
+	int status;
+
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
 /*
  * Initialize slot table
  *
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 31ca211..7b7d4e8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -618,6 +618,14 @@ static int nfs4_stat_to_errno(int);
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
 
 static struct {
@@ -2557,6 +2565,32 @@ static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(nops, &hdr);
 	return 0;
 }
+
+/*
+ * a GET_LEASE_TIME request
+ */
+static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
+					struct nfs4_get_lease_time_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
+	int status;
+	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+	__be32 *nops;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->la_seq_args, &hdr);
+	status = encode_putrootfh(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = encode_fsinfo(&xdr, lease_bitmap, &hdr);
+ out:
+	encode_nops(nops, &hdr);
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -5112,6 +5146,27 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
 		status = decode_exchange_id(&xdr, res);
 	return status;
 }
+
+/*
+ * a GET_LEASE_TIME request
+ */
+static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
+					struct nfs4_get_lease_time_res *res)
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
 
 /*
@@ -5359,6 +5414,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
+  PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
-- 
1.6.0.2

