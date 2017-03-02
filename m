Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:36004 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752711AbdCBQPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:15:02 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 10/19] NFS OFFLOAD_CANCEL xdr
Date: Thu, 2 Mar 2017 11:01:14 -0500
Message-ID: <20170302160123.30375-11-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c         | 66 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 5 files changed, 70 insertions(+)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 352af86..d782606 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -43,6 +43,9 @@
 #define decode_offload_status_maxsz	(op_decode_hdr_maxsz + \
 					 2 /* osr_count */ + \
 					 1 + 1 /* osr_complete<1> */)
+#define encode_offload_cancel_maxsz	(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define decode_offload_cancel_maxsz	(op_decode_hdr_maxsz)
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -102,6 +105,12 @@
 #define NFS4_dec_offload_status_sz	(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_offload_status_maxsz)
+#define NFS4_enc_offload_cancel_sz	(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_offload_cancel_maxsz)
+#define NFS4_dec_offload_cancel_sz	(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_offload_cancel_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -220,6 +229,14 @@ static void encode_offload_status(struct xdr_stream *xdr,
 	encode_nfs4_stateid(xdr, &args->osa_stateid);
 }
 
+static void encode_offload_cancel(struct xdr_stream *xdr,
+				  struct nfs42_offload_status_args *args,
+				  struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_OFFLOAD_CANCEL, decode_offload_cancel_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->osa_stateid);
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -357,6 +374,24 @@ static void nfs4_xdr_enc_offload_status(struct rpc_rqst *req,
 }
 
 /*
+ * Encode OFFLOAD_CANEL request
+ */
+static void nfs4_xdr_enc_offload_cancel(struct rpc_rqst *req,
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
+	encode_offload_cancel(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode DEALLOCATE request
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
@@ -629,6 +664,12 @@ static int decode_offload_status(struct xdr_stream *xdr,
 	return -EIO;
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
@@ -774,6 +815,31 @@ static int nfs4_xdr_dec_offload_status(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode OFFLOAD_CANCEL response
+ */
+static int nfs4_xdr_dec_offload_cancel(struct rpc_rqst *rqstp,
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
index 9071652..59be0f7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9246,6 +9246,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		| NFS_CAP_COPY
 		| NFS_CAP_COPY_NOTIFY
 		| NFS_CAP_OFFLOAD_STATUS
+		| NFS_CAP_OFFLOAD_CANCEL
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a01ff49..697edf3 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7575,6 +7575,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(COPY,		enc_copy,		dec_copy),
 	PROC(COPY_NOTIFY,	enc_copy_notify,	dec_copy_notify),
 	PROC(OFFLOAD_STATUS,	enc_offload_status,	dec_offload_status),
+	PROC(OFFLOAD_CANCEL,    enc_offload_cancel,     dec_offload_cancel),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 0ed1026..e43c106 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -526,6 +526,7 @@ enum {
 	NFSPROC4_CLNT_COPY,
 	NFSPROC4_CLNT_COPY_NOTIFY,
 	NFSPROC4_CLNT_OFFLOAD_STATUS,
+	NFSPROC4_CLNT_OFFLOAD_CANCEL,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4bc9a13..488ff40 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -252,5 +252,6 @@ struct nfs_server {
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_COPY_NOTIFY	(1U << 25)
 #define NFS_CAP_OFFLOAD_STATUS	(1U << 26)
+#define NFS_CAP_OFFLOAD_CANCEL	(1U << 27)
 
 #endif
-- 
1.8.3.1

