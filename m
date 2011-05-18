Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63410 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932747Ab1ERCRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 22:17:05 -0400
Message-ID: <4DD32CAB.5010405@cn.fujitsu.com>
Date: Wed, 18 May 2011 10:19:23 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: check the size of response
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Compare response's size to the session se_fmaxresp_sz and 
se_fmaxresp_cached at the same function.

And modify function name nfsd4_check_drc_limit to
nfsd4_check_response_size.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4xdr.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6766af..a7cf985 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3224,12 +3224,12 @@ static nfsd4_enc nfsd4_enc_ops[] = {
  * pad: add on 8 bytes for the next operation's op_code and status so that
  * there is room to cache a failure on the next operation.
  *
- * Compare this length to the session se_fmaxresp_cached.
+ * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
  *
  * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
  * will be at least a page and will therefore hold the xdr_buf head.
  */
-static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
+static int nfsd4_check_response_size(struct nfsd4_compoundres *resp)
 {
 	int status = 0;
 	struct xdr_buf *xb = &resp->rqstp->rq_res;
@@ -3242,7 +3242,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 		return status;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cachethis == 0)
+	if (session == NULL)
 		return status;
 
 	if (resp->opcnt >= args->opcnt)
@@ -3259,10 +3259,14 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
 		length, xb->page_len, tlen, pad);
 
-	if (length <= session->se_fchannel.maxresp_cached)
-		return status;
-	else
+	if (length > session->se_fchannel.maxresp_sz)
+		return nfserr_rep_too_big;
+
+	if (slot->sl_cachethis == 1 &&
+	    length > session->se_fchannel.maxresp_cached)
 		return nfserr_rep_too_big_to_cache;
+
+	return status;
 }
 
 void
@@ -3282,8 +3286,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum]);
 	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
-	if (!op->status && nfsd4_check_drc_limit(resp))
-		op->status = nfserr_rep_too_big_to_cache;
+	if (!op->status)
+		op->status = nfsd4_check_response_size(resp);
 status:
 	/*
 	 * Note: We write the status directly, instead of using WRITE32(),
-- 
1.7.4.5


