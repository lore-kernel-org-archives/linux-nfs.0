Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbaCWBM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/50] nfsd4: fix encoding of out-of-space replies
Date: Sat, 22 Mar 2014 21:11:45 -0400
Message-Id: <1395537141-10389-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
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
 fs/nfsd/nfs4xdr.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2ad423d..c150121 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3632,6 +3632,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	__be32 *statp;
+	nfsd4_enc encoder;
 	__be32 *p;
 
 	RESERVE_SPACE(8);
@@ -3643,7 +3644,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		goto status;
 	BUG_ON(op->opnum < 0 || op->opnum >= ARRAY_SIZE(nfsd4_enc_ops) ||
 	       !nfsd4_enc_ops[op->opnum]);
-	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
+	encoder = nfsd4_enc_ops[op->opnum];
+	op->status = encoder(resp, op->status, &op->u);
 	/* nfsd4_check_resp_size guarantees enough room for error status */
 	if (!op->status)
 		op->status = nfsd4_check_resp_size(resp, 0);
@@ -3655,6 +3657,24 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		else
 			op->status = nfserr_rep_too_big;
 	}
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
1.8.5.3

