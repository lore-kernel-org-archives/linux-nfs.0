Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.netapp.com ([216.240.18.38]:17616 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756863Ab1DLTtI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 15:49:08 -0400
Message-ID: <4DA4AA4D.4070502@netapp.com>
Date: Tue, 12 Apr 2011 15:38:53 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFS: SECINFO_NO_NAME for v4.1 initial mount
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


If mounting through AUTH_UNIX returns -EPERM on NFS v4.1, we place
a SECINFO_NO_NAME call to find the authflavor needed in order to 
perform the mount.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |    3 ++
 fs/nfs/namespace.c      |    2 +-
 fs/nfs/nfs4_fs.h        |    2 +
 fs/nfs/nfs4proc.c       |   58 +++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |   68 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |    9 ++++++
 7 files changed, 141 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ce118ce..361a3a3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -266,6 +266,9 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
+#ifdef CONFIG_NFS_V4
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
+#endif
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 1f063ba..8102391 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -119,7 +119,7 @@ Elong:
 }
 
 #ifdef CONFIG_NFS_V4
-static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
 	struct xdr_netobj oid;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e1c261d..0478c6d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -65,6 +65,8 @@ struct nfs4_minor_version_ops {
 			int cache_reply);
 	int	(*validate_stateid)(struct nfs_delegation *,
 			const nfs4_stateid *);
+	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *, 
+			struct nfs_fsinfo *);
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e27ebf..0da35e4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2233,9 +2233,10 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
+	int minor_version = server->nfs_client->cl_minorversion;
 	int status = nfs4_lookup_root(server, fhandle, info);
 	if (status == -EPERM)
-		status = nfs4_find_root_sec(server, fhandle, info);
+		status = nfs_v4_minor_ops[minor_version]->find_root_sec(server, fhandle, info);
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
 	if (status == 0)
@@ -5802,6 +5803,59 @@ out:
 	rpc_put_task(task);
 	return status;
 }
+
+static int
+_nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle, 
+		    struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
+{
+	struct nfs41_secinfo_no_name_args args = {
+		.style = 0,
+	};
+	struct nfs41_secinfo_no_name_res res = {
+		.flavors = flavors,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SECINFO_NO_NAME],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+}
+
+static int
+nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
+		    struct nfs_fsinfo *info)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
+	struct nfs4_secinfo_flavors *flavors;
+	struct page *page = alloc_page(GFP_KERNEL);
+
+	if (!page) {
+		err = -ENOMEM;
+		goto out;
+	}
+	flavors = page_address(page);
+
+	do {
+		err = nfs4_handle_exception(server,
+					_nfs41_find_root_sec(server, fhandle, info, flavors),
+					&exception);
+	} while (exception.retry);
+
+	if (err)
+		goto out_freepage;
+
+	flavor = nfs_find_best_sec(flavors);
+	if (err == 0)
+		err = nfs4_lookup_root_sec(server, fhandle, info, flavor);
+
+out_freepage:
+	put_page(page);
+out:
+	return err;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
@@ -5863,6 +5917,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.call_sync = _nfs4_call_sync,
 	.validate_stateid = nfs4_validate_delegation_stateid,
+	.find_root_sec = nfs4_find_root_sec,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
@@ -5873,6 +5928,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.call_sync = _nfs4_call_sync_session,
 	.validate_stateid = nfs41_validate_delegation_stateid,
+	.find_root_sec = nfs41_find_root_sec,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dddfb57..06a43b9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -338,6 +338,8 @@ static int nfs4_stat_to_errno(int);
 				1 /* layoutupdate4 layout type */ + \
 				1 /* NULL filelayout layoutupdate4 payload */)
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
+#define encode_secinfo_no_name_maxsz (op_encode_hdr_maxsz + 4)
+#define decode_secinfo_no_name_maxsz decode_secinfo_maxsz
 
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
@@ -760,6 +762,12 @@ static int nfs4_stat_to_errno(int);
 				decode_putfh_maxsz + \
 				decode_layoutcommit_maxsz + \
 				decode_getattr_maxsz)
+#define NFS4_enc_secinfo_no_name_sz	(compound_encode_hdr_maxsz + \
+					encode_putrootfh_maxsz +\
+					encode_secinfo_no_name_maxsz)
+#define NFS4_dec_secinfo_no_name_sz	(compound_decode_hdr_maxsz + \
+					decode_putrootfh_maxsz + \
+					decode_secinfo_no_name_maxsz)
 
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
@@ -1890,6 +1898,20 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	hdr->replen += decode_layoutcommit_maxsz;
 	return 0;
 }
+
+static int
+encode_secinfo_no_name(struct xdr_stream *xdr,
+		       const struct nfs41_secinfo_no_name_args *args,
+		       struct compound_hdr *hdr)
+{
+	__be32 *p;
+	p =reserve_space(xdr, 8);
+	*p++ = cpu_to_be32(OP_SECINFO_NO_NAME);
+	*p++ = cpu_to_be32(args->style);
+	hdr->nops++;
+	hdr->replen += decode_secinfo_no_name_maxsz;
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2723,6 +2745,25 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 	encode_nops(&hdr);
 	return 0;
 }
+
+/*
+ * Encode SECINFO_NO_NAME request
+ */
+static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					struct nfs41_secinfo_no_name_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putrootfh(xdr, &hdr);
+	encode_secinfo_no_name(xdr, args, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -6345,6 +6386,32 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
+/*
+ * Decode SECINFO_NO_NAME response
+ */
+static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					struct nfs41_secinfo_no_name_res *res)
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
+	status = decode_putrootfh(xdr);
+	if (status)
+		goto out;
+	status = decode_secinfo(xdr, res);
+	if (status)
+		goto out;
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /**
@@ -6544,6 +6611,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
 	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
+	PROC(SECINFO_NO_NAME,	enc_secinfo_no_name,	dec_secinfo_no_name),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 178fafe..7668f25 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -562,6 +562,7 @@ enum {
 	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_GETDEVICEINFO,
 	NFSPROC4_CLNT_LAYOUTCOMMIT,
+	NFSPROC4_CLNT_SECINFO_NO_NAME,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 78b101e..c4a0407 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1060,6 +1060,15 @@ struct nfs41_reclaim_complete_args {
 struct nfs41_reclaim_complete_res {
 	struct nfs4_sequence_res	seq_res;
 };
+
+#define SECINFO_STYLE_CURRENT_FH 0
+#define SECINFO_STYLE_PARENT 1
+struct nfs41_secinfo_no_name_args {
+	int				style;
+	struct nfs4_sequence_args	seq_args;
+};
+
+#define nfs41_secinfo_no_name_res nfs4_secinfo_res
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
-- 
1.7.4.4

