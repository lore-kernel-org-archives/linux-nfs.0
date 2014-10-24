Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39076 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288AbaJXOmj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2014 10:42:39 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/2] nfs: Add ALLOCATE support
Date: Fri, 24 Oct 2014 10:42:12 -0400
Message-ID: <1414161733-26726-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1414161733-26726-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1414161733-26726-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for using the NFS v4.2 operation ALLOCATE to
preallocate data in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42.h            |  1 +
 fs/nfs/nfs42proc.c        | 46 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  1 +
 fs/nfs/nfs4file.c         | 19 +++++++++++++
 fs/nfs/nfs4proc.c         |  3 ++-
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 14 ++++++++++
 10 files changed, 154 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index d10333a..42656a9 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -6,6 +6,7 @@
 #define __LINUX_FS_NFS_NFS4_2_H
 
 /* nfs4.2proc.c */
+int nfs42_proc_allocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 
 /* nfs4.2xdr.h */
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 056f5aa..44e0c7b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -32,6 +32,52 @@ static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 	return ret;
 }
 
+int _nfs42_proc_allocate(struct file *filep, loff_t offset, loff_t len)
+{
+	struct nfs42_allocate_args args = {
+		.alloc_fh	= NFS_FH(file_inode(filep)),
+		.alloc_offset	= offset,
+		.alloc_length	= len,
+	};
+	struct nfs42_allocate_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ALLOCATE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(file_inode(filep));
+	int status;
+
+	status = nfs42_set_rw_stateid(&args.alloc_stateid, filep, FMODE_WRITE);
+	if (status)
+		return status;
+
+	return nfs4_call_sync(server->client, server, &msg,
+			      &args.seq_args, &res.seq_res, 0);
+}
+
+int nfs42_proc_allocate(struct file *filep, loff_t offset, loff_t len)
+{
+	struct inode *inode = file_inode(filep);
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs4_exception exception = { };
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_ALLOCATE))
+		return -EOPNOTSUPP;
+
+	do {
+		err = _nfs42_proc_allocate(filep, offset, len);
+		if (err == -ENOTSUPP) {
+			server->caps &= ~NFS_CAP_ALLOCATE;
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
index c90469b..9506f5a 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -4,6 +4,11 @@
 #ifndef __LINUX_FS_NFS_NFS4_2XDR_H
 #define __LINUX_FS_NFS_NFS4_2XDR_H
 
+#define encode_allocate_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* offest */ + \
+					 2 /* length */)
+#define decode_allocate_maxsz		(op_decode_hdr_maxsz)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 encode_stateid_maxsz + \
 					 2 /* offset */ + \
@@ -14,6 +19,12 @@
 					 2 /* offset */ + \
 					 2 /* length */)
 
+#define NFS4_enc_allocate_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_allocate_maxsz)
+#define NFS4_dec_allocate_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_allocate_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -22,6 +33,16 @@
 					 decode_seek_maxsz)
 
 
+static void encode_allocate(struct xdr_stream *xdr,
+			    struct nfs42_allocate_args *args,
+			    struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_ALLOCATE, decode_allocate_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->alloc_stateid);
+	encode_uint64(xdr, args->alloc_offset);
+	encode_uint64(xdr, args->alloc_length);
+}
+
 static void encode_seek(struct xdr_stream *xdr,
 			struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
@@ -33,6 +54,24 @@ static void encode_seek(struct xdr_stream *xdr,
 }
 
 /*
+ * Encode ALLOCATE request
+ */
+static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
+				  struct xdr_stream *xdr,
+				  struct nfs42_allocate_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->alloc_fh, &hdr);
+	encode_allocate(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode SEEK request
  */
 static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
@@ -50,6 +89,11 @@ static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+static int decode_allocate(struct xdr_stream *xdr, struct nfs42_allocate_res *res)
+{
+	return decode_op_hdr(xdr, OP_ALLOCATE);
+}
+
 static int decode_seek(struct xdr_stream *xdr, struct nfs42_seek_res *res)
 {
 	int status;
@@ -73,6 +117,30 @@ out_overflow:
 }
 
 /*
+ * Decode ALLOCATE request
+ */
+static int nfs4_xdr_dec_allocate(struct rpc_rqst *rqstp,
+				 struct xdr_stream *xdr,
+				 struct nfs42_allocate_res *res)
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
+	status = decode_allocate(xdr, res);
+out:
+	return status;
+}
+
+/*
  * Decode SEEK request
  */
 static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index be6cac3..a081787 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -226,6 +226,7 @@ int nfs4_replace_transport(struct nfs_server *server,
 				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
+extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index c51fb4d..6256957 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -3,6 +3,8 @@
  *
  *  Copyright (C) 1992  Rick Sladkey
  */
+#include <linux/fs.h>
+#include <linux/falloc.h>
 #include <linux/nfs_fs.h>
 #include "internal.h"
 #include "fscache.h"
@@ -134,6 +136,20 @@ static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 		return nfs_file_llseek(filep, offset, whence);
 	}
 }
+
+static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t len)
+{
+	struct inode *inode = file_inode(filep);
+	long ret;
+
+	if (mode != 0)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&inode->i_mutex);
+	ret = nfs42_proc_allocate(filep, offset, len);
+	mutex_unlock(&inode->i_mutex);
+	return ret;
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
@@ -155,6 +171,9 @@ const struct file_operations nfs4_file_operations = {
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
+#ifdef CONFIG_NFS_V4_2
+	.fallocate	= nfs42_fallocate,
+#endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= simple_nosetlease,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8aba549..65a3859 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -344,7 +344,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 /* This is the error handling routine for processes that are allowed
  * to sleep.
  */
-static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
@@ -8431,6 +8431,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
+		| NFS_CAP_ALLOCATE
 		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 206c08a..0a14845 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7394,6 +7394,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 #ifdef CONFIG_NFS_V4_2
 	PROC(SEEK,		enc_seek,		dec_seek),
+	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 356acc2..2b28a21 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -490,6 +490,7 @@ enum {
 
 	/* nfs42 */
 	NFSPROC4_CLNT_SEEK,
+	NFSPROC4_CLNT_ALLOCATE,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a32ba0d..df6ed42 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -231,5 +231,6 @@ struct nfs_server {
 #define NFS_CAP_ATOMIC_OPEN_V1	(1U << 17)
 #define NFS_CAP_SECURITY_LABEL	(1U << 18)
 #define NFS_CAP_SEEK		(1U << 19)
+#define NFS_CAP_ALLOCATE	(1U << 20)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 983876f..f3fc647 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1232,6 +1232,20 @@ struct pnfs_ds_commit_info {
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
+struct nfs42_allocate_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*alloc_fh;
+	nfs4_stateid			 alloc_stateid;
+	u64				 alloc_offset;
+	u64				 alloc_length;
+};
+
+struct nfs42_allocate_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			status;
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
2.1.2

