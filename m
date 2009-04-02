From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 01/21] SQUASHME: nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall
Date: Fri,  3 Apr 2009 01:37:30 +0300
Message-ID: <1238711850-22053-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25798 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765275AbZDBWhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:37:38 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "nfsd41: cb_recall callback"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 02e0a61..10c6a80 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -441,9 +441,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
-	status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
-	if (status)
-		goto out;
+	if (rpc_res && rpc_res->res_seq) {
+		status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
+		if (status)
+			goto out;
+	}
 	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
 out:
 	return status;
-- 
1.6.2.1

