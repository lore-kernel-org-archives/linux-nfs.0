From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 33/44] nfsd41: Remove ip address collision detection case per review comment
Date: Tue, 16 Jun 2009 04:20:47 +0300
Message-ID: <1245115247-7890-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2623
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757372AbZFPBUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Sager <sager@netapp.com>

Verified that cthon and pynfs exchange id tests pass (except for the
two expected fails: EID8 and EID50)

Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c91b333..8ac5630 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1158,12 +1158,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			expire_client(conf);
 			goto out_new;
 		}
-		if (ip_addr != conf->cl_addr &&
-		    !(exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)) {
-			/* Client collision. 18.35.4 case 3 */
-			status = nfserr_clid_inuse;
-			goto out;
-		}
 		/*
 		 * Set bit when the owner id and verifier map to an already
 		 * confirmed client id (18.35.3).
@@ -1177,12 +1171,12 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		copy_verf(conf, &verf);
 		new = conf;
 		goto out_copy;
-	} else {
-		/* 18.35.4 case 7 */
-		if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
-			status = nfserr_noent;
-			goto out;
-		}
+	}
+
+	/* 18.35.4 case 7 */
+	if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+		status = nfserr_noent;
+		goto out;
 	}
 
 	unconf  = find_unconfirmed_client_by_str(dname, strhashval, true);
-- 
1.6.3

