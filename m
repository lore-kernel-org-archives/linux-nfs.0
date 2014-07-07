Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:63755 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbaGGTDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 15:03:49 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so3955194qab.15
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 12:03:48 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: close potential race between delegation break and laundromat
Date: Mon,  7 Jul 2014 15:03:38 -0400
Message-Id: <1404759818-10350-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce says:

    There's also a preexisting expire_client/laundromat vs break race:

    - expire_client/laundromat adds a delegation to its local
      reaplist using the same dl_recall_lru field that a delegation
      uses to track its position on the recall lru and drops the
      state lock.

    - a concurrent break_lease adds the delegation to the lru.

    - expire/client/laundromat then walks it reaplist and sees the
      lru head as just another delegation on the list....

Fix this race by checking the dl_time under the state_lock. If we find
that it's not 0, then we know that it has already been queued to the
LRU list and that we shouldn't queue it again.

In the case of destroy_client, we also have some similar races there.
Just bump the dl_time by one before we drop the state_lock. We're
destroying the delegations anyway, so a 1s difference there won't
matter.

The fault injection code also requires a bit of surgery here:

First, in the case of nfsd_forget_client_delegations, we must prevent
the same sort of race vs. the delegation break callback. For that, we
just increment the dl_time to ensure that a delegation callback can't
race in while we're working on it.

We can't do that for nfsd_recall_client_delegations, as we need to have
it actually queue the delegation, and that won't happen if we increment
the dl_time. The state lock is held over that function, so we don't need
to worry about these sorts of races there.

There is one other potential bug nfsd_recall_client_delegations though.
Entries on the victims list are not dequeued before calling
nfsd_break_one_deleg. That's a potential list corruptor, so ensure that
we do that there.

Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c400ec17915e..2a7d7176ed30 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1287,6 +1287,7 @@ destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		list_del_init(&dp->dl_perclnt);
+		++dp->dl_time;
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
@@ -2933,10 +2934,14 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * it's safe to take a reference: */
 	atomic_inc(&dp->dl_count);
 
-	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
-
-	/* Only place dl_time is set; protected by i_lock: */
-	dp->dl_time = get_seconds();
+	/*
+	 * If the dl_time != 0, then we know that it has already been
+	 * queued for a lease break. Don't queue it again.
+	 */
+	if (dp->dl_time == 0) {
+		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
+		dp->dl_time = get_seconds();
+	}
 
 	block_delegations(&dp->dl_fh);
 
@@ -5069,15 +5074,18 @@ u64 nfsd_print_client_openowners(struct nfs4_client *clp, u64 max)
 }
 
 static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
-				     struct list_head *victims)
+				     struct list_head *victims, bool revoke)
 {
 	struct nfs4_delegation *dp, *next;
 	u64 count = 0;
 
 	lockdep_assert_held(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
-		if (victims)
+		if (victims) {
+			if (revoke)
+				++dp->dl_time;
 			list_move(&dp->dl_recall_lru, victims);
+		}
 		if (++count == max)
 			break;
 	}
@@ -5091,7 +5099,7 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	u64 count;
 
 	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, &victims);
+	count = nfsd_find_all_delegations(clp, max, &victims, true);
 	spin_unlock(&state_lock);
 
 	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
@@ -5102,14 +5110,18 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 
 u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 {
-	struct nfs4_delegation *dp, *next;
+	struct nfs4_delegation *dp;
 	LIST_HEAD(victims);
 	u64 count;
 
 	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, &victims);
-	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
+	count = nfsd_find_all_delegations(clp, max, &victims, false);
+	while (!list_empty(&victims)) {
+		dp = list_first_entry(&victims, struct nfs4_delegation,
+					dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
 		nfsd_break_one_deleg(dp);
+	}
 	spin_unlock(&state_lock);
 
 	return count;
@@ -5120,7 +5132,7 @@ u64 nfsd_print_client_delegations(struct nfs4_client *clp, u64 max)
 	u64 count = 0;
 
 	spin_lock(&state_lock);
-	count = nfsd_find_all_delegations(clp, max, NULL);
+	count = nfsd_find_all_delegations(clp, max, NULL, false);
 	spin_unlock(&state_lock);
 
 	nfsd_print_count(clp, count, "delegations");
-- 
1.9.3

