Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51610 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab3GSVD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:03:56 -0400
From: <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC 3/5] NFS: Add COPY nfs operation
Date: Fri, 19 Jul 2013 17:03:48 -0400
Message-ID: <1374267830-30154-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This adds the copy_range file_ops function pointer used by the
sys_copy_range() function call.  This patch only implements sync copies,
so if an async copy happens we decode the stateid and ignore it.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/inode.c          |   2 +
 fs/nfs/nfs4_fs.h        |   4 ++
 fs/nfs/nfs4file.c       |  53 +++++++++++++++++
 fs/nfs/nfs4proc.c       |  16 ++++++
 fs/nfs/nfs4xdr.c        | 150 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |  11 +++-
 include/linux/nfs_xdr.h |  30 ++++++++++
 7 files changed, 265 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..80849a0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -677,6 +677,7 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	kfree(new);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_get_lock_context);
 
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -689,6 +690,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 	spin_unlock(&inode->i_lock);
 	kfree(l_ctx);
 }
+EXPORT_SYMBOL_GPL(nfs_put_lock_context);
 
 /**
  * nfs_close_context - Common close_context() routine NFSv2/v3
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ee81e35..26c7cf0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -300,6 +300,10 @@ is_ds_client(struct nfs_client *clp)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+int nfs42_proc_copy(struct nfs_server *, struct nfs42_copy_args *, struct nfs42_copy_res *);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e5b804d..ca77ab4 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -117,6 +117,56 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	return ret;
 }
 
+#ifdef CONFIG_NFS_V4_2
+static int nfs4_find_copy_stateid(struct file *file, nfs4_stateid *stateid,
+				  fmode_t mode)
+{
+	struct nfs_open_context *open;
+	struct nfs_lock_context *lock;
+	int ret;
+
+	open = nfs_file_open_context(file);
+	if (!open)
+		return PTR_ERR(open);
+
+	lock = nfs_get_lock_context(open);
+	ret = nfs4_set_rw_stateid(stateid, open, lock, mode);
+
+	if (lock)
+		nfs_put_lock_context(lock);
+	return ret;
+}
+
+static ssize_t nfs4_copy_range(struct file *file_in, loff_t pos_in,
+			       struct file *file_out, loff_t pos_out,
+			       size_t count)
+{
+	int err;
+	struct nfs42_copy_args args = {
+		.src_fh  = NFS_FH(file_inode(file_in)),
+		.src_pos = pos_in,
+		.dst_fh  = NFS_FH(file_inode(file_out)),
+		.dst_pos = pos_out,
+		.count   = count,
+	};
+	struct nfs42_copy_res res;
+
+	err = nfs4_find_copy_stateid(file_in, &args.src_stateid, FMODE_READ);
+	if (err)
+		return err;
+
+	err = nfs4_find_copy_stateid(file_out, &args.dst_stateid, FMODE_WRITE);
+	if (err)
+		return err;
+
+	err = nfs42_proc_copy(NFS_SERVER(file_inode(file_out)), &args, &res);
+	if (err)
+		return err;
+
+	return res.cp_res.wr_bytes_copied;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 const struct file_operations nfs4_file_operations = {
 	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
@@ -134,4 +184,7 @@ const struct file_operations nfs4_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+#ifdef CONFIG_NFS_V4_2
+	.copy_range	= nfs4_copy_range,
+#endif /* CONFIG_NFS_V4_2 */
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cf11799..f7eb4fd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7346,6 +7346,22 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+int nfs42_proc_copy(struct nfs_server *server, struct nfs42_copy_args *args,
+		    struct nfs42_copy_res *res)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
+		.rpc_argp = args,
+		.rpc_resp = res,
+	};
+
+	dprintk("NFS call copy %p\n", &args);
+	return nfs4_call_sync(server->client, server, &msg,
+				&(args->seq_args), &(res->seq_res), 0);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0abfb846..d70c6bc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -416,6 +416,16 @@ static int nfs4_stat_to_errno(int);
 #define decode_sequence_maxsz	0
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+#define encode_copy_maxsz		(op_encode_hdr_maxsz +          \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 + 2 + 2 + 1 + 1 + 1)
+#define decode_copy_maxsz		(op_decode_hdr_maxsz + \
+					 1 + XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 + 1 + XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
@@ -875,6 +885,19 @@ const u32 nfs41_maxgetdevinfo_overhead = ((RPC_MAX_REPHEADER_WITH_AUTH +
 EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
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
+#endif /* CONFIG_NFS_V4_2 */
+
 static const umode_t nfs_type2fmt[] = {
 	[NF4BAD] = 0,
 	[NF4REG] = S_IFREG,
@@ -2048,6 +2071,27 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static void encode_copy(struct xdr_stream *xdr,
+			struct nfs42_copy_args *args,
+			struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_COPY, decode_copy_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->src_stateid);
+	encode_nfs4_stateid(xdr, &args->dst_stateid);
+
+	/* TODO: Partial file copy with changable offsets */
+	encode_uint64(xdr, args->src_pos); /* src offset */
+	encode_uint64(xdr, args->dst_pos); /* dst offset */
+	encode_uint64(xdr, args->count); /* count */
+
+	encode_uint32(xdr, COPY4_METADATA); /* flags */
+
+	encode_uint32(xdr, 0); /* ca_destination */
+	encode_uint32(xdr, 0); /* src server list */
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -2994,6 +3038,29 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
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
+	return;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
@@ -5943,6 +6010,54 @@ out_overflow:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static int decode_write_response(struct xdr_stream *xdr,
+				 struct nfs42_write_response *write_res)
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
+		write_res->wr_stateid = NULL;
+	else {
+		write_res->wr_stateid = kmalloc(sizeof(nfs4_stateid), GFP_KERNEL);
+		if (decode_stateid(xdr, write_res->wr_stateid) != 0)
+			goto out_free;
+	}
+
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_free;
+	p = xdr_decode_hyper(p, &write_res->wr_bytes_copied);
+	write_res->wr_committed = be32_to_cpup(p);
+
+	return decode_write_verifier(xdr, &write_res->wr_verf);
+
+out_free:
+	kfree(write_res->wr_stateid);
+
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
+	if (status)
+		return status;
+
+	return decode_write_response(xdr, &res->cp_res);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -7155,6 +7270,38 @@ out:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
+ * Decode COPY request
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
+#endif /* CONFIG_NFS_V4_2 */
+
 /**
  * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
  *                      the local page cache.
@@ -7364,6 +7511,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
+#if defined(CONFIG_NFS_V4_2)
+	PROC(COPY,		enc_copy,		dec_copy),
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 const struct rpc_version nfs_version4 = {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index ebf60c6..347de63 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -120,7 +120,7 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS4_OP 	OP_COPY
 
 enum nfsstat4 {
 	NFS4_OK = 0,
@@ -333,6 +333,12 @@ enum lock_type4 {
 	NFS4_WRITEW_LT = 4
 };
 
+#ifdef CONFIG_NFS_V4_2
+enum copy_flags4 {
+	COPY4_GUARDED = (1 << 0),
+	COPY4_METADATA = (1 << 1),
+};
+#endif
 
 /* Mandatory Attributes */
 #define FATTR4_WORD0_SUPPORTED_ATTRS    (1UL << 0)
@@ -481,6 +487,9 @@ enum {
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
+
+	/* nfs42 */
+	NFSPROC4_CLNT_COPY,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8651574..0bc6b14 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1204,6 +1204,36 @@ struct pnfs_ds_commit_info {
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+struct nfs42_write_response
+{
+	nfs4_stateid			*wr_stateid;
+	u64				wr_bytes_copied;
+	int				wr_committed;
+	struct nfs_write_verifier	wr_verf;
+};
+
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
+struct nfs42_copy_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			status;
+	struct nfs42_write_response	cp_res;
+};
+#endif
+
 struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
-- 
1.8.3.3

