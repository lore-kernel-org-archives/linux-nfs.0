Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:16091 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbcCHV4E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 16:56:04 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v3 2/3] NFS: Add COPY nfs operation
Date: Tue, 8 Mar 2016 16:55:56 -0500
Message-ID: <1457474158-16050-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

This adds the copy_range file_ops function pointer used by the
sys_copy_range() function call.  This patch only implements sync copies,
so if an async copy happens we decode the stateid and ignore it.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
--
v3:
- Update exception handling to match the rest of the v4.2 code
- Use nfs_commit_file() to send the commit through the standard
  commit path
---
 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        | 105 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  23 ++++++++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  26 +++++++++
 9 files changed, 305 insertions(+)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index b587ccd..b6cd153 100644
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
index dff8346..579ee20 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -126,6 +126,111 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
+				struct nfs_lock_context *src_lock,
+				struct file *dst, loff_t pos_dst,
+				struct nfs_lock_context *dst_lock,
+				size_t count)
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
+	struct inode *dst_inode = file_inode(dst);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
+	int status;
+
+	status = nfs4_set_rw_stateid(&args.src_stateid, src_lock->open_context,
+				     src_lock, FMODE_READ);
+	if (status)
+		return status;
+
+	status = nfs4_set_rw_stateid(&args.dst_stateid, dst_lock->open_context,
+				     dst_lock, FMODE_WRITE);
+	if (status)
+		return status;
+
+	status = nfs4_call_sync(server->client, server, &msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status == -ENOTSUPP)
+		server->caps &= ~NFS_CAP_COPY;
+	if (status)
+		return status;
+
+	if (res.write_res.verifier.committed != NFS_FILE_SYNC) {
+		status = nfs_commit_file(dst, &res.write_res.verifier.verifier);
+		if (status)
+			return status;
+	}
+
+	truncate_pagecache_range(dst_inode, pos_dst,
+				 pos_dst + res.write_res.count);
+
+	return res.write_res.count;
+}
+
+ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
+			struct file *dst, loff_t pos_dst,
+			size_t count)
+{
+	struct nfs_server *server = NFS_SERVER(file_inode(dst));
+	struct nfs_lock_context *src_lock;
+	struct nfs_lock_context *dst_lock;
+	struct nfs4_exception src_exception = { };
+	struct nfs4_exception dst_exception = { };
+	ssize_t err, err2;
+
+	if (!nfs_server_capable(file_inode(dst), NFS_CAP_COPY))
+		return -EOPNOTSUPP;
+
+	src_lock = nfs_get_lock_context(nfs_file_open_context(src));
+	if (IS_ERR(src_lock))
+		return PTR_ERR(src_lock);
+
+	src_exception.inode = file_inode(src);
+	src_exception.state = src_lock->open_context->state;
+
+	dst_lock = nfs_get_lock_context(nfs_file_open_context(dst));
+	if (IS_ERR(dst_lock)) {
+		err = PTR_ERR(dst_lock);
+		goto out_put_src_lock;
+	}
+
+	dst_exception.inode = file_inode(dst);
+	dst_exception.state = dst_lock->open_context->state;
+
+	do {
+		mutex_lock(&file_inode(dst)->i_mutex);
+		err = _nfs42_proc_copy(src, pos_src, src_lock,
+				       dst, pos_dst, dst_lock, count);
+		mutex_unlock(&file_inode(dst)->i_mutex);
+
+		if (err == -ENOTSUPP) {
+			err = -EOPNOTSUPP;
+			break;
+		}
+
+		err2 = nfs4_handle_exception(server, err, &src_exception);
+		err  = nfs4_handle_exception(server, err, &dst_exception);
+		if (!err)
+			err = err2;
+	} while (src_exception.retry || dst_exception.retry);
+
+	nfs_put_lock_context(dst_lock);
+out_put_src_lock:
+	nfs_put_lock_context(src_lock);
+	return err;
+}
+
 static loff_t _nfs42_proc_llseek(struct file *filep,
 		struct nfs_lock_context *lock, loff_t offset, int whence)
 {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 0ca482a..6dc6f2a 100644
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
@@ -49,6 +62,16 @@
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
@@ -102,6 +125,23 @@ static void encode_allocate(struct xdr_stream *xdr,
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
@@ -182,6 +222,26 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
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
@@ -266,6 +326,62 @@ static int decode_allocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
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
+	res->verifier.committed = be32_to_cpup(p);
+	return decode_verifier(xdr, &res->verifier.verifier);
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_copy_requirements(struct xdr_stream *xdr,
+				    struct nfs42_copy_res *res) {
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->consecutive = be32_to_cpup(p++);
+	res->synchronous = be32_to_cpup(p++);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
+{
+	int status;
+
+	status = decode_op_hdr(xdr, OP_COPY);
+	if (status == NFS4ERR_OFFLOAD_NO_REQS) {
+		status = decode_copy_requirements(xdr, res);
+		if (status)
+			return status;
+		return NFS4ERR_OFFLOAD_NO_REQS;
+	} else if (status)
+		return status;
+
+	status = decode_write_response(xdr, &res->write_res);
+	if (status)
+		return status;
+
+	return decode_copy_requirements(xdr, res);
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
@@ -331,6 +447,36 @@ out:
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
index 57ca1c8..c2047ef 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -160,6 +160,28 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 #ifdef CONFIG_NFS_V4_2
+static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
+				    struct file *file_out, loff_t pos_out,
+				    size_t count, unsigned int flags)
+{
+	struct inode *in_inode = file_inode(file_in);
+	struct inode *out_inode = file_inode(file_out);
+	int ret;
+
+	if (in_inode == out_inode)
+		return -EINVAL;
+
+	/* flush any pending writes */
+	ret = nfs_sync_inode(in_inode);
+	if (ret)
+		return ret;
+	ret = nfs_sync_inode(out_inode);
+	if (ret)
+		return ret;
+
+	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+}
+
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 {
 	loff_t ret;
@@ -274,6 +296,7 @@ const struct file_operations nfs4_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
 #ifdef CONFIG_NFS_V4_2
+	.copy_file_range = nfs4_copy_file_range,
 	.llseek		= nfs4_file_llseek,
 	.fallocate	= nfs42_fallocate,
 	.clone_file_range = nfs42_clone_file_range,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c70de30..eb08640 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8792,6 +8792,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
+		| NFS_CAP_COPY
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e44412..bc3a3f5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7515,6 +7515,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
 	PROC(CLONE,		enc_clone,		dec_clone),
+	PROC(COPY,		enc_copy,		dec_copy),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index d6f9b4e..ed14d1a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -504,6 +504,7 @@ enum {
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_CLONE,
+	NFSPROC4_CLNT_COPY,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7fcc13c..14a762d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -246,5 +246,6 @@ struct nfs_server {
 #define NFS_CAP_DEALLOCATE	(1U << 21)
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
 #define NFS_CAP_CLONE		(1U << 23)
+#define NFS_CAP_COPY		(1U << 24)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d320906..d7adcab 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1343,6 +1343,32 @@ struct nfs42_falloc_res {
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
+	u64			count;
+	struct nfs_writeverf	verifier;
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
2.7.2

