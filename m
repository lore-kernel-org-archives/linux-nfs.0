Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:38069 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaFENpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:45:07 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so1359025qaq.31
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:45:06 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: don't halt scanning the DRC LRU list when there's an RC_INPROG entry
Date: Thu,  5 Jun 2014 09:45:00 -0400
Message-Id: <1401975900-13398-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the DRC cache pruner will stop scanning the list when it
hits an entry that is RC_INPROG. It's possible however for a call to
take a *very* long time. In that case, we don't want it to block other
entries from being pruned if they are expired or we need to trim the
cache to get back under the limit.

Fix the DRC cache pruner to just ignore RC_INPROG entries.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfscache.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index f8f060ffbf4f..6040da8830ff 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -224,13 +224,6 @@ hash_refile(struct svc_cacherep *rp)
 	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
 }
 
-static inline bool
-nfsd_cache_entry_expired(struct svc_cacherep *rp)
-{
-	return rp->c_state != RC_INPROG &&
-	       time_after(jiffies, rp->c_timestamp + RC_EXPIRE);
-}
-
 /*
  * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
  * Also prune the oldest ones when the total exceeds the max number of entries.
@@ -242,8 +235,14 @@ prune_cache_entries(void)
 	long freed = 0;
 
 	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
-		if (!nfsd_cache_entry_expired(rp) &&
-		    num_drc_entries <= max_drc_entries)
+		/*
+		 * Don't free entries attached to calls that are still
+		 * in-progress, but do keep scanning the list.
+		 */
+		if (rp->c_state == RC_INPROG)
+			continue;
+		if (num_drc_entries <= max_drc_entries &&
+		    time_before(jiffies, rp->c_timestamp + RC_EXPIRE))
 			break;
 		nfsd_reply_cache_free_locked(rp);
 		freed++;
-- 
1.9.3

