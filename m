From: andros@netapp.com
Subject: [PATCH 24/31] nfsd41: fix nfsd4_replay_cache_entry comments
Date: Tue, 28 Apr 2009 12:59:58 -0400
Message-ID: <1240938005-23778-24-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
 <1240938005-23778-18-git-send-email-andros@netapp.com>
 <1240938005-23778-19-git-send-email-andros@netapp.com>
 <1240938005-23778-20-git-send-email-andros@netapp.com>
 <1240938005-23778-21-git-send-email-andros@netapp.com>
 <1240938005-23778-22-git-send-email-andros@netapp.com>
 <1240938005-23778-23-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760153AbZD1RAq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:46 -0400
In-Reply-To: <1240938005-23778-23-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 61a25cf..d38a48f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1081,8 +1081,8 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 }
 
 /*
- * Keep the first page of the replay. Copy the NFSv4.1 data from the first
- * cached page.  Replace any futher replay pages from the cache.
+ * The sequence operation is not cached because we can use the slot and
+ * session values.
  */
 __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
@@ -1093,16 +1093,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
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
1.5.4.3

