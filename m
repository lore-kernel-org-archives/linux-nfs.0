Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:54633 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751451AbdJMUyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Oct 2017 16:54:15 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 01/10] NFSD CB_OFFLOAD xdr
Date: Fri, 13 Oct 2017 16:54:03 -0400
Message-ID: <20171013205412.65532-2-kolga@netapp.com>
In-Reply-To: <20171013205412.65532-1-kolga@netapp.com>
References: <20171013205412.65532-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4callback.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h        |  1 +
 fs/nfsd/xdr4.h         |  6 ++++
 fs/nfsd/xdr4cb.h       | 10 ++++++
 4 files changed, 114 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 49b0a9e..d12d914 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -39,6 +39,7 @@
 #include "state.h"
 #include "netns.h"
 #include "xdr4cb.h"
+#include "xdr4.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -105,6 +106,7 @@ enum nfs_cb_opnum4 {
 	OP_CB_WANTS_CANCELLED		= 12,
 	OP_CB_NOTIFY_LOCK		= 13,
 	OP_CB_NOTIFY_DEVICEID		= 14,
+	OP_CB_OFFLOAD			= 15,
 	OP_CB_ILLEGAL			= 10044
 };
 
@@ -683,6 +685,100 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 }
 
 /*
+ * struct write_response4 {
+ *	stateid4	wr_callback_id<1>;
+ *	length4		wr_count;
+ *	stable_how4	wr_committed;
+ *	verifier4	wr_writeverf;
+ * };
+ * union offload_info4 switch (nfsstat4 coa_status) {
+ *	case NFS4_OK:
+ *		write_response4	coa_resok4;
+ *	default:
+ *	length4		coa_bytes_copied;
+ * };
+ * struct CB_OFFLOAD4args {
+ *	nfs_fh4		coa_fh;
+ *	stateid4	coa_stateid;
+ *	offload_info4	coa_offload_info;
+ * };
+ */
+static void encode_offload_info4(struct xdr_stream *xdr,
+				 __be32 nfserr,
+				 const struct nfsd4_copy *cp)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	*p++ = nfserr;
+	if (!nfserr) {
+		p = xdr_reserve_space(xdr, 4 + 8 + 4 + NFS4_VERIFIER_SIZE);
+		p = xdr_encode_empty_array(p);
+		p = xdr_encode_hyper(p, cp->cp_res.wr_bytes_written);
+		*p++ = cpu_to_be32(cp->cp_res.wr_stable_how);
+		p = xdr_encode_opaque_fixed(p, cp->cp_res.wr_verifier.data,
+					    NFS4_VERIFIER_SIZE);
+	} else {
+		p = xdr_reserve_space(xdr, 8);
+		p = xdr_encode_hyper(p, cp->cp_res.wr_bytes_written);
+	}
+}
+
+static void encode_cb_offload4args(struct xdr_stream *xdr,
+				   __be32 nfserr,
+				   const struct knfsd_fh *fh,
+				   const struct nfsd4_copy *cp,
+				   struct nfs4_cb_compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	*p++ = cpu_to_be32(OP_CB_OFFLOAD);
+	encode_nfs_fh4(xdr, fh);
+	encode_stateid4(xdr, &cp->cp_res.cb_stateid);
+	encode_offload_info4(xdr, nfserr, cp);
+
+	hdr->nops++;
+}
+
+static void nfs4_xdr_enc_cb_offload(struct rpc_rqst *req,
+				    struct xdr_stream *xdr,
+				    const void *data)
+{
+	const struct nfsd4_callback *cb = data;
+	const struct nfsd4_copy *cp =
+		container_of(cb, struct nfsd4_copy, cp_cb);
+	struct nfs4_cb_compound_hdr hdr = {
+		.ident = 0,
+		.minorversion = cb->cb_clp->cl_minorversion,
+	};
+
+	encode_cb_compound4args(xdr, &hdr);
+	encode_cb_sequence4args(xdr, cb, &hdr);
+	encode_cb_offload4args(xdr, cp->nfserr, &cp->fh, cp, &hdr);
+	encode_cb_nops(&hdr);
+}
+
+static int nfs4_xdr_dec_cb_offload(struct rpc_rqst *rqstp,
+				   struct xdr_stream *xdr,
+				   void *data)
+{
+	struct nfsd4_callback *cb = data;
+	struct nfs4_cb_compound_hdr hdr;
+	int status;
+
+	status = decode_cb_compound4res(xdr, &hdr);
+	if (unlikely(status))
+		return status;
+
+	if (cb) {
+		status = decode_cb_sequence4res(xdr, cb);
+		if (unlikely(status || cb->cb_seq_status))
+			return status;
+	}
+	return decode_cb_op_status(xdr, OP_CB_OFFLOAD, &cb->cb_status);
+}
+/*
  * RPC procedure tables
  */
 #define PROC(proc, call, argtype, restype)				\
@@ -703,6 +799,7 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 	PROC(CB_LAYOUT,	COMPOUND,	cb_layout,	cb_layout),
 #endif
 	PROC(CB_NOTIFY_LOCK,	COMPOUND,	cb_notify_lock,	cb_notify_lock),
+	PROC(CB_OFFLOAD,	COMPOUND,	cb_offload,	cb_offload),
 };
 
 static unsigned int nfs4_cb_counts[ARRAY_SIZE(nfs4_cb_procedures)];
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 005c911..f8b0210 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -570,6 +570,7 @@ enum nfsd4_cb_op {
 	NFSPROC4_CLNT_CB_NULL = 0,
 	NFSPROC4_CLNT_CB_RECALL,
 	NFSPROC4_CLNT_CB_LAYOUT,
+	NFSPROC4_CLNT_CB_OFFLOAD,
 	NFSPROC4_CLNT_CB_SEQUENCE,
 	NFSPROC4_CLNT_CB_NOTIFY_LOCK,
 };
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1e4edbf..4ac2676 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -507,6 +507,7 @@ struct nfsd42_write_res {
 	u64			wr_bytes_written;
 	u32			wr_stable_how;
 	nfs4_verifier		wr_verifier;
+	stateid_t		cb_stateid;
 };
 
 struct nfsd4_copy {
@@ -523,6 +524,11 @@ struct nfsd4_copy {
 
 	/* response */
 	struct nfsd42_write_res	cp_res;
+
+	/* for cb_offload */
+	struct nfsd4_callback	cp_cb;
+	__be32			nfserr;
+	struct knfsd_fh		fh;
 };
 
 struct nfsd4_seek {
diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index 49b719d..7e39913 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -37,3 +37,13 @@
 #define NFS4_dec_cb_notify_lock_sz	(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
+#define enc_cb_offload_info_sz		(1 + 1 + 2 + 1 +		\
+					XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#define NFS4_enc_cb_offload_sz		(cb_compound_enc_hdr_sz +       \
+					cb_sequence_enc_sz +            \
+					enc_nfs4_fh_sz +		\
+					enc_stateid_sz +		\
+					enc_cb_offload_info_sz)
+#define NFS4_dec_cb_offload_sz		(cb_compound_dec_hdr_sz  +      \
+					cb_sequence_dec_sz +            \
+					op_dec_sz)
-- 
1.8.3.1

