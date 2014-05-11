Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757341AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/43] nfsd4: allow space for final error return
Date: Sun, 11 May 2014 16:52:12 -0400
Message-Id: <1399841568-19716-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This post-encoding check should be taking into account the need to
encode at least an out-of-space error to the following op (if any).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fb40dd1..e915bb1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3632,6 +3632,7 @@ void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
+	struct svc_rqst *rqstp = resp->rqstp;
 	__be32 *statp;
 	nfsd4_enc encoder;
 	__be32 *p;
@@ -3648,8 +3649,12 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
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
1.7.9.5

