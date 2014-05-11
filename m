Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38566 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757472AbaEKUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:53:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 18/43] nfsd4: nfsd4_check_resp_size needn't recalculate length
Date: Sun, 11 May 2014 16:52:23 -0400
Message-Id: <1399841568-19716-19-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're keeping the length updated as we go now, so there's no need for
the extra calculation here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 846d241..4c036eb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3735,32 +3735,20 @@ static nfsd4_enc nfsd4_enc_ops[] = {
  */
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 {
-	struct xdr_buf *xb = &resp->rqstp->rq_res;
+	struct xdr_buf *buf = &resp->rqstp->rq_res;
 	struct nfsd4_session *session = NULL;
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	u32 length, tlen = 0;
 
 	if (!nfsd4_has_session(&resp->cstate))
 		return 0;
 
 	session = resp->cstate.session;
 
-	if (xb->page_len == 0) {
-		length = (char *)resp->xdr.p - (char *)xb->head[0].iov_base + pad;
-	} else {
-		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
-			tlen = (char *)resp->xdr.p - (char *)xb->tail[0].iov_base;
-
-		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
-	}
-	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
-		length, xb->page_len, tlen, pad);
-
-	if (length > session->se_fchannel.maxresp_sz)
+	if (buf->len + pad > session->se_fchannel.maxresp_sz)
 		return nfserr_rep_too_big;
 
 	if ((slot->sl_flags & NFSD4_SLOT_CACHETHIS) &&
-	    length > session->se_fchannel.maxresp_cached)
+	    buf->len + pad > session->se_fchannel.maxresp_cached)
 		return nfserr_rep_too_big_to_cache;
 
 	return 0;
-- 
1.7.9.5

