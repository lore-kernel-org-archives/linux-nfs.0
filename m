Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:6292 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754523AbeGITNb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:13:31 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 02/13] NFS CB_OFFLOAD xdr
Date: Mon, 9 Jul 2018 15:13:28 -0400
Message-ID: <20180709191339.44740-3-kolga@netapp.com>
In-Reply-To: <20180709191339.44740-1-kolga@netapp.com>
References: <20180709191339.44740-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback.h      | 12 ++++++++
 fs/nfs/callback_proc.c |  7 +++++
 fs/nfs/callback_xdr.c  | 80 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 98 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index a20a0bc..8f34daf 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -184,6 +184,18 @@ struct cb_notify_lock_args {
 extern __be32 nfs4_callback_notify_lock(void *argp, void *resp,
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
+extern __be32 nfs4_callback_offload(void *args, void *dummy,
+				    struct cb_process_state *cps);
+#endif /* CONFIG_NFS_V4_2 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(void *argp, void *resp,
 				    struct cb_process_state *cps);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43ba390..9647616 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -661,3 +661,10 @@ __be32 nfs4_callback_notify_lock(void *argp, void *resp,
 	return htonl(NFS4_OK);
 }
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+__be32 nfs4_callback_offload(void *args, void *dummy,
+			     struct cb_process_state *cps)
+{
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a813979..d1dea85 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -38,6 +38,9 @@
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_NOTIFY_LOCK_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+#define CB_OP_OFFLOAD_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ)
+#endif /* CONFIG_NFS_V4_2 */
 
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
@@ -527,7 +530,72 @@ static __be32 decode_notify_lock_args(struct svc_rqst *rqstp,
 }
 
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+static __be32 decode_write_response(struct xdr_stream *xdr,
+					struct cb_offloadargs *args)
+{
+	__be32 *p;
+
+	/* skip the always zero field */
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		goto out;
+	p++;
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
+					void *data)
+{
+	struct cb_offloadargs *args = data;
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
@@ -773,7 +841,10 @@ static void nfs4_cb_free_slot(struct cb_process_state *cps)
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
@@ -969,6 +1040,13 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 		.res_maxsize = CB_OP_NOTIFY_LOCK_RES_MAXSZ,
 	},
 #endif /* CONFIG_NFS_V4_1 */
+#ifdef CONFIG_NFS_V4_2
+	[OP_CB_OFFLOAD] = {
+		.process_op = nfs4_callback_offload,
+		.decode_args = decode_offload_args,
+		.res_maxsize = CB_OP_OFFLOAD_RES_MAXSZ,
+	},
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 /*
-- 
1.8.3.1

