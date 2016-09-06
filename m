Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753565AbcIFPEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 11:04:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] nfsd: plumb in a CB_NOTIFY_LOCK operation
Date: Tue,  6 Sep 2016 11:04:47 -0400
Message-Id: <1473174290-29612-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
References: <1473174290-29612-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the encoding/decoding for CB_NOTIFY_LOCK operations.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h        |  7 +++++++
 fs/nfsd/xdr4cb.h       |  9 ++++++++
 3 files changed, 73 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 04c68d900324..3fc90cbbbf0b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -623,6 +623,62 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 }
 #endif /* CONFIG_NFSD_PNFS */
 
+static void encode_stateowner(struct xdr_stream *xdr, struct nfs4_stateowner *so)
+{
+	__be32	*p;
+
+	p = xdr_reserve_space(xdr, 8 + 4 + so->so_owner.len);
+	p = xdr_encode_opaque_fixed(p, &so->so_client->cl_clientid, 8);
+	xdr_encode_opaque(p, so->so_owner.data, so->so_owner.len);
+}
+
+static void nfs4_xdr_enc_cb_notify_lock(struct rpc_rqst *req,
+					struct xdr_stream *xdr,
+					const struct nfsd4_callback *cb)
+{
+	const struct nfsd4_blocked_lock *nbl =
+		container_of(cb, struct nfsd4_blocked_lock, nbl_cb);
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)nbl->nbl_lock.fl_owner;
+	struct nfs4_cb_compound_hdr hdr = {
+		.ident = 0,
+		.minorversion = cb->cb_clp->cl_minorversion,
+	};
+
+	__be32 *p;
+
+	BUG_ON(hdr.minorversion == 0);
+
+	encode_cb_compound4args(xdr, &hdr);
+	encode_cb_sequence4args(xdr, cb, &hdr);
+
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_CB_NOTIFY_LOCK);
+	encode_nfs_fh4(xdr, &nbl->nbl_fh);
+	encode_stateowner(xdr, &lo->lo_owner);
+	hdr.nops++;
+
+	encode_cb_nops(&hdr);
+}
+
+static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
+					struct xdr_stream *xdr,
+					struct nfsd4_callback *cb)
+{
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
+	return decode_cb_op_status(xdr, OP_CB_NOTIFY_LOCK, &cb->cb_status);
+}
+
 /*
  * RPC procedure tables
  */
@@ -643,6 +699,7 @@ static struct rpc_procinfo nfs4_cb_procedures[] = {
 #ifdef CONFIG_NFSD_PNFS
 	PROC(CB_LAYOUT,	COMPOUND,	cb_layout,	cb_layout),
 #endif
+	PROC(CB_NOTIFY_LOCK,	COMPOUND,	cb_notify_lock,	cb_notify_lock),
 };
 
 static struct rpc_version nfs_cb_version4 = {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b95adf9a1595..127cc84ca5a3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -572,6 +572,7 @@ enum nfsd4_cb_op {
 	NFSPROC4_CLNT_CB_RECALL,
 	NFSPROC4_CLNT_CB_LAYOUT,
 	NFSPROC4_CLNT_CB_SEQUENCE,
+	NFSPROC4_CLNT_CB_NOTIFY_LOCK,
 };
 
 /* Returns true iff a is later than b: */
@@ -580,6 +581,12 @@ static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
 	return (s32)(a->si_generation - b->si_generation) > 0;
 }
 
+struct nfsd4_blocked_lock {
+	struct file_lock	nbl_lock;
+	struct knfsd_fh		nbl_fh;
+	struct nfsd4_callback	nbl_cb;
+};
+
 struct nfsd4_compound_state;
 struct nfsd_net;
 
diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index c47f6fdb111a..49b719dfef95 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -28,3 +28,12 @@
 #define NFS4_dec_cb_layout_sz		(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
+
+#define NFS4_enc_cb_notify_lock_sz	(cb_compound_enc_hdr_sz +        \
+					cb_sequence_enc_sz +             \
+					2 + 1 +				 \
+					XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+					enc_nfs4_fh_sz)
+#define NFS4_dec_cb_notify_lock_sz	(cb_compound_dec_hdr_sz  +      \
+					cb_sequence_dec_sz +            \
+					op_dec_sz)
-- 
2.7.4

