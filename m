Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10685 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750867AbeDMRDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:03:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 03/13] NFS OFFLOAD_STATUS xdr
Date: Fri, 13 Apr 2018 13:03:04 -0400
Message-ID: <20180413170314.17634-4-kolga@netapp.com>
In-Reply-To: <20180413170314.17634-1-kolga@netapp.com>
References: <20180413170314.17634-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c         | 91 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 12 +++++++
 6 files changed, 107 insertions(+)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 5966e1e..8789486 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -26,6 +26,11 @@
 					 NFS42_WRITE_RES_SIZE + \
 					 1 /* cr_consecutive */ + \
 					 1 /* cr_synchronous */)
+#define encode_offload_status_maxsz	(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define decode_offload_status_maxsz	(op_decode_hdr_maxsz + \
+					 2 /* osr_count */ + \
+					 1 + 1 /* osr_complete<1> */)
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -75,6 +80,12 @@
 					 decode_putfh_maxsz + \
 					 decode_copy_maxsz + \
 					 decode_commit_maxsz)
+#define NFS4_enc_offload_status_sz	(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_offload_status_maxsz)
+#define NFS4_dec_offload_status_sz	(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_offload_status_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -145,6 +156,14 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint32(xdr, 0); /* src server list */
 }
 
+static void encode_offload_status(struct xdr_stream *xdr,
+				  const struct nfs42_offload_status_args *args,
+				  struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_OFFLOAD_STATUS, decode_offload_status_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->osa_stateid);
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      const struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -261,6 +280,25 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 }
 
 /*
+ * Encode OFFLOAD_STATUS request
+ */
+static void nfs4_xdr_enc_offload_status(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					const void *data)
+{
+	const struct nfs42_offload_status_args *args = data;
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
@@ -413,6 +451,33 @@ static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
 	return decode_copy_requirements(xdr, res);
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
+		if (unlikely(!p))
+			goto out_overflow;
+		res->osr_status = nfs4_stat_to_errno(be32_to_cpup(p));
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
@@ -513,6 +578,32 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode OFFLOAD_STATUS response
+ */
+static int nfs4_xdr_dec_offload_status(struct rpc_rqst *rqstp,
+				       struct xdr_stream *xdr,
+				       void *data)
+{
+	struct nfs42_offload_status_res *res = data;
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
index 47f3c27..08f12b5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9495,6 +9495,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
+		| NFS_CAP_OFFLOAD_STATUS
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 65c9c41..ca82e16 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7755,6 +7755,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	PROC42(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
 	PROC42(CLONE,		enc_clone,		dec_clone),
 	PROC42(COPY,		enc_copy,		dec_copy),
+	PROC42(OFFLOAD_STATUS,	enc_offload_status,	dec_offload_status),
 	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 57ffaa2..47ae050 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -527,6 +527,7 @@ enum {
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
+	NFSPROC4_CLNT_OFFLOAD_STATUS,
 
 	NFSPROC4_CLNT_LOOKUPP,
 };
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4e735be..1f6e9d6 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -254,5 +254,6 @@ struct nfs_server {
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
+#define NFS_CAP_OFFLOAD_STATUS	(1U << 25)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6959968..b5ea289 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1400,6 +1400,18 @@ struct nfs42_copy_res {
 	struct nfs_commitres		commit_res;
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

