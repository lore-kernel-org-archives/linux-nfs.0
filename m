Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:7365 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932677Ab3J1PAq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:00:46 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] NFS: Implement SEEK
Date: Mon, 28 Oct 2013 11:00:18 -0400
Message-ID: <1382972418-2249-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The SEEK operation is used when an application makes an lseek call with
either the SEEK_HOLE or SEEK_DATA flags set.  I fall back on
nfs_file_llseek() when other flags are set or in the NFS < 4.2 case.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h        |  1 +
 fs/nfs/nfs4file.c       | 38 +++++++++++++++++++++
 fs/nfs/nfs4proc.c       | 29 ++++++++++++++++
 fs/nfs/nfs4xdr.c        | 91 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |  1 +
 include/linux/nfs_xdr.h | 20 +++++++++++
 6 files changed, 180 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f52fc5f..badc1fa 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -355,6 +355,7 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 #ifdef CONFIG_NFS_V4_2
 int nfs42_proc_fallocate(struct nfs_server *, struct nfs42_write_plus_args *,
 			 struct nfs42_write_res *, struct rpc_cred *);
+loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
 #endif /* CONFIG_NFS_V4_2 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index caf0658..b88ba0c 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -218,10 +218,48 @@ static long nfs42_fallocate(struct file *file, int mode, loff_t offset, loff_t l
 		err = nfs_wait_for_offload(&res);
 	return err;
 }
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
 #endif /* CONFIG_NFS_V4_2 */
 
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
index 003bacb..79f1295 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7865,6 +7865,35 @@ int nfs42_proc_fallocate(struct nfs_server *server,
 
 	return err;
 }
+
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
 #endif /* CONFIG_NFS_V4_2 */
 
 static bool nfs4_match_stateid(const nfs4_stateid *s1,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 28e2fad..f7ced39 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -435,6 +435,10 @@ static int nfs4_stat_to_errno(int);
 					 2 /* bytes written */ + \
 					 1 /* committed */ + \
 					 XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#define encode_seek_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 + 1)
+#define decode_seek_maxsz		(op_decode_hdr_maxsz + 1 + 1 + 5)
 #endif /* CONFIG_NFS_V4_2 */
 
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
@@ -903,6 +907,12 @@ EXPORT_SYMBOL_GPL(nfs41_maxgetdevinfo_overhead);
 #define NFS4_dec_write_plus_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_write_plus_maxsz)
+#define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_seek_maxsz)
+#define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_seek_maxsz)
 #endif /* CONFIG_NFS_V4_2 */
 
 static const umode_t nfs_type2fmt[] = {
@@ -2104,6 +2114,16 @@ static void encode_write_plus(struct xdr_stream *xdr,
 	encode_uint32(xdr, 1);
 	encode_write_plus_hole(xdr, args);
 }
+
+static void encode_seek(struct xdr_stream *xdr,
+			struct nfs42_seek_args *args,
+			struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_SEEK, decode_seek_maxsz, hdr);
+	encode_nfs4_stateid(xdr, args->sa_stateid);
+	encode_uint64(xdr, args->sa_offset);
+	encode_uint32(xdr, args->sa_what);
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 /*
@@ -3071,6 +3091,25 @@ static void nfs4_xdr_enc_write_plus(struct rpc_rqst *req,
 	encode_nops(&hdr);
 	return;
 }
+
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
+	return;
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -6081,6 +6120,33 @@ static int decode_writeplus(struct xdr_stream *xdr, struct nfs42_write_res *res)
 
 	return decode_write_response(xdr, res);
 }
+
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
+
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 /*
@@ -7320,6 +7386,30 @@ static int nfs4_xdr_dec_write_plus(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
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
 #endif /* CONFIG_NFS_V4_2 */
 
 /**
@@ -7533,6 +7623,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 #if defined(CONFIG_NFS_V4_2)
 	PROC(WRITE_PLUS,	enc_write_plus,		dec_write_plus),
+	PROC(SEEK,		enc_seek,		dec_seek),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 237016a..0d9033a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -492,6 +492,7 @@ enum {
 
 	/* nfs42 */
 	NFSPROC4_CLNT_WRITE_PLUS,
+	NFSPROC4_CLNT_SEEK,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d8cbe5a..a46f803 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1236,6 +1236,26 @@ struct nfs42_write_plus_args {
 	u32				wp_allocated;
 };
 
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
+
 struct nfs42_write_res
 {
 	struct nfs4_sequence_res	seq_res;
-- 
1.8.4.1

