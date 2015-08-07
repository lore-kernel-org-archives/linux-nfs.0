Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:32826 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753773AbbHGUo5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 16:44:57 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 7/7] NFS: Add COPY nfs operation
Date: Fri, 7 Aug 2015 16:38:23 -0400
Message-ID: <1438979904-8775-8-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This adds the copy_range file_ops function pointer used by the
sys_copy_range() function call.  This patch only implements sync copies,
so if an async copy happens we decode the stateid and ignore it.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        |  40 ++++++++++++++
 fs/nfs/nfs42xdr.c         | 136 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |   8 +++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  27 +++++++++
 9 files changed, 216 insertions(+)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index ff66ae7..b54b916 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -13,6 +13,7 @@
 
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
+ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d731bbf..fa665f9 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -135,6 +135,46 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
+			struct file *dst, loff_t pos_dst,
+			size_t count)
+{
+	struct nfs42_copy_args args = {
+		.src_fh		= NFS_FH(file_inode(src)),
+		.src_pos	= pos_src,
+		.dst_fh		= NFS_FH(file_inode(dst)),
+		.dst_pos	= pos_dst,
+		.count		= count,
+	};
+	struct nfs42_copy_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(file_inode(dst));
+	int status;
+
+	if (!(server->caps & NFS_CAP_COPY))
+		return -ENOTSUPP;
+
+	status = nfs42_set_rw_stateid(&args.src_stateid, src, FMODE_READ);
+	if (status)
+		return status;
+
+	status = nfs42_set_rw_stateid(&args.dst_stateid, dst, FMODE_WRITE);
+	if (status)
+		return status;
+
+	status = nfs4_call_sync(server->client, server, &msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status == -ENOTSUPP)
+		server->caps &= ~NFS_CAP_COPY;
+	if (status)
+		return status;
+	return res.write_res.count;
+}
+
 static loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(filep);
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index a6bd27d..489bbf3 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -9,9 +9,22 @@
 #define encode_fallocate_maxsz		(encode_stateid_maxsz + \
 					 2 /* offset */ + \
 					 2 /* length */)
+#define NFS42_WRITE_RES_SIZE		(1 /* wr_callback_id size */ +\
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* wr_count */ + \
+					 1 /* wr_committed */ + \
+					 XDR_QUADLEN(NFS4_VERIFIER_SIZE))
 #define encode_allocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_allocate_maxsz		(op_decode_hdr_maxsz)
+#define encode_copy_maxsz		(op_encode_hdr_maxsz +          \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 + 2 + 2 + 1 + 1 + 1)
+#define decode_copy_maxsz		(op_decode_hdr_maxsz + \
+					 NFS42_WRITE_RES_SIZE + \
+					 1 /* cr_consecutive */ + \
+					 1 /* cr_synchronous */)
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -43,6 +56,16 @@
 					 decode_putfh_maxsz + \
 					 decode_allocate_maxsz + \
 					 decode_getattr_maxsz)
+#define NFS4_enc_copy_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_savefh_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_copy_maxsz)
+#define NFS4_dec_copy_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_savefh_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_copy_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -83,6 +106,23 @@ static void encode_allocate(struct xdr_stream *xdr,
 	encode_fallocate(xdr, args);
 }
 
+static void encode_copy(struct xdr_stream *xdr,
+			struct nfs42_copy_args *args,
+			struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_COPY, decode_copy_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->src_stateid);
+	encode_nfs4_stateid(xdr, &args->dst_stateid);
+
+	encode_uint64(xdr, args->src_pos);
+	encode_uint64(xdr, args->dst_pos);
+	encode_uint64(xdr, args->count);
+
+	encode_uint32(xdr, 1); /* consecutive = true */
+	encode_uint32(xdr, 1); /* synchronous = true */
+	encode_uint32(xdr, 0); /* src server list */
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -148,6 +188,26 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 }
 
 /*
+ * Encode COPY request
+ */
+static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
+			      struct xdr_stream *xdr,
+			      struct nfs42_copy_args *args)
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
+	encode_copy(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode DEALLOCATE request
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
@@ -211,6 +271,52 @@ static int decode_allocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 	return decode_op_hdr(xdr, OP_ALLOCATE);
 }
 
+static int decode_write_response(struct xdr_stream *xdr,
+				 struct nfs42_write_res *res)
+{
+	__be32 *p;
+	int stateids;
+
+	p = xdr_inline_decode(xdr, 4 + 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	stateids = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &res->count);
+	res->committed = be32_to_cpup(p);
+	return decode_verifier(xdr, &res->verifier);
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
+{
+	__be32 *p;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_COPY);
+	if (status)
+		return status;
+
+	status = decode_write_response(xdr, &res->write_res);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->consecutive = be32_to_cpup(p++);
+	res->synchronous = be32_to_cpup(p++);
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
@@ -272,6 +378,36 @@ out:
 }
 
 /*
+ * Decode COPY response
+ */
+static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
+			     struct xdr_stream *xdr,
+			     struct nfs42_copy_res *res)
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
+	status = decode_copy(xdr, res);
+out:
+	return status;
+}
+
+/*
  * Decode DEALLOCATE request
  */
 static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index dcd39d4..cc3353a 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -132,6 +132,13 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 #ifdef CONFIG_NFS_V4_2
+static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
+				    struct file *file_out, loff_t pos_out,
+				    size_t count, int flags)
+{
+	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+}
+
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 {
 	loff_t ret;
@@ -186,6 +193,7 @@ const struct file_operations nfs4_file_operations = {
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 #ifdef CONFIG_NFS_V4_2
+	.copy_file_range = nfs4_copy_file_range,
 	.fallocate	= nfs42_fallocate,
 #endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3acb1eb..f0c59eb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8648,6 +8648,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
+		| NFS_CAP_COPY
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..8296628 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7432,6 +7432,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
+	PROC(COPY,		enc_copy,		dec_copy),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b8e72aa..c975a99 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -501,6 +501,7 @@ enum {
 	NFSPROC4_CLNT_ALLOCATE,
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_LAYOUTSTATS,
+	NFSPROC4_CLNT_COPY,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 20bc8e5..8d37f59 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -238,5 +238,6 @@ struct nfs_server {
 #define NFS_CAP_ALLOCATE	(1U << 20)
 #define NFS_CAP_DEALLOCATE	(1U << 21)
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
+#define NFS_CAP_COPY		(1U << 23)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7bbe505..e5f6227 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1321,6 +1321,33 @@ struct nfs42_falloc_res {
 	const struct nfs_server		*falloc_server;
 };
 
+struct nfs42_copy_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*src_fh;
+	nfs4_stateid			src_stateid;
+	u64				src_pos;
+
+	struct nfs_fh			*dst_fh;
+	nfs4_stateid			dst_stateid;
+	u64				dst_pos;
+
+	u64				count;
+};
+
+struct nfs42_write_res {
+	u64		count;
+	u32		committed;
+	nfs4_verifier	verifier;
+};
+
+struct nfs42_copy_res {
+	struct nfs4_sequence_res	seq_res;
+	struct nfs42_write_res		write_res;
+	bool				consecutive;
+	bool				synchronous;
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
2.5.0

