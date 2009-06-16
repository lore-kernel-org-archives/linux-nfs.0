From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 30/44] nfsd41: add test for failed sequence operation
Date: Tue, 16 Jun 2009 04:20:38 +0300
Message-ID: <1245115238-7791-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2701
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757170AbZFPBUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Failed sequence operations are not cached.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/xdr4.h |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index d99c8fe..39161d3 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -463,6 +463,13 @@ struct nfsd4_compoundres {
 	struct nfsd4_compound_state	cstate;
 };
 
+static inline bool nfsd4_is_failed_sequence(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
+	return resp->opcnt == 1 && args->ops[0].opnum == OP_SEQUENCE &&
+		resp->cstate.status;
+}
+
 static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
@@ -472,7 +479,8 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
 	return !resp->cstate.slot->sl_cachethis ||
-			nfsd4_is_solo_sequence(resp);
+			nfsd4_is_solo_sequence(resp) ||
+			nfsd4_is_failed_sequence(resp);
 }
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.6.3

