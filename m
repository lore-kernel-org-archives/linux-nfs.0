Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26631 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934425AbaH0PTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 11:19:23 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Implement SEEK
Date: Wed, 27 Aug 2014 11:18:50 -0400
Message-ID: <1409152730-8070-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409152730-8070-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409152730-8070-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

The SEEK operation is used when an application makes an lseek call with
either the SEEK_HOLE or SEEK_DATA flags set.  I fall back on
nfs_file_llseek() if the server does not have SEEK support.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/Makefile           |  1 +
 fs/nfs/inode.c            |  2 +
 fs/nfs/nfs4.2.h           | 14 +++++++
 fs/nfs/nfs4.2proc.c       | 39 +++++++++++++++++++
 fs/nfs/nfs4.2xdr.h        | 98 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  7 ++++
 fs/nfs/nfs4client.c       |  2 +
 fs/nfs/nfs4file.c         | 68 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 -
 fs/nfs/nfs4xdr.c          |  7 ++++
 fs/nfsd/nfs4proc.c        |  2 +-
 include/linux/nfs4.h      |  3 ++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 19 +++++++++
 14 files changed, 262 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs4.2.h
 create mode 100644 fs/nfs/nfs4.2proc.c
 create mode 100644 fs/nfs/nfs4.2xdr.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 4782e08..92fefda 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -28,6 +28,7 @@ nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o
 nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
 nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
 nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_NFS_V4_2)	+= nfs4.2proc.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 577a36f..56d073e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -716,6 +716,7 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	kfree(new);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_get_lock_context);
 
 void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 {
@@ -728,6 +729,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 	spin_unlock(&inode->i_lock);
 	kfree(l_ctx);
 }
+EXPORT_SYMBOL_GPL(nfs_put_lock_context);
 
 /**
  * nfs_close_context - Common close_context() routine NFSv2/v3
diff --git a/fs/nfs/nfs4.2.h b/fs/nfs/nfs4.2.h
new file mode 100644
index 0000000..9eecdf2
--- /dev/null
+++ b/fs/nfs/nfs4.2.h
@@ -0,0 +1,14 @@
+/*
+ * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp>
+ */
+
+#ifndef __LINUX_FS_NFS_NFS4_2_H
+#define __LINUX_FS_NFS_NFS4_2_H
+
+/* nfs4.2proc.c */
+loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
+
+/* nfs4.2xdr.h */
+extern struct rpc_procinfo nfs4_2_procedures[];
+
+#endif /* __LINUX_FS_NFS_NFS4_2_H */
diff --git a/fs/nfs/nfs4.2proc.c b/fs/nfs/nfs4.2proc.c
new file mode 100644
index 0000000..588c6ed
--- /dev/null
+++ b/fs/nfs/nfs4.2proc.c
@@ -0,0 +1,39 @@
+/*
+ * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp>
+ */
+#include <linux/fs.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_xdr.h>
+#include <linux/nfs_fs.h>
+#include "nfs4_fs.h"
+#include "nfs4.2.h"
+
+
+loff_t nfs42_proc_llseek(struct inode *inode, nfs4_stateid *stateid,
+			 loff_t offset, int whence)
+{
+	struct nfs42_seek_args args = {
+		.sa_fh		= NFS_FH(inode),
+		.sa_stateid	= stateid,
+		.sa_offset	= offset,
+		.sa_what	= (whence == SEEK_HOLE) ?
+					NFS4_CONTENT_HOLE : NFS4_CONTENT_DATA,
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
+	status = nfs4_call_sync(server->client, server, &msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status)
+		return status;
+	return res.sr_offset;
+}
diff --git a/fs/nfs/nfs4.2xdr.h b/fs/nfs/nfs4.2xdr.h
new file mode 100644
index 0000000..a30cb3a
--- /dev/null
+++ b/fs/nfs/nfs4.2xdr.h
@@ -0,0 +1,98 @@
+/*
+ * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp>
+ */
+#ifndef __LINUX_FS_NFS_NFS4_2XDR_H
+#define __LINUX_FS_NFS_NFS4_2XDR_H
+
+#define encode_seek_maxsz		(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 /* offset */ + \
+					 1 /* whence */)
+#define decode_seek_maxsz		(op_decode_hdr_maxsz + \
+					 1 /* eof */ + \
+					 1 /* whence */ + \
+					 2 /* offset */ + \
+					 2 /* length */)
+
+#define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_seek_maxsz)
+#define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_seek_maxsz)
+
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
+}
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
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->sr_eof = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &res->sr_offset);
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
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
+#endif /* __LINUX_FS_NFS_NFS4_2XDR_H */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 92193ed..ec1078f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -227,6 +227,9 @@ int nfs4_replace_transport(struct nfs_server *server,
 				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
+extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
+			  struct rpc_message *, struct nfs4_sequence_args *,
+			  struct nfs4_sequence_res *, int);
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
@@ -364,6 +367,10 @@ nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+loff_t nfs42_proc_llseek(struct inode *, nfs4_stateid *, loff_t, int);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 53e435a..f914797 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -931,6 +931,8 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 			server->client->cl_auth->au_flavor == RPC_AUTH_UNIX)
 		server->caps |= NFS_CAP_UIDGID_NOMAP;
 
+	if (server->nfs_client->cl_minorversion >= 2)
+		server->caps |= NFS_CAP_SEEK;
 
 	/* Probe the root fh to retrieve its FSID and filehandle */
 	error = nfs4_get_rootfh(server, mntfh, auth_probe);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index a816f06..52760a3 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -8,6 +8,10 @@
 #include "fscache.h"
 #include "pnfs.h"
 
+#ifdef CONFIG_NFS_V4_2
+#include "nfs4.2.h"
+#endif
+
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
 static int
@@ -115,8 +119,72 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	return ret;
 }
 
+#ifdef CONFIG_NFS_V4_2
+static int nfs42_select_stateid(struct file *file, nfs4_stateid *stateid, fmode_t mode)
+{
+	struct nfs_open_context *open;
+	struct nfs_lock_context *lock;
+	int ret;
+
+	open = nfs_file_open_context(file);
+	if (!open)
+		return -EBADF;
+
+	lock = nfs_get_lock_context(open);
+	if (IS_ERR(lock))
+		return PTR_ERR(lock);
+
+	ret = nfs4_set_rw_stateid(stateid, open, lock, mode);
+
+	if (lock)
+		nfs_put_lock_context(lock);
+	return ret;
+}
+
+static loff_t nfs42_file_llseek(struct file *filep, loff_t offset, int whence)
+{
+	struct inode *inode = file_inode(filep);
+	nfs4_stateid stateid;
+	loff_t pos;
+	int err;
+
+	err = nfs42_select_stateid(filep, &stateid, FMODE_READ | FMODE_WRITE);
+	if (err < 0)
+		return err;
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
+	loff_t ret;
+
+	switch (whence) {
+	case SEEK_HOLE:
+	case SEEK_DATA:
+		if (server->caps & NFS_CAP_SEEK) {
+			ret = nfs42_file_llseek(filep, offset, whence);
+			if (ret != -ENOTSUPP)
+				return ret;
+			server->caps &= ~NFS_CAP_SEEK;
+		}
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
 	.read		= new_sync_read,
 	.write		= new_sync_write,
 	.read_iter	= nfs_file_read,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7dd8aca..fd6e984 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -875,7 +875,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	return ret;
 }
 
-static
 int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs_server *server,
 		   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e13b59d..c4f93da 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7427,6 +7427,10 @@ nfs4_stat_to_errno(int stat)
 	return -stat;
 }
 
+#if defined(CONFIG_NFS_V4_2)
+#include "nfs4.2xdr.h"
+#endif /* CONFIG_NFS_V4_2 */
+
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
@@ -7495,6 +7499,9 @@ struct rpc_procinfo	nfs4_procedures[] = {
 			enc_bind_conn_to_session, dec_bind_conn_to_session),
 	PROC(DESTROY_CLIENTID,	enc_destroy_clientid,	dec_destroy_clientid),
 #endif /* CONFIG_NFS_V4_1 */
+#if defined(CONFIG_NFS_V4_2)
+	PROC(SEEK,		enc_seek,		dec_seek),
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 const struct rpc_version nfs_version4 = {
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f555eb2..32e8234 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1019,7 +1019,7 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_seek *seek)
 {
 	struct file *file;
-	__be32 status = nfs_ok;
+	__be32 status;
 
 	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
 					    &seek->seek_stateid,
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 026b0c0..356acc2 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -487,6 +487,9 @@ enum {
 	NFSPROC4_CLNT_GETDEVICELIST,
 	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
 	NFSPROC4_CLNT_DESTROY_CLIENTID,
+
+	/* nfs42 */
+	NFSPROC4_CLNT_SEEK,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 922be2e..a32ba0d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -230,5 +230,6 @@ struct nfs_server {
 #define NFS_CAP_STATEID_NFSV41	(1U << 16)
 #define NFS_CAP_ATOMIC_OPEN_V1	(1U << 17)
 #define NFS_CAP_SECURITY_LABEL	(1U << 18)
+#define NFS_CAP_SEEK		(1U << 19)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0040629..9724257 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1239,6 +1239,25 @@ struct pnfs_ds_commit_info {
 
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
+	u64	sr_offset;
+};
+#endif
+
 struct nfs_page;
 
 #define NFS_PAGEVEC_SIZE	(8U)
-- 
2.1.0

