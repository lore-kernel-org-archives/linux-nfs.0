Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:46645 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbaGHSEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:37 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so5417290qga.23
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 001/100] nfsd: close potential race between delegation break and laundromat
Date: Tue,  8 Jul 2014 14:02:49 -0400
Message-Id: <1404842668-22521-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
that it's not 0, then we know that it has already been queued to the LRU
list and that we shouldn't queue it again.

In the case of destroy_client, we must also ensure that we don't hit
similar races by ensuring that we don't move any delegations to the
reaplist with a dl_time of 0. Just bump the dl_time by one before we
drop the state_lock. We're destroying the delegations anyway, so a 1s
difference there won't matter.

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
 fs/nfsd/nfs4state.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 763aeeb67ccf..633b34fd6c92 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1287,6 +1287,8 @@ destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		list_del_init(&dp->dl_perclnt);
+		/* Ensure that deleg break won't try to requeue it */
+		++dp->dl_time;
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
@@ -2933,10 +2935,14 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
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
 
@@ -5081,8 +5087,23 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 
 	lockdep_assert_held(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
-		if (victims)
+		if (victims) {
+			/*
+			 * It's not safe to mess with delegations that have a
+			 * non-zero dl_time. They might have already been broken
+			 * and could be processed by the laundromat outside of
+			 * the state_lock. Just leave them be.
+			 */
+			if (dp->dl_time != 0)
+				continue;
+
+			/*
+			 * Increment dl_time to ensure that delegation breaks
+			 * don't monkey with it now that we are.
+			 */
+			++dp->dl_time;
 			list_move(&dp->dl_recall_lru, victims);
+		}
 		if (++count == max)
 			break;
 	}
@@ -5107,14 +5128,19 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 
 u64 nfsd_recall_client_delegations(struct nfs4_client *clp, u64 max)
 {
-	struct nfs4_delegation *dp, *next;
+	struct nfs4_delegation *dp;
 	LIST_HEAD(victims);
 	u64 count;
 
 	spin_lock(&state_lock);
 	count = nfsd_find_all_delegations(clp, max, &victims);
-	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
+	while (!list_empty(&victims)) {
+		dp = list_first_entry(&victims, struct nfs4_delegation,
+					dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
+		dp->dl_time = 0;
 		nfsd_break_one_deleg(dp);
+	}
 	spin_unlock(&state_lock);
 
 	return count;
-- 
1.9.3

