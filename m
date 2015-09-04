Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19310 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932689AbbIDRaA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:00 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 07/16] NFS add COPY_NOTIFY operation
Date: Fri, 4 Sep 2015 13:29:29 -0400
Message-ID: <1441387778-16465-8-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only NL4_NETATTR, No support for NL4_NAME and NL4_URL.
Allow only one source server address to be returned for now.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs42.h                |   2 +-
 fs/nfs/nfs42proc.c            |  98 ++++++++++++++++++++++++-
 fs/nfs/nfs42xdr.c             | 167 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c             |   2 +-
 fs/nfs/nfs4proc.c             |   1 +
 fs/nfs/nfs4xdr.c              |   1 +
 include/linux/nfs4.h          |   7 ++
 include/linux/nfs4intercopy.h |  11 +++
 include/linux/nfs_fs_sb.h     |   1 +
 include/linux/nfs_xdr.h       |  22 ++++++
 10 files changed, 307 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index b54b916..9288ea2 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -13,7 +13,7 @@
 
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
-ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+ssize_t nfs42_do_copy(struct file *, loff_t, struct file *, loff_t, size_t);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c100439..92b5d5a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -3,6 +3,7 @@
  */
 #include <linux/fs.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
@@ -38,6 +39,26 @@ static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 	return ret;
 }
 
+static void nfs42_set_netaddr(struct file *file_out,
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
+}
+
 static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 				 loff_t offset, loff_t len)
 {
@@ -136,9 +157,8 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
-ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
-			struct file *dst, loff_t pos_dst,
-			size_t count)
+static ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
+			       struct file *dst, loff_t pos_dst, size_t count)
 {
 	struct nfs42_copy_args args = {
 		.src_fh		= NFS_FH(file_inode(src)),
@@ -212,6 +232,78 @@ static loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
 }
 
+static int nfs42_proc_copy_notify(struct file *src, struct file *dst,
+				  struct nfs42_copy_notify_res *res)
+{
+	struct nfs42_copy_notify_args *args;
+	struct nfs_server *src_server = NFS_SERVER(file_inode(src));
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY_NOTIFY],
+		.rpc_resp = res,
+	};
+	int status;
+
+	if (!(src_server->caps & NFS_CAP_COPY_NOTIFY))
+		return -ENOTSUPP;
+
+	args = kzalloc(sizeof(struct nfs42_copy_notify_args), GFP_NOFS);
+	if (args == NULL)
+		return -ENOMEM;
+
+	args->cna_src_fh  = NFS_FH(file_inode(src)),
+	args->cna_dst.nl4_type = NL4_NETADDR;
+	nfs42_set_netaddr(src, &args->cna_dst.u.nl4_addr);
+
+	status = nfs42_set_rw_stateid(&args->cna_src_stateid, src, FMODE_READ);
+	if (status)
+		return status;
+
+	msg.rpc_argp = args;
+	status = nfs4_call_sync(src_server->client, src_server, &msg,
+				&args->cna_seq_args, &res->cnr_seq_res, 0);
+	if (status == -ENOTSUPP)
+		src_server->caps &= ~NFS_CAP_COPY_NOTIFY;
+
+	kfree(args);
+	return status;
+}
+
+static bool nfs42_intra_ssc(struct file *in, struct file *out)
+{
+	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
+	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
+
+	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
+			    (struct sockaddr *)&c_out->cl_addr);
+}
+
+ssize_t nfs42_do_copy(struct file *src, loff_t pos_src, struct file *dst,
+		      loff_t pos_dst, size_t count)
+{
+	struct nfs42_copy_notify_res *cn_resp = NULL;
+	ssize_t ret;
+
+	if (nfs42_intra_ssc(src, dst)) {  /* Intra-ssc */
+		ret = copy_offload_same_fs(src, dst);
+		if (ret != 0)
+			return ret;
+	} else {  /* Inter-ssc */
+		cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
+					GFP_NOFS);
+		if (unlikely(cn_resp == NULL))
+			return -ENOMEM;
+
+		ret = nfs42_proc_copy_notify(src, dst, cn_resp);
+		if (ret)
+			goto out_err;
+	}
+	ret = nfs42_proc_copy(src, pos_src, dst, pos_dst, count);
+
+out_err:
+	kfree(cn_resp);
+	return ret;
+}
+
 loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(filep));
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index ae260d3..feb29af 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -25,6 +25,16 @@
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
@@ -66,6 +76,12 @@
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
@@ -123,6 +139,30 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint32(xdr, 0); /* src server list */
 }
 
+static void encode_copy_notify(struct xdr_stream *xdr,
+			       struct nfs42_copy_notify_args *args,
+			       struct compound_hdr *hdr)
+{
+	encode_op_hdr(xdr, OP_COPY_NOTIFY, decode_copy_notify_maxsz, hdr);
+	encode_nfs4_stateid(xdr, &args->cna_src_stateid);
+	encode_uint32(xdr, args->cna_dst.nl4_type);
+	switch (args->cna_dst.nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		encode_string(xdr, args->cna_dst.u.nl4_str_sz,
+				args->cna_dst.u.nl4_str);
+		break;
+	case NL4_NETADDR:
+		encode_string(xdr, args->cna_dst.u.nl4_addr.na_netid_len,
+				args->cna_dst.u.nl4_addr.na_netid);
+		encode_string(xdr, args->cna_dst.u.nl4_addr.na_uaddr_len,
+				args->cna_dst.u.nl4_addr.na_uaddr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
+}
+
 static void encode_deallocate(struct xdr_stream *xdr,
 			      struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
@@ -208,6 +248,24 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
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
@@ -326,6 +384,90 @@ static int decode_copy(struct xdr_stream *xdr, struct nfs42_copy_res *res)
 	return decode_copy_requirements(xdr, res);
 }
 
+static int decode_copy_notify(struct xdr_stream *xdr,
+			      struct nfs42_copy_notify_res *res)
+{
+	struct nfs42_netaddr *naddr;
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
+		res->cnr_src[i].nl4_type = be32_to_cpup(p);
+		switch (res->cnr_src[i].nl4_type) {
+		case NL4_NAME:
+		case NL4_URL:
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+				return -EIO;
+			memcpy(&res->cnr_src[i].u.nl4_str, dummy_str, dummy);
+			res->cnr_src[i].u.nl4_str_sz = dummy;
+			break;
+		case NL4_NETADDR:
+			naddr = &res->cnr_src[i].u.nl4_addr;
+
+			/* netid string */
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > RPCBIND_MAXNETIDLEN))
+				return -EIO;
+			naddr->na_netid_len = dummy;
+			memcpy(naddr->na_netid, dummy_str, naddr->na_netid_len);
+
+			/* uaddr string */
+			status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+			if (unlikely(status))
+				return status;
+			if (unlikely(dummy > RPCBIND_MAXUADDRLEN))
+				return -EIO;
+			naddr->na_uaddr_len = dummy;
+			memcpy(naddr->na_uaddr, dummy_str, naddr->na_uaddr_len);
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
@@ -417,6 +559,31 @@ out:
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
index 7c6f651..addc7fe 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -151,7 +151,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	return nfs42_do_copy(file_in, pos_in, file_out, pos_out, count);
 }
 
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e05d4c0..cffec79a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8650,6 +8650,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN_V1
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
+		| NFS_CAP_COPY_NOTIFY
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
 		| NFS_CAP_LAYOUTSTATS,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8296628..8f3187e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7433,6 +7433,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(DEALLOCATE,	enc_deallocate,		dec_deallocate),
 	PROC(LAYOUTSTATS,	enc_layoutstats,	dec_layoutstats),
 	PROC(COPY,		enc_copy,		dec_copy),
+	PROC(COPY_NOTIFY,	enc_copy_notify,	dec_copy_notify),
 #endif /* CONFIG_NFS_V4_2 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c975a99..8a92182 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -502,6 +502,7 @@ enum {
 	NFSPROC4_CLNT_DEALLOCATE,
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_COPY,
+	NFSPROC4_CLNT_COPY_NOTIFY,
 };
 
 /* nfs41 types */
@@ -572,4 +573,10 @@ enum data_content4 {
 	NFS4_CONTENT_HOLE		= 1,
 };
 
+enum netloc_type4 {
+	NL4_NAME		= 1,
+	NL4_URL			= 2,
+	NL4_NETADDR		= 3,
+};
+
 #endif
diff --git a/include/linux/nfs4intercopy.h b/include/linux/nfs4intercopy.h
index e490bca..751721e 100644
--- a/include/linux/nfs4intercopy.h
+++ b/include/linux/nfs4intercopy.h
@@ -19,6 +19,17 @@ struct nfs42_netaddr {
 	char		na_uaddr[RPCBIND_MAXUADDRLEN + 1];
 };
 
+struct nl4_server {
+	enum netloc_type4	nl4_type;
+	union {
+		struct { /* NL4_NAME, NL4_URL */
+			int	nl4_str_sz;
+			char	nl4_str[NFS4_OPAQUE_LIMIT + 1];
+		};
+		struct nfs42_netaddr	nl4_addr; /* NL4_NETADDR */
+	} u;
+};
+
 struct nfs42_inter_ssc {
 	struct vfsmount		*sc_root_mnt;
 	struct dentry		*sc_mnt_dentry;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8d37f59..0e636a9 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -239,5 +239,6 @@ struct nfs_server {
 #define NFS_CAP_DEALLOCATE	(1U << 21)
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
 #define NFS_CAP_COPY		(1U << 23)
+#define NFS_CAP_COPY_NOTIFY	(1U << 24)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index dd44d3a..a7f63fb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1324,6 +1324,9 @@ struct nfs42_falloc_res {
 	const struct nfs_server		*falloc_server;
 };
 
+/*  support 1 source server for now */
+#define NFS42_MAX_SSC_SRC	1
+
 struct nfs42_copy_args {
 	struct nfs4_sequence_args	seq_args;
 
@@ -1351,6 +1354,25 @@ struct nfs42_copy_res {
 	bool				synchronous;
 };
 
+struct nfs42_copy_notify_args {
+	struct nfs4_sequence_args	cna_seq_args;
+
+	struct nfs_fh		*cna_src_fh;
+	nfs4_stateid		cna_src_stateid;
+	/* cna_destiniation_server */
+	struct nl4_server	cna_dst;
+};
+
+struct nfs42_copy_notify_res {
+	struct nfs4_sequence_res	cnr_seq_res;
+
+	struct nfstime4		cnr_lease_time;
+	nfs4_stateid		cnr_stateid;
+	/* cnr_source_server */
+	int	cnr_nsrc;	/* for now, always 1 */
+	struct nl4_server	cnr_src[NFS42_MAX_SSC_SRC];
+};
+
 struct nfs42_seek_args {
 	struct nfs4_sequence_args	seq_args;
 
-- 
1.8.3.1

