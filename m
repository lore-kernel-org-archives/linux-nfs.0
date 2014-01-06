Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18280 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291AbaAFV5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 16:57:19 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
Subject: [PATCH 3/3] NFS: Client side changes for READ_PLUS
Date: Mon, 6 Jan 2014 16:57:13 -0500
Message-ID: <1389045433-22990-4-git-send-email-Anna.Schumaker@netapp.com>
In-Reply-To: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements client side read plus.  At the moment, the client
is coded to expect files that are: <HOLE>, <DATA>, or <HOLE><DATA> this
may change eventually.
---
 fs/nfs/nfs4client.c       |   2 +-
 fs/nfs/nfs4proc.c         |  23 +++++-
 fs/nfs/nfs4xdr.c          | 191 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 5 files changed, 215 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b2bce67..b93672b 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -912,7 +912,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 
 	/* Set the basic capabilities */
 	server->caps |= server->nfs_client->cl_mvops->init_caps;
-	server->caps |= NFS_CAP_SEEK | NFS_CAP_WRITE_PLUS_HOLE;
+	server->caps |= NFS_CAP_SEEK | NFS_CAP_WRITE_PLUS_HOLE | NFS_CAP_READ_PLUS;
 	if (server->flags & NFS_MOUNT_NORDIRPLUS)
 			server->caps &= ~NFS_CAP_READDIRPLUS;
 	/*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ce4124c..925f8b9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4069,9 +4069,13 @@ static bool nfs4_read_stateid_changed(struct rpc_task *task,
 
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
-
+	struct nfs_server *server = NFS_SERVER(data->header->inode);
 	dprintk("--> %s\n", __func__);
 
+	if ((server->nfs_client->cl_minorversion >= 2) && (task->tk_status == -ENOTSUPP)) {
+		server->caps &= ~NFS_CAP_READ_PLUS;
+		return -EAGAIN;
+	}
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 	if (nfs4_read_stateid_changed(task, &data->args))
@@ -4080,11 +4084,26 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 				    nfs4_read_done_cb(task, data);
 }
 
+#ifdef CONFIG_NFS_V4_2
+static void nfs4_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	if ((server->nfs_client->cl_minorversion < 2) || !(server->caps & NFS_CAP_READ_PLUS))
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	else
+		msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ_PLUS];
+}
+#else
+static void nfs4_read_plus_support(struct nfs_server *server, struct rpc_message *msg)
+{
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
 	data->timestamp   = jiffies;
 	data->read_done_cb = nfs4_read_done_cb;
-	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	nfs4_read_plus_support(NFS_SERVER(data->header->inode), msg);
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 534afee..a45f19d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -430,6 +430,15 @@ static int nfs4_stat_to_errno(int);
 					 2 /* bytes written */ + \
 					 1 /* committed */ + \
 					 XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#define encode_read_plus_maxsz		(op_encode_hdr_maxsz + \
+					 encode_stateid_maxsz + 3)
+#define decode_read_plus_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* rpr_eof */ + \
+					 1 /* rpr_contents array size */ + \
+					 1 /* data_content4 */ + \
+					 2 /* data_info4.di_offset */ + \
+					 2 /* data_info4.di_length */ + \
+					 1 /* data_info4.di_allocated */)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
 					 2 /* offset */ + \
@@ -923,6 +932,12 @@ EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #define NFS4_dec_write_plus_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_write_plus_maxsz)
+#define NFS4_enc_read_plus_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz +\
+					 encode_read_plus_maxsz)
+#define NFS4_dec_read_plus_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_read_plus_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -2133,6 +2148,20 @@ static void encode_write_plus(struct xdr_stream *xdr,
 	encode_write_plus_hole(xdr, args);
 }
 
+static void encode_read_plus(struct xdr_stream *xdr,
+			     struct nfs_readargs *args,
+			     struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_READ_PLUS, decode_read_plus_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->stateid);
+
+	p = reserve_space(xdr, 12);
+	p = xdr_encode_hyper(p, args->offset);
+	*p = cpu_to_be32(args->count);
+}
+
 static void encode_seek(struct xdr_stream *xdr,
 			struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
@@ -3139,6 +3168,28 @@ static void nfs4_xdr_enc_write_plus(struct rpc_rqst *req,
 }
 
 /*
+ * Encode READ_PLUS request
+ */
+static void nfs4_xdr_enc_read_plus(struct rpc_rqst *req,
+				   struct xdr_stream *xdr,
+				   struct nfs_readargs *args)
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
@@ -6181,6 +6232,119 @@ static int decode_write_plus(struct xdr_stream *xdr, struct nfs42_write_res *res
 	return decode_write_response(xdr, res);
 }
 
+struct read_plus_hole {
+	uint64_t offset;
+	uint64_t length;
+};
+
+static int decode_read_plus_data(struct xdr_stream *xdr, struct rpc_rqst *req,
+				 struct nfs_readres *res)
+{
+	__be32 *p;
+	uint64_t offset;
+	uint32_t count, eof, recvd, allocated;
+
+	eof = res->eof;
+
+	p = xdr_inline_decode(xdr, 16);
+	if (unlikely(!p))
+		goto out_overflow;
+	p = xdr_decode_hyper(p, &offset);
+	allocated = be32_to_cpup(p++);
+	count = be32_to_cpup(p);
+
+	recvd = xdr_read_pages(xdr, count);
+	if (count > recvd) {
+		dprintk("NFS: server cheating in read reply: "
+				"count %u > recvd %u\n", count, recvd);
+		count = recvd;
+		eof = 0;
+	}
+
+	res->count += count;
+	res->eof = eof;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_read_plus_hole(struct xdr_stream *xdr, struct rpc_rqst *req,
+				 struct nfs_readres *res, struct read_plus_hole *info)
+{
+	__be32 *p;
+	uint32_t allocated;
+
+	p = xdr_inline_decode(xdr, 20);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &info->offset);
+	p = xdr_decode_hyper(p, &info->length);
+	allocated = be32_to_cpup(p);
+
+	res->count += info->length;
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_read_plus(struct xdr_stream *xdr, struct rpc_rqst *req,
+			    struct nfs_readres *res)
+{
+	__be32 *p;
+	uint32_t num_contents, content_type;
+	struct read_plus_hole pending_hole = {
+		.offset = 0,
+		.length = 0,
+	};
+	int status, i;
+
+	status = decode_op_hdr(xdr, OP_READ_PLUS);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->eof = be32_to_cpup(p++);
+	res->count = 0;
+
+	num_contents = be32_to_cpup(p);
+
+	for (i = 0; i < num_contents; i++) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+
+		content_type = be32_to_cpup(p);
+		switch (content_type) {
+		case NFS4_CONTENT_DATA:
+			status = decode_read_plus_data(xdr, req, res);
+			break;
+		case NFS4_CONTENT_HOLE:
+			status = decode_read_plus_hole(xdr, req, res, &pending_hole);
+			break;
+		default:
+			break;
+		}
+
+		if (status != 0)
+			return status;
+	}
+
+	if (pending_hole.length != 0)
+		xdr_shift_hole(xdr, pending_hole.offset, pending_hole.length);
+
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 {
 	int status;
@@ -7486,6 +7650,32 @@ out:
 }
 
 /*
+ * Decode READ_PLUS response
+ */
+static int nfs4_xdr_dec_read_plus(struct rpc_rqst *rqstp,
+				  struct xdr_stream *xdr,
+				  struct nfs_readres *res)
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
+	status = decode_read_plus(xdr, rqstp, res);
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
@@ -7722,6 +7912,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 #if defined(CONFIG_NFS_V4_2)
 	PROC(WRITE_PLUS,	enc_write_plus,		dec_write_plus),
+	PROC(READ_PLUS,		enc_read_plus,		dec_read_plus),
 	PROC(SEEK,		enc_seek,		dec_seek),
 #endif /* CONFIG_NFS_V4_2 */
 };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 6c0e0b9..c1175a3 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -488,6 +488,7 @@ enum {
 
 	/* nfs42 */
 	NFSPROC4_CLNT_WRITE_PLUS,
+	NFSPROC4_CLNT_READ_PLUS,
 	NFSPROC4_CLNT_SEEK,
 };
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index aba3053..f194cd2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -231,5 +231,6 @@ struct nfs_server {
 #define NFS_CAP_SECURITY_LABEL	(1U << 18)
 #define NFS_CAP_SEEK		(1U << 19)
 #define NFS_CAP_WRITE_PLUS_HOLE	(1U << 20)
+#define NFS_CAP_READ_PLUS	(1U << 21)
 
 #endif
-- 
1.8.5.2

