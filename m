From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 24/35] nfsd41: check encode size for sessions maxresponse cached
Date: Fri,  3 Apr 2009 08:28:48 +0300
Message-ID: <1238736528-17829-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23648 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756270AbZDCF2w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:52 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Calculate the space the compound response has taken after encoding the current
operation.

pad: add on 8 bytes for the next operation's op_code and status so that
there is room to cache a failure on the next operation.

Compare this length to the session se_fmaxresp_cached and return
nfserr_rep_too_big_to_cache if the length is too large.

Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
will be at least a page and will therefore hold the xdr_buf head.

Signed-off-by: Andy Adamson <andros@netapp.com>
[nfsd41: non-page DRC for solo sequence responses]
[fixed nfsd4_check_drc_limit cosmetics]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use cstate session in nfsd4_check_drc_limit]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index dd81ac1..7fdee82 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3078,6 +3078,54 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
 };
 
+/*
+ * Calculate the total amount of memory that the compound response has taken
+ * after encoding the current operation.
+ *
+ * pad: add on 8 bytes for the next operation's op_code and status so that
+ * there is room to cache a failure on the next operation.
+ *
+ * Compare this length to the session se_fmaxresp_cached.
+ *
+ * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
+ * will be at least a page and will therefore hold the xdr_buf head.
+ */
+static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
+{
+	int status = 0;
+	struct xdr_buf *xb = &resp->rqstp->rq_res;
+	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
+	struct nfsd4_session *session = NULL;
+	struct nfsd4_slot *slot = resp->cstate.slot;
+	u32 length, tlen = 0, pad = 8;
+
+	if (!nfsd4_has_session(&resp->cstate))
+		return status;
+
+	session = resp->cstate.session;
+	if (session == NULL || slot->sl_cache_entry.ce_cachethis == 0)
+		return status;
+
+	if (resp->opcnt >= args->opcnt)
+		pad = 0; /* this is the last operation */
+
+	if (xb->page_len == 0) {
+		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
+	} else {
+		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
+			tlen = (char *)resp->p - (char *)xb->tail[0].iov_base;
+
+		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
+	}
+	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
+		length, xb->page_len, tlen, pad);
+
+	if (length <= session->se_fmaxresp_cached)
+		return status;
+	else
+		return nfserr_rep_too_big_to_cache;
+}
+
 void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
@@ -3094,6 +3142,9 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
 	       !nfsd4_enc_ops[op->opnum]);
 	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
+	/* nfsd4_check_drc_limit guarantees enough room for error status */
+	if (!op->status && nfsd4_check_drc_limit(resp))
+		op->status = nfserr_rep_too_big_to_cache;
 status:
 	/*
 	 * Note: We write the status directly, instead of using WRITE32(),
-- 
1.6.2.1

