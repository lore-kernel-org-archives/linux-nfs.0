From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Sat, 28 Mar 2009 11:34:41 +0300
Message-ID: <1238229281-11516-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16571 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756438AbZC1Ieq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:34:46 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Rework the back channel xdr using the shared v4.0 and v4.1 framework.]
Signed-off-by: Andy Adamson <andros@netapp.com>
[fixed indentation]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |  118 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/state.h |    7 ++-
 2 files changed, 124 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6b7ef87..7ada6b1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -255,6 +255,29 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec,
 	hdr->nops++;
 }
 
+static void
+encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
+		   struct nfs4_cb_compound_hdr *hdr)
+{
+	__be32 *p;
+
+	if (hdr->minorversion == 0)
+		return;
+
+	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
+
+	WRITE32(OP_CB_SEQUENCE);
+#ifdef CONFIG_NFSD_V4_1
+	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(args->cbs_clp->cl_cb_seq_nr);
+#endif /* CONFIG_NFSD_V4_1 */
+	WRITE32(0);		/* slotid, always 0 */
+	WRITE32(0);		/* highest slotid always 0 */
+	WRITE32(0);		/* cachethis always 0 */
+	WRITE32(0); /* FIXME: support referring_call_lists */
+	hdr->nops++;
+}
+
 static int
 nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 {
@@ -319,6 +342,69 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	return 0;
 }
 
+/*
+ * Our current back channel implmentation supports a single backchannel
+ * with a single slot.
+ */
+static int
+decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
+		   struct rpc_rqst *rqstp)
+{
+	struct nfs4_callback *cb =
+		(struct nfs4_callback *)rqstp->rq_task->tk_client->cl_private;
+	struct nfs4_sessionid id;
+	int status;
+	u32 dummy;
+	__be32 *p;
+
+	if (cb->cb_minorversion == 0)
+		return 0;
+
+	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
+	if (status)
+		return status;
+
+	/*
+	 * If the server returns different values for sessionID, slotID or
+	 * sequence number, the server is looney tunes.
+	 */
+	status = -ESERVERFAULT;
+
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
+	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
+#ifdef CONFIG_NFSD_V4_1
+	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
+		   NFS4_MAX_SESSIONID_LEN)) {
+		dprintk("%s Invalid session id\n", __func__);
+		goto out;
+	}
+	READ32(dummy);
+	if (dummy != res->cbs_clp->cl_cb_seq_nr) {
+		dprintk("%s Invalid sequence number\n", __func__);
+		goto out;
+	}
+#endif /* CONFIG_NFSD_V4_1 */
+	READ32(dummy); 	/* slotid must be 0 */
+	if (dummy != 0) {
+		dprintk("%s Invalid slotid\n", __func__);
+		goto out;
+	}
+	READ32(dummy); 	/* highest slotid must be 0 */
+	if (dummy != 0) {
+		dprintk("%s Invalid highest slotid\n", __func__);
+		goto out;
+	}
+	READ32(dummy); 	/* target highest slotid must be 0 */
+	if (dummy != 0) {
+		dprintk("%s Invalid target highest slotid\n", __func__);
+		goto out;
+	}
+	status = 0;
+out:
+	return status;
+}
+
+
 static int
 nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 {
@@ -503,6 +589,38 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	return;
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+/*
+ * FIXME: cb_sequence should support referring call lists, cachethis, and
+ * multiple slots
+ */
+static int
+nfs41_cb_sequence_setup(struct nfs4_client *clp, struct nfsd4_cb_sequence *args)
+{
+	u32 *ptr = (u32 *)clp->cl_sessionid.data;
+
+	dprintk("%s: %u:%u:%u:%u\n", __func__,
+		ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	mutex_lock(&clp->cl_cb_mutex);
+	args->cbs_clp = clp;
+	clp->cl_cb_seq_nr++;
+	return 0;
+}
+
+static void
+nfs41_cb_sequence_done(struct nfs4_client *clp, struct nfsd4_cb_sequence *res)
+{
+	u32 *ptr = (u32 *)clp->cl_sessionid.data;
+
+	dprintk("%s: %u:%u:%u:%u\n", __func__,
+		ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	/* FIXME: support multiple callback slots */
+	mutex_unlock(&clp->cl_cb_mutex);
+}
+#endif /* CONFIG_NFSD_V4_1 */
+
 /*
  * called with dp->dl_count inc'ed.
  */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f2783d4..0ea8c89 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -61,6 +61,10 @@ typedef struct {
 #define si_stateownerid   si_opaque.so_stateownerid
 #define si_fileid         si_opaque.so_fileid
 
+struct nfsd4_cb_sequence {
+	/* args/res */
+	struct nfs4_client	*cbs_clp;
+};
 
 struct nfs4_cb_recall {
 	u32			cbr_ident;
@@ -195,7 +199,8 @@ struct nfs4_client {
 	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
-
+	/* We currently support a single back channel with a single slot */
+	u32			cl_cb_seq_nr;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct mutex		cl_cb_mutex;
 #endif /* CONFIG_NFSD_V4_1 */
-- 
1.6.2.1

