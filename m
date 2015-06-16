Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33445 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbbFPOsv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:48:51 -0400
Received: by padev16 with SMTP id ev16so14231675pad.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:48:50 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 01/11] NFSv.2/pnfs Add a LAYOUTSTATS rpc function
Date: Tue, 16 Jun 2015 22:47:22 +0800
Message-Id: <1434466052-10491-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42.h          |   7 ++-
 fs/nfs/nfs42proc.c      |  27 +++++++++++
 fs/nfs/nfs42xdr.c       | 122 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h        |   1 +
 fs/nfs/nfs4proc.c       |   4 +-
 fs/nfs/nfs4xdr.c        |   1 +
 include/linux/nfs4.h    |   1 +
 include/linux/nfs_xdr.h |  43 +++++++++++++++++
 8 files changed, 203 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 7afb894..579cb0e 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -5,11 +5,16 @@
 #ifndef __LINUX_FS_NFS_NFS4_2_H
 #define __LINUX_FS_NFS_NFS4_2_H
 
+/* FIXME:  two LAYOUTSTATS calls per compound at most! Do we need to support
+ * more? Need to consider not to pre-alloc too much for a compound. */
+#define PNFS_LAYOUTSTATS_MAXDEV (4)
+
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
-
+int nfs42_proc_layoutstats_generic(struct nfs_server *,
+				   struct nfs42_layoutstat_data *);
 /* nfs4.2xdr.h */
 extern struct rpc_procinfo nfs4_2_procedures[];
 
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3a9e752..ac92968 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -165,3 +165,30 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 
 	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
 }
+
+static const struct rpc_call_ops nfs42_layoutstat_ops = {
+};
+
+int nfs42_proc_layoutstats_generic(struct nfs_server *server,
+				   struct nfs42_layoutstat_data *data)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTSTATS],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client = server->client,
+		.rpc_message = &msg,
+		.callback_ops = &nfs42_layoutstat_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
+	struct rpc_task *task;
+
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	task = rpc_run_task(&task_setup);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	return 0;
+}
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 1a25b27..9aae020 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -4,6 +4,8 @@
 #ifndef __LINUX_FS_NFS_NFS4_2XDR_H
 #define __LINUX_FS_NFS_NFS4_2XDR_H
 
+#include "nfs42.h"
+
 #define encode_fallocate_maxsz		(encode_stateid_maxsz + \
 					 2 /* offset */ + \
 					 2 /* length */)
@@ -22,6 +24,16 @@
 					 1 /* whence */ + \
 					 2 /* offset */ + \
 					 2 /* length */)
+#define encode_io_info_maxsz		4
+#define encode_layoutstats_maxsz	(op_decode_hdr_maxsz + \
+					2 /* offset */ + \
+					2 /* length */ + \
+					encode_stateid_maxsz + \
+					encode_io_info_maxsz + \
+					encode_io_info_maxsz + \
+					1 /* opaque devaddr4 length */ + \
+					XDR_QUADLEN(PNFS_LAYOUTSTATS_MAXSIZE))
+#define decode_layoutstats_maxsz	(op_decode_hdr_maxsz)
 
 #define NFS4_enc_allocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
@@ -45,6 +57,14 @@
 #define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_seek_maxsz)
+#define NFS4_enc_layoutstats_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
+					 encode_putfh_maxsz + \
+					 PNFS_LAYOUTSTATS_MAXDEV * encode_layoutstats_maxsz)
+#define NFS4_dec_layoutstats_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
+					 decode_putfh_maxsz + \
+					 PNFS_LAYOUTSTATS_MAXDEV * decode_layoutstats_maxsz)
 
 
 static void encode_fallocate(struct xdr_stream *xdr,
@@ -81,6 +101,33 @@ static void encode_seek(struct xdr_stream *xdr,
 	encode_uint32(xdr, args->sa_what);
 }
 
+static void encode_layoutstats(struct xdr_stream *xdr,
+			       struct nfs42_layoutstat_args *args,
+			       struct nfs42_layoutstat_devinfo *devinfo,
+			       struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	encode_op_hdr(xdr, OP_LAYOUTSTATS, decode_layoutstats_maxsz, hdr);
+	p = reserve_space(xdr, 8 + 8);
+	p = xdr_encode_hyper(p, devinfo->offset);
+	p = xdr_encode_hyper(p, devinfo->length);
+	encode_nfs4_stateid(xdr, &args->stateid);
+	p = reserve_space(xdr, 4*8 + NFS4_DEVICEID4_SIZE + 4);
+	p = xdr_encode_hyper(p, devinfo->read_count);
+	p = xdr_encode_hyper(p, devinfo->read_bytes);
+	p = xdr_encode_hyper(p, devinfo->write_count);
+	p = xdr_encode_hyper(p, devinfo->write_bytes);
+	p = xdr_encode_opaque_fixed(p, devinfo->dev_id.data,
+			NFS4_DEVICEID4_SIZE);
+	/* Encode layoutupdate4 */
+	*p++ = cpu_to_be32(devinfo->layout_type);
+	if (devinfo->layoutstats_encode != NULL)
+		devinfo->layoutstats_encode(xdr, args, devinfo);
+	else
+		encode_uint32(xdr, 0);
+}
+
 /*
  * Encode ALLOCATE request
  */
@@ -137,6 +184,28 @@ static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode LAYOUTSTATS request
+ */
+static void nfs4_xdr_enc_layoutstats(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs42_layoutstat_args *args)
+{
+	int i;
+
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	WARN_ON(args->num_dev > PNFS_LAYOUTSTATS_MAXDEV);
+	for (i = 0; i < args->num_dev; i++)
+		encode_layoutstats(xdr, args, &args->devinfo[i], &hdr);
+	encode_nops(&hdr);
+}
+
 static int decode_allocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_ALLOCATE);
@@ -169,6 +238,28 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_layoutstats(struct xdr_stream *xdr,
+			      struct nfs42_layoutstat_res *res)
+{
+	int status;
+	__be32 *p;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTSTATS);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	res->rpc_status = be32_to_cpup(p++);
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 /*
  * Decode ALLOCATE request
  */
@@ -246,4 +337,35 @@ static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
+/*
+ * Decode LAYOUTSTATS request
+ */
+static int nfs4_xdr_dec_layoutstats(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    struct nfs42_layoutstat_res *res)
+{
+	struct compound_hdr hdr;
+	int status, i;
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
+	WARN_ON(res->num_dev > PNFS_LAYOUTSTATS_MAXDEV);
+	for (i = 0; i < res->num_dev; i++) {
+		status = decode_layoutstats(xdr, res);
+		if (status)
+			goto out;
+	}
+out:
+	res->rpc_status = status;
+	return status;
+}
+
 #endif /* __LINUX_FS_NFS_NFS4_2XDR_H */
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index fdef424..ea3bee9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -233,6 +233,7 @@ extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
+extern void nfs4_init_sequence(struct nfs4_sequence_args *, struct nfs4_sequence_res *, int);
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55e1e3a..a231691 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -482,8 +482,8 @@ struct nfs4_call_sync_data {
 	struct nfs4_sequence_res *seq_res;
 };
 
-static void nfs4_init_sequence(struct nfs4_sequence_args *args,
-			       struct nfs4_sequence_res *res, int cache_reply)
+void nfs4_init_sequence(struct nfs4_sequence_args *args,
+			struct nfs4_sequence_res *res, int cache_reply)
 {
 	args->sa_slot = NULL;
 	args->sa_cache_this = cache_reply;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0aea978..102239d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7427,6 +7427,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SEEK,		enc_seek,		dec_seek),
 	PROC(ALLOCATE,		enc_allocate,		dec_allocate),
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
+	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 32201c2..b8e72aa 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -500,6 +500,7 @@ enum {
 	NFSPROC4_CLNT_SEEK,
 	NFSPROC4_CLNT_ALLOCATE,
 	NFSPROC4_CLNT_DEALLOCATE,
+	NFSPROC4_CLNT_LAYOUTSTATS,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 93ab607..0b75d54 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -316,6 +316,49 @@ struct nfs4_layoutreturn {
 	int rpc_status;
 };
 
+#define PNFS_LAYOUTSTATS_MAXSIZE 256
+
+struct nfs42_layoutstat_args;
+struct nfs42_layoutstat_devinfo;
+typedef	void (*layoutstats_encode_t)(struct xdr_stream *,
+		struct nfs42_layoutstat_args *,
+		struct nfs42_layoutstat_devinfo *);
+
+/* Per file per deviceid layoutstats */
+struct nfs42_layoutstat_devinfo {
+	struct nfs4_deviceid dev_id;
+	__u64 offset;
+	__u64 length;
+	__u64 read_count;
+	__u64 read_bytes;
+	__u64 write_count;
+	__u64 write_bytes;
+	__u32 layout_type;
+	layoutstats_encode_t layoutstats_encode;
+	void *layout_private;
+};
+
+struct nfs42_layoutstat_args {
+	struct nfs4_sequence_args seq_args;
+	struct nfs_fh *fh;
+	struct inode *inode;
+	nfs4_stateid stateid;
+	int num_dev;
+	struct nfs42_layoutstat_devinfo *devinfo;
+};
+
+struct nfs42_layoutstat_res {
+	struct nfs4_sequence_res seq_res;
+	int num_dev;
+	int rpc_status;
+};
+
+struct nfs42_layoutstat_data {
+	struct inode *inode;
+	struct nfs42_layoutstat_args args;
+	struct nfs42_layoutstat_res res;
+};
+
 struct stateowner_id {
 	__u64	create_time;
 	__u32	uniquifier;
-- 
1.8.3.1

