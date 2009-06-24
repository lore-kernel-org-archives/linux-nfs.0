From: andros@netapp.com
Subject: [PATCH 11/14] nfsd41: fix nfsd4_replay_cache_entry comments
Date: Wed, 24 Jun 2009 15:37:55 -0400
Message-ID: <1245872278-18743-12-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
 <1245872278-18743-10-git-send-email-andros@netapp.com>
 <1245872278-18743-11-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506AbZFXTiG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:06 -0400
In-Reply-To: <1245872278-18743-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 51a51d2..7662ca8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1066,8 +1066,8 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 }
 
 /*
- * Keep the first page of the replay. Copy the NFSv4.1 data from the first
- * cached page.  Replace any futher replay pages from the cache.
+ * The sequence operation is not cached because we can use the slot and
+ * session values.
  */
 __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
@@ -1078,16 +1078,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
 	dprintk("--> %s slot %p\n", __func__, slot);
 
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
1.5.4.3

