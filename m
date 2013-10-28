Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43799 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932669Ab3J1PAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:00:44 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFS: Use WRITE_PLUS for hole punches
Date: Mon, 28 Oct 2013 11:00:16 -0400
Message-ID: <1382972418-2249-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements a version of fallocate for NFS v4.  In the v4.2
case, we use WRITE_PLUS with DATA_CONTENT_HOLE set to punch a hole in a
file.  In NFS < v4.2, we fall back to the generic VFS fallocate
implementation.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/inode.c          |   2 +
 fs/nfs/nfs4_fs.h        |   5 ++
 fs/nfs/nfs4file.c       |  53 ++++++++++++++++++
 fs/nfs/nfs4proc.c       |  39 +++++++++++++
 fs/nfs/nfs4xdr.c        | 142 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |   3 +
 include/linux/nfs_xdr.h |  29 ++++++++++
 7 files changed, 273 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index eda8879..de0efbd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -680,6 +680,7 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	kfree(new);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_get_lock_context);
 
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -692,6 +693,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 	spin_unlock(&inode->i_lock);
 	kfree(l_ctx);
 }
+EXPORT_SYMBOL_GPL(nfs_put_lock_context);
 
 /**
  * nfs_close_context - Common close_context() routine NFSv2/v3
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 28842ab..1557f15 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -352,6 +352,11 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+int nfs42_proc_fallocate(struct nfs_server *, struct nfs42_write_plus_args *,
+			 struct nfs42_write_res *, struct rpc_cred *);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 77efaf1..ab2fbe0 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -118,6 +118,56 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	return ret;
 }
 
+#ifdef CONFIG_NFS_V4_2
+static int nfs42_select_stateid(struct file *file, nfs4_stateid *stateid,
+				fmode_t mode, struct nfs_open_context **ctx)
+{
+	struct nfs_lock_context *lock;
+	int ret;
+
+	*ctx = nfs_file_open_context(file);
+	if (!*ctx)
+		return -EBADF;
+
+	lock = nfs_get_lock_context(*ctx);
+	if (IS_ERR(lock))
+		return PTR_ERR(lock);
+
+	ret = nfs4_set_rw_stateid(stateid, *ctx, lock, mode);
+
+	if (lock)
+		nfs_put_lock_context(lock);
+	return ret;
+}
+
+static long nfs42_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
+{
+	int err;
+	struct inode *inode = file_inode(file);
+	struct nfs42_write_plus_args args = {
+		.wp_fh		= NFS_FH(inode),
+		.wp_stable	= NFS_FILE_SYNC,
+		.wp_content	= NFS4_CONTENT_HOLE,
+		.wp_offset	= offset,
+		.wp_length	= len,
+		.wp_allocated	= (mode == 0),
+	};
+
+	struct nfs_open_context *ctx;
+	struct nfs42_write_res res;
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	if (server->nfs_client->cl_minorversion < 2)
+		return -EOPNOTSUPP;
+
+	err = nfs42_select_stateid(file, &args.wp_stateid, FMODE_WRITE, &ctx);
+	if (err < 0)
+		return err;
+
+	return nfs42_proc_fallocate(server, &args, &res, ctx->cred);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 const struct file_operations nfs4_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
@@ -133,6 +183,9 @@ const struct file_operations nfs4_file_operations = {
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= nfs_file_splice_write,
+#ifdef CONFIG_NFS_V4_2
+	.fallocate	= nfs42_fallocate,
+#endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2b4845..003bacb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7828,6 +7828,45 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+int _nfs42_proc_fallocate(struct nfs_server *server,
+			  struct nfs42_write_plus_args *args,
+			  struct nfs42_write_res *res,
+			  struct rpc_cred *cred)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE_PLUS],
+		.rpc_argp = args,
+		.rpc_resp = res,
+		.rpc_cred = cred,
+	};
+	int status;
+
+	status = nfs4_call_sync(server->client, server, &msg,
+				&args->seq_args, &res->seq_res, 0);
+	if (status == -NFS4ERR_NOTSUPP)
+		return -EOPNOTSUPP;
+	return status;
+}
+
+int nfs42_proc_fallocate(struct nfs_server *server,
+			 struct nfs42_write_plus_args *args,
+			 struct nfs42_write_res *res,
+			 struct rpc_cred *cred)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(server,
+			_nfs42_proc_fallocate(server, args, res, cred),
+			&exception);
+	} while (exception.retry);
+
+	return err;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 79210d2..4ffecbe 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -420,6 +420,23 @@ static int nfs4_stat_to_errno(int);
 #define decode_sequence_maxsz	0
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+#define encode_write_plus_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 1 /* stable */ + \
+					 1 /* number of writes */ + \
+					 1 /* data_content4 */ + \
+					 2 /* offset */ + \
+					 2 /* length */ + \
+					 1 /* allocated */)
+#define decode_write_plus_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* number of stateids */ +\
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* bytes written */ + \
+					 1 /* committed */ + \
+					 XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
@@ -879,6 +896,15 @@ const u32 nfs41_maxgetdevinfo_overhead = ((RPC_MAX_REPHEADER_WITH_AUTH +
 EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+#define NFS4_enc_write_plus_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_write_plus_maxsz)
+#define NFS4_dec_write_plus_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_write_plus_maxsz)
+#endif /* CONFIG_NFS_V4_2 */
+
 static const umode_t nfs_type2fmt[] = {
 	[NF4BAD] = 0,
 	[NF4REG] = S_IFREG,
@@ -2058,6 +2084,28 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static void encode_write_plus_hole(struct xdr_stream *xdr,
+				   struct nfs42_write_plus_args *args)
+{
+	encode_uint32(xdr, NFS4_CONTENT_HOLE);
+	encode_uint64(xdr, args->wp_offset);
+	encode_uint64(xdr, args->wp_length);
+	encode_uint32(xdr, args->wp_allocated);
+}
+
+static void encode_write_plus(struct xdr_stream *xdr,
+			      struct nfs42_write_plus_args *args,
+			      struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_WRITE_PLUS, decode_write_plus_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->wp_stateid);
+	encode_uint32(xdr, args->wp_stable);
+	encode_uint32(xdr, 1);
+	encode_write_plus_hole(xdr, args);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -3004,6 +3052,27 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
+ * Encode WRITE_PLUS request
+ */
+static void nfs4_xdr_enc_write_plus(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    struct nfs42_write_plus_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->wp_fh, &hdr);
+	encode_write_plus(xdr, args, &hdr);
+	encode_nops(&hdr);
+	return;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
@@ -5971,6 +6040,49 @@ static int decode_free_stateid(struct xdr_stream *xdr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static int decode_write_response(struct xdr_stream *xdr,
+				 struct nfs42_write_res *write_res)
+{
+	__be32 *p;
+	int num_ids;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	num_ids = be32_to_cpup(p);
+
+	if (num_ids == 0)
+		write_res->wr_async = false;
+	else {
+		if (decode_stateid(xdr, &write_res->wr_stateid) != 0)
+			goto out_overflow;
+		write_res->wr_async = true;
+	}
+
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
+	p = xdr_decode_hyper(p, &write_res->wr_bytes_copied);
+	write_res->wr_committed = be32_to_cpup(p);
+
+	return decode_write_verifier(xdr, &write_res->wr_verf);
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_writeplus(struct xdr_stream *xdr, struct nfs42_write_res *res)
+{
+	res->wr_status = decode_op_hdr(xdr, OP_WRITE_PLUS);
+	if (res->wr_status)
+		return res->wr_status;
+
+	return decode_write_response(xdr, res);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -7183,6 +7295,33 @@ out:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
+ * Decode WRITE_PLUS response
+ */
+static int nfs4_xdr_dec_write_plus(struct rpc_rqst *rqstp,
+				   struct xdr_stream *xdr,
+				   struct nfs42_write_res *res)
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
+	status = decode_writeplus(xdr, res);
+
+out:
+	return status;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /**
  * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
  *                      the local page cache.
@@ -7392,6 +7531,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
+#if defined(CONFIG_NFS_V4_2)
+	PROC(WRITE_PLUS,	enc_write_plus,		dec_write_plus),
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 const struct rpc_version nfs_version4 = {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 81d6b09..237016a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -489,6 +489,9 @@ enum {
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
+
+	/* nfs42 */
+	NFSPROC4_CLNT_WRITE_PLUS,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 49f52c8..d8cbe5a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1223,6 +1223,35 @@ struct pnfs_ds_commit_info {
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+struct nfs42_write_plus_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*wp_fh;
+	nfs4_stateid			wp_stateid;
+	enum nfs3_stable_how		wp_stable;
+	enum data_content4		wp_content;
+	u64				wp_offset;
+	u64				wp_length;
+	u32				wp_allocated;
+};
+
+struct nfs42_write_res
+{
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			wr_status;
+
+	bool				wr_async;
+	nfs4_stateid			wr_stateid;
+	u64				wr_bytes_copied;
+	int				wr_committed;
+	struct nfs_write_verifier	wr_verf;
+
+	struct list_head		wait_list;
+	struct completion		completion;
+};
+#endif
+
 struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
-- 
1.8.4.1

