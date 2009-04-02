From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 51/67] nfs41: sequence operation
Date: Thu,  2 Apr 2009 16:57:57 +0300
Message-ID: <1238680677-14997-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26825 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752337AbZDBN6g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:36 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the sequence operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Check returned sessionid, slotid and slot sequenceid in decode_sequence.

If the server returns different values for sessionID, slotID or slot sequence
number than what was sent, the server is looney tunes.

Pass the sequence operation status to nfs41_sequence_done in order to
determine when to increment the slot sequence ID.

Free slot is separated from sequence done.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
[nfs41: sequence res use slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: deref slot table in decode_sequence only for minorversion!=0]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_call_sync]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
[nfs41: return ESERVERFAULT in decode_sequence]
[no sr_session, no sr_flags]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: use nfs4_call_sync_sequence to renew session lease]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove nfs4_call_sync_sequence forward definition]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: use struct nfs_client for nfs41_proc_async_sequence]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: pass *session in seq_args and seq_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41 nfs41_sequence_call_done update error checking]
[nfs41 nfs41_sequence_done update error checking]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove switch on error from nfs41_sequence_call_done]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   92 ++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c  |  127 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 214 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c03d775..e1b942e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4570,6 +4570,98 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	return status;
 }
 
+/*
+ * Renew the cl_session lease.
+ */
+static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	struct nfs4_sequence_args args;
+	struct nfs4_sequence_res res;
+
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEQUENCE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+		.rpc_cred = cred,
+	};
+
+	args.sa_cache_this = 0;
+
+	return nfs4_call_sync_sequence(clp, clp->cl_rpcclient, &msg, &args,
+				       &res, 0);
+}
+
+void nfs41_sequence_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_client *clp = (struct nfs_client *)data;
+
+	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
+
+	if (task->tk_status < 0) {
+		dprintk("%s ERROR %d\n", __func__, task->tk_status);
+
+		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
+								== -EAGAIN) {
+			rpc_restart_call(task);
+			return;
+		}
+	}
+	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
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
+	struct nfs_client *clp;
+	struct nfs4_sequence_args *args;
+	struct nfs4_sequence_res *res;
+
+	clp = (struct nfs_client *)data;
+	args = task->tk_msg.rpc_argp;
+	res = task->tk_msg.rpc_resp;
+
+	if (nfs4_setup_sequence(clp, args, res, 0, task))
+		return;
+	rpc_call_start(task);
+}
+
+static const struct rpc_call_ops nfs41_sequence_ops = {
+	.rpc_call_done = nfs41_sequence_call_done,
+	.rpc_call_prepare = nfs41_sequence_prepare,
+};
+
+static int nfs41_proc_async_sequence(struct nfs_client *clp,
+				     struct rpc_cred *cred)
+{
+	struct nfs4_sequence_args *args;
+	struct nfs4_sequence_res *res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEQUENCE],
+		.rpc_cred = cred,
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
+	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	msg.rpc_argp = args;
+	msg.rpc_resp = res;
+
+	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
+			      &nfs41_sequence_ops, (void *)clp);
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1ad51b5..80af0ae 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -296,8 +296,10 @@ static int nfs4_stat_to_errno(int);
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
@@ -661,6 +663,12 @@ static int nfs4_stat_to_errno(int);
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
@@ -1635,11 +1643,39 @@ static void encode_sequence(struct xdr_stream *xdr,
 {
 #if defined(CONFIG_NFS_V4_1)
 	struct nfs4_session *session = args->sa_session;
+	struct nfs4_slot_table *tp;
+	struct nfs4_slot *slot;
+	__be32 *p;
 
 	if (!session)
 		return;
 
-	/* stub */
+	tp = &session->fc_slot_table;
+
+	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
+	slot = tp->slots + args->sa_slotid;
+
+	RESERVE_SPACE(4);
+	WRITE32(OP_SEQUENCE);
+
+	/*
+	 * Sessionid + seqid + slotid + max slotid + cache_this
+	 */
+	dprintk("%s: sessionid=%u:%u:%u:%u seqid=%d slotid=%d "
+		"max_slotid=%d cache_this=%d\n",
+		__func__,
+		((u32 *)session->sess_id.data)[0],
+		((u32 *)session->sess_id.data)[1],
+		((u32 *)session->sess_id.data)[2],
+		((u32 *)session->sess_id.data)[3],
+		slot->seq_nr, args->sa_slotid,
+		tp->highest_used_slotid, args->sa_cache_this);
+	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 16);
+	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(slot->seq_nr);
+	WRITE32(args->sa_slotid);
+	WRITE32(tp->highest_used_slotid);
+	WRITE32(args->sa_cache_this);
 	hdr->nops++;
 	hdr->replen += decode_sequence_maxsz;
 #endif /* CONFIG_NFS_V4_1 */
@@ -2391,6 +2427,24 @@ static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a SEQUENCE request
+ */
+static int nfs4_xdr_enc_sequence(struct rpc_rqst *req, uint32_t *p,
+				 struct nfs4_sequence_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(args),
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4242,13 +4296,58 @@ static int decode_sequence(struct xdr_stream *xdr,
 			   struct rpc_rqst *rqstp)
 {
 #if defined(CONFIG_NFS_V4_1)
+	struct nfs4_slot *slot;
+	struct nfs4_sessionid id;
+	u32 dummy;
+	int status;
+	__be32 *p;
+
 	if (!res->sr_session)
 		return 0;
 
-	/* stub */
-#endif /* CONFIG_NFS_V4_1 */
+	status = decode_op_hdr(xdr, OP_SEQUENCE);
+	if (status)
+		goto out_err;
 
+	/*
+	 * If the server returns different values for sessionID, slotID or
+	 * sequence number, the server is looney tunes.
+	 */
+	status = -ESERVERFAULT;
+
+	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
+	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
+	if (memcmp(id.data, res->sr_session->sess_id.data,
+		   NFS4_MAX_SESSIONID_LEN)) {
+		dprintk("%s Invalid session id\n", __func__);
+		goto out_err;
+	}
+	/* seqid */
+	READ32(dummy);
+	if (dummy != slot->seq_nr) {
+		dprintk("%s Invalid sequence number\n", __func__);
+		goto out_err;
+	}
+	/* slot id */
+	READ32(dummy);
+	if (dummy != res->sr_slotid) {
+		dprintk("%s Invalid slot id\n", __func__);
+		goto out_err;
+	}
+	/* highest slot id - currently not processed */
+	READ32(dummy);
+	/* target highest slot id - currently not processed */
+	READ32(dummy);
+	/* result flags - currently not processed */
+	READ32(dummy);
+	status = 0;
+out_err:
+	res->sr_status = status;
+	return status;
+#else  /* CONFIG_NFS_V4_1 */
 	return 0;
+#endif /* CONFIG_NFS_V4_1 */
 }
 
 /*
@@ -5187,6 +5286,23 @@ static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a SEQUENCE request
+ */
+static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp, uint32_t *p,
+				 struct nfs4_sequence_res *res)
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
@@ -5381,6 +5497,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
   PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
   PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
+  PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
-- 
1.6.2.1

