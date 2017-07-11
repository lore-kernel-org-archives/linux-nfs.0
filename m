Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:17907 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755848AbdGKQoW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:22 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 03/42] NFS CB_OFFLOAD xdr
Date: Tue, 11 Jul 2017 12:43:37 -0400
Message-ID: <20170711164416.1982-4-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback.h      | 13 ++++++++
 fs/nfs/callback_proc.c |  7 +++++
 fs/nfs/callback_xdr.c  | 80 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 99 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c701c30..e4ab65d 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -189,6 +189,19 @@ extern __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args,
 					 void *dummy,
 					 struct cb_process_state *cps);
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+struct cb_offloadargs {
+	struct nfs_fh		coa_fh;
+	nfs4_stateid		coa_stateid;
+	uint32_t		error;
+	uint64_t		wr_count;
+	struct nfs_writeverf	wr_writeverf;
+};
+
+extern __be32 nfs4_callback_offload(
+	struct cb_offloadargs *args,
+	void *dummy, struct cb_process_state *cps);
+#endif /* CONFIG_NFS_V4_2 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_getattrres *res,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 52479f1..5396751 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -647,3 +647,10 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
 	return htonl(NFS4_OK);
 }
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+__be32 nfs4_callback_offload(struct cb_offloadargs *args, void *dummy,
+				struct cb_process_state *cps)
+{
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 390ac9c..be5ffa1 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -37,6 +37,9 @@
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_NOTIFY_LOCK_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+#define CB_OP_OFFLOAD_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ)
+#endif /* CONFIG_NFS_V4_2 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
@@ -521,7 +524,72 @@ static __be32 decode_notify_lock_args(struct svc_rqst *rqstp, struct xdr_stream
 }
 
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+static __be32 decode_write_response(struct xdr_stream *xdr,
+					struct cb_offloadargs *args)
+{
+	__be32 *p;
+	__be32 dummy;
+
+	/* skip the always zero field */
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		goto out;
+	dummy = ntohl(*p++);
+
+	/* decode count, stable_how, verifier */
+	p = xdr_inline_decode(xdr, 8 + 4);
+	if (unlikely(!p))
+		goto out;
+	p = xdr_decode_hyper(p, &args->wr_count);
+	args->wr_writeverf.committed = be32_to_cpup(p);
+	p = xdr_inline_decode(xdr, NFS4_VERIFIER_SIZE);
+	if (likely(p)) {
+		memcpy(&args->wr_writeverf.verifier.data[0], p,
+			NFS4_VERIFIER_SIZE);
+		return 0;
+	}
+out:
+	return htonl(NFS4ERR_RESOURCE);
+}
+
+static __be32 decode_offload_args(struct svc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					struct cb_offloadargs *args)
+{
+	__be32 *p;
+	__be32 status;
+
+	/* decode fh */
+	status = decode_fh(xdr, &args->coa_fh);
+	if (unlikely(status != 0))
+		return status;
+
+	/* decode stateid */
+	status = decode_stateid(xdr, &args->coa_stateid);
+	if (unlikely(status != 0))
+		return status;
 
+	/* decode status */
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		goto out;
+	args->error = ntohl(*p++);
+	if (!args->error) {
+		status = decode_write_response(xdr, args);
+		if (unlikely(status != 0))
+			return status;
+	} else {
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out;
+		p = xdr_decode_hyper(p, &args->wr_count);
+	}
+	return 0;
+out:
+	return htonl(NFS4ERR_RESOURCE);
+}
+#endif /* CONFIG_NFS_V4_2 */
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
 	if (unlikely(xdr_stream_encode_opaque(xdr, str, len) < 0))
@@ -785,7 +853,10 @@ static void nfs4_cb_free_slot(struct cb_process_state *cps)
 	if (status != htonl(NFS4ERR_OP_ILLEGAL))
 		return status;
 
-	if (op_nr == OP_CB_OFFLOAD)
+	if (op_nr == OP_CB_OFFLOAD) {
+		*op = &callback_ops[op_nr];
+		return htonl(NFS_OK);
+	} else
 		return htonl(NFS4ERR_NOTSUPP);
 	return htonl(NFS4ERR_OP_ILLEGAL);
 }
@@ -982,6 +1053,13 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		.res_maxsize = CB_OP_NOTIFY_LOCK_RES_MAXSZ,
 	},
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+	[OP_CB_OFFLOAD] = {
+		.process_op = (callback_process_op_t)nfs4_callback_offload,
+		.decode_args = (callback_decode_arg_t)decode_offload_args,
+		.res_maxsize = CB_OP_OFFLOAD_RES_MAXSZ,
+	},
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 /*
-- 
1.8.3.1

