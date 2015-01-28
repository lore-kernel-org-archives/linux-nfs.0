Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:49184 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422AbbA1UoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:44:01 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/6] NFS: Add READ_PLUS support for data segments
Date: Wed, 28 Jan 2015 15:43:45 -0500
Message-ID: <1422477830-28090-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for decoding a single NFS4_CONTENT_DATA segment,
matching the behaviour of READ without introducing holes.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c         | 135 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  30 ++++++++++-
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |   2 +-
 6 files changed, 167 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 038a7e1..3d7c01b 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -13,6 +13,15 @@
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
+#define encode_read_plus_maxsz		(op_encode_hdr_maxsz + \
+					 encode_stateid_maxsz + 3)
+#define decode_read_plus_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* rpr_eof */ + \
+					 1 /* rpr_contents count */ + \
+					 1 /* data_content4 */ + \
+					 2 /* data_info4.di_offset */ + \
+					 2 /* data_info4.di_length */)
+
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 encode_stateid_maxsz + \
 					 2 /* offset */ + \
@@ -35,6 +44,12 @@
 #define NFS4_dec_deallocate_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_deallocate_maxsz)
+#define NFS4_enc_read_plus_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_read_plus_maxsz)
+#define NFS4_dec_read_plus_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_read_plus_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -67,6 +82,16 @@ static void encode_deallocate(struct xdr_stream *xdr,
 	encode_fallocate(xdr, args);
 }
 
+static void encode_read_plus(struct xdr_stream *xdr,
+			     struct nfs_pgio_args *args,
+			     struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_READ_PLUS, decode_read_plus_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->stateid);
+	encode_uint64(xdr, args->offset);
+	encode_uint32(xdr, args->count);
+}
+
 static void encode_seek(struct xdr_stream *xdr,
 			struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
@@ -114,6 +139,28 @@ static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
 }
 
 /*
+ * Encode READ_PLUS request
+ */
+static void nfs4_xdr_enc_read_plus(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   struct nfs_pgio_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_read_plus(xdr, args, &hdr);
+
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
+			 args->pages, args->pgbase, args->count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	encode_nops(&hdr);
+}
+
+/*
  * Encode SEEK request
  */
 static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
@@ -141,6 +188,68 @@ static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *re
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
 }
 
+static int decode_read_plus_data(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	uint32_t count, recvd;
+	uint64_t offset;
+
+	p = xdr_inline_decode(xdr, 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &offset);
+	count = be32_to_cpup(p);
+
+	recvd = xdr_read_pages(xdr, count);
+	if (recvd < count)
+		res->eof = 0;
+
+	res->count = recvd;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	int status, type;
+	uint32_t segments;
+
+	status = decode_op_hdr(xdr, OP_READ_PLUS);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->count = 0;
+	res->eof = be32_to_cpup(p++);
+	segments = be32_to_cpup(p++);
+	if (segments == 0)
+		return 0;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	type = be32_to_cpup(p++);
+	if (type == NFS4_CONTENT_DATA)
+		status = decode_read_plus_data(xdr, res);
+	else
+		status = -ENOTSUPP;
+
+	if (segments > 1)
+		res->eof = 0;
+	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 {
 	int status;
@@ -212,6 +321,32 @@ out:
 }
 
 /*
+ * Decode READ_PLUS request
+ */
+static int nfs4_xdr_dec_read_plus(struct rpc_rqst *rqstp,
+				  struct xdr_stream *xdr,
+				  struct nfs_pgio_res *res)
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
+	status = decode_read_plus(xdr, res);
+	if (!status)
+		status = res->count;
+out:
+	return status;
+}
+
+/*
  * Decode SEEK request
  */
 static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f75b92..5887340 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -68,6 +68,10 @@
 
 #include "nfs4trace.h"
 
+#ifdef CONFIG_NFS_V4_2
+#include "nfs42.h"
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
 #define NFS4_POLL_RETRY_MIN	(HZ/10)
@@ -4150,9 +4154,15 @@ static bool nfs4_read_stateid_changed(struct rpc_task *task,
 
 static int nfs4_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
-
+	struct nfs_server *server = NFS_SERVER(hdr->inode);
 	dprintk("--> %s\n", __func__);
 
+	if ((server->caps & NFS_CAP_READ_PLUS) && (task->tk_status == -ENOTSUPP)) {
+		server->caps &= ~NFS_CAP_READ_PLUS;
+		if (rpc_restart_call_prepare(task))
+			task->tk_status = 0;
+		return -EAGAIN;
+	}
 	if (!nfs4_sequence_done(task, &hdr->res.seq_res))
 		return -EAGAIN;
 	if (nfs4_read_stateid_changed(task, &hdr->args))
@@ -4161,12 +4171,27 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 				    nfs4_read_done_cb(task, hdr);
 }
 
+#ifdef CONFIG_NFS_V4_2
+static void nfs42_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	if (server->caps & NFS_CAP_READ_PLUS)
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ_PLUS];
+	else
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+}
+#else
+static void nfs42_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void nfs4_proc_read_setup(struct nfs_pgio_header *hdr,
 				 struct rpc_message *msg)
 {
 	hdr->timestamp   = jiffies;
 	hdr->pgio_done_cb = nfs4_read_done_cb;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	nfs42_read_plus_support(NFS_SERVER(hdr->inode), msg);
 	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 0);
 }
 
@@ -8463,6 +8488,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_DEALLOCATE
+		| NFS_CAP_READ_PLUS
 		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4125339..da01f00 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7397,6 +7397,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SEEK,		enc_seek,		dec_seek),
 	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
+	PROC(READ_PLUS,		enc_read_plus,		dec_read_plus),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 022b761..41fc2f4 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -492,6 +492,7 @@ enum {
 	NFSPROC4_CLNT_SEEK,
 	NFSPROC4_CLNT_ALLOCATE,
 	NFSPROC4_CLNT_DEALLOCATE,
+	NFSPROC4_CLNT_READ_PLUS,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ddea982..95609f2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -236,5 +236,6 @@ struct nfs_server {
 #define NFS_CAP_SEEK		(1U << 19)
 #define NFS_CAP_ALLOCATE	(1U << 20)
 #define NFS_CAP_DEALLOCATE	(1U << 21)
+#define NFS_CAP_READ_PLUS	(1U << 22)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e5c3b62..f09f023 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -513,7 +513,7 @@ struct nfs_pgio_args {
 struct nfs_pgio_res {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *	fattr;
-	__u32			count;
+	__u64			count;
 	int			eof;		/* used by read */
 	struct nfs_writeverf *	verf;		/* used by write */
 	const struct nfs_server *server;	/* used by write */
-- 
2.2.2

