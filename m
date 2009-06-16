From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 04:19:32 +0300
Message-ID: <1245115172-7030-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2607
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753402AbZFPBTb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replay processing needs to preceed other error processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bfc808b..5aef525 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
-		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    (ip_addr != unconf->cl_addr)) {
-			status = nfserr_clid_inuse;
-			goto out_cache;
-		}
-
 		slot = &unconf->cl_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status) {
@@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
+		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
+		    (ip_addr != unconf->cl_addr)) {
+			status = nfserr_clid_inuse;
+			goto out_cache;
+		}
+
 		slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
-- 
1.6.3

