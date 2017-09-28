Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:18048 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752213AbdI1R2o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:44 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 05/11] NFS add COPY_NOTIFY operation
Date: Thu, 28 Sep 2017 13:28:33 -0400
Message-ID: <20170928172839.50741-6-kolga@netapp.com>
In-Reply-To: <20170928172839.50741-1-kolga@netapp.com>
References: <20170928172839.50741-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try using the delegation stateid, then the open stateid.

Only NL4_NETATTR, No support for NL4_NAME and NL4_URL.
Allow only one source server address to be returned for now.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h            |   3 +-
 fs/nfs/nfs42proc.c        |  91 +++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 181 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4file.c         |  17 +++++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4state.c        |   2 +-
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  16 ++++
 11 files changed, 313 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index b8affc8..b4e4d6ab 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -23,7 +23,8 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
 int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
 int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
 			      struct nfs42_offload_status_res *);
-
+int nfs42_proc_copy_notify(struct file *, struct file *,
+			   struct nfs42_copy_notify_res *);
 static inline bool nfs42_files_from_same_server(struct file *in, struct file *out)
 {
 	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 378d774..7b1650c 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -2,6 +2,7 @@
  * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
  */
 #include <linux/fs.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs.h>
 #include <linux/nfs3.h>
@@ -14,10 +15,30 @@
 #include "pnfs.h"
 #include "nfs4session.h"
 #include "internal.h"
+#include "delegation.h"
 
 #define NFSDBG_FACILITY NFSDBG_PROC
 static int nfs42_do_offload_cancel_async(struct file *dst, nfs4_stateid *std);
 
+static void nfs42_set_netaddr(struct file *filep, struct nfs42_netaddr *naddr)
+{
+	struct nfs_client *clp = (NFS_SERVER(file_inode(filep)))->nfs_client;
+	unsigned short port = 2049;
+
+	rcu_read_lock();
+	naddr->netid_len = scnprintf(naddr->netid,
+					sizeof(naddr->netid), "%s",
+					rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_NETID));
+	naddr->addr_len = scnprintf(naddr->addr,
+					sizeof(naddr->addr),
+					"%s.%u.%u",
+					rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_ADDR),
+					port >> 8, port & 255);
+	rcu_read_unlock();
+}
+
 static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 		struct nfs_lock_context *lock, loff_t offset, loff_t len)
 {
@@ -494,6 +515,76 @@ int nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
 	return status;
 }
 
+int _nfs42_proc_copy_notify(struct file *src, struct file *dst,
+			    struct nfs42_copy_notify_args *args,
+			    struct nfs42_copy_notify_res *res)
+{
+	struct nfs_server *src_server = NFS_SERVER(file_inode(src));
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY_NOTIFY],
+		.rpc_argp = args,
+		.rpc_resp = res,
+	};
+	int status;
+	struct nfs_open_context *ctx;
+	struct nfs_lock_context *l_ctx;
+
+	ctx = get_nfs_open_context(nfs_file_open_context(src));
+	l_ctx = nfs_get_lock_context(ctx);
+	if (IS_ERR(l_ctx))
+		return PTR_ERR(l_ctx);
+
+	status = nfs4_set_rw_stateid(&args->cna_src_stateid, ctx, l_ctx,
+				     FMODE_READ);
+	nfs_put_lock_context(l_ctx);
+	if (status)
+		return status;
+
+	status = nfs4_call_sync(src_server->client, src_server, &msg,
+				&args->cna_seq_args, &res->cnr_seq_res, 0);
+	if (status == -ENOTSUPP)
+		src_server->caps &= ~NFS_CAP_COPY_NOTIFY;
+
+	put_nfs_open_context(nfs_file_open_context(src));
+	return status;
+}
+
+int nfs42_proc_copy_notify(struct file *src, struct file *dst,
+				struct nfs42_copy_notify_res *res)
+{
+	struct nfs_server *src_server = NFS_SERVER(file_inode(src));
+	struct nfs42_copy_notify_args *args;
+	struct nfs4_exception exception = {
+		.inode = file_inode(src),
+	};
+	int status;
+
+	if (!(src_server->caps & NFS_CAP_COPY_NOTIFY))
+		return -EOPNOTSUPP;
+
+	args = kzalloc(sizeof(struct nfs42_copy_notify_args), GFP_NOFS);
+	if (args == NULL)
+		return -ENOMEM;
+
+	args->cna_src_fh  = NFS_FH(file_inode(src)),
+	args->cna_dst.nl4_type = NL4_NETADDR;
+	nfs42_set_netaddr(dst, &args->cna_dst.u.nl4_addr);
+	exception.stateid = &args->cna_src_stateid;
+
+	do {
+		status = _nfs42_proc_copy_notify(src, dst, args, res);
+		if (status == -ENOTSUPP) {
+			status = -EOPNOTSUPP;
+			goto out;
+		}
+		status = nfs4_handle_exception(src_server, status, &exception);
+	} while (exception.retry);
+
+out:
+	kfree(args);
+	return status;
+}
+
 static loff_t _nfs42_proc_llseek(struct file *filep,
 		struct nfs_lock_context *lock, loff_t offset, int whence)
 {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 2c37c66..081c883 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -33,6 +33,16 @@
 #define encode_offload_cancel_maxsz	(op_encode_hdr_maxsz + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE))
 #define decode_offload_cancel_maxsz	(op_decode_hdr_maxsz)
+#define encode_copy_notify_maxsz	(op_encode_hdr_maxsz + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 1 + /* nl4_type */ \
+					 1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
+#define decode_copy_notify_maxsz	(op_decode_hdr_maxsz + \
+					 3 + /* cnr_lease_time */\
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 1 + /* Support 1 cnr_source_server */\
+					 1 + /* nl4_type */ \
+					 1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
 #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
 					 encode_fallocate_maxsz)
 #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
@@ -94,6 +104,12 @@
 #define NFS4_dec_offload_cancel_sz	(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_offload_cancel_maxsz)
+#define NFS4_enc_copy_notify_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_copy_notify_maxsz)
+#define NFS4_dec_copy_notify_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_copy_notify_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -147,6 +163,25 @@ static void encode_allocate(struct xdr_stream *xdr,
 	encode_fallocate(xdr, args);
 }
 
+static void encode_nl4_server(struct xdr_stream *xdr, const struct nl4_server *ns)
+{
+	encode_uint32(xdr, ns->nl4_type);
+	switch (ns->nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		encode_string(xdr, ns->u.nl4_str_sz, ns->u.nl4_str);
+		break;
+	case NL4_NETADDR:
+		encode_string(xdr, ns->u.nl4_addr.netid_len,
+			      ns->u.nl4_addr.netid);
+		encode_string(xdr, ns->u.nl4_addr.addr_len,
+			      ns->u.nl4_addr.addr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
+}
+
 static void encode_copy(struct xdr_stream *xdr,
 			const struct nfs42_copy_args *args,
 			struct compound_hdr *hdr)
@@ -180,6 +215,15 @@ static void encode_offload_cancel(struct xdr_stream *xdr,
 	encode_nfs4_stateid(xdr, &args->osa_stateid);
 }
 
+static void encode_copy_notify(struct xdr_stream *xdr,
+			       const struct nfs42_copy_notify_args *args,
+			       struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_COPY_NOTIFY, decode_copy_notify_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->cna_src_stateid);
+	encode_nl4_server(xdr, &args->cna_dst);
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      const struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -335,6 +379,25 @@ static void nfs4_xdr_enc_offload_cancel(struct rpc_rqst *req,
 }
 
 /*
+ * Encode COPY_NOTIFY request
+ */
+static void nfs4_xdr_enc_copy_notify(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     const void *data)
+{
+	const struct nfs42_copy_notify_args *args = data;
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->cna_seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->cna_seq_args, &hdr);
+	encode_putfh(xdr, args->cna_src_fh, &hdr);
+	encode_copy_notify(xdr, args, &hdr);
+	encode_nops(&hdr);
+}
+
+/*
  * Encode DEALLOCATE request
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
@@ -453,6 +516,58 @@ static int decode_write_response(struct xdr_stream *xdr,
 	return -EIO;
 }
 
+static int decode_nl4_server(struct xdr_stream *xdr, struct nl4_server *ns)
+{
+	struct nfs42_netaddr *naddr;
+	uint32_t dummy;
+	char *dummy_str;
+	__be32 *p;
+	int status;
+
+	/* nl_type */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
+	ns->nl4_type = be32_to_cpup(p);
+	switch (ns->nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+		if (unlikely(status))
+			return status;
+		if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+			return -EIO;
+		memcpy(&ns->u.nl4_str, dummy_str, dummy);
+		ns->u.nl4_str_sz = dummy;
+		break;
+	case NL4_NETADDR:
+		naddr = &ns->u.nl4_addr;
+
+		/* netid string */
+		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+		if (unlikely(status))
+			return status;
+		if (unlikely(dummy > RPCBIND_MAXNETIDLEN))
+			return -EIO;
+		naddr->netid_len = dummy;
+		memcpy(naddr->netid, dummy_str, naddr->netid_len);
+
+		/* uaddr string */
+		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+		if (unlikely(status))
+			return status;
+		if (unlikely(dummy > RPCBIND_MAXUADDRLEN))
+			return -EIO;
+		naddr->addr_len = dummy;
+		memcpy(naddr->addr, dummy_str, naddr->addr_len);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		return -EIO;
+	}
+	return 0;
+}
+
 static int decode_copy_requirements(struct xdr_stream *xdr,
 				    struct nfs42_copy_res *res) {
 	__be32 *p;
@@ -520,6 +635,46 @@ static int decode_offload_cancel(struct xdr_stream *xdr,
 	return decode_op_hdr(xdr, OP_OFFLOAD_CANCEL);
 }
 
+static int decode_copy_notify(struct xdr_stream *xdr,
+			      struct nfs42_copy_notify_res *res)
+{
+	__be32 *p;
+	int status, count;
+
+	status = decode_op_hdr(xdr, OP_COPY_NOTIFY);
+	if (status)
+		return status;
+	/* cnr_lease_time */
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
+	p = xdr_decode_hyper(p, &res->cnr_lease_time.seconds);
+	res->cnr_lease_time.nseconds = be32_to_cpup(p);
+
+	status = decode_opaque_fixed(xdr, &res->cnr_stateid, NFS4_STATEID_SIZE);
+	if (unlikely(status))
+		goto out_overflow;
+
+	/* number of source addresses */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	count = be32_to_cpup(p);
+	if (count > 1)
+		pr_warn("NFS: %s: nsvr %d > Supported. Use first servers\n",
+			 __func__, count);
+
+	status = decode_nl4_server(xdr, &res->cnr_src);
+	if (unlikely(status))
+		goto out_overflow;
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *res)
 {
 	return decode_op_hdr(xdr, OP_DEALLOCATE);
@@ -673,6 +828,32 @@ static int nfs4_xdr_dec_offload_cancel(struct rpc_rqst *rqstp,
 }
 
 /*
+ * Decode COPY_NOTIFY response
+ */
+static int nfs4_xdr_dec_copy_notify(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    void *data)
+{
+	struct nfs42_copy_notify_res *res = data;
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->cnr_seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_copy_notify(xdr, res);
+
+out:
+	return status;
+}
+
+/*
  * Decode DEALLOCATE request
  */
 static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2ea141c..c143e34 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -464,6 +464,7 @@ extern void nfs41_handle_server_scope(struct nfs_client *,
 extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
 		const struct nfs_lock_context *, nfs4_stateid *,
 		struct rpc_cred **);
+extern void nfs4_copy_open_stateid(nfs4_stateid *, struct nfs4_state *);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 881b819..8b9483d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,12 +133,29 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
+	struct nfs42_copy_notify_res *cn_resp = NULL;
 	ssize_t ret;
 
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 retry:
+	if (nfs42_files_from_same_server(file_in, file_out)) {  /* Intra-ssc */
+		if (file_in->f_op != file_out->f_op)
+			return -EXDEV;
+	} else {  /* Inter-ssc */
+		cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
+				  GFP_NOFS);
+		if (unlikely(cn_resp == NULL))
+			return -ENOMEM;
+
+		ret = nfs42_proc_copy_notify(file_in, file_out, cn_resp);
+		if (ret)
+			goto out;
+	}
 	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+
+out:
+	kfree(cn_resp);
 	if (ret == -EAGAIN)
 		goto retry;
 	return ret;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 30829ce..08b85dc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9330,6 +9330,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
 		| NFS_CAP_COPY
 		| NFS_CAP_OFFLOAD_STATUS
 		| NFS_CAP_OFFLOAD_CANCEL
+		| NFS_CAP_COPY_NOTIFY
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0f14800..00d265b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -985,7 +985,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	return ret;
 }
 
-static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	const nfs4_stateid *src;
 	int seq;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e45f74b..5ba1d08 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7735,6 +7735,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	PROC(COPY,		enc_copy,		dec_copy),
 	PROC(OFFLOAD_STATUS,	enc_offload_status,	dec_offload_status),
 	PROC(OFFLOAD_CANCEL,    enc_offload_cancel,     dec_offload_cancel),
+	PROC(COPY_NOTIFY,	enc_copy_notify,	dec_copy_notify),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 5b330ab..aff3121 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -527,6 +527,7 @@ enum {
 	NFSPROC4_CLNT_COPY,
 	NFSPROC4_CLNT_OFFLOAD_STATUS,
 	NFSPROC4_CLNT_OFFLOAD_CANCEL,
+	NFSPROC4_CLNT_COPY_NOTIFY,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 72f159e..654585e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -256,5 +256,6 @@ struct nfs_server {
 #define NFS_CAP_COPY		(1U << 24)
 #define NFS_CAP_OFFLOAD_STATUS	(1U << 25)
 #define NFS_CAP_OFFLOAD_CANCEL	(1U << 26)
+#define NFS_CAP_COPY_NOTIFY	(1U << 27)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 020d958..af39603 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1413,6 +1413,22 @@ struct nfs42_offload_status_res {
 	int				osr_status;
 };
 
+struct nfs42_copy_notify_args {
+	struct nfs4_sequence_args	cna_seq_args;
+
+	struct nfs_fh		*cna_src_fh;
+	nfs4_stateid		cna_src_stateid;
+	struct nl4_server	cna_dst;
+};
+
+struct nfs42_copy_notify_res {
+	struct nfs4_sequence_res	cnr_seq_res;
+
+	struct nfstime4		cnr_lease_time;
+	nfs4_stateid		cnr_stateid;
+	struct nl4_server	cnr_src;
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

