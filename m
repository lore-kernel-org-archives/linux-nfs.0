Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757609AbaEKUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 19/43] nfsd4: remove redundant encode buffer size checking
Date: Sun, 11 May 2014 16:52:24 -0400
Message-Id: <1399841568-19716-20-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Now that all op encoders can handle running out of space, we no longer
need to check the remaining size for every operation; only nonidempotent
operations need that check, and that can be done by
nfsd4_check_resp_size.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   14 --------------
 fs/nfsd/nfs4xdr.c  |   22 +++++++++++++---------
 2 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d9fe000..d50fc14 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1228,7 +1228,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *save_fh = &cstate->save_fh;
-	int		slack_bytes;
 	u32		plen = 0;
 	__be32		status;
 
@@ -1282,19 +1281,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
-		/* We must be able to encode a successful response to
-		 * this operation, with enough room left over to encode a
-		 * failed response to the next operation.  If we don't
-		 * have enough room, fail with ERR_RESOURCE.
-		 */
-		slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
-		if (slack_bytes < COMPOUND_SLACK_SPACE
-				+ COMPOUND_ERR_SLACK_SPACE) {
-			BUG_ON(slack_bytes < COMPOUND_ERR_SLACK_SPACE);
-			op->status = nfserr_resource;
-			goto encode_op;
-		}
-
 		opdesc = OPDESC(op);
 
 		if (!current_fh->fh_dentry) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4c036eb..a330dd7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3736,20 +3736,24 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 {
 	struct xdr_buf *buf = &resp->rqstp->rq_res;
-	struct nfsd4_session *session = NULL;
+	struct nfsd4_session *session = resp->cstate.session;
 	struct nfsd4_slot *slot = resp->cstate.slot;
+	int slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
 
-	if (!nfsd4_has_session(&resp->cstate))
-		return 0;
+	if (nfsd4_has_session(&resp->cstate)) {
 
-	session = resp->cstate.session;
+		if (buf->len + pad > session->se_fchannel.maxresp_sz)
+			return nfserr_rep_too_big;
 
-	if (buf->len + pad > session->se_fchannel.maxresp_sz)
-		return nfserr_rep_too_big;
+		if ((slot->sl_flags & NFSD4_SLOT_CACHETHIS) &&
+		    buf->len + pad > session->se_fchannel.maxresp_cached)
+			return nfserr_rep_too_big_to_cache;
+	}
 
-	if ((slot->sl_flags & NFSD4_SLOT_CACHETHIS) &&
-	    buf->len + pad > session->se_fchannel.maxresp_cached)
-		return nfserr_rep_too_big_to_cache;
+	if (pad > slack_bytes) {
+		WARN_ON_ONCE(nfsd4_has_session(&resp->cstate));
+		return nfserr_resource;
+	}
 
 	return 0;
 }
-- 
1.7.9.5

