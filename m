Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6150 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569AbaIIOuA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:50:00 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfs: Add ALLOCATE support
Date: Tue, 9 Sep 2014 10:49:55 -0400
Message-ID: <1410274196-30841-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for using the NFS v4.2 operation ALLOCATE to
preallocate data in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c        | 37 ++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.h         | 68 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  2 ++
 fs/nfs/nfs4client.c       |  2 +-
 fs/nfs/nfs4file.c         | 34 ++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  2 +-
 fs/nfs/nfs4xdr.c          |  1 +
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 14 ++++++++++
 10 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 4c0703f..10c1605 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -12,6 +12,43 @@
 #include "nfs42.h"
 
 
+int _nfs42_proc_allocate(struct inode *inode, nfs4_stateid *stateid,
+			 loff_t offset, loff_t len)
+{
+	struct nfs42_allocate_args args = {
+		.alloc_fh	= NFS_FH(inode),
+		.alloc_stateid	= stateid,
+		.alloc_offset	= offset,
+		.alloc_length	= len,
+	};
+	struct nfs42_allocate_res res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ALLOCATE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	return nfs4_call_sync(server->client, server, &msg,
+			      &args.seq_args, &res.seq_res, 0);
+}
+
+int nfs42_proc_allocate(struct inode *inode, nfs4_stateid *stateid,
+			loff_t offset, loff_t len)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = _nfs42_proc_allocate(inode, stateid, offset, len);
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
index a30cb3a..10f4104 100644
--- a/fs/nfs/nfs42xdr.h
+++ b/fs/nfs/nfs42xdr.h
@@ -4,6 +4,11 @@
 #ifndef __LINUX_FS_NFS_NFS4_2XDR_H
 #define __LINUX_FS_NFS_NFS4_2XDR_H
 
+#define encode_allocate_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* offest */ + \
+					 2 /* length */)
+#define decode_allocate_maxsz		(op_decode_hdr_maxsz)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
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
+	encode_nfs4_stateid(xdr, args->alloc_stateid);
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
index ec1078f..f2d915d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -227,6 +227,7 @@ int nfs4_replace_transport(struct nfs_server *server,
 				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
+extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception *);
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
@@ -368,6 +369,7 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
+int nfs42_proc_allocate(struct inode *, nfs4_stateid *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
 #endif /* CONFIG_NFS_V4_2 */
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index f914797..d2cb702 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -932,7 +932,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 		server->caps |= NFS_CAP_UIDGID_NOMAP;
 
 	if (server->nfs_client->cl_minorversion >= 2)
-		server->caps |= NFS_CAP_SEEK;
+		server->caps |= NFS_CAP_ALLOCATE | NFS_CAP_SEEK;
 
 	/* Probe the root fh to retrieve its FSID and filehandle */
 	error = nfs4_get_rootfh(server, mntfh, auth_probe);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 6702f99..c6fbd27 100644
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
@@ -177,6 +179,35 @@ static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 		return nfs_file_llseek(filep, offset, whence);
 	}
 }
+
+static long nfs42_allocate(struct inode *inode, nfs4_stateid *stateid,
+			   loff_t offset, loff_t len)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	long ret = -EOPNOTSUPP;
+
+	if (server->caps & NFS_CAP_ALLOCATE) {
+		ret = nfs42_proc_allocate(inode, stateid, offset, len);
+		if (ret == -EOPNOTSUPP)
+			server->caps &= ~NFS_CAP_ALLOCATE;
+	}
+	return ret;
+}
+
+static long nfs42_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
+{
+	nfs4_stateid stateid;
+	int err;
+
+	if (mode & FALLOC_FL_PUNCH_HOLE)
+		return -EOPNOTSUPP;
+
+	err = nfs42_select_stateid(file, &stateid, FMODE_WRITE);
+	if (err < 0)
+		return err;
+
+	return nfs42_allocate(file_inode(file), &stateid, offset, len);
+}
 #endif /* CONFIG_NFS_V4_2 */
 
 const struct file_operations nfs4_file_operations = {
@@ -198,6 +229,9 @@ const struct file_operations nfs4_file_operations = {
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
 	.splice_write	= iter_file_splice_write,
+#ifdef CONFIG_NFS_V4_2
+	.fallocate	= nfs42_fallocate,
+#endif /* CONFIG_NFS_V4_2 */
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fd6e984..35e519e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -334,7 +334,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 /* This is the error handling routine for processes that are allowed
  * to sleep.
  */
-static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6b94428..c7479ea 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7501,6 +7501,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 #if defined(CONFIG_NFS_V4_2)
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
index 9724257..c6fae64 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1240,6 +1240,20 @@ struct pnfs_ds_commit_info {
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
+struct nfs42_allocate_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*alloc_fh;
+	nfs4_stateid			*alloc_stateid;
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
2.1.0

