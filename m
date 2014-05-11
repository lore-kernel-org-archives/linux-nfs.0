Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755717AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/43] nfsd4: fix encoding of out-of-space replies
Date: Sun, 11 May 2014 16:52:11 -0400
Message-Id: <1399841568-19716-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If nfsd4_check_resp_size() returns an error then we should really be
truncating the reply here, otherwise we may leave extra garbage at the
end of the rpc reply.

Also add a warning to catch any cases where our reply-size estimates may
be wrong in the case of a non-idempotent operation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6cdd660..fb40dd1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3633,6 +3633,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	__be32 *statp;
+	nfsd4_enc encoder;
 	__be32 *p;
 
 	RESERVE_SPACE(8);
@@ -3644,10 +3645,29 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		goto status;
 	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
 	       !nfsd4_enc_ops[op->opnum]);
-	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
+	encoder = nfsd4_enc_ops[op->opnum];
+	op->status = encoder(resp, op->status, &op->u);
 	/* nfsd4_check_resp_size guarantees enough room for error status */
 	if (!op->status)
 		op->status = nfsd4_check_resp_size(resp, 0);
+	if (op->status == nfserr_resource ||
+	    op->status == nfserr_rep_too_big ||
+	    op->status == nfserr_rep_too_big_to_cache) {
+		/*
+		 * The operation may have already been encoded or
+		 * partially encoded.  No op returns anything additional
+		 * in the case of one of these three errors, so we can
+		 * just truncate back to after the status.  But it's a
+		 * bug if we had to do this on a non-idempotent op:
+		 */
+		if (OPDESC(op)->op_flags & OP_MODIFIES_SOMETHING) {
+			printk("unable to encode reply to nonidempotent op"
+			       " %d (%s)\n", op->opnum,
+			       nfsd4_op_name(op->opnum));
+			WARN_ON_ONCE(1);
+		}
+		resp->xdr.p = statp + 1;
+	}
 	if (so) {
 		so->so_replay.rp_status = op->status;
 		so->so_replay.rp_buflen = (char *)resp->xdr.p - (char *)(statp+1);
-- 
1.7.9.5

