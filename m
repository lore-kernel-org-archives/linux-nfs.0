From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 34/51] nfsd41: cb_sequence callback
Date: Mon, 10 Nov 2008 22:52:20 +0200
Message-ID: <1226350340-11380-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57397 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbYKJUwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:52:33 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the cb_sequence callback conforming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |   57 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfsd/state.h |   12 +++++++++
 2 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b1d2299..312fe87 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -280,7 +280,18 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
 static int
 encode_cb_sequence(struct xdr_stream *xdr, struct nfs41_cb_sequence *args)
 {
-	return -1;	/* stub */
+	u32 *p;
+
+	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
+
+	WRITE32(OP_CB_SEQUENCE);
+	WRITEMEM(args->cbs_sessionid, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(args->cbs_seqid);
+	WRITE32(args->cbs_slotid);
+	WRITE32(args->cbs_highest_slotid);
+	WRITE32(args->cbsa_cachethis);
+	WRITE32(0); /* FIXME: support referring_call_lists */
+	return 0;
 }
 #endif /* defined(CONFIG_NFSD_V4_1) */
 
@@ -393,7 +404,19 @@ out:
 static int
 decode_cb_sequence(struct xdr_stream *xdr, struct nfs41_cb_sequence *res)
 {
-	return -1;	/* stub */
+	int status;
+	u32 *p;
+
+	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
+	if (status)
+		return status;
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
+	COPYMEM(res->cbs_sessionid, NFS4_MAX_SESSIONID_LEN);
+	READ32(res->cbs_seqid);
+	READ32(res->cbs_slotid);
+	READ32(res->cbs_highest_slotid);
+	READ32(res->cbsr_target_highest_slotid);
+	return 0;
 }
 
 static int
@@ -593,6 +616,36 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	return;
 }
 
+#if defined(CONFIG_NFSD_V4_1)
+/* FIXME: cb_sequence should support referring call lists, cachethis, and multiple slots */
+static int
+nfs41_cb_sequence_setup(struct nfs4_client *clp, struct nfs41_cb_sequence *args)
+{
+	u32 *ptr = (u32 *)clp->cl_sessionid;
+	dprintk("%s: %u:%u:%u:%u\n", __func__,
+		ptr[0], ptr[1], ptr[2], ptr[3]);
+
+	mutex_lock(&clp->cl_cb_mutex);
+	memcpy(args->cbs_sessionid, clp->cl_sessionid, NFS4_MAX_SESSIONID_LEN);
+	args->cbs_seqid = ++clp->cl_cb_seq_nr;
+	args->cbs_slotid = 0;
+	args->cbs_highest_slotid = 0;
+	args->cbsa_cachethis = 0;
+	return 0;
+}
+
+static void
+nfs41_cb_sequence_done(struct nfs4_client *clp, struct nfs41_cb_sequence *res)
+{
+	u32 *ptr = (u32 *)res->cbs_sessionid;
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
  * nfs4_lock_state() may or may not have been called.
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index eb8d55c..4f37e2f 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -181,6 +181,16 @@ struct current_session {
 	struct nfsd_sessionid	cs_sid;
 	struct nfs41_slot	*cs_slot;
 };
+
+struct nfs41_cb_sequence {
+	/* args/res */
+	char			cbs_sessionid[NFS4_MAX_SESSIONID_LEN];
+	u32			cbs_seqid;
+	u32			cbs_slotid;
+	u32			cbs_highest_slotid;
+	u32			cbsa_cachethis;			/* args only */
+	u32			cbsr_target_highest_slotid;	/* res only */
+};
 #endif /* CONFIG_NFSD_V4_1 */
 
 #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
@@ -222,6 +232,8 @@ struct nfs4_client {
 
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct mutex		cl_cb_mutex;
+	/* FIXME: support multiple callback slots */
+	u32			cl_cb_seq_nr;
 #endif /* CONFIG_NFSD_V4_1 */
 };
 
-- 
1.6.0.2

