Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18693 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697AbaIIOuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:50:02 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfs: Add DEALLOCATE support
Date: Tue, 9 Sep 2014 10:49:56 -0400
Message-ID: <1410274196-30841-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for using the NFS v4.2 operation DEALLOCATE to
punch holes in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c        | 37 ++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.h         | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  1 +
 fs/nfs/nfs4client.c       |  2 +-
 fs/nfs/nfs4file.c         | 19 ++++++++++---
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 14 ++++++++++
 9 files changed, 140 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 10c1605..6dd631f 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -49,6 +49,43 @@ int nfs42_proc_allocate(struct inode *inode, nfs4_stateid *stateid,
 	return err;
 }
 
+int _nfs42_proc_deallocate(struct inode *inode, nfs4_stateid *stateid,
+			   loff_t offset, loff_t len)
+{
+	struct nfs42_deallocate_args args = {
+		.dealloc_fh		= NFS_FH(inode),
+		.dealloc_stateid	= stateid,
+		.dealloc_offset		= offset,
+		.dealloc_length		= len,
+	};
+	struct nfs42_deallocate_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	return nfs4_call_sync(server->client, server, &msg,
+			      &args.seq_args, &res.seq_res, 0);
+}
+
+int nfs42_proc_deallocate(struct inode *inode, nfs4_stateid *stateid,
+			loff_t offset, loff_t len)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = _nfs42_proc_deallocate(inode, stateid, offset, len);
+		if (err == -ENOTSUPP)
+			return -EOPNOTSUPP;
+		err = nfs4_handle_exception(NFS_SERVER(inode), err, &exception);
+	} while (exception.retry);
+
+	return err;
+}
+
 loff_t nfs42_proc_llseek(struct inode *inode, nfs4_stateid *stateid,
 			 loff_t offset, int whence)
 {
diff --git a/fs/nfs/nfs42xdr.h b/fs/nfs/nfs42xdr.h
index 10f4104..3cb2d43 100644
--- a/fs/nfs/nfs42xdr.h
+++ b/fs/nfs/nfs42xdr.h
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
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
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
+	encode_nfs4_stateid(xdr, args->dealloc_stateid);
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
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f2d915d..be50bbf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -370,6 +370,7 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 
 #ifdef CONFIG_NFS_V4_2
 int nfs42_proc_allocate(struct inode *, nfs4_stateid *, loff_t, loff_t);
+int nfs42_proc_deallocate(struct inode *, nfs4_stateid *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
 #endif /* CONFIG_NFS_V4_2 */
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d2cb702..9de4b69 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -932,7 +932,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 		server->caps |= NFS_CAP_UIDGID_NOMAP;
 
 	if (server->nfs_client->cl_minorversion >= 2)
-		server->caps |= NFS_CAP_ALLOCATE | NFS_CAP_SEEK;
+		server->caps |= NFS_CAP_ALLOCATE | NFS_CAP_DEALLOCATE | NFS_CAP_SEEK;
 
 	/* Probe the root fh to retrieve its FSID and filehandle */
 	error = nfs4_get_rootfh(server, mntfh, auth_probe);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index c6fbd27..651497f 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -194,18 +194,31 @@ static long nfs42_allocate(struct inode *inode, nfs4_stateid *stateid,
 	return ret;
 }
 
+static long nfs42_deallocate(struct inode *inode, nfs4_stateid *stateid,
+			     loff_t offset, loff_t len)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	long ret = -EOPNOTSUPP;
+
+	if (server->caps & NFS_CAP_DEALLOCATE) {
+		ret = nfs42_proc_deallocate(inode, stateid, offset, len);
+		if (ret == -EOPNOTSUPP)
+			server->caps &= ~NFS_CAP_DEALLOCATE;
+	}
+	return ret;
+}
+
 static long nfs42_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 {
 	nfs4_stateid stateid;
 	int err;
 
-	if (mode & FALLOC_FL_PUNCH_HOLE)
-		return -EOPNOTSUPP;
-
 	err = nfs42_select_stateid(file, &stateid, FMODE_WRITE);
 	if (err < 0)
 		return err;
 
+	if (mode & FALLOC_FL_PUNCH_HOLE)
+		return nfs42_deallocate(file_inode(file), &stateid, offset, len);
 	return nfs42_allocate(file_inode(file), &stateid, offset, len);
 }
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c7479ea..5dcd7b9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7502,6 +7502,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #if defined(CONFIG_NFS_V4_2)
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
index c6fae64..4f0388d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1254,6 +1254,20 @@ struct nfs42_allocate_res {
 	unsigned int			status;
 };
 
+struct nfs42_deallocate_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*dealloc_fh;
+	nfs4_stateid			*dealloc_stateid;
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
2.1.0

