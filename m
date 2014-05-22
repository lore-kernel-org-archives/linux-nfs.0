Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaEVTce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/52] nfsd4: fix encoding of out-of-space replies
Date: Thu, 22 May 2014 15:31:46 -0400
Message-Id: <1400787148-25941-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
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
 fs/nfsd/nfs4proc.c |  9 +++++++++
 fs/nfsd/nfs4xdr.c  | 17 ++++++++++++++++-
 fs/nfsd/xdr4.h     |  2 ++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 747d6a8..db14965 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1859,6 +1859,15 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
+void warn_on_nonidempotent_op(struct nfsd4_op *op)
+{
+	if (OPDESC(op)->op_flags & OP_MODIFIES_SOMETHING) {
+		pr_err("unable to encode reply to nonidempotent op %d (%s)\n",
+			op->opnum, nfsd4_op_name(op->opnum));
+		WARN_ON_ONCE(1);
+	}
+}
+
 #ifdef NFSD_DEBUG
 static const char *nfsd4_op_name(unsigned opnum)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1879250..24ba652 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3637,6 +3637,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	__be32 *statp;
+	nfsd4_enc encoder;
 	__be32 *p;
 
 	RESERVE_SPACE(8);
@@ -3648,10 +3649,24 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
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
+		warn_on_nonidempotent_op(op);
+		resp->xdr.p = statp + 1;
+	}
 	if (so) {
 		so->so_replay.rp_status = op->status;
 		so->so_replay.rp_buflen = (char *)resp->xdr.p
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index f62a055..15ca477 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -536,6 +536,8 @@ static inline bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
 	return argp->opcnt == resp->opcnt;
 }
 
+void warn_on_nonidempotent_op(struct nfsd4_op *op);
+
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
 
 static inline void
-- 
1.9.0

