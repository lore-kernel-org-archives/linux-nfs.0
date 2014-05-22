Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43367 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbaEVTce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/52] nfsd4: allow space for final error return
Date: Thu, 22 May 2014 15:31:47 -0400
Message-Id: <1400787148-25941-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This post-encoding check should be taking into account the need to
encode at least an out-of-space error to the following op (if any).

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 24ba652..2ed8036 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3636,6 +3636,7 @@ void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
+	struct svc_rqst *rqstp = resp->rqstp;
 	__be32 *statp;
 	nfsd4_enc encoder;
 	__be32 *p;
@@ -3652,8 +3653,12 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	encoder = nfsd4_enc_ops[op->opnum];
 	op->status = encoder(resp, op->status, &op->u);
 	/* nfsd4_check_resp_size guarantees enough room for error status */
-	if (!op->status)
-		op->status = nfsd4_check_resp_size(resp, 0);
+	if (!op->status) {
+		int space_needed = 0;
+		if (!nfsd4_last_compound_op(rqstp))
+			space_needed = COMPOUND_ERR_SLACK_SPACE;
+		op->status = nfsd4_check_resp_size(resp, space_needed);
+	}
 	if (op->status == nfserr_resource ||
 	    op->status == nfserr_rep_too_big ||
 	    op->status == nfserr_rep_too_big_to_cache) {
-- 
1.9.0

