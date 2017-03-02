Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:10047 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751422AbdCBRoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 12:44:00 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 08/19] NFS OFFLOAD_STATUS xdr
Date: Thu, 2 Mar 2017 11:01:12 -0500
Message-ID: <20170302160123.30375-9-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c         | 87 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 12 +++++++
 6 files changed, 103 insertions(+)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index fa0daaa..352af86 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -38,6 +38,11 @@
 					 1 + /* Support 1 cnr_source_server */\
 					 1 + /* nl4_type */ \
 					 1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
+#define encode_offload_status_maxsz	(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define decode_offload_status_maxsz	(op_decode_hdr_maxsz + \
+					 2 /* osr_count */ + \
+					 1 + 1 /* osr_complete<1> */)
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -91,6 +96,12 @@
 #define NFS4_dec_copy_notify_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_copy_notify_maxsz)
+#define NFS4_enc_offload_status_sz	(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_offload_status_maxsz)
+#define NFS4_dec_offload_status_sz	(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_offload_status_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -201,6 +212,14 @@ static void encode_copy_notify(struct xdr_stream *xdr,
 	encode_nl4_server(xdr, &args->cna_dst);
 }
 
+static void encode_offload_status(struct xdr_stream *xdr,
+				  struct nfs42_offload_status_args *args,
+				  struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_OFFLOAD_STATUS, decode_offload_status_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->osa_stateid);
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -320,6 +339,24 @@ static void nfs4_xdr_enc_copy_notify(struct rpc_rqst *req,
 }
 
 /*
+ * Encode OFFLOAD_STATUS request
+ */
+static void nfs4_xdr_enc_offload_status(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					struct nfs42_offload_status_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->osa_seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->osa_seq_args, &hdr);
+	encode_putfh(xdr, args->osa_src_fh, &hdr);
+	encode_offload_status(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode DEALLOCATE request
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
@@ -567,6 +604,31 @@ static int decode_copy_notify(struct xdr_stream *xdr,
 	return -EIO;
 }
 
+static int decode_offload_status(struct xdr_stream *xdr,
+				 struct nfs42_offload_status_res *res)
+{
+	__be32 *p;
+	uint32_t count;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_OFFLOAD_STATUS);
+	if (status)
+		return status;
+	p = xdr_inline_decode(xdr, 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	p = xdr_decode_hyper(p, &res->osr_count);
+	count = be32_to_cpup(p++);
+	if (count) {
+		p = xdr_inline_decode(xdr, 4);
+		res->osr_status = be32_to_cpup(p);
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
@@ -687,6 +749,31 @@ static int nfs4_xdr_dec_copy_notify(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode OFFLOAD_STATUS response
+ */
+static int nfs4_xdr_dec_offload_status(struct rpc_rqst *rqstp,
+				       struct xdr_stream *xdr,
+				       struct nfs42_offload_status_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->osr_seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_offload_status(xdr, res);
+
+out:
+	return status;
+}
+
+/*
  * Decode DEALLOCATE request
  */
 static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4633b26..9071652 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9245,6 +9245,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
 		| NFS_CAP_COPY_NOTIFY
+		| NFS_CAP_OFFLOAD_STATUS
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9def5c6..a01ff49 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7574,6 +7574,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(CLONE,		enc_clone,		dec_clone),
 	PROC(COPY,		enc_copy,		dec_copy),
 	PROC(COPY_NOTIFY,	enc_copy_notify,	dec_copy_notify),
+	PROC(OFFLOAD_STATUS,	enc_offload_status,	dec_offload_status),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e4be278..0ed1026 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -525,6 +525,7 @@ enum {
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
 	NFSPROC4_CLNT_COPY_NOTIFY,
+	NFSPROC4_CLNT_OFFLOAD_STATUS,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a538b69..4bc9a13 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -251,5 +251,6 @@ struct nfs_server {
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_COPY_NOTIFY	(1U << 25)
+#define NFS_CAP_OFFLOAD_STATUS	(1U << 26)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9d4ea77..65b4323 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1405,6 +1405,18 @@ struct nfs42_copy_notify_res {
 	struct nl4_servers	cnr_src;
 };
 
+struct nfs42_offload_status_args {
+	struct nfs4_sequence_args	osa_seq_args;
+	struct nfs_fh			*osa_src_fh;
+	nfs4_stateid			osa_stateid;
+};
+
+struct nfs42_offload_status_res {
+	struct nfs4_sequence_res	osr_seq_res;
+	uint64_t			osr_count;
+	int				osr_status;
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

