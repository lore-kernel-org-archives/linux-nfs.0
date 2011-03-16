Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18415 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab1CPUyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 16:54:23 -0400
Message-ID: <4D812374.2060007@netapp.com>
Date: Wed, 16 Mar 2011 16:54:12 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 3/5] NFS: Add secinfo procedure
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


This patch adds the nfs4 operation secinfo as a
valid nfs rpc operation.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c       |   35 ++++++++++++
 fs/nfs/nfs4xdr.c        |  135 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |   34 ++++++++++++
 4 files changed, 205 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4486574..0b8bae1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4639,6 +4639,40 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	return status;
 }
 
+static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
+{
+	int status;
+	struct nfs4_secinfo_arg args = {
+		.dir_fh = NFS_FH(dir),
+		.name   = name,
+	};
+	struct nfs4_secinfo_res res = {
+		.flavors     = flavors,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SECINFO],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+
+	dprintk("NFS call  secinfo %s\n", name->name);
+	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	dprintk("NFS reply  secinfo: %d\n", status);
+	return status;
+}
+
+int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(dir),
+				_nfs4_proc_secinfo(dir, name, flavors),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
 #ifdef CONFIG_NFS_V4_1
 /*
  * Check the exchange flags returned by the server for invalid flags, having
@@ -5756,6 +5790,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
 	.init_client	= nfs4_init_client,
+	.secinfo	= nfs4_proc_secinfo,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0cf560f..98afcf9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -46,6 +46,7 @@
 #include <linux/kdev_t.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/sunrpc/gss_api.h>
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
@@ -253,6 +254,8 @@ static int nfs4_stat_to_errno(int);
 				(encode_getattr_maxsz)
 #define decode_fs_locations_maxsz \
 				(0)
+#define encode_secinfo_maxsz	(op_encode_hdr_maxsz + nfs4_name_maxsz)
+#define decode_secinfo_maxsz	(op_decode_hdr_maxsz + 4 + (NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)))
 
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MACHINE_NAME_LEN (64)
@@ -676,6 +679,14 @@ static int nfs4_stat_to_errno(int);
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
+#define NFS4_enc_secinfo_sz 	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
+				encode_putfh_maxsz + \
+				encode_secinfo_maxsz)
+#define NFS4_dec_secinfo_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_secinfo_maxsz)
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_enc_exchange_id_sz \
 				(compound_encode_hdr_maxsz + \
@@ -1620,6 +1631,18 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	hdr->replen += decode_delegreturn_maxsz;
 }
 
+static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
+{
+	int len = name->len;
+	__be32 *p;
+
+	p = reserve_space(xdr, 8 + len);
+	*p++ = cpu_to_be32(OP_SECINFO);
+	xdr_encode_opaque(p, name->name, len);
+	hdr->nops++;
+	hdr->replen += decode_secinfo_maxsz;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
 static void encode_exchange_id(struct xdr_stream *xdr,
@@ -2465,6 +2488,24 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode SECINFO request
+ */
+static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
+				struct xdr_stream *xdr,
+				struct nfs4_secinfo_arg *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->dir_fh, &hdr);
+	encode_secinfo(xdr, args->name, &hdr);
+	encode_nops(&hdr);
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * EXCHANGE_ID request
@@ -4680,6 +4721,73 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+static int decode_secinfo_gss(struct xdr_stream *xdr, struct nfs4_secinfo_flavor *flavor)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	flavor->gss.sec_oid4.len = be32_to_cpup(p);
+	if (flavor->gss.sec_oid4.len > GSS_OID_MAX_LEN)
+		goto out_err;
+
+	p = xdr_inline_decode(xdr, flavor->gss.sec_oid4.len);
+	if (unlikely(!p))
+		goto out_overflow;
+	memcpy(flavor->gss.sec_oid4.data, p, flavor->gss.sec_oid4.len);
+
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+	flavor->gss.qop4 = be32_to_cpup(p++);
+	flavor->gss.service = be32_to_cpup(p);
+
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+out_err:
+	return -EINVAL;
+}
+
+static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
+{
+	struct nfs4_secinfo_flavor *sec_flavor;
+	int status;
+	__be32 *p;
+	int i;
+
+	status = decode_op_hdr(xdr, OP_SECINFO);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	res->flavors->num_flavors = be32_to_cpup(p);
+
+	for (i = 0; i < res->flavors->num_flavors; i++) {
+		sec_flavor = &res->flavors->flavors[i];
+		if ((char *)&sec_flavor[1] - (char *)res > PAGE_SIZE)
+			break;
+
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		sec_flavor->flavor = be32_to_cpup(p);
+
+		if (sec_flavor->flavor == RPC_AUTH_GSS) {
+			if (decode_secinfo_gss(xdr, sec_flavor))
+				break;
+		}
+	}
+
+	return 0;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 static int decode_exchange_id(struct xdr_stream *xdr,
 			      struct nfs41_exchange_id_res *res)
@@ -5919,6 +6027,32 @@ out:
 	return status;
 }
 
+/*
+ * Decode SECINFO response
+ */
+static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct nfs4_secinfo_res *res)
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
+	status = decode_secinfo(xdr, res);
+	if (status)
+		goto out;
+out:
+	return status;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * Decode EXCHANGE_ID response
@@ -6258,6 +6392,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(SETACL,		enc_setacl,		dec_setacl),
 	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
+	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
 #if defined(CONFIG_NFS_V4_1)
 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
 	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 134716e..7e7f6b7 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -550,6 +550,7 @@ enum {
 	NFSPROC4_CLNT_SETACL,
 	NFSPROC4_CLNT_FS_LOCATIONS,
 	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
+	NFSPROC4_CLNT_SECINFO,
 
 	/* nfs41 */
 	NFSPROC4_CLNT_EXCHANGE_ID,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 71ee679..8f3d7b2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -3,6 +3,7 @@
 
 #include <linux/nfsacl.h>
 #include <linux/nfs3.h>
+#include <linux/sunrpc/gss_api.h>
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
@@ -936,6 +937,38 @@ struct nfs4_fs_locations_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
+struct nfs4_secinfo_oid {
+	unsigned int len;
+	char data[GSS_OID_MAX_LEN];
+};
+
+struct nfs4_secinfo_gss {
+	struct nfs4_secinfo_oid sec_oid4;
+	unsigned int qop4;
+	unsigned int service;
+};
+
+struct nfs4_secinfo_flavor {
+	unsigned int 		flavor;
+	struct nfs4_secinfo_gss	gss;
+};
+
+struct nfs4_secinfo_flavors {
+	unsigned int num_flavors;
+	struct nfs4_secinfo_flavor flavors[0];
+};
+
+struct nfs4_secinfo_arg {
+	const struct nfs_fh		*dir_fh;
+	const struct qstr		*name;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_secinfo_res {
+	struct nfs4_secinfo_flavors	*flavors;
+	struct nfs4_sequence_res	seq_res;
+};
+
 #endif /* CONFIG_NFS_V4 */
 
 struct nfstime4 {
@@ -1118,6 +1151,7 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
+	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };
 
 /*
-- 
1.7.4.1

