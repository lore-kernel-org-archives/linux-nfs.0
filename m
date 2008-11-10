From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 38/85] nfs41: sequence operation
Date: Mon, 10 Nov 2008 22:24:52 +0200
Message-ID: <1226348692-8492-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48821 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYKJUY6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:58 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the sequence operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Check returned sessionid, slotid and slot sequenceid in decode_sequence.

Pass the sequence operation status to nfs41_sequence_done in order to
determine when to increment the slot sequence ID.

Free slot is separated from sequence done.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   92 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c  |  115 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 201 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a205328..836f4f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4620,13 +4620,101 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 
 static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 {
-	return -1;	/* stub */
+	struct nfs41_sequence_args args;
+	struct nfs41_sequence_res res;
+	struct nfs_server *server;
+
+	struct rpc_message msg = {
+		.rpc_proc	= nfs4_proc(clp, NFSPROC4_CLNT_SEQUENCE),
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
+	};
+	int status;
+
+	/*
+	 * We need to renew the lease on the server. For this, we use any
+	 * session we have on the server to send the SEQUENCE op
+	 */
+	BUG_ON(list_empty(&clp->cl_superblocks));
+
+	server = list_entry(clp->cl_superblocks.next, struct nfs_server,
+				client_link);
+
+	args.sa_cache_this = 0;
+
+	status = _nfs4_call_sync(server, &msg, &args, &res, 0);
+	return status;
+}
+
+void nfs41_sequence_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_server *server = (struct nfs_server *)data;
+
+	nfs4_sequence_done(server, task->tk_msg.rpc_resp, task->tk_status);
+	nfs4_sequence_free_slot(server, task->tk_msg.rpc_resp);
+	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
+
+	put_rpccred(task->tk_msg.rpc_cred);
+	kfree(task->tk_msg.rpc_argp);
+	kfree(task->tk_msg.rpc_resp);
+
+	dprintk("<-- %s\n", __func__);
+}
+
+static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_server *server;
+	struct nfs41_sequence_args *args;
+	struct nfs41_sequence_res *res;
+
+	server = (struct nfs_server *)data;
+	args = task->tk_msg.rpc_argp;
+	res = task->tk_msg.rpc_resp;
+
+	if (nfs4_setup_sequence(server->nfs_client, args, res, 0, task))
+		return;
+	rpc_call_start(task);
 }
 
+static const struct rpc_call_ops nfs41_sequence_ops = {
+	.rpc_call_done = nfs41_sequence_call_done,
+	.rpc_call_prepare = nfs41_sequence_prepare,
+};
+
 static int nfs41_proc_async_sequence(struct nfs_client *clp,
 				     struct rpc_cred *cred)
 {
-	return -1;	/* stub */
+	struct nfs41_sequence_args *args;
+	struct nfs41_sequence_res *res;
+	struct nfs_server *server;
+	struct rpc_message msg = {
+		.rpc_proc	= nfs4_proc(clp, NFSPROC4_CLNT_SEQUENCE),
+		.rpc_cred	= cred,
+	};
+
+	args = kzalloc(sizeof(*args), GFP_KERNEL);
+	if (!args)
+		return -ENOMEM;
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res) {
+		kfree(args);
+		return -ENOMEM;
+	}
+	msg.rpc_argp = args;
+	msg.rpc_resp = res;
+
+	/*
+	 * We need to renew the lease on the server. For this, we use any
+	 * session we have on the server to send the SEQUENCE op
+	 */
+	BUG_ON(list_empty(&clp->cl_superblocks));
+
+	server = list_entry(clp->cl_superblocks.next, struct nfs_server,
+					 client_link);
+
+	return rpc_call_async(server->client, &msg, RPC_TASK_SOFT,
+				&nfs41_sequence_ops, (void *)server);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d34856e..81cf09d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -292,8 +292,10 @@ static int nfs4_stat_to_errno(int);
 				     decode_channel_attrs_maxsz)
 #define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
 #define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
-#define encode_sequence_maxsz	0 /* stub */
-#define decode_sequence_maxsz	0 /* stub */
+#define encode_sequence_maxsz	(op_encode_hdr_maxsz + \
+				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 4)
+#define decode_sequence_maxsz	(op_decode_hdr_maxsz + \
+				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -657,6 +659,12 @@ static int nfs4_stat_to_errno(int);
 					 encode_destroy_session_maxsz)
 #define NFS4_dec_destroy_session_sz	(compound_decode_hdr_maxsz + \
 					 decode_destroy_session_maxsz)
+#define NFS4_enc_sequence_sz \
+				(compound_decode_hdr_maxsz + \
+				 encode_sequence_maxsz)
+#define NFS4_dec_sequence_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz)
 #define NFS4_enc_get_lease_time_sz	(compound_encode_hdr_maxsz + \
 					 encode_sequence_maxsz + \
 					 encode_putrootfh_maxsz + \
@@ -1720,10 +1728,34 @@ static int encode_sequence(struct xdr_stream *xdr,
 			   const struct nfs41_sequence_args *args,
 			   struct compound_hdr *hdr)
 {
+	struct nfs4_slot_table *tp = &args->sa_session->fore_channel.slot_table;
+	__be32 *p;
+
 	if (hdr->minorversion == 0)
 		return 0;
 
-	/* stub */
+	WARN_ON(slot_idx(tp, args->sa_slot) < 0);
+
+	RESERVE_SPACE(4);
+	WRITE32(OP_SEQUENCE);
+
+	/*
+	 * Sessionid + seqid + slotid + max slotid + cache_this
+	 */
+	dprintk("%s: sessionid=%u:%u:%u:%u seqid=%d slotid=%d "
+		"max_slotid=%d cache_this=%d\n",
+		__func__, ((u32 *)args->sa_session->sess_id)[0],
+		((u32 *)args->sa_session->sess_id)[1],
+		((u32 *)args->sa_session->sess_id)[2],
+		((u32 *)args->sa_session->sess_id)[3],
+		args->sa_slot->seq_nr, slot_idx(tp, args->sa_slot),
+		tp->highest_used_slotid, args->sa_cache_this);
+	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
+	WRITEMEM(args->sa_session->sess_id, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(args->sa_slot->seq_nr);
+	WRITE32(slot_idx(tp, args->sa_slot));
+	WRITE32(tp->highest_used_slotid);
+	WRITE32(args->sa_cache_this);
 	hdr->nops++;
 
 	return 0;
@@ -2723,6 +2755,25 @@ static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a SEQUENCE request
+ */
+static int nfs4_xdr_enc_sequence(struct rpc_rqst *req, uint32_t *p,
+				  struct nfs41_sequence_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
+	__be32 *nops;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, args, &hdr);
+	encode_nops(nops, &hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4493,12 +4544,50 @@ static int decode_sequence(struct xdr_stream *xdr,
 			   struct nfs41_sequence_res *res,
 			   struct rpc_rqst *rqstp)
 {
+	struct nfs4_slot_table *tp = &res->sr_session->fore_channel.slot_table;
+	struct sessionid4 id;
+	u32 dummy;
+	int status;
+	__be32 *p;
+
 	if (rqstp->rq_task->tk_client->cl_mvers == 0)
 		return 0;
 
-	/* stub */
+	status = decode_op_hdr(xdr, OP_SEQUENCE);
+	if (status)
+		goto out_err;
+
+	status = -EIO;
+
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
+	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
+	if (memcmp(id.data, res->sr_session->sess_id, NFS4_MAX_SESSIONID_LEN)) {
+		dprintk("%s Invalid session id\n", __func__);
+		goto out_err;
+	}
+	/* seqid */
+	READ32(dummy);
+	if (dummy != res->sr_slot->seq_nr) {
+		dprintk("%s Invalid sequence number\n", __func__);
+		goto out_err;
+	}
+	/* slot id */
+	READ32(dummy);
+	if (dummy != slot_idx(tp, res->sr_slot)) {
+		dprintk("%s Invalid slot id\n", __func__);
+		goto out_err;
+	}
+	/* highest slot id - currently not processed */
+	READ32(dummy);
+	/* target highest slot id - currently not processed */
+	READ32(dummy);
+	READ32(res->sr_flags);
 
 	return 0;
+out_err:
+	/* task->tk_status is from the sequence operation */
+	res->sr_flags = SEQ4_STATUS_USE_TK_STATUS;
+	return status;
 }
 #else /* CONFIG_NFS_V4_1 */
 static inline int decode_sequence(struct xdr_stream *xdr,
@@ -5401,6 +5490,23 @@ static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a SEQUENCE request
+ */
+static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp, uint32_t *p,
+				  struct nfs41_sequence_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_sequence(&xdr, res, rqstp);
+	return status;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
@@ -5669,6 +5775,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
   PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
   PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
+  PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
-- 
1.6.0.2

