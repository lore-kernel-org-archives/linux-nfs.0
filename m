Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:7604 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbbCQWlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:11 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 03/10] NFS add COPY_NOTIFY operation
Date: Tue, 17 Mar 2015 18:31:31 -0400
Message-ID: <1426631498-14772-4-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only NL4_NETATTR, No support for NL4_NAME and NL4_URL.
Allow only one source server address to be returned for now.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs42.h            |   2 +
 fs/nfs/nfs42proc.c        |  57 ++++++++++++++++
 fs/nfs/nfs42xdr.c         | 166 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  30 +++++++--
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 include/linux/nfs4.h      |   7 ++
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  38 +++++++++++
 9 files changed, 299 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 28da8dc..849b51e 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -8,6 +8,8 @@
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
 ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+int nfs42_proc_copy_notify(struct file *, struct file *,
+		 struct nfs42_copy_notify_res *);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 1ce9274..e09e793 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -11,6 +11,8 @@
 #include "nfs4_fs.h"
 #include "nfs42.h"
 
+#define NFSDBG_FACILITY         NFSDBG_PROC
+
 static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 				fmode_t fmode)
 {
@@ -32,6 +34,28 @@ static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 	return ret;
 }
 
+static void nfs42_set_cn_args_netaddr(struct file *file_out,
+				      struct nfs42_netaddr *naddr)
+{
+	struct nfs_client *clp = (NFS_SERVER(file_inode(file_out)))->nfs_client;
+	unsigned short port = 2049;
+
+	rcu_read_lock();
+	naddr->na_netid_len = scnprintf(naddr->na_netid,
+					sizeof(naddr->na_netid), "%s",
+					rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_NETID));
+	naddr->na_uaddr_len = scnprintf(naddr->na_uaddr,
+					sizeof(naddr->na_uaddr),
+					"%s.%u.%u",
+					rpc_peeraddr2str(clp->cl_rpcclient,
+					RPC_DISPLAY_ADDR),
+					port >> 8, port & 255);
+	rcu_read_unlock();
+	dprintk("<-- %s netid %s uaddr %s\n", __func__,
+		naddr->na_netid, naddr->na_uaddr);
+}
+
 static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 				 loff_t offset, loff_t len)
 {
@@ -162,6 +186,39 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	return res.write_res.count;
 }
 
+int nfs42_proc_copy_notify(struct file *src, struct file *dst,
+			   struct nfs42_copy_notify_res *res)
+{
+	struct nfs42_copy_notify_args args = {
+		.cna_src_fh  = NFS_FH(file_inode(src)),
+	};
+	struct nfs_server *src_server = NFS_SERVER(file_inode(src));
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY_NOTIFY],
+		.rpc_argp = &args,
+		.rpc_resp = res,
+	};
+	struct nfs_server *server = NFS_SERVER(file_inode(src));
+	int status;
+
+	if (!(server->caps & NFS_CAP_COPY_NOTIFY))
+		return -ENOTSUPP;
+
+	args.cna_nl_type = NL4_NETADDR;
+	nfs42_set_cn_args_netaddr(src, &args.u.cna_addr);
+
+	status = nfs42_set_rw_stateid(&args.cna_src_stateid, src, FMODE_READ);
+	if (status)
+		return status;
+
+	status = nfs4_call_sync(src_server->client, src_server, &msg,
+				&args.cna_seq_args, &res->cnr_seq_res, 0);
+	if (status == -ENOTSUPP)
+		server->caps &= ~NFS_CAP_COPY_NOTIFY;
+
+	return status;
+}
+
 loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(filep);
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index f4b301c..94a484a 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -23,6 +23,16 @@
 					 NFS42_WRITE_RES_SIZE + \
 					 1 /* cr_consecutive */ + \
 					 1 /* cr_synchronous */)
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
@@ -63,6 +73,12 @@
 					 decode_savefh_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_copy_maxsz)
+#define NFS4_enc_copy_notify_sz		(compound_encode_hdr_maxsz + \
+					 encode_putfh_maxsz + \
+					 encode_copy_notify_maxsz)
+#define NFS4_dec_copy_notify_sz		(compound_decode_hdr_maxsz + \
+					 decode_putfh_maxsz + \
+					 decode_copy_notify_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
@@ -118,6 +134,27 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint32(xdr, 0); /* src server list */
 }
 
+static void encode_copy_notify(struct xdr_stream *xdr,
+			       struct nfs42_copy_notify_args *args,
+			       struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_COPY_NOTIFY, decode_copy_notify_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->cna_src_stateid);
+	encode_uint32(xdr, args->cna_nl_type);
+	switch (args->cna_nl_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		encode_string(xdr, args->u.cna_str_sz, args->u.cna_str);
+		break;
+	case NL4_NETADDR:
+		encode_string(xdr, args->u.cna_addr.na_netid_len, args->u.cna_addr.na_netid);
+		encode_string(xdr, args->u.cna_addr.na_uaddr_len, args->u.cna_addr.na_uaddr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -186,6 +223,24 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 }
 
 /*
+ * Encode COPY_NOTIFY request
+ */
+static void nfs4_xdr_enc_copy_notify(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs42_copy_notify_args *args)
+{
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
@@ -306,6 +361,92 @@ static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
 	return decode_copy_requirements(xdr, res);
 }
 
+static int decode_copy_notify(struct xdr_stream *xdr,
+			      struct nfs42_copy_notify_res *res)
+{
+	__be32 *p;
+	uint32_t dummy;
+	char *dummy_str;
+	int status, i;
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
+	/* XXXX should be a decode_netaddr function to parse multiple
+	 * addresses. For now, limit to one. */
+
+	/* number of source addresses */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->cnr_nsrc = be32_to_cpup(p);
+	if (res->cnr_nsrc > NFS42_MAX_SSC_SRC) {
+		pr_warn("NFS: %s num server > %d: %d. Exiting with error EIO\n",
+			__func__, NFS42_MAX_SSC_SRC, res->cnr_nsrc);
+		return -EIO;
+	}
+
+	for (i = 0; i < NFS42_MAX_SSC_SRC; i++) {
+		/* nl_type */
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		res->src[i].cnr_nl_type = be32_to_cpup(p);
+		switch (res->src[i].cnr_nl_type) {
+		case NL4_NAME:
+		case NL4_URL:
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+				return -EIO;
+			memcpy(&res->src[i].u.cnr_str, dummy_str, dummy);
+			res->src[i].u.cnr_str_sz = dummy;
+			break;
+		case NL4_NETADDR:
+			/* netid string */
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > RPCBIND_MAXNETIDLEN))
+				return -EIO;
+			res->src[i].u.cnr_addr.na_netid_len = dummy;
+			memcpy(&res->src[i].u.cnr_addr.na_netid, dummy_str,
+				res->src[i].u.cnr_addr.na_netid_len);
+
+			/* uaddr string */
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > RPCBIND_MAXUADDRLEN))
+				return -EIO;
+			res->src[i].u.cnr_addr.na_uaddr_len = dummy;
+			memcpy(&res->src[i].u.cnr_addr.na_uaddr, dummy_str,
+				res->src[i].u.cnr_addr.na_uaddr_len);
+			break;
+		default:
+			WARN_ON_ONCE(1);
+			return -EIO;
+		}
+	}
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
@@ -481,6 +622,31 @@ out:
 }
 
 /*
+ * Decode COPY_NOTIFY response
+ */
+static int nfs4_xdr_dec_copy_notify(struct rpc_rqst *rqstp,
+				    struct xdr_stream *xdr,
+				    struct nfs42_copy_notify_res *res)
+{
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
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e3be9c33..c71bf6a 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -11,6 +11,7 @@
 #include "pnfs.h"
 
 #ifdef CONFIG_NFS_V4_2
+#include <linux/sunrpc/addr.h>
 #include "nfs42.h"
 #endif
 
@@ -122,14 +123,35 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 #ifdef CONFIG_NFS_V4_2
+static bool nfs42_intra_ssc(struct file *in, struct file *out)
+{
+	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
+	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
+
+	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
+			    (struct sockaddr *)&c_out->cl_addr);
+}
+
 static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, int flags)
 {
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb ||
-	    file_in->f_path.mnt != file_out->f_path.mnt)
-		return -ENOTSUPP;
-	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	if (nfs42_intra_ssc(file_in, file_out)) {  /* Intra-ssc */
+		if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb ||
+			       file_in->f_path.mnt != file_out->f_path.mnt)
+			return -ENOTSUPP;
+		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	} else {  /* Inter-ssc */
+		struct nfs42_copy_notify_res cn_res = {
+			.cnr_nsrc = 0,
+		};
+		int err;
+
+		err = nfs42_proc_copy_notify(file_in, file_out, &cn_res);
+		if (err)
+			return err;
+		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	}
 }
 
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d4b146b..d96219f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8575,6 +8575,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
+		| NFS_CAP_COPY_NOTIFY
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_READ_PLUS
 		| NFS_CAP_SEEK,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 784eec0..fae32fe 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7427,6 +7427,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 	PROC(READ_PLUS,		enc_read_plus,		dec_read_plus),
 	PROC(COPY,		enc_copy,		dec_copy),
+	PROC(COPY_NOTIFY,	enc_copy_notify,	dec_copy_notify),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9f99f9a..2b4fd1c 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -495,6 +495,7 @@ enum {
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_READ_PLUS,
 	NFSPROC4_CLNT_COPY,
+	NFSPROC4_CLNT_COPY_NOTIFY,
 };
 
 /* nfs41 types */
@@ -565,4 +566,10 @@ enum data_content4 {
 	NFS4_CONTENT_HOLE		= 1,
 };
 
+enum netloc_type4 {
+	NL4_NAME		= 1,
+	NL4_URL			= 2,
+	NL4_NETADDR		= 3,
+};
+
 #endif
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 478baf1..d0d2403 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -239,5 +239,6 @@ struct nfs_server {
 #define NFS_CAP_DEALLOCATE	(1U << 21)
 #define NFS_CAP_READ_PLUS	(1U << 22)
 #define NFS_CAP_COPY		(1U << 23)
+#define NFS_CAP_COPY_NOTIFY	(1U << 24)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 83c16c9..984e0e6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1285,6 +1285,9 @@ struct nfs42_falloc_res {
 	const struct nfs_server		*falloc_server;
 };
 
+/*  support 1 source server for now */
+#define NFS42_MAX_SSC_SRC	1
+
 struct nfs42_copy_args {
 	struct nfs4_sequence_args	seq_args;
 
@@ -1312,6 +1315,41 @@ struct nfs42_copy_res {
 	bool				synchronous;
 };
 
+
+struct nfs42_copy_notify_args {
+	struct nfs4_sequence_args	cna_seq_args;
+
+	struct nfs_fh		*cna_src_fh;
+	nfs4_stateid		cna_src_stateid;
+	union { /* cna_destiniation_server */
+		struct { /* NL4_NAME, NL4_URL */
+			int	cna_str_sz;
+			char	cna_str[NFS4_OPAQUE_LIMIT + 1];
+		};
+		struct nfs42_netaddr	cna_addr; /* NL4_NETADDR */
+	} u;
+	enum netloc_type4	cna_nl_type;
+};
+
+struct nfs42_copy_notify_res {
+	struct nfs4_sequence_res	cnr_seq_res;
+
+	struct nfstime4			cnr_lease_time;
+	nfs4_stateid			cnr_stateid;
+	int	cnr_nsrc; /* for now, always 1 */
+	struct { /* cnr_source_server<> */
+		enum netloc_type4		cnr_nl_type;
+		union {
+			struct {
+				/* NL4_NAME, NL4_URL */
+				int	cnr_str_sz;
+				char	cnr_str[NFS4_OPAQUE_LIMIT + 1];
+			};
+			struct nfs42_netaddr	cnr_addr; /* NL4_NETADDR */
+		} u;
+	} src[NFS42_MAX_SSC_SRC];
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

