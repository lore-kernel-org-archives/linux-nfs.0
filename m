Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18916 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756Ab3KLTGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:06:25 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: Implement SEEK
Date: Tue, 12 Nov 2013 14:06:11 -0500
Message-ID: <1384283171-8062-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1384283171-8062-1-git-send-email-bjschuma@netapp.com>
References: <1384283171-8062-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The SEEK operation is used when an application makes an lseek call with
either the SEEK_HOLE or SEEK_DATA flags set.  I fall back on
nfs_file_llseek() when other flags are set or in the NFS < 4.2 case.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>

---
Changed in v2:
- Remove unnecessary return from nfs4_xdr_enc_seek()

 fs/nfs/inode.c          |   2 +
 fs/nfs/nfs4_fs.h        |   4 ++
 fs/nfs/nfs4file.c       |  61 +++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |  31 ++++++++++++++
 fs/nfs/nfs4xdr.c        | 109 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |   3 ++
 include/linux/nfs_xdr.h |  22 ++++++++++
 7 files changed, 232 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 471ba59..e558d8f 100644
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
index 3ce79b0..a4abb3c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -365,6 +365,10 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 1f01b55..82167fc 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -118,8 +118,69 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
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
+static loff_t nfs42_file_llseek(struct file *filep, loff_t offset, int whence)
+{
+	nfs4_stateid stateid;
+	struct nfs_open_context *ctx;
+	struct inode *inode = file_inode(filep);
+	loff_t pos;
+
+	pos = nfs42_select_stateid(filep, &stateid, FMODE_READ | FMODE_WRITE, &ctx);
+	if (pos < 0)
+		return pos;
+
+	nfs_wb_all(inode);
+	pos = nfs42_proc_llseek(inode, &stateid, offset, whence);
+	if (pos < 0)
+		return pos;
+	return vfs_setpos(filep, pos, inode->i_sb->s_maxbytes);
+}
+
+static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
+{
+	struct nfs_server *server = NFS_SERVER(file_inode(filep));
+
+	if (server->nfs_client->cl_minorversion < 2)
+		return nfs_file_llseek(filep, offset, whence);
+
+	switch (whence) {
+	case SEEK_HOLE:
+	case SEEK_DATA:
+		return nfs42_file_llseek(filep, offset, whence);
+	default:
+		return nfs_file_llseek(filep, offset, whence);
+	}
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 const struct file_operations nfs4_file_operations = {
+#ifdef CONFIG_NFS_V4_2
+	.llseek		= nfs4_file_llseek,
+#else
 	.llseek		= nfs_file_llseek,
+#endif
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e28b5c..9907225 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8163,6 +8163,37 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+loff_t nfs42_proc_llseek(struct inode *inode, nfs4_stateid *stateid,
+			 loff_t offset, int whence)
+{
+	struct nfs42_seek_args args = {
+		.sa_fh		= NFS_FH(inode),
+		.sa_stateid	= stateid,
+		.sa_offset	= offset,
+	};
+	struct nfs42_seek_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEEK],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(inode);
+	int status;
+
+	if (whence == SEEK_HOLE)
+		args.sa_what = NFS4_CONTENT_HOLE;
+	else
+		args.sa_what = NFS4_CONTENT_DATA;
+
+	status = nfs4_call_sync(server->client, server, &msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status)
+		return status;
+	return res.sr_offset;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f903389..05396ee 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -420,6 +420,18 @@ static int nfs4_stat_to_errno(int);
 #define decode_sequence_maxsz	0
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+#define encode_seek_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* offset */ + \
+					 1 /* whence */)
+#define decode_seek_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* eof */ + \
+					 1 /* whence */ + \
+					 2 /* offset */ + \
+					 2 /* length */)
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
@@ -895,6 +907,15 @@ const u32 nfs41_maxgetdevinfo_overhead = ((RPC_MAX_REPHEADER_WITH_AUTH +
 EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+#define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_seek_maxsz)
+#define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_seek_maxsz)
+#endif /* CONFIG_NFS_V4_2 */
+
 static const umode_t nfs_type2fmt[] = {
 	[NF4BAD] = 0,
 	[NF4REG] = S_IFREG,
@@ -2074,6 +2095,18 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static void encode_seek(struct xdr_stream *xdr,
+			struct nfs42_seek_args *args,
+			struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_SEEK, decode_seek_maxsz, hdr);
+	encode_nfs4_stateid(xdr, args->sa_stateid);
+	encode_uint64(xdr, args->sa_offset);
+	encode_uint32(xdr, args->sa_what);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -3049,6 +3082,26 @@ static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
+ * Encode SEEK request
+ */
+static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
+			      struct xdr_stream *xdr,
+			      struct nfs42_seek_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->sa_fh, &hdr);
+	encode_seek(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
@@ -6016,6 +6069,33 @@ static int decode_free_stateid(struct xdr_stream *xdr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
+{
+	int status;
+	__be32 *p;
+
+	status = decode_op_hdr(xdr, OP_SEEK);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 28);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->sr_eof = be32_to_cpup(p++);
+	res->sr_whence = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &res->sr_offset);
+	p = xdr_decode_hyper(p, &res->sr_length);
+	res->sr_allocated = be32_to_cpup(p);
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -7269,6 +7349,32 @@ out:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+/*
+ * Decode SEEK request
+ */
+static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
+			     struct xdr_stream *xdr,
+			     struct nfs42_seek_res *res)
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
+	status = decode_seek(xdr, res);
+out:
+	return status;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 /**
  * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
  *                      the local page cache.
@@ -7479,6 +7585,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
+#if defined(CONFIG_NFS_V4_2)
+	PROC(SEEK,		enc_seek,		dec_seek),
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 const struct rpc_version nfs_version4 = {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 144f511..05125b1 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -493,6 +493,9 @@ enum {
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
+
+	/* nfs42 */
+	NFSPROC4_CLNT_SEEK,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ccfcec..9fcabef 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1247,6 +1247,28 @@ struct pnfs_ds_commit_info {
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+struct nfs42_seek_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*sa_fh;
+	nfs4_stateid			*sa_stateid;
+	u64				sa_offset;
+	u32				sa_what;
+};
+
+struct nfs42_seek_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			status;
+
+	u32	sr_eof;
+	u32	sr_whence;
+	u64	sr_offset;
+	u64	sr_length;
+	u32	sr_allocated;
+};
+#endif
+
 struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
-- 
1.8.4.2

