From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 37/85] nfs41: destroy_session operation
Date: Mon, 10 Nov 2008 22:24:42 +0200
Message-ID: <1226348682-8457-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48817 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbYKJUYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:47 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the destroy_session operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   23 ++++++++++++++++++-
 fs/nfs/nfs4xdr.c  |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c    |    2 +
 3 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7607dfd..a205328 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4592,9 +4592,30 @@ out:
 	return status;
 }
 
+/*
+ * Issue the over-the-wire RPC DESTROY_SESSION.
+ * The caller must serialize access to this routine.
+ */
 int nfs4_proc_destroy_session(struct nfs4_session *session)
 {
-	return -1;	/* stub */
+	int status = 0;
+	struct rpc_message msg;
+
+	dprintk("--> nfs4_proc_destroy_session\n");
+
+	msg.rpc_proc = nfs4_proc(session->clp, NFSPROC4_CLNT_DESTROY_SESSION);
+	msg.rpc_argp = session;
+	msg.rpc_resp = NULL;
+	msg.rpc_cred = NULL;
+	status = rpc_call_sync(session->clnt, &msg, 0);
+
+	if (status)
+		printk(KERN_WARNING
+		      "Got error %d from the server on DESTROY_SESSION. "
+		      "Session has been destroyed regardless...\n", status);
+
+	dprintk("<-- nfs4_proc_destroy_session\n");
+	return status;
 }
 
 static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4dfb04e..d34856e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -290,6 +290,8 @@ static int nfs4_stat_to_errno(int);
 				     1 /* csr_flags */ + \
 				     decode_channel_attrs_maxsz + \
 				     decode_channel_attrs_maxsz)
+#define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
+#define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
 #define encode_sequence_maxsz	0 /* stub */
 #define decode_sequence_maxsz	0 /* stub */
 #else /* CONFIG_NFS_V4_1 */
@@ -651,6 +653,10 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_create_session_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_create_session_maxsz)
+#define NFS4_enc_destroy_session_sz	(compound_encode_hdr_maxsz + \
+					 encode_destroy_session_maxsz)
+#define NFS4_dec_destroy_session_sz	(compound_decode_hdr_maxsz + \
+					 decode_destroy_session_maxsz)
 #define NFS4_enc_get_lease_time_sz	(compound_encode_hdr_maxsz + \
 					 encode_sequence_maxsz + \
 					 encode_putrootfh_maxsz + \
@@ -1697,6 +1703,19 @@ static int encode_create_session(struct xdr_stream *xdr,
 	return 0;
 }
 
+static int encode_destroy_session(struct xdr_stream *xdr,
+				  struct nfs4_session *session,
+				  struct compound_hdr *hdr)
+{
+	uint32_t *p;
+	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
+	WRITE32(OP_DESTROY_SESSION);
+	WRITEMEM(session->sess_id, NFS4_MAX_SESSIONID_LEN);
+	hdr->nops++;
+
+	return 0;
+}
+
 static int encode_sequence(struct xdr_stream *xdr,
 			   const struct nfs41_sequence_args *args,
 			   struct compound_hdr *hdr)
@@ -2684,6 +2703,26 @@ static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a DESTROY_SESSION request
+ */
+static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
+					struct nfs4_session *session)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
+	__be32 *nops;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	nops = encode_compound_hdr(&xdr, &hdr);
+
+	encode_destroy_session(&xdr, session, &hdr);
+	encode_nops(nops, &hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4445,6 +4484,11 @@ static int decode_create_session(struct xdr_stream *xdr,
 	return 0;
 }
 
+static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
+{
+	return decode_op_hdr(xdr, OP_DESTROY_SESSION);
+}
+
 static int decode_sequence(struct xdr_stream *xdr,
 			   struct nfs41_sequence_res *res,
 			   struct rpc_rqst *rqstp)
@@ -5340,6 +5384,23 @@ static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a DESTROY_SESSION request
+ */
+static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
+					 void *dummy)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_destroy_session(&xdr, dummy);
+	return status;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
@@ -5607,6 +5668,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
   PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
+  PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 03f143d..d7f99f8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2431,11 +2431,13 @@ static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
+	dprintk("--> %s\n", __func__);
 	nfs_return_all_delegations(sb);
 	kill_anon_super(sb);
 
 	nfs4_renewd_prepare_shutdown(server);
 	nfs_free_server(server);
+	dprintk("<-- %s\n", __func__);
 }
 
 /*
-- 
1.6.0.2

