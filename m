From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 49/67] nfs41: destroy_session operation
Date: Thu,  2 Apr 2009 16:57:43 +0300
Message-ID: <1238680663-14934-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31690 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752337AbZDBN6d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:33 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the destroy_session operation conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove extraneous rpc_clnt pointer]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41; NFS_CS_READY required for DESTROY_SESSION]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: pass *session in seq_args and seq_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   30 +++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c  |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/super.c    |    2 +
 3 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ce8999..27b00c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4535,6 +4535,36 @@ out:
 	return status;
 }
 
+/*
+ * Issue the over-the-wire RPC DESTROY_SESSION.
+ * The caller must serialize access to this routine.
+ */
+int nfs4_proc_destroy_session(struct nfs4_session *session)
+{
+	int status = 0;
+	struct rpc_message msg;
+
+	dprintk("--> nfs4_proc_destroy_session\n");
+
+	/* session is still being setup */
+	if (session->clp->cl_cons_state != NFS_CS_READY)
+		return status;
+
+	msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_SESSION];
+	msg.rpc_argp = session;
+	msg.rpc_resp = NULL;
+	msg.rpc_cred = NULL;
+	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
+
+	if (status)
+		printk(KERN_WARNING
+			"Got error %d from the server on DESTROY_SESSION. "
+			"Session has been destroyed regardless...\n", status);
+
+	dprintk("<-- nfs4_proc_destroy_session\n");
+	return status;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 11c210f..1ad51b5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -294,6 +294,8 @@ static int nfs4_stat_to_errno(int);
 				     1 /* csr_flags */ + \
 				     decode_channel_attrs_maxsz + \
 				     decode_channel_attrs_maxsz)
+#define encode_destroy_session_maxsz    (op_encode_hdr_maxsz + 4)
+#define decode_destroy_session_maxsz    (op_decode_hdr_maxsz)
 #define encode_sequence_maxsz	0 /* stub */
 #define decode_sequence_maxsz	0 /* stub */
 #else /* CONFIG_NFS_V4_1 */
@@ -655,6 +657,10 @@ static int nfs4_stat_to_errno(int);
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
@@ -1609,6 +1615,18 @@ static void encode_create_session(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_create_session_maxsz;
 }
+
+static void encode_destroy_session(struct xdr_stream *xdr,
+				   struct nfs4_session *session,
+				   struct compound_hdr *hdr)
+{
+	uint32_t *p;
+	RESERVE_SPACE(4 + NFS4_MAX_SESSIONID_LEN);
+	WRITE32(OP_DESTROY_SESSION);
+	WRITEMEM(session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
+	hdr->nops++;
+	hdr->replen += decode_destroy_session_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void encode_sequence(struct xdr_stream *xdr,
@@ -2355,6 +2373,24 @@ static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
+ * a DESTROY_SESSION request
+ */
+static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
+					struct nfs4_session *session)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = session->clp->cl_minorversion,
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_destroy_session(&xdr, session, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
+/*
  * a GET_LEASE_TIME request
  */
 static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
@@ -4194,6 +4230,11 @@ static int decode_create_session(struct xdr_stream *xdr,
 
 	return 0;
 }
+
+static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
+{
+	return decode_op_hdr(xdr, OP_DESTROY_SESSION);
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static int decode_sequence(struct xdr_stream *xdr,
@@ -5129,6 +5170,23 @@ static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
 }
 
 /*
+ * a DESTROY_SESSION request
+ */
+static int nfs4_xdr_dec_destroy_session(struct rpc_rqst *rqstp, uint32_t *p,
+					void *dummy)
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
@@ -5322,6 +5380,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
   PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
+  PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
 #endif /* CONFIG_NFS_V4_1 */
 };
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4d22b18..6ae7088 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2604,12 +2604,14 @@ static void nfs4_kill_super(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
+	dprintk("--> %s\n", __func__);
 	nfs_super_return_all_delegations(sb);
 	kill_anon_super(sb);
 
 	nfs4_renewd_prepare_shutdown(server);
 	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
+	dprintk("<-- %s\n", __func__);
 }
 
 /*
-- 
1.6.2.1

