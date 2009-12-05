From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 2/4] nfs41: RECLAIM_COMPLETE XDR functionality
Date: Sat,  5 Dec 2009 12:20:26 -0800
Message-ID: <1260044428-16341-3-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260044428-16341-2-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61724 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756529AbZLEU0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:26:07 -0500
In-Reply-To: <1260044428-16341-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

XDR encoding and decoding for RECLAIM_COMPLETE.  Implements the necessary
encoding to indicate reclaim complete for the entire client.  In the future,
it can be extended to provide reclaim complete functionality for a single
file system after migration.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4xdr.c        |   66 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |   10 +++++++
 3 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1969ba4..ee0a15b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -299,6 +299,8 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 4)
 #define decode_sequence_maxsz	(op_decode_hdr_maxsz + \
 				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
+#define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
+#define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -676,6 +678,12 @@ static int nfs4_stat_to_errno(int);
 					 decode_sequence_maxsz + \
 					 decode_putrootfh_maxsz + \
 					 decode_fsinfo_maxsz)
+#define NFS4_enc_reclaim_complete_sz	(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_reclaim_complete_maxsz)
+#define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_reclaim_complete_maxsz)
 #endif /* CONFIG_NFS_V4_1 */
 
 static const umode_t nfs_type2fmt[] = {
@@ -1592,6 +1600,19 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_destroy_session_maxsz;
 }
+
+static void encode_reclaim_complete(struct xdr_stream *xdr,
+				    struct nfs41_reclaim_complete_args *args,
+				    struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 8);
+	*p++ = cpu_to_be32(OP_RECLAIM_COMPLETE);
+	*p++ = cpu_to_be32(args->one_fs);
+	hdr->nops++;
+	hdr->replen += decode_reclaim_complete_maxsz;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void encode_sequence(struct xdr_stream *xdr,
@@ -2420,6 +2441,26 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ * a RECLAIM_COMPLETE request
+ */
+static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
+				     struct nfs41_reclaim_complete_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args)
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	encode_reclaim_complete(&xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -4528,6 +4569,11 @@ static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
 {
 	return decode_op_hdr(xdr, OP_DESTROY_SESSION);
 }
+
+static int decode_reclaim_complete(struct xdr_stream *xdr, void *dummy)
+{
+	return decode_op_hdr(xdr, OP_RECLAIM_COMPLETE);
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static int decode_sequence(struct xdr_stream *xdr,
@@ -5591,6 +5637,25 @@ static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp, uint32_t *p,
 		status = decode_fsinfo(&xdr, res->lr_fsinfo);
 	return status;
 }
+
+/*
+ * Decode RECLAIM_COMPLETE response
+ */
+static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
+					 struct nfs41_reclaim_complete_res *res)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (!status)
+		status = decode_reclaim_complete(&xdr, (void *)NULL);
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
@@ -5767,6 +5832,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(DESTROY_SESSION,	enc_destroy_session,	dec_destroy_session),
   PROC(SEQUENCE,	enc_sequence,	dec_sequence),
   PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
+  PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c4c0602..f7bb8e0 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -528,6 +528,7 @@ enum {
 	NFSPROC4_CLNT_DESTROY_SESSION,
 	NFSPROC4_CLNT_SEQUENCE,
 	NFSPROC4_CLNT_GET_LEASE_TIME,
+	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62f63fb..1810d1f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -938,6 +938,16 @@ struct nfs41_create_session_args {
 struct nfs41_create_session_res {
 	struct nfs_client	       *client;
 };
+
+struct nfs41_reclaim_complete_args {
+	/* In the future extend to include curr_fh for use with migration */
+	unsigned char			one_fs:1;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs41_reclaim_complete_res {
+	struct nfs4_sequence_res	seq_res;
+};
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
-- 
1.5.4.3

