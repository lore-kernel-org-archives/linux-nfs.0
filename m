Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47867 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbaCWBM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 15/50] nfsd4: allow space for final error return
Date: Sat, 22 Mar 2014 21:11:46 -0400
Message-Id: <1395537141-10389-16-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This post-encoding check should be taking into account the need to
encode at least an out-of-space error to the following op (if any).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c150121..ed486e7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3631,6 +3631,7 @@ void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
+	struct svc_rqst *rqstp = resp->rqstp;
 	__be32 *statp;
 	nfsd4_enc encoder;
 	__be32 *p;
@@ -3647,8 +3648,12 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
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
 	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
 		struct nfsd4_slot *slot = resp->cstate.slot;
 
-- 
1.8.5.3

