From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 25/44] nfsd41: fix nfsd4_replay_cache_entry comments
Date: Tue, 16 Jun 2009 04:20:24 +0300
Message-ID: <1245115224-7626-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2348
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756132AbZFPBUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 439cf80..03e0c4d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1067,8 +1067,8 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 }
 
 /*
- * Keep the first page of the replay. Copy the NFSv4.1 data from the first
- * cached page.  Replace any futher replay pages from the cache.
+ * The sequence operation is not cached because we can use the slot and
+ * session values.
  */
 __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
@@ -1079,16 +1079,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
 	dprintk("--> %s datalen %d\n", __func__, slot->sl_datalen);
 
-	/*
-	 * If this is just the sequence operation, we did not keep
-	 * a page in the cache entry because we can just use the
-	 * slot info stored in struct nfsd4_sequence that was checked
-	 * against the slot in nfsd4_sequence().
-	 *
-	 * This occurs when seq->cachethis is FALSE, or when the client
-	 * session inactivity timer fires and a solo sequence operation
-	 * is sent (lease renewal).
-	 */
+	/* Target max slot and flags will be set once they are implemented */
 	seq->maxslots = resp->cstate.session->se_fchannel.maxreqs;
 
 	/* Either returns 0 or nfserr_retry_uncached */
-- 
1.6.3

