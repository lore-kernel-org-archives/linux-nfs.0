Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33346 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbGMJHP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:07:15 -0400
Received: by padck2 with SMTP id ck2so39609671pad.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:07:14 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2 3/8] nfs42: add CLONE xdr functions
Date: Mon, 13 Jul 2015 17:06:03 +0800
Message-Id: <1436778368-65447-4-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
References: <1436778368-65447-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xdr definitions per draft-ietf-nfsv4-minorversion2-38.txt

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42xdr.c       | 97 ++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |  1 +
 include/linux/nfs4.h    |  2 +
 include/linux/nfs_xdr.h | 19 ++++++++++
 4 files changed, 118 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 0eb29e1..0ca482a 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -34,6 +34,12 @@
 					1 /* opaque devaddr4 length */ + \
 					XDR_QUADLEN(PNFS_LAYOUTSTATS_MAXSIZE))
 #define decode_layoutstats_maxsz	(op_decode_hdr_maxsz)
+#define encode_clone_maxsz		(encode_stateid_maxsz + \
+					encode_stateid_maxsz + \
+					2 /* src offset */ + \
+					2 /* dst offset */ + \
+					2 /* count */)
+#define decode_clone_maxsz		(op_decode_hdr_maxsz)
 
 #define NFS4_enc_allocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
@@ -65,7 +71,20 @@
 					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 PNFS_LAYOUTSTATS_MAXDEV * decode_layoutstats_maxsz)
-
+#define NFS4_enc_clone_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_savefh_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_clone_maxsz + \
+					 encode_getattr_maxsz)
+#define NFS4_dec_clone_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_savefh_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_clone_maxsz + \
+					 decode_getattr_maxsz)
 
 static void encode_fallocate(struct xdr_stream *xdr,
 			     struct nfs42_falloc_args *args)
@@ -128,6 +147,21 @@ static void encode_layoutstats(struct xdr_stream *xdr,
 		encode_uint32(xdr, 0);
 }
 
+static void encode_clone(struct xdr_stream *xdr,
+			 struct nfs42_clone_args *args,
+			 struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_CLONE, decode_clone_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->src_stateid);
+	encode_nfs4_stateid(xdr, &args->dst_stateid);
+	p = reserve_space(xdr, 3*8);
+	p = xdr_encode_hyper(p, args->src_offset);
+	p = xdr_encode_hyper(p, args->dst_offset);
+	xdr_encode_hyper(p, args->count);
+}
+
 /*
  * Encode ALLOCATE request
  */
@@ -206,6 +240,27 @@ static void nfs4_xdr_enc_layoutstats(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode CLONE request
+ */
+static void nfs4_xdr_enc_clone(struct rpc_rqst *req,
+			       struct xdr_stream *xdr,
+			       struct nfs42_clone_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->src_fh, &hdr);
+	encode_savefh(xdr, &hdr);
+	encode_putfh(xdr, args->dst_fh, &hdr);
+	encode_clone(xdr, args, &hdr);
+	encode_getfattr(xdr, args->dst_bitmask, &hdr);
+	encode_nops(&hdr);
+}
+
 static int decode_allocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_ALLOCATE);
@@ -243,6 +298,11 @@ static int decode_layoutstats(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_LAYOUTSTATS);
 }
 
+static int decode_clone(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_CLONE);
+}
+
 /*
  * Decode ALLOCATE request
  */
@@ -351,4 +411,39 @@ out:
 	return status;
 }
 
+/*
+ * Decode CLONE request
+ */
+static int nfs4_xdr_dec_clone(struct rpc_rqst *rqstp,
+			      struct xdr_stream *xdr,
+			      struct nfs42_clone_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_savefh(xdr);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_clone(xdr);
+	if (status)
+		goto out;
+	status = decode_getfattr(xdr, res->dst_fattr, res->server);
+
+out:
+	res->rpc_status = status;
+	return status;
+}
+
 #endif /* __LINUX_FS_NFS_NFS4_2XDR_H */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..d9ea209 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7432,6 +7432,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
+	PROC(CLONE,		enc_clone,		dec_clone),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b8e72aa..7ccb06a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -130,6 +130,7 @@ enum nfs_opnum4 {
 	OP_READ_PLUS = 68,
 	OP_SEEK = 69,
 	OP_WRITE_SAME = 70,
+	OP_CLONE = 71,
 
 	OP_ILLEGAL = 10044,
 };
@@ -501,6 +502,7 @@ enum {
 	NFSPROC4_CLNT_ALLOCATE,
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_LAYOUTSTATS,
+	NFSPROC4_CLNT_CLONE,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7bbe505..838b7b6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -359,6 +359,25 @@ struct nfs42_layoutstat_data {
 	struct nfs42_layoutstat_res res;
 };
 
+struct nfs42_clone_args {
+	struct nfs4_sequence_args	seq_args;
+	struct nfs_fh			*src_fh;
+	struct nfs_fh			*dst_fh;
+	nfs4_stateid			src_stateid;
+	nfs4_stateid			dst_stateid;
+	__u64				src_offset;
+	__u64				dst_offset;
+	__u64				count;
+	const u32			*dst_bitmask;
+};
+
+struct nfs42_clone_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			rpc_status;
+	struct nfs_fattr		*dst_fattr;
+	const struct nfs_server		*server;
+};
+
 struct stateowner_id {
 	__u64	create_time;
 	__u32	uniquifier;
-- 
1.8.3.1

