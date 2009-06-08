From: andros@netapp.com
Subject: [PATCH 23/30] nfsd41: fix nfsd4_replay_cache_entry comments
Date: Mon,  8 Jun 2009 14:21:04 -0400
Message-ID: <1244485271-7461-24-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830AbZFHSVg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:36 -0400
In-Reply-To: <1244485271-7461-23-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 94c4c6c..694cfb7 100644
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
 	seq->maxslots = resp->cstate.session->se_fnumslots;
 
 	/* Either returns 0 or nfserr_retry_uncached */
-- 
1.5.4.3

