Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38570 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757589AbaEKUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 20/43] nfsd4: size-checking cleanup
Date: Sun, 11 May 2014 16:52:25 -0400
Message-Id: <1399841568-19716-21-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Better variable name, some comments, etc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    9 ++++++---
 fs/nfsd/nfs4xdr.c  |   29 +++++++++++++++--------------
 2 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d50fc14..18063e0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1228,7 +1228,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *save_fh = &cstate->save_fh;
-	u32		plen = 0;
 	__be32		status;
 
 	svcxdr_init_encode(rqstp, resp);
@@ -1298,9 +1297,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 
 		/* If op is non-idempotent */
 		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
-			plen = opdesc->op_rsize_bop(rqstp, op);
 			/*
-			 * If there's still another operation, make sure
+			 * Don't execute this op if we couldn't encode a
+			 * succesful reply:
+			 */
+			u32 plen = opdesc->op_rsize_bop(rqstp, op);
+			/*
+			 * Plus if there's another operation, make sure
 			 * we'll have space to at least encode an error:
 			 */
 			if (resp->opcnt < args->opcnt)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a330dd7..def2ceb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3722,35 +3722,36 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 };
 
 /*
- * Calculate the total amount of memory that the compound response has taken
- * after encoding the current operation with pad.
+ * Calculate whether we still have space to encode repsize bytes.
+ * There are two considerations:
+ *     - For NFS versions >=4.1, the size of the reply must stay within
+ *       session limits
+ *     - For all NFS versions, we must stay within limited preallocated
+ *       buffer space.
  *
- * pad: if operation is non-idempotent, pad was calculate by op_rsize_bop()
- *      which was specified at nfsd4_operation, else pad is zero.
- *
- * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
- *
- * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
- * will be at least a page and will therefore hold the xdr_buf head.
+ * This is called before the operation is processed, so can only provide
+ * an upper estimate.  For some nonidempotent operations (such as
+ * getattr), it's not necessarily a problem if that estimate is wrong,
+ * as we can fail it after processing without significant side effects.
  */
-__be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
+__be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 respsize)
 {
 	struct xdr_buf *buf = &resp->rqstp->rq_res;
 	struct nfsd4_session *session = resp->cstate.session;
-	struct nfsd4_slot *slot = resp->cstate.slot;
 	int slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
 
 	if (nfsd4_has_session(&resp->cstate)) {
+		struct nfsd4_slot *slot = resp->cstate.slot;
 
-		if (buf->len + pad > session->se_fchannel.maxresp_sz)
+		if (buf->len + respsize > session->se_fchannel.maxresp_sz)
 			return nfserr_rep_too_big;
 
 		if ((slot->sl_flags & NFSD4_SLOT_CACHETHIS) &&
-		    buf->len + pad > session->se_fchannel.maxresp_cached)
+		    buf->len + respsize > session->se_fchannel.maxresp_cached)
 			return nfserr_rep_too_big_to_cache;
 	}
 
-	if (pad > slack_bytes) {
+	if (respsize > slack_bytes) {
 		WARN_ON_ONCE(nfsd4_has_session(&resp->cstate));
 		return nfserr_resource;
 	}
-- 
1.7.9.5

