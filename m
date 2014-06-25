Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:54134 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757165AbaFYNsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 09:48:41 -0400
Received: by mail-qg0-f47.google.com with SMTP id q108so1671293qgd.34
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 06:48:40 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: stable@vger.kernel.org
Cc: kasparek@fit.vutbr.cz, linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [stable PATCH] nfsd: don't halt scanning the DRC LRU list when there's an RC_INPROG entry
Date: Wed, 25 Jun 2014 09:48:34 -0400
Message-Id: <1403704114-3536-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patch below has already made it into mainline as commit
1b19453d1c6abcfa7c312ba6c9f11a277568fc94. I think we need it in stable
as well. In addition to making the cache pruner more efficient, it also
fixes a logic bug in prune_cache_entries. If num_drc_entries is greater
than the max, then we can end up freeing the entry even if it's still
RC_INPROG. This patch ensures that RC_INPROG entries are always skipped
and that prevents a use-after-free.

Please apply this to any stable kernel, v3.9 or above. Original patch
description follows.

See:
     https://bugzilla.kernel.org/show_bug.cgi?id=77031

Thanks to Tomas Kasparek for the bug report.

--------------------------[snip]----------------------------

Currently, the DRC cache pruner will stop scanning the list when it
hits an entry that is RC_INPROG. It's possible however for a call to
take a *very* long time. In that case, we don't want it to block other
entries from being pruned if they are expired or we need to trim the
cache to get back under the limit.

Fix the DRC cache pruner to just ignore RC_INPROG entries.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
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

