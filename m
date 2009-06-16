From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 31/44] nfsd41: remove redundant failed sequence check
Date: Tue, 16 Jun 2009 04:20:41 +0300
Message-ID: <1245115241-7824-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2653
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757255AbZFPBUl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5866f94..591879d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1002,16 +1002,9 @@ void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct nfsd4_compoundargs *args = rqstp->rq_argp;
-	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
 	dprintk("--> %s cachethis %d\n", __func__, slot->sl_cachethis);
 
-	/* Don't cache a failed OP_SEQUENCE. */
-	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
-		return;
-
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-- 
1.6.3

