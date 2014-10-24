Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33032 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767AbaJXOmk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2014 10:42:40 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 2/2] nfs: Add DEALLOCATE support
Date: Fri, 24 Oct 2014 10:42:13 -0400
Message-ID: <1414161733-26726-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1414161733-26726-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1414161733-26726-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for using the NFS v4.2 operation DEALLOCATE to
punch holes in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42.h            |  1 +
 fs/nfs/nfs42proc.c        | 46 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  7 +++--
 fs/nfs/nfs4proc.c         |  1 +
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 14 ++++++++++
 9 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 42656a9..7afb894 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -7,6 +7,7 @@
 
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
+int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 
 /* nfs4.2xdr.h */
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 44e0c7b..9613362 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -78,6 +78,52 @@ int nfs42_proc_allocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+int _nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
+{
+	struct nfs42_deallocate_args args = {
+		.dealloc_fh		= NFS_FH(file_inode(filep)),
+		.dealloc_offset		= offset,
+		.dealloc_length		= len,
+	};
+	struct nfs42_deallocate_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(file_inode(filep));
+	int status;
+
+	status = nfs42_set_rw_stateid(&args.dealloc_stateid, filep, FMODE_WRITE);
+	if (status)
+		return status;
+
+	return nfs4_call_sync(server->client, server, &msg,
+			      &args.seq_args, &res.seq_res, 0);
+}
+
+int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
+{
+	struct inode *inode = file_inode(filep);
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_exception exception = { };
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_DEALLOCATE))
+		return -EOPNOTSUPP;
+
+	do {
+		err = _nfs42_proc_deallocate(filep, offset, len);
+		if (err == -ENOTSUPP) {
+			server->caps &= ~NFS_CAP_DEALLOCATE;
+			return -EOPNOTSUPP;
+		}
+		err = nfs4_handle_exception(server, err, &exception);
+	} while (exception.retry);
+
+	return err;
+}
+
 loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(filep);
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 9506f5a..5db9dad 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -9,6 +9,11 @@
 					 2 /* offest */ + \
 					 2 /* length */)
 #define decode_allocate_maxsz		(op_decode_hdr_maxsz)
+#define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* offest */ + \
+					 2 /* length */)
+#define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 encode_stateid_maxsz + \
 					 2 /* offset */ + \
@@ -25,6 +30,12 @@
 #define NFS4_dec_allocate_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_allocate_maxsz)
+#define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_deallocate_maxsz)
+#define NFS4_dec_deallocate_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_deallocate_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -43,6 +54,16 @@ static void encode_allocate(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->alloc_length);
 }
 
+static void encode_deallocate(struct xdr_stream *xdr,
+			      struct nfs42_deallocate_args *args,
+			      struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_DEALLOCATE, decode_deallocate_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->dealloc_stateid);
+	encode_uint64(xdr, args->dealloc_offset);
+	encode_uint64(xdr, args->dealloc_length);
+}
+
 static void encode_seek(struct xdr_stream *xdr,
 			struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
@@ -72,6 +93,24 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 }
 
 /*
+ * Encode DEALLOCATE request
+ */
+static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    struct nfs42_deallocate_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->dealloc_fh, &hdr);
+	encode_deallocate(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode SEEK request
  */
 static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
@@ -94,6 +133,11 @@ static int decode_allocate(struct xdr_stream *xdr, struct nfs42_allocate_res *re
 	return decode_op_hdr(xdr, OP_ALLOCATE);
 }
 
+static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_deallocate_res *res)
+{
+	return decode_op_hdr(xdr, OP_DEALLOCATE);
+}
+
 static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 {
 	int status;
@@ -141,6 +185,30 @@ out:
 }
 
 /*
+ * Decode DEALLOCATE request
+ */
+static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
+				   struct xdr_stream *xdr,
+				   struct nfs42_deallocate_res *res)
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
+	status = decode_deallocate(xdr, res);
+out:
+	return status;
+}
+
+/*
  * Decode SEEK request
  */
 static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 6256957..1b2d82d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -142,11 +142,14 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 	struct inode *inode = file_inode(filep);
 	long ret;
 
-	if (mode != 0)
+	if ((mode != 0) && (mode != (FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE)))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&inode->i_mutex);
-	ret = nfs42_proc_allocate(filep, offset, len);
+	if (mode & FALLOC_FL_PUNCH_HOLE)
+		ret = nfs42_proc_deallocate(filep, offset, len);
+	else
+		ret = nfs42_proc_allocate(filep, offset, len);
 	mutex_unlock(&inode->i_mutex);
 	return ret;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 65a3859..cb5dd74 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8432,6 +8432,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
+		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0a14845..03d0fa6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7395,6 +7395,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #ifdef CONFIG_NFS_V4_2
 	PROC(SEEK,		enc_seek,		dec_seek),
 	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
+	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2b28a21..022b761 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -491,6 +491,7 @@ enum {
 	/* nfs42 */
 	NFSPROC4_CLNT_SEEK,
 	NFSPROC4_CLNT_ALLOCATE,
+	NFSPROC4_CLNT_DEALLOCATE,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index df6ed42..1e37fbb 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -232,5 +232,6 @@ struct nfs_server {
 #define NFS_CAP_SECURITY_LABEL	(1U << 18)
 #define NFS_CAP_SEEK		(1U << 19)
 #define NFS_CAP_ALLOCATE	(1U << 20)
+#define NFS_CAP_DEALLOCATE	(1U << 21)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f3fc647..9098e51 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1246,6 +1246,20 @@ struct nfs42_allocate_res {
 	unsigned int			status;
 };
 
+struct nfs42_deallocate_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*dealloc_fh;
+	nfs4_stateid			 dealloc_stateid;
+	u64				 dealloc_offset;
+	u64				 dealloc_length;
+};
+
+struct nfs42_deallocate_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			status;
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
2.1.2

