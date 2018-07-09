Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:22229 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754529AbeGITNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:13:32 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 03/13] NFS OFFLOAD_CANCEL xdr
Date: Mon, 9 Jul 2018 15:13:29 -0400
Message-ID: <20180709191339.44740-4-kolga@netapp.com>
In-Reply-To: <20180709191339.44740-1-kolga@netapp.com>
References: <20180709191339.44740-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c         | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 12 +++++++++
 6 files changed, 84 insertions(+)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 5966e1e..09a540d0 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -26,6 +26,9 @@
 					 NFS42_WRITE_RES_SIZE + \
 					 1 /* cr_consecutive */ + \
 					 1 /* cr_synchronous */)
+#define encode_offload_cancel_maxsz	(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define decode_offload_cancel_maxsz	(op_decode_hdr_maxsz)
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -75,6 +78,12 @@
 					 decode_putfh_maxsz + \
 					 decode_copy_maxsz + \
 					 decode_commit_maxsz)
+#define NFS4_enc_offload_cancel_sz	(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_offload_cancel_maxsz)
+#define NFS4_dec_offload_cancel_sz	(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_offload_cancel_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -145,6 +154,14 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint32(xdr, 0); /* src server list */
 }
 
+static void encode_offload_cancel(struct xdr_stream *xdr,
+				  const struct nfs42_offload_status_args *args,
+				  struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_OFFLOAD_CANCEL, decode_offload_cancel_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->osa_stateid);
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      const struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -261,6 +278,25 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 }
 
 /*
+ * Encode OFFLOAD_CANEL request
+ */
+static void nfs4_xdr_enc_offload_cancel(struct rpc_rqst *req,
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
+	encode_offload_cancel(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode DEALLOCATE request
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
@@ -413,6 +449,12 @@ static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
 	return decode_copy_requirements(xdr, res);
 }
 
+static int decode_offload_cancel(struct xdr_stream *xdr,
+				 struct nfs42_offload_status_res *res)
+{
+	return decode_op_hdr(xdr, OP_OFFLOAD_CANCEL);
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
@@ -513,6 +555,32 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode OFFLOAD_CANCEL response
+ */
+static int nfs4_xdr_dec_offload_cancel(struct rpc_rqst *rqstp,
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
+	status = decode_offload_cancel(xdr, res);
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
index 5a8190e..95e35c8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9555,6 +9555,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		| NFS_CAP_LGOPEN
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
+		| NFS_CAP_OFFLOAD_CANCEL
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index cd41d25..b7bde12 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7789,6 +7789,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	PROC42(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
 	PROC42(CLONE,		enc_clone,		dec_clone),
 	PROC42(COPY,		enc_copy,		dec_copy),
+	PROC42(OFFLOAD_CANCEL,	enc_offload_cancel,	dec_offload_cancel),
 	PROC(LOOKUPP,		enc_lookupp,		dec_lookupp),
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 57ffaa2..c44b872 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -527,6 +527,7 @@ enum {
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
+	NFSPROC4_CLNT_OFFLOAD_CANCEL,
 
 	NFSPROC4_CLNT_LOOKUPP,
 };
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2c18d61..fbc735f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -255,5 +255,6 @@ struct nfs_server {
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
+#define NFS_CAP_OFFLOAD_CANCEL	(1U << 25)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3b7325c..85e928a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1403,6 +1403,18 @@ struct nfs42_copy_res {
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

